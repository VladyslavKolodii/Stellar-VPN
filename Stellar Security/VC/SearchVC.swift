//
//  SearchVC.swift
//  Stellar Security
//
//  Created by Aira on 14.01.2021.
//

import UIKit
import FlagKit

class SearchVC: UIViewController {
    
    @IBOutlet weak var leadingUB: UIButton!
    @IBOutlet weak var titleLB: UILabel!
    @IBOutlet weak var serverLB: UILabel!
    @IBOutlet weak var servrTV: UITableView!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var serachUV: UIView!
    
    var countryList = [ServerModel]()
    var cityList = [LocationModel]()
    var isShowingCities = false
    var selectedServer: ServerModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUIView()
        initData(key: "")
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
        let tapBG = UITapGestureRecognizer(target: self, action: #selector(onTapBackUV))
        self.view.addGestureRecognizer(tapBG)
        serachUV.layer.borderColor = UIColor.clear.cgColor
        servrTV.setSideCorener(radius: 25.0, cornerSide: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        servrTV.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        servrTV.delegate = self
        servrTV.dataSource = self
        handleView(isShowingCities: isShowingCities)
    }
    
    func handleView(isShowingCities: Bool) {
        searchTF.text = ""
        if isShowingCities {
            cityList = selectedServer.cities!
            leadingUB.setImage(UIImage(systemName: "chevron.left"), for: .normal)
            titleLB.text = selectedServer.country
            searchTF.placeholder = "Search city"
            serverLB.text = "Choose city"
        } else {
            countryList = AppUtils.gServers
            leadingUB.setImage(UIImage(systemName: "chevron.down"), for: .normal)
            titleLB.text = "Select Location"
            searchTF.placeholder = "Search country"
            serverLB.text = "All Servers"
        }
    }
    
    @IBAction func onTapLeadingUB(_ sender: Any) {
        if isShowingCities {
            isShowingCities = false
            handleView(isShowingCities: isShowingCities)
            servrTV.reloadData()
        } else {
            print("selected server ======> \(selectedServer)")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func onTapBackUV() {
        serachUV.layer.borderColor = UIColor(named: "mainWhite")?.cgColor
        self.view.endEditing(true)
    }
    
    @IBAction func startEditing(_ sender: Any) {
        serachUV.layer.borderColor = UIColor(named: "mainColorBlack")?.cgColor
    }
    
    func initData(key: String) {
        if key.isEmpty {
            countryList = AppUtils.gServers
            guard let selectedServer = selectedServer else {
                return
            }
            cityList = selectedServer.cities!
        } else {
            if isShowingCities {
                cityList.removeAll()
                for model in selectedServer.cities! {
                    if model.name.components(separatedBy: " - ")[1].lowercased().contains(key.lowercased()) {
                        cityList.append(model)
                    }
                }
            } else {
                countryList.removeAll()
                for model in AppUtils.gServers {
                    if model.country!.lowercased().contains(key.lowercased()) {
                        countryList.append(model)
                    }
                }
            }
        }
        servrTV.reloadData()
    }
    
    @IBAction func typingSearchKey(_ sender: UITextField) {
        initData(key: sender.text!)
    }
}

extension SearchVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72.0
    }
}

extension SearchVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isShowingCities ? cityList.count : countryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !isShowingCities {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell", for: indexPath) as! CountryCell
            cell.initCell(model: countryList[indexPath.row], index: indexPath.row)
            cell.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath) as! CityCell
            cell.initCell(cityModel: cityList[indexPath.row], serverModel: selectedServer, index: indexPath.row)
            cell.delegate = self
            return cell
        }
    }
    
}

extension SearchVC: CountryCellDelegate {
    func didTapCountryCell(model: ServerModel, index: Int) {
        selectedServer = model
        print("selected Server Model =======> \(model.country ?? "")")
        self.view.endEditing(true)
        for indexNum in 0..<countryList.count {
            if indexNum != index {
                countryList[indexNum].isSelected = false
                for model in countryList[indexNum].cities! {
                    model.isSelected = false
                }
            } else {
                countryList[indexNum].isSelected = true
            }
        }
        serachUV.layer.borderColor = UIColor(named: "mainWhite")?.cgColor
        if model.cities!.count > 1 {
            isShowingCities = true
            handleView(isShowingCities: isShowingCities)
        } else {
            if SharedUtils().checkSetValue(key: AGREE_CONTINUE) {
                if AppUtils.gIsSubscripted {
                    model.cities![0].isSelected = true
                    if SharedUtils().checkSetValue(key: SELECTED_SERVER_HOST) {
                        if SharedUtils().getUserDefaultString(key: SELECTED_SERVER_HOST) == model.cities![0].host {
                            self.dismiss(animated: true, completion: nil)
                        } else {
                            SharedUtils().setUserDefaultString(key: SELECTED_SERVER_FLAG, value: model.cities![0].id)
                            SharedUtils().setUserDefaultString(key: SELECTED_SERVER_NAME, value: model.cities![0].name)
                            SharedUtils().setUserDefaultString(key: SELECTED_SERVER_HOST, value: model.cities![0].host)
                            self.dismiss(animated: true, completion: {
                                NotificationCenter.default.post(name: .didSelectServer, object: nil)
                            })
                        }
                    } else {
                        SharedUtils().setUserDefaultString(key: SELECTED_SERVER_FLAG, value: model.cities![0].id)
                        SharedUtils().setUserDefaultString(key: SELECTED_SERVER_NAME, value: model.cities![0].name)
                        SharedUtils().setUserDefaultString(key: SELECTED_SERVER_HOST, value: model.cities![0].host)
                        self.dismiss(animated: true, completion: {
                            NotificationCenter.default.post(name: .didSelectServer, object: nil)
                        })
                    }
                    
                } else {
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PremiumVC") as! PremiumVC
                    self.present(vc, animated: true, completion: nil)
                }
            } else {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AgreeVC") as! AgreeVC
                self.present(vc, animated: true, completion: nil)
            }
        }
        servrTV.reloadData()
    }
}

