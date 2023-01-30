//
//  SharedUtil.swift
//  Stellar Security
//
//  Created by Aira on 15.01.2021.
//

import Foundation

let key: String = "PURCHASED_PRODUCT_ID"
let JWETOEKN:String = "JWETOKEN"
let LICENSE_USERNAME: String = "LICENSE_USERNAME"
let LICENSE_PASSWORD: String = "LICENSE_PASSWORD"
let SELECTED_SERVER_FLAG: String = "SELECTED_SERVER_FLAG"
let SELECTED_SERVER_NAME: String = "SELECTED_SERVER_NAME"
let SELECTED_SERVER_HOST: String = "SELECTED_SERVER_HOST"
let AGREE_CONTINUE: String = "AGREE_CONTINUE"

class SharedUtils {
    var shared: UserDefaults?
    
    init() {
        shared = UserDefaults.standard
    }
    
    func setUserDefaultString(key: String, value: String) {
        shared!.set(value, forKey: key)
    }
    
    func getUserDefaultString(key: String) -> String {
        return shared!.string(forKey: key)!
    }
    
    func removeUserDefaultString(key: String) {
        shared!.removeObject(forKey: key)
    }
    
    func checkSetValue(key: String) -> Bool {
        if shared!.object(forKey: key) == nil {
            return false
        } else {
            return true
        }
    }
}
