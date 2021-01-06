//
//  GeoTableMainViewController.swift
//  MatrixGeoTableJacob
//
//  Created by hyperactive hi-tech ltd on 05/01/2021.
//  Copyright © 2021 JFTech. All rights reserved.
//

import UIKit

class GeoTableMainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NetworkResponseHandler
{
    @IBOutlet weak var MainTable: UITableView!
    @IBOutlet weak var SortByNameButton: UIButton!
    @IBOutlet weak var SortByNativeNameButton: UIButton!
    @IBOutlet weak var SortByAreaButton: UIButton!
    private var shownCountries: [Country] = []
    {
        didSet
        {
            DispatchQueue.main.async {
                self.MainTable.reloadData()
                print(self.MainTable.numberOfRows(inSection: 0))
            }
        }
    }
    private var cellSelected = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        MainTable.delegate = self
        MainTable.dataSource = self
        MainTable.register(UINib(nibName: "GeoTableSelectedCountryHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "GeoTableSelectedCountryHeader")
        GeoTableMainDataRepository.RequestData(responseHandler: self)
    }
    
    func HandleServerError()
    {
        let serverErrorAlert = UIAlertController(title: "Server Error!", message: "The server responded with an error, would you like to try again?", preferredStyle: .alert)
        serverErrorAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {action in GeoTableMainDataRepository.RequestData(responseHandler: self)}))
        serverErrorAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(serverErrorAlert, animated: true, completion: nil)
    }
    
    func HandleNetworkError()
    {
        let networkErrorAlert = UIAlertController(title: "Network Error!", message: "There appears to be a local error, would you like to check wifi settings?", preferredStyle: .alert)
        networkErrorAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {action in
            guard let settingsURL = URL(string: "App-prefs:WIFI")
                else { return }
            if UIApplication.shared.canOpenURL(settingsURL)
            {
                UIApplication.shared.open(settingsURL, completionHandler: nil)
            }
        }))
        networkErrorAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(networkErrorAlert, animated: true, completion: nil)
    }
    
    func HandleDataRecieved(data: [Country])
    {
        shownCountries = data
    }
    
    @IBAction func OnSortByButtonTouch(_ sender: UIButton)
    {
        switch sender.titleLabel!.text!
        {
            case "Name":
                if sender.currentTitleColor == UIColor.red
                {
                    shownCountries = shownCountries.sorted(by: { $0.Name < $1.Name})
                    sender.setTitleColor(UIColor.green, for: .normal)
                }
                else
                {
                    shownCountries = shownCountries.sorted(by: { $0.Name > $1.Name})
                    sender.setTitleColor(UIColor.red, for: .normal)
                }
            break
            case "Native Name":
                if sender.currentTitleColor == UIColor.red
                {
                    shownCountries = shownCountries.sorted(by: { $0.NativeName < $1.NativeName})
                    sender.setTitleColor(UIColor.green, for: .normal)
                }
                else
                {
                    shownCountries = shownCountries.sorted(by: { $0.NativeName > $1.NativeName})
                    sender.setTitleColor(UIColor.red, for: .normal)
                }
            break
            case "Area":
                if sender.currentTitleColor == UIColor.red
                {
                    shownCountries = shownCountries.sorted(by: { $0.Area < $1.Area})
                    sender.setTitleColor(UIColor.green, for: .normal)
                }
                else
                {
                    shownCountries = shownCountries.sorted(by: { $0.Area > $1.Area})
                    sender.setTitleColor(UIColor.red, for: .normal)
                }
            break
            default:
            break
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return shownCountries.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if self.cellSelected
        {
            let selectedCountryHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "GeoTableSelectedCountryHeader") as? GeoTableSelectedCountryHeader
            selectedCountryHeader?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onBackCellTouch(recognizer:))))
            return selectedCountryHeader
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let country = shownCountries[indexPath.row]
        let countryCell = tableView.dequeueReusableCell(withIdentifier: "GeoTableCountryCell", for: indexPath) as! GeoTableCountryCell
        countryCell.CountryNameLable.text = country.Name
        countryCell.CountryNativeNameLable.text = country.NativeName
        countryCell.AssociatedCountry = country
        countryCell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onCellTouch(recognizer:))))
        return countryCell
    }
    
    @objc private func onCellTouch(recognizer: UITapGestureRecognizer)
    {
        let cell = recognizer.view as! GeoTableCountryCell
        cellSelected = true
        shownCountries = cell.AssociatedCountry!.Bordering
    }
    
    @objc private func onBackCellTouch(recognizer: UITapGestureRecognizer)
    {
        cellSelected = false
        shownCountries = GeoTableMainDataRepository.GeoData
    }
}
