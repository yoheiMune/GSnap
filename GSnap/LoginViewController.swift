//
//  ViewController.swift
//  GSnap
//
//  Created by Munesada Yohei on 2018/07/29.
//  Copyright © 2018年 Munesada Yohei. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var loginIdInput: UITextField!
    
    @IBOutlet weak var loginPasswordInput: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onTapLogin(_ sender: Any) {
        
        guard let loginId = loginIdInput.text,
            let loginPassword = loginPasswordInput.text else {
                errorLabel.isHidden = false
                errorLabel.text = "ログインIDとパスワードは必ず入力してください。"
                return
        }
        
        if loginId.isEmpty && loginPassword.isEmpty {
            errorLabel.isHidden = false
            errorLabel.text = "ログインIDとパスワードは必ず入力してください。"
            return
        }
        
        // TODO 仮で.
        if loginId != "test" || loginPassword != "test" {
            errorLabel.isHidden = false
            errorLabel.text = "ログインIDまたはパスワードが違います。"
            return
        }
        
        // エラー表示を非表示に.
        errorLabel.isHidden = true
        
        // OK.
        
    }
    
}

