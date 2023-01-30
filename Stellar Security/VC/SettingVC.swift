//
//  SettingVC.swift
//  Stellar Security
//
//  Created by Aira on 14.01.2021.
//

import UIKit
import StoreKit
import MessageUI
import CRNotifications

class SettingVC: UIViewController {
    
    @IBOutlet weak var settingTV: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingTV.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        settingTV.delegate = self
        settingTV.dataSource = self
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    @IBAction func onTapCloseUB(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SettingVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 72.0
        } else {
            return 40.0
        }
    }
}

extension SettingVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return SETTINGS.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if SETTINGS[section].isExpanded! {
            return SETTINGS[section].subContents!.count + 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let headercell = tableView.dequeueReusableCell(withIdentifier: "SettingHeaderCell", for: indexPath) as! SettingHeaderCell
            headercell.initCell(model: SETTINGS[indexPath.section])
            headercell.delegate = self
            return headercell
        } else {
            let itemcell = tableView.dequeueReusableCell(withIdentifier: "SettingItemCell", for: indexPath) as! SettingItemCell
            itemcell.initCell(model: SETTINGS[indexPath.section].subContents![indexPath.row - 1])
            itemcell.delegate = self
            return itemcell
        }
    }
}

extension SettingVC: SettingHeaderDelegate {
    func didSelectHeader(model: SettingModel) {
        if model.isExpandable! {
            settingTV.reloadData()
        } else {
            print("selected setting ====> \(model.content ?? "")")
            if model.content == "Privacy Policy" {
                if let url = URL(string: "http://stellarsecurityvpn.com/privacy.html") {
                    UIApplication.shared.open(url)
                }
            } else if model.content == "Restore purchase" {
                IAPUtil.shared.restorePurchases(withHandler: {(result) in
                    switch result {
                    case .success(_):
                        print("Success ====> restore purchase")
                    case .failure(_):
                        print("Failed =====> restore purcahse")
                    }
                })
            } else if model.content == "Contact support" {
                let mailVC: MFMailComposeViewController = MFMailComposeViewController()
                mailVC.mailComposeDelegate = self
                let toRecipents = ["info@stellarsecurityvpn.com"]
                mailVC.setToRecipients(toRecipents)
                if MFMailComposeViewController.canSendMail() {
                    self.present(mailVC, animated: true, completion: nil)
                }
            } else if model.content == "Terms of service" {
                if let url = URL(string: "http://stellarsecurityvpn.com/terms.html") {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
}

extension SettingVC: SettingItemDelegate {
    func didSelectItem(model: String) {
        print(model)
    }
}

protocol SettingHeaderDelegate {
    func didSelectHeader(model: SettingModel)
}

class SettingHeaderCell: UITableViewCell {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var content: UILabel!
    
    var settingModel: SettingModel!
    var delegate: SettingHeaderDelegate?
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func initCell(model: SettingModel) {
        settingModel = model
        icon.image = UIImage(named: model.icon!)
        content.text = model.content!
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapHeader))
        contentView.addGestureRecognizer(tapGesture)
    }
    
    @objc func onTapHeader() {
        if settingModel.isExpandable! {
            settingModel.isExpanded = !settingModel.isExpanded!
        }
        delegate?.didSelectHeader(model: self.settingModel)
    }
    
}

protocol SettingItemDelegate {
    func didSelectItem(model: String)
}

class SettingItemCell: UITableViewCell {
    
    @IBOutlet weak var subContent: UILabel!
    var selectedItem: String!
    var delegate: SettingItemDelegate?
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func initCell(model: String) {
        selectedItem = model
        subContent.text = model
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapItem))
        contentView.addGestureRecognizer(tapGesture)
    }
    
    @objc func onTapItem() {
        delegate?.didSelectItem(model: selectedItem)
    }
}

extension SettingVC: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
        switch result {
        case .cancelled:
            AppUtils.showNotificaiton(type: CRNotifications.info, title: "Canceled", message: "Canceled Sending Message")
            break
        case .sent:
            AppUtils.showNotificaiton(type: CRNotifications.success, title: "Success", message: "Succed Sending Message")
            break
        case .failed:
            AppUtils.showNotificaiton(type: CRNotifications.error, title: "Failed", message: "Failed Sending Message")
            break
        case .saved:
            AppUtils.showNotificaiton(type: CRNotifications.info, title: "Saved", message: "Saved Message")
            break
        default:
            break
        }
    }
}
