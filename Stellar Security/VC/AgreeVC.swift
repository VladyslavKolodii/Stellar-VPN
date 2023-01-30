//
//  AgreeVC.swift
//  Stellar Security
//
//  Created by Aira on 9.02.2021.
//

import UIKit

class AgreeVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func onTapAgreeUB(_ sender: Any) {
        self.dismiss(animated: true) {
            SharedUtils().setUserDefaultString(key: AGREE_CONTINUE, value: "AGREE_CONTINUE")
        }
    }
    @IBAction func onTapCloseUB(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
