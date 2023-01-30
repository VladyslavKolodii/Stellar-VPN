//
//  LocationModel.swift
//  SparVPN
//
//  Created by Aira on 9.01.2021.
//

import Foundation
import UIKit
import SwiftyJSON

class LocationModel {
    var id: String = ""
    var name: String = ""
    var host: String = ""
    var port: Int = 0
    var proto: String = ""
    var isSelected: Bool = false
    
    func initWithJSON(data: JSON) {
        id = data["id"].stringValue.uppercased()
        name = data["name"].stringValue
        host = data["host"].stringValue
        port = data["port"].intValue
        proto = data["tcp"].stringValue
        isSelected = false
    }
}
