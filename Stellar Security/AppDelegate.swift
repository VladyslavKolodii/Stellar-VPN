//
//  AppDelegate.swift
//  Stellar Security
//
//  Created by Aira on 13.01.2021.
//

import UIKit
import IQKeyboardManager

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Thread.sleep(forTimeInterval: 1.0)
        IQKeyboardManager.shared().isEnabled = true
        IAPUtil.shared.startObserving()
        checkingSubscriptionState()
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        IAPUtil.shared.stopObserving()
    }
    
    func checkingSubscriptionState() {
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL, FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                let receiptString = receiptData.base64EncodedString(options: [])
                let params = [
                    "receipt-data": receiptString,
                    "password": "43d36ac7d3f548399b01f8f86c459b09"
                ]
                let appleServer = appStoreReceiptURL.lastPathComponent == "sandboxReceipt" ? "sandbox": "buy"
                let strURL = "https://\(appleServer).itunes.apple.com/verifyReceipt"
                ApiUtils.apiConnection(param: params, url: strURL, method: .post, isReuquiredToken: false) { (result) in
                    print(result)
                    guard let latest_receipt_info_arr = result["latest_receipt_info"].array else {
                        return
                    }
                    if latest_receipt_info_arr.count != 0 {
                        print("expire date ====>\(latest_receipt_info_arr.first!["expires_date_ms"])")
                        let expiresDateValue = latest_receipt_info_arr.first!["expires_date_ms"].intValue / 1000
                        let expireDate = Date(timeIntervalSince1970: TimeInterval(expiresDateValue))
                        print(Date(timeIntervalSince1970: TimeInterval(expiresDateValue)))
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
                        formatter.timeZone = TimeZone(secondsFromGMT: 0)
                        let curDate = formatter.string(from: Date())
                        
                        if formatter.date(from: curDate)! > expireDate {
                            AppUtils.gIsSubscripted = false
                            print("expired")
                        } else {
                            AppUtils.gIsSubscripted = true
                            print("not expired")
                        }
                    }
                }
            } catch {
                
            }
        }
    }
}
