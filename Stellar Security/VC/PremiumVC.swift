//
//  PremiumVC.swift
//  Stellar Security
//
//  Created by Aira on 14.01.2021.
//

import UIKit
import StoreKit
import CRNotifications

class PremiumVC: UIViewController {

    @IBOutlet weak var topUV: UIView!
    @IBOutlet weak var premiumTV: UITableView!
    @IBOutlet weak var restoreUV: UIView!
    @IBOutlet weak var descLB: UILabel!
    
    var premiums: [PremiumModel] = [PremiumModel]()
    var skProducts: [SKProduct] = [SKProduct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topUV.setSideCorener(radius: 25.0, cornerSide: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner])

        premiumTV.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        premiumTV.delegate = self
        premiumTV.dataSource = self
        
        let restoreGesture = UITapGestureRecognizer(target: self, action: #selector(onTapRestoreUB))
        restoreUV.addGestureRecognizer(restoreGesture)
        
        descLB.isUserInteractionEnabled = true
        let tapDesc = UITapGestureRecognizer(target: self, action: #selector(onTapDescTV))
        descLB.addGestureRecognizer(tapDesc)
        
        initIAP()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func onTapDescTV(_ gesture: UITapGestureRecognizer) {
        guard let text = descLB.text else {return}
        let privacyPolicy = (text as NSString).range(of: "Account")
        let terms = (text as NSString).range(of: "Terms")
        if gesture.didTapAttributedTextInLabel(label: descLB, inRange: privacyPolicy) {
            if let url = URL(string: "http://stellarsecurityvpn.com/privacy.html") {
                UIApplication.shared.open(url)
            }
        } else if gesture.didTapAttributedTextInLabel(label: descLB, inRange: terms) {
            if let url = URL(string: "http://stellarsecurityvpn.com/terms.html") {
                UIApplication.shared.open(url)
            }
        }
    }
    
    @objc func onTapRestoreUB() {
        AppUtils.onShowProgressView(name: "Loading...")
        IAPUtil.shared.restorePurchases(withHandler: {(result) in
            AppUtils.onhideProgressView()
            switch result {
            case .success(let val):
                if val {
                    AppUtils.gIsSubscripted = true
                    AppUtils.showNotificaitonWithCallBack(type: CRNotifications.success, title: "Success", message: "Success Restore!") {
                        self.dismiss(animated: true, completion: nil)
                    }
                } else {
                    AppUtils.showNotificaitonWithCallBack(type: CRNotifications.info, title: "Info", message: "There is no item to restore.") {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            case .failure(let error):
                AppUtils.showNotificaitonWithCallBack(type: CRNotifications.error, title: "Erorr!", message: error.localizedDescription) {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        })
    }
    
    func initIAP() {
        AppUtils.onShowProgressView(name: "Loading")
        IAPUtil.shared.getProducts(withHandler: { [self](result) in
            AppUtils.onhideProgressView()
            switch result {
                case .success(let products):
                    self.skProducts = products
                    for product in products {
                        let premium: PremiumModel = PremiumModel()
                        premium.initWidthSKProduct(product: product)
                        self.premiums.append(premium)
                    }
                    DispatchQueue.main.async {
                        premiumTV.reloadData()
                    }
                    
                case .failure(let error):
                    AppUtils.showNotificaiton(type: CRNotifications.error, title: "Erorr!", message: error.errorDescription!)
                }
        })
    }
    
    @IBAction func onTapContinueUB(_ sender: Any) {
        for model in premiums {
            if model.isSelected {
                handleIAP(productID: model.productID)
            }
        }
    }
    
    func handleIAP(productID: String) {
        for product in skProducts {
            if product.productIdentifier == productID {
                IAPUtil.shared.buy(product: product) {(result) in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let val):
                            if val {
                                print("=======>success")
                                AppUtils.gIsSubscripted = true
                                UserDefaults.standard.setValue(productID, forKey: "SUBSCRIBED_ID")
                                if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL, FileManager.default.fileExists(atPath: appStoreReceiptURL.path){
                                    do {
                                        let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                                        print(receiptData)
                                        let receiptString = receiptData.base64EncodedString(options: [])
                                        self.dismiss(animated: true, completion: nil)
                                    } catch {
                                        
                                    }
                                    
                                }
                            } else {
                                AppUtils.showNotificaitonWithCallBack(type: CRNotifications.error, title: "Info", message: "Already purchased.") {
                                    self.dismiss(animated: true, completion: nil)
                                }
                            }
                        case .failure(_):
                            print("=======>failed")
                            AppUtils.showNotificaitonWithCallBack(type: CRNotifications.error, title: "Error", message: "Something went wrong.") {
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func onTapCloseUB(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension PremiumVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88.0
    }
}

extension PremiumVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return premiums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PremiumCell", for: indexPath) as! PremiumCell
        cell.initCell(model: premiums[indexPath.row], index: indexPath.row)
        cell.delegate = self
        return cell
    }
}

extension PremiumVC: PremiumCellDelegate {
    func didTapCell(model: PremiumModel, index: Int) {
        for selectedIndex in 0..<premiums.count {
            if selectedIndex != index {
                premiums[selectedIndex].isSelected = false
            }
        }
        premiumTV.reloadData()
    }
}

protocol PremiumCellDelegate {
    func didTapCell(model: PremiumModel, index: Int)
}

class PremiumCell: UITableViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var contentLB: UILabel!
    @IBOutlet weak var containUV: UIView!
    
    var selectedModel: PremiumModel!
    var selectedIndex: Int!
    var delegate: PremiumCellDelegate?
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func initCell(model: PremiumModel, index: Int) {
        selectedModel = model
        selectedIndex = index
        if model.isSelected {
            icon.image = UIImage(systemName: "checkmark.circle.fill")
            icon.tintColor = UIColor(named: "mainBlue")
            contentLB.textColor = UIColor(named: "mainBlue")
            containUV.backgroundColor = UIColor(named: "mainWhite")
        } else {
            icon.image = UIImage(systemName: "circle")
            icon.tintColor = UIColor(named: "mainGrey")
            contentLB.textColor = UIColor(named: "mainColorBlack")
            containUV.backgroundColor = UIColor(named: "mainWhite")?.withAlphaComponent(0.5)
        }
        
        contentLB.text = model.content
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onTapCell))
        containUV.addGestureRecognizer(gesture)
    }
    
    @objc func onTapCell() {
        selectedModel.isSelected = true
        delegate?.didTapCell(model: selectedModel, index: selectedIndex)
    }
}
