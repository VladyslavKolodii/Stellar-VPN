//
//  VPNManager.swift
//  SparVPN
//
//  Created by Aira on 22.01.2021.
//

import Foundation
import NetworkExtension

class VPNManager {
    
    static var shared = VPNManager()
    
    
    
    func startVPN(host: String, userName: String, completion: @escaping (Error?) -> Void) {
        NEVPNManager.shared().loadFromPreferences(completionHandler: {(err)in
            guard err == nil else {
                print(err?.localizedDescription)
                return
            }
            
            /*SharedUtils().setUserDefaultString(key: LICENSE_USERNAME, value: "0511-05334b868750697bc7a378c80db976ce30af9ef4")
            SharedUtils().setUserDefaultString(key: LICENSE_PASSWORD, value: "a3abfa22f8ab37ebcea209a7e3f85113ec4c9043")
            let userName = "0511-05334b868750697bc7a378c80db976ce30af9ef4"*/
            
            let p = NEVPNProtocolIKEv2()
            p.username = userName
            p.serverAddress = host
            p.useExtendedAuthentication = false
            p.localIdentifier = userName
            p.disconnectOnSleep = false
            p.authenticationMethod = .none
            p.useExtendedAuthentication = true
            let kcs = KeychainService()
            p.passwordReference = kcs.load(key: "VPN_PASSWORD")
            p.serverCertificateCommonName = "phantom.avira-vpn.com"
            print("======>\(userName)")
            print("======>\(p.passwordReference)")
            NEVPNManager.shared().protocolConfiguration = p
            NEVPNManager.shared().localizedDescription = "SparVPN"
            NEVPNManager.shared().isEnabled = true
            NEVPNManager.shared().saveToPreferences(completionHandler: {(err) in
                guard err == nil else {
                    completion(err!)
                    return
                }
                NEVPNManager.shared().loadFromPreferences { (err) in
                    guard err == nil else {
                        completion(err!)
                        return
                    }
                    NEVPNManager.shared().isEnabled = true
                    NEVPNManager.shared().saveToPreferences(completionHandler: { (err) in
                        guard err == nil else {
                            completion(err!)
                            return
                        }
                        do {
                            try NEVPNManager.shared().connection.startVPNTunnel()
                            DispatchQueue.main.async {
                                completion(nil)
                            }
                        }
                        catch
                        {
                            DispatchQueue.main.async {
                                completion(error)
                            }
                        }
                    })
                }
            })
        })
    }
    
    func checkStatus() -> Int {

      let status =  NEVPNManager.shared().connection.status
          print("VPN connection status = \(status.rawValue)")

          switch status {
          case NEVPNStatus.connected:
              return 1
          case NEVPNStatus.invalid :
               return -1
          case NEVPNStatus.disconnected :
              return 0
          case NEVPNStatus.connecting , NEVPNStatus.reasserting:
              return 1
          case NEVPNStatus.disconnecting:
              return 0
          default:
              return 0
          }
      }
    
    func stopVPN() {
        NEVPNManager.shared().connection.stopVPNTunnel()
    }
}
