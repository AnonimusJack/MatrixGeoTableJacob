//
//  GeoTableMainDataRepository.swift
//  MatrixGeoTableJacob
//
//  Created by Jacob on 06/01/2021.
//  Copyright © 2021 JFTech. All rights reserved.
//

import Foundation

public class GeoTableMainDataRepository
{
    public static var GeoData: [Country] = []
    private static let fileURI = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("GeoData.json")
    
    
    public static func RequestData(responseHandler: NetworkResponseHandler)
    {
        guard let fileURI = fileURI
            else { return requestDataFromServer(responseHandler: responseHandler) }
        if FileManager.default.fileExists(atPath: fileURI.path)
        {
            DispatchQueue(label: "com.geo_table.fetch_data", qos: .utility).async {
                requestDataFromLocal(responseHandler: responseHandler)
            }
        }
        else
        {
            requestDataFromServer(responseHandler: responseHandler)
        }
    }
    
    private static func processJsonResponse(json: [[String : Any]])
    {
        if json.count != 0
        {
            var rawJson: [String : [String : Any]] = [:]
            for countryJson in json
            {
                rawJson[countryJson["alpha3Code"] as! String] = countryJson
            }
            saveDataFromServerToLocalJSON(jsonData: rawJson)
            processRawJson(rawData: rawJson)
        }
    }
    
    private static func convertBorderingStringArrayToCountriesArray(compiledJson: inout [String : Country], borderingRaw: inout [String],country: Country)
    {
        for borderingCountryAlphaCode: String in borderingRaw
        {
            if let borderingCountry =  compiledJson[borderingCountryAlphaCode]
            {
                country.Bordering.append(borderingCountry)
            }
        }
    }
    
    private static func processRawJson(rawData: [String : [String : Any]])
    {
        var preBorderingCountries = convertRawSavedDataToStringCountryMap(rawJson: rawData)
        GeoData = Array(preBorderingCountries.values)
        //Populate borders from raw data with country objects
        for preBorderedCountryKey in preBorderingCountries.keys
        {
            let geoDataCountryReference = GeoData.first(where: { country in country.Name == preBorderingCountries[preBorderedCountryKey]?.Name })!
            var borders = rawData[preBorderedCountryKey]!["borders"]! as! [String]
            convertBorderingStringArrayToCountriesArray(compiledJson: &preBorderingCountries, borderingRaw: &borders, country: geoDataCountryReference)
        }
    }
    
    private static func convertRawSavedDataToStringCountryMap(rawJson: [String : [String : Any]]) -> [String : Country]
    {
        var countries: [String : Country] = [:]
        for key: String in rawJson.keys
        {
            countries[key] = Country(json: rawJson[key]!)
        }
        return countries
    }
    
    private static func saveDataFromServerToLocalJSON(jsonData: [String : [String : Any]])
    {
        //Validate fileURI has been created
        guard let fileURI = fileURI
            else { return }
        //Create a stream to output the file
        guard let writeStream = OutputStream(toFileAtPath: fileURI.path, append: false)
            else { return }
        writeStream.open()
        defer { writeStream.close() }
        var error: NSError?
        //Create Json and write it to file
        JSONSerialization.writeJSONObject(jsonData, to: writeStream, options: [], error: &error)
        //Error Handling
        if let error = error { print(error) }
    }
    
    private static func requestDataFromLocal(responseHandler: NetworkResponseHandler)
    {
        //Validate fileURI has been created
        guard let fileURI = fileURI
            else { return }
        //Create a stream to read the file
        guard let readStream = InputStream(url: fileURI)
            else { return }
        readStream.open()
        defer { readStream.close() }
        do
        {
            guard let rawSavedData = try JSONSerialization.jsonObject(with: readStream, options: []) as? [String : [String : Any]]
                else { return }
            processRawJson(rawData: rawSavedData)
            responseHandler.HandleDataRecieved(data: GeoData)
        }
        catch
        {
            print(error)
        }
    }
    
    private static func requestDataFromServer(responseHandler: NetworkResponseHandler)
    {
        guard let url = URL(string: "https://restcountries.eu/rest/v2/all?fields=name;alpha3Code;area;borders;nativeName")
            else { return }
        let networkTask = URLSession.shared.dataTask(with: url)
        {
            (data, response, error) in
            guard let dataResponse = data, error == nil
                else
            {
                //Handle local error
                print(error!)
                responseHandler.HandleNetworkError()
                return
            }
            //Handle Server Error
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode)
                else { return responseHandler.HandleServerError() }
            do
            {
                let jsonResponse = try JSONSerialization.jsonObject(with: dataResponse, options: [])
                processJsonResponse(json: jsonResponse as! [[String: Any]])
                responseHandler.HandleDataRecieved(data: GeoData)
            }
            catch let parsingError
            {
                print(parsingError)
            }
        }
        networkTask.resume()
    }
}
