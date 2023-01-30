//
//  ServerModel.swift
//  Stellar Security
//
//  Created by Aira on 14.01.2021.
//

import Foundation

class ServerModel {
    var imgFlag: String?
    var country: String?
    var cities: [LocationModel]?
    var isSelected: Bool?
    
    init(imgFlag: String, country: String, cities: [LocationModel], isSelected: Bool) {
        self.imgFlag = imgFlag
        self.country = country
        self.cities = cities
        self.isSelected = isSelected
    }
}
