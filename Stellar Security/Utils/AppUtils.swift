//
//  AppUtils.swift
//  Stellar Security
//
//  Created by Aira on 15.01.2021.
//

import Foundation
import SVProgressHUD
import CRNotifications

class AppUtils {
    
    static var gLocations: [LocationModel] = [LocationModel]()
    static var gGroupLocationById: Dictionary = [String: [LocationModel]]()
    static var gServers: [ServerModel] = [ServerModel]()
    static var gSelectedHost: String = ""
    
    static var gIsSubscripted: Bool = false
    
    static func onShowProgressView (name: String) {
        SVProgressHUD.show(withStatus: name)
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.custom)
        SVProgressHUD.setForegroundColor (UIColor.blue)
        SVProgressHUD.setBackgroundColor (UIColor.black.withAlphaComponent(0.0))
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
        SVProgressHUD.setRingNoTextRadius(20)
        SVProgressHUD.setRingThickness(3)
        SVProgressHUD.setDefaultAnimationType(SVProgressHUDAnimationType.flat)
    }
    
    static func onhideProgressView() {
        SVProgressHUD.dismiss()
    }
    
    static func showNotificaiton(type: CRNotificationType, title: String, message: String) {
        CRNotifications.showNotification(type: type, title: title, message: message, dismissDelay: 2.0)
    }
    
    static func showNotificaitonWithCallBack(type: CRNotificationType, title: String, message: String, callback: @escaping (() -> Void)) {
        CRNotifications.showNotification(type: type, title: title, message: message, dismissDelay: 2.0) {
            callback()
        }
    }
}