extension SearchVC: CityCellDelegate {
    func didTapCityCell(model: LocationModel, index: Int) {
        self.view.endEditing(true)
        if SharedUtils().checkSetValue(key: AGREE_CONTINUE) {
            if AppUtils.gIsSubscripted {
                for selectedIndex in 0..<cityList.count {
                    if selectedIndex != index {
                        cityList[selectedIndex].isSelected = false
                    } else {
                        cityList[selectedIndex].isSelected = true
                        if SharedUtils().checkSetValue(key: SELECTED_SERVER_HOST) {
                            if SharedUtils().getUserDefaultString(key: SELECTED_SERVER_HOST) == cityList[selectedIndex].host {
                                self.dismiss(animated: true, completion: nil)
                            } else {
                                SharedUtils().setUserDefaultString(key: SELECTED_SERVER_FLAG, value: model.id)
                                SharedUtils().setUserDefaultString(key: SELECTED_SERVER_NAME, value: model.name)
                                SharedUtils().setUserDefaultString(key: SELECTED_SERVER_HOST, value: model.host)
                                self.dismiss(animated: true, completion: {
                                    NotificationCenter.default.post(name: .didSelectServer, object: nil)
                                })
                            }
                        } else {
                            SharedUtils().setUserDefaultString(key: SELECTED_SERVER_FLAG, value: model.id)
                            SharedUtils().setUserDefaultString(key: SELECTED_SERVER_NAME, value: model.name)
                            SharedUtils().setUserDefaultString(key: SELECTED_SERVER_HOST, value: model.host)
                            self.dismiss(animated: true, completion: {
                                NotificationCenter.default.post(name: .didSelectServer, object: nil)
                            })
                        }
                    }
                }
                servrTV.reloadData()
            } else {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PremiumVC") as! PremiumVC
                self.present(vc, animated: true, completion: nil)
            }
        } else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AgreeVC") as! AgreeVC
            self.present(vc, animated: true, completion: nil)
        }
    }
}

protocol CountryCellDelegate {
    func didTapCountryCell(model: ServerModel, index: Int)
}

class CountryCell: UITableViewCell {
    
    @IBOutlet weak var flagUIMG: UIImageView!
    @IBOutlet weak var countryLB: UILabel!
    @IBOutlet weak var locationLB: UILabel!
    @IBOutlet weak var arrowUIMG: UIImageView!
    @IBOutlet weak var selectedUV: UIView!
    
    var serverModel: ServerModel!
    var serverModelIndex: Int!
    var delegate: CountryCellDelegate?
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func initCell(model: ServerModel, index: Int) {
        serverModel = model
        serverModelIndex = index
        if model.isSelected! {
            selectedUV.isHidden = false
            selectedUV.backgroundColor = UIColor(named: "mainBlue")?.withAlphaComponent(0.4)
        } else {
            selectedUV.isHidden = true
        }
        let flag = Flag(countryCode: model.imgFlag!)
        flagUIMG.image = flag?.originalImage
        countryLB.text = model.country
        if model.cities!.count > 1 {
            locationLB.text = "\(model.cities!.count) locations"
            arrowUIMG.isHidden = false
            locationLB.isHidden = false
        } else {
            arrowUIMG.isHidden = true
            locationLB.isHidden = true
        }
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onTapCell))
        self.contentView.addGestureRecognizer(gesture)
    }
    
    @objc func onTapCell() {
        delegate?.didTapCountryCell(model: serverModel, index: serverModelIndex)
    }
}

protocol CityCellDelegate {
    func didTapCityCell(model: LocationModel, index: Int)
}

class CityCell: UITableViewCell {
    
    @IBOutlet weak var flagUIMG: UIImageView!
    @IBOutlet weak var cityLB: UILabel!
    @IBOutlet weak var selctedUV: UIView!
    
    var city: LocationModel!
    var server: ServerModel!
    var indexNum: Int!
    var delegate: CityCellDelegate?
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func initCell(cityModel: LocationModel, serverModel: ServerModel, index: Int) {
        indexNum = index
        city = cityModel
        server = serverModel
        let flag = Flag(countryCode: server.imgFlag!)
        flagUIMG.image = flag?.originalImage
        cityLB.text = city.name.components(separatedBy: " - ")[1]
        if city.isSelected {
            selctedUV.isHidden = false
            selctedUV.backgroundColor = UIColor(named: "mainBlue")?.withAlphaComponent(0.4)
        } else {
            selctedUV.isHidden = true
        }
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onTapCell))
        self.contentView.addGestureRecognizer(gesture)
    }
    
    @objc func onTapCell() {
        delegate?.didTapCityCell(model: city, index: indexNum)
    }
}
