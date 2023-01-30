//
//  MainVC.swift
//  Stellar Security
//
//  Created by Aira on 13.01.2021.
//

import UIKit
import FlagKit

class MainVC: UIViewController {
    
    @IBOutlet weak var leftCornerUV: UIView!
    @IBOutlet weak var rightCorenerUV: UIView!
    @IBOutlet weak var semiCircleUV: SemiCircle!
    @IBOutlet weak var ringCircleUV: RingCircle!
    @IBOutlet weak var connectionTimeLB: UILabel!
    @IBOutlet weak var locationUV: UIView!
    @IBOutlet weak var selectedServerUIMG: UIImageView!
    @IBOutlet weak var selectedServerLB: UILabel!
    
    var isConnected = false
    var timer: Timer?
    var seconds = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUIView()
        initLocationData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didSelectServer), name: .didSelectServer, object: nil)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    func initUIView() {
        leftCornerUV.setSideCorener(radius: leftCornerUV.frame.width * 3 / 4, cornerSide: [.layerMinXMaxYCorner])
        rightCorenerUV.setSideCorener(radius: rightCorenerUV.frame.width * 3 / 4, cornerSide: [.layerMaxXMaxYCorner])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapConnectUV))
        ringCircleUV.addGestureRecognizer(tapGesture)
        
        let tapLocation = UITapGestureRecognizer(target: self, action: #selector(onTapLocationUV))
        locationUV.addGestureRecognizer(tapLocation)
        
        if SharedUtils().checkSetValue(key: SELECTED_SERVER_HOST) {
            initSelectedServer()
        }
    }
    
    func initSelectedServer() {
        let flag = Flag(countryCode: SharedUtils().getUserDefaultString(key: SELECTED_SERVER_FLAG))
        selectedServerUIMG.image = flag?.originalImage
        selectedServerLB.text = SharedUtils().getUserDefaultString(key: SELECTED_SERVER_NAME)
    }
    
    func initLocationData() {
        ApiUtils.apiConnection(param: [:], url: ApiUtils.LOCATION, method: .get, isReuquiredToken: true, success: {(result) in
            let jsonArr = result.arrayValue
            AppUtils.gLocations.removeAll()
            for i in 0..<jsonArr.count {
                let location: LocationModel = LocationModel()
                location.initWithJSON(data: jsonArr[i])
                AppUtils.gLocations.append(location)
            }
            AppUtils.gGroupLocationById = Dictionary(grouping: AppUtils.gLocations) {$0.id}
            let dictKeys = Array(AppUtils.gGroupLocationById.keys)
            let sortDictKeys = Array(dictKeys).sorted()
            AppUtils.gServers.removeAll()
            for key in sortDictKeys {
                var country: String = ""
                if AppUtils.gGroupLocationById[key]!.count > 1 {
                    country = (AppUtils.gGroupLocationById[key]?.first?.name)!.components(separatedBy: " - ")[0]
                } else {
                    country = (AppUtils.gGroupLocationById[key]?.first?.name)!
                }
                let server: ServerModel = ServerModel(imgFlag: key, country: country, cities: AppUtils.gGroupLocationById[key]!, isSelected: false)
                AppUtils.gServers.append(server)
            }
        })
    }
    
    @objc func didSelectServer() {
        if AppUtils.gSelectedHost == SharedUtils().getUserDefaultString(key: SELECTED_SERVER_HOST) {
            return
        }
        isConnected = false
        timer?.invalidate()
        VPNManager().stopVPN()
        initSelectedServer()
        onTapConnectUV()
    }
    
    @objc func onTapConnectUV() {
        if AppUtils.gIsSubscripted {
            if SharedUtils().checkSetValue(key: SELECTED_SERVER_HOST) {
                if !isConnected {
                    VPNManager().startVPN(host: SharedUtils().getUserDefaultString(key: SELECTED_SERVER_HOST), userName: SharedUtils().getUserDefaultString(key: LICENSE_USERNAME), completion: {(err) in
                        if err == nil {
                            self.isConnected = true
                            self.seconds = 0
                            var bgTask = UIBackgroundTaskIdentifier(rawValue: 0)
                            bgTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
                                UIApplication.shared.endBackgroundTask(bgTask)
                            })
                            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.handleTimer), userInfo: nil, repeats: true)
                            RunLoop.current.add(self.timer!, forMode: .default)
                            self.ringCircleUV.initCircleRing(fillColor: UIColor(named: "mainGreen")!)
                            AppUtils.gSelectedHost = SharedUtils().getUserDefaultString(key: SELECTED_SERVER_HOST)
                        } else {
                            self.isConnected = false
                            self.connectionTimeLB.text = "Tap to connect"
                            self.timer?.invalidate()
                            VPNManager().stopVPN()
                            self.ringCircleUV.initCircleRing(fillColor: UIColor(named: "mainBlue")!)
                        }
                    })
                } else {
                    VPNManager().stopVPN()
                    self.isConnected = false
                    connectionTimeLB.text = "Tap to connect"
                    timer?.invalidate()
                    self.ringCircleUV.initCircleRing(fillColor: UIColor(named: "mainBlue")!)
                }
            } else {
                onTapLocationUV()
            }
        } else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PremiumVC") as! PremiumVC
            self.present(vc, animated: true, completion: nil)
        }
    }
    @IBAction func onTapPremiumUB(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PremiumVC") as! PremiumVC
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func handleTimer() {
        seconds += 1
        if seconds < 60 {
            let strSeconds = String(format: "%02d", seconds)
            connectionTimeLB.text = "Conected - 00:" + strSeconds
        } else if seconds >= 60 && seconds < 3600 {
            let min: Int = seconds / 60
            let second: Int = seconds % 60
            let strMin = String(format: "%02d", min)
            let strSec = String(format: "%02d", second)
            connectionTimeLB.text = "Conected - " + strMin + ":" + strSec
        } else {
            let hur: Int = seconds / 3660
            let min: Int = (seconds % 3600) / 60
            let sec: Int = seconds % 60
            let strHur = String(format: "%02d", hur)
            let strMin = String(format: "%02d", min)
            let strSec = String(format: "%02d", sec)
            connectionTimeLB.text = "Conected - " + strHur + ":" + strMin + ":" + strSec
        }
    }
    
    @objc func onTapLocationUV() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchVC") as! SearchVC
        self.present(vc, animated: true, completion: nil)
    }
    
}
