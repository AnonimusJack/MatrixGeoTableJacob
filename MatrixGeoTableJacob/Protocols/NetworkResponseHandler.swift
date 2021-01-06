//
//  NetworkResponseHandler.swift
//  MatrixGeoTableJacob
//
//  Created by hyperactive hi-tech ltd on 06/01/2021.
//  Copyright © 2021 JFTech. All rights reserved.
//

import Foundation

public protocol NetworkResponseHandler
{
    func HandleServerError()
    func HandleNetworkError()
    func HandleDataRecieved(data: [Country])
}
