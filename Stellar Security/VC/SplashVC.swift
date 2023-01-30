//
//  SplashVC.swift
//  Stellar Security
//
//  Created by Aira on 13.01.2021.
//

import UIKit

class SplashVC: UIViewController {
    
    @IBOutlet weak var bottomUV: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bottomUV.setSideCorener(radius: 25.0, cornerSide: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        
        let param: [String: String] = [
            "uuid": UIDevice.current.identifierForVendor!.uuidString
        ]
        ApiUtils.apiConnection(param: param, url: ApiUtils.INITIAL, method: .post, isReuquiredToken: false, success: {(result) in
            let license_username = result["license_username"].stringValue
            let license_password = result["license_password"].stringValue
            let jwtToken = result["jwtToken"].stringValue
            
            SharedUtils().setUserDefaultString(key: JWETOEKN, value: jwtToken)
            SharedUtils().setUserDefaultString(key: LICENSE_USERNAME, value: license_username)
            SharedUtils().setUserDefaultString(key: LICENSE_PASSWORD, value: license_password)
            KeychainService().save(key: "VPN_PASSWORD", value: SharedUtils().getUserDefaultString(key: LICENSE_PASSWORD))
            self.performSegue(withIdentifier: "goMainVC", sender: nil)
        })
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
