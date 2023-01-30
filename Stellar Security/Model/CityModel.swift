//
//  CityModel.swift
//  Stellar Security
//
//  Created by Aira on 14.01.2021.
//

import Foundation

class CityModel{
    var cityName: String?
    var isSelected: Bool?
    
    init(cityName: String, isSelected: Bool) {
        self.cityName = cityName
        self.isSelected = isSelected
    }
}
