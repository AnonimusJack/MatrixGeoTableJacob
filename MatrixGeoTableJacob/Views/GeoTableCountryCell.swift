//
//  GeoTableCountryCell.swift
//  MatrixGeoTableJacob
//
//  Created by hyperactive hi-tech ltd on 05/01/2021.
//  Copyright © 2021 JFTech. All rights reserved.
//

import UIKit

class GeoTableCountryCell: UITableViewCell
{
    @IBOutlet weak var CountryNameLable: UILabel!
    
    @IBOutlet weak var CountryNativeNameLable: UILabel!
    public var AssociatedCountry: Country?
}
