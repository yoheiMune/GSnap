//
//  ViewController.swift
//  GSnap
//
//  Created by Munesada Yohei on 2018/07/29.
//  Copyright © 2018 Munesada Yohei. All rights reserved.
//

import UIKit

/**
    ログイン機能を扱うViewController.
 */
class LoginViewController: UIViewController {

    // テキストフィールド（ログインID)
    @IBOutlet weak var loginIdInput: UITextField!
    
    // テキストフィールド（パスワード)
    @IBOutlet weak var loginPasswordInput: UITextField!
    
    // エラーラベル
    @IBOutlet weak var errorLabel: UILabel!
    
    // ViewControllerが読み込まれた時に呼び出される.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // テキストフィールドのdelegateを設定する.
        loginIdInput.delegate = self
        loginPasswordInput.delegate = self
    }

    /**
        ログインボタンをタップした時.
    */
    @IBAction func onTapLogin(_ sender: Any) {
        
        // ログインIDやパスワードが未指定の場合はエラー.
        guard let loginId = loginIdInput.text,
            let loginPassword = loginPasswordInput.text else {
                errorLabel.isHidden = false
                errorLabel.text = "ログインIDとパスワードは必ず入力してください。"
                return
        }
        
        // ログインIDやパスワードが未指定の場合はエラー.
        if loginId.isEmpty && loginPassword.isEmpty {
            errorLabel.isHidden = false
            errorLabel.text = "ログインIDとパスワードは必ず入力してください。"
            return
        }
        
        // エラー表示を非表示に.
        errorLabel.isHidden = true
        
        // APIでログイン.
        ApiManager.shared.login(loginId: loginId, password: loginPassword) { errorInfo in
            
            // エラー表示.
            if let errorInfo = errorInfo {
                self.errorLabel.isHidden = false
                self.errorLabel.text = errorInfo["message"]
                return
            }
            
            // 成功したよ、ダイアログの表示.
            self.showAlert(message: "ログイン成功したよ！")
            
            // 成功したので、スレッドを表示する.
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.showTimelineStoryboard()
            }
            
        }
    }
}

// テキストフィールドのDelegate実装.
extension LoginViewController : UITextFieldDelegate {
    
    // リターンキーが押された時.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる.
        textField.resignFirstResponder()
        return true
    }
}

