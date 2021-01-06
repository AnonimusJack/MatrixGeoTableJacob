//
//  Country.swift
//  MatrixGeoTableJacob
//
//  Created by Jacob on 05/01/2021.
//  Copyright © 2021 JFTech. All rights reserved.
//

import Foundation

public class Country
{
    let Name: String
    let NativeName: String
    let Area: Double
    var Bordering: [Country]
    
    init(json: [String : Any])
    {
        Name = json["name"] as? String ?? ""
        NativeName = json["nativeName"] as? String ?? ""
        Area = json["area"] as? Double ?? 0
        Bordering = []
    }
}
