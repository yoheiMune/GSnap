//
//  ViewController.swift
//  GSnap
//
//  Created by Munesada Yohei on 2018/07/29.
//  Copyright © 2018 Munesada Yohei. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var loginIdInput: UITextField!
    
    @IBOutlet weak var loginPasswordInput: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginIdInput.delegate = self
        loginPasswordInput.delegate = self
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
        
        // エラー表示を非表示に.
        errorLabel.isHidden = true
        
        // APIでログイン.
        ApiManager.shared.login(loginId: loginId, password: loginPassword) { [weak self] errorInfo in
            
            // エラー表示.
            if let errorInfo = errorInfo {
                self?.errorLabel.isHidden = false
                self?.errorLabel.text = errorInfo["message"]
                return
            }
            
            // 成功したので、スレッドを表示する.
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.showTimelineStoryboard()
            }
            
        }
    }
}

extension LoginViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

