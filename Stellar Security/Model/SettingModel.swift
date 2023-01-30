//
//  SettingModel.swift
//  Stellar Security
//
//  Created by Aira on 14.01.2021.
//

import Foundation
import UIKit

class SettingModel {
    var icon: String?
    var content: String?
    var subContents: [String]?
    var isExpandable: Bool?
    var isExpanded: Bool?
    
    init(icon: String, content: String, subContents: [String], isExpanded: Bool) {
        self.icon = icon
        self.content = content
        self.subContents = subContents
        self.isExpandable = subContents.count > 0 ? true : false
        self.isExpanded = isExpanded
    }
}
