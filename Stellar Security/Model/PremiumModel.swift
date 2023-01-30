//
//  PremiumModel.swift
//  Stellar Security
//
//  Created by Aira on 14.01.2021.
//

import Foundation
import StoreKit

class PremiumModel {
    var content: String = ""
    var isSelected: Bool = false
    var productID: String = ""
    
    func initWidthSKProduct(product: SKProduct) {
        let price = IAPUtil.shared.getPriceFormatted(for: product)
        productID = product.productIdentifier
        switch product.subscriptionPeriod?.unit.rawValue {
        case 3:
            content = "Start 3 Days Free Trial \n Then \(price!)/\(product.subscriptionPeriod!.numberOfUnits)year"
            isSelected = true
            print(price! + "/" + "")
            break
        case 2:
            if product.subscriptionPeriod!.numberOfUnits > 1 {
                content = "Start 3 Days Free Trial \n Then \(price!)/\(product.subscriptionPeriod!.numberOfUnits)months"
            } else {
                content = "Monthly: \(price!)"
            }
            isSelected = false
            break
        default:
            print("=====>")
        }
        
        if product.productIdentifier == UserDefaults.standard.string(forKey: "SUBSCIRBED_ID") {
            isSelected = true
        }
    }
}
