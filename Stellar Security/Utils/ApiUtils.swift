//
//  ApiUtils.swift
//  PaySlip
//
//  Created by Aira on 8/8/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ApiUtils {
    
    static var BASE_URL: String = "https://sparvpnuimobileapiprod.azurewebsites.net/api/v1/"
    
    static var INITIAL: String = BASE_URL + "subscription/initial"
    static var LOCATION: String = BASE_URL + "vpn/regions"
    static var LICENSE: String = BASE_URL + "license/credentials"
    
    static func apiConnection(param: [String: String], url: String, method: HTTPMethod, isReuquiredToken: Bool,  success: @escaping ((JSON) -> Void)) {
        
        guard let url = URL(string: url) else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        if isReuquiredToken {
            request.setValue("Bearer \(SharedUtils().getUserDefaultString(key: JWETOEKN) )", forHTTPHeaderField: "Authorization")
        }
        do {
            if method == .post {
                request.httpBody = try JSONSerialization.data(withJSONObject: param)
            }            
        } catch let error{
            print(error.localizedDescription)
        }
        
        Alamofire.request(request).responseJSON{(response) in
            if response.error != nil {
                print(response.error.debugDescription)
                AppUtils.onhideProgressView()
                return
            }
            if let data = response.result.value {
                let json = JSON.init(data)
                success(json)
            }
        }
    }
}
