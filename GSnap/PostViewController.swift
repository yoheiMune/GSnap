//
//  PostViewController.swift
//  GSnap
//
//  Created by Munesada Yohei on 2018/08/06.
//  Copyright © 2018 Munesada Yohei. All rights reserved.
//

import UIKit

// 投稿本文のデフォルトメッセージ.
let defaultPostMessage = "ここをタップしてメッセージを書こう！"

/**
    投稿ViewController.
 */
class PostViewController: UIViewController {
    
    // ユーザーが選択した画像.
    @IBOutlet weak var userImageView: UIImageView!
    
    // 投稿本文.
    @IBOutlet weak var textView: UITextView!
    
    // カメラまたは写真から画像を選択したか？
    private var imageSelected = false
    
    override func viewDidLoad() {
        // ナビゲーションにタイトルを設定.
        self.title = "投稿"
        
        // 本文TextViewのdelegateを設定.
        self.textView.delegate = self
        
        // ちょっとだけ装飾（TextViewに枠線を追加）.
        textView.layer.cornerRadius = 3
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
    }
    
    /// カメラボタンがタップされた.
    @IBAction func onTapCamera(_ sender: Any) {
        
        // カメラ起動が可能かをチェック.
        if UIImagePickerController.isSourceTypeAvailable(.camera) == false {
            self.showAlert(message: "カメラは利用できません。")
            return
        }
        
        // カメラを起動.
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        self.present(picker, animated: true)
    }
    
    /// 写真ボタンがタップされた.
    @IBAction func onTapPhoto(_ sender: Any) {
        
        // アルバムが利用可能かをチェック.
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == false {
            self.showAlert(message: "アルバムは利用できません。")
            return
        }
        
        // アルバムを起動.
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        self.present(picker, animated: true)
    }
    
    /// 投稿ボタンがタップされた.
    @IBAction func onTapPost(_ sender: Any) {
        
        // 入力チェック.
        if imageSelected == false {
            self.showAlert(message: "投稿する画像を選択してください。")
            return
        }
        guard let text = textView.text else {
            self.showAlert(message: "投稿する文言を入力してください。")
            return
        }
        if textView.text == defaultPostMessage {
            self.showAlert(message: "投稿する文言を入力してください。")
            return
        }

        // 進捗表示を開始.
        self.showProgress()

        // APIで投稿.
        ApiManager.shared.post(image: userImageView.image!, text: text) { [weak self] errorInfo in
        
            // 進捗表示を終了.
            self?.hideProgress()
            
            // エラー処理.
            if let errorInfo = errorInfo {
                if let message = errorInfo["message"] as? String {
                    self?.showAlert(message: message)
                } else {
                    self?.showAlert(message: "エラーが発生しました。")
                }
                return
            }
            
            // 投稿完了を通知.
            self?.showAlert(message: "投稿しました。")
            
            // タイムラインを表示.
            self?.navigationController?.tabBarController?.selectedIndex = 0
        }
    }
}

// UIImagePickerController で必要なので実装（具体的な処理は不要なので中身はない）.
extension PostViewController: UINavigationControllerDelegate {}

// カメラor写真で画像が選択された時などの処理を実装する.
extension PostViewController: UIImagePickerControllerDelegate {
    
    // カメラor写真で画像が選択された
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // UIImagePickerControllerを閉じる.
        picker.dismiss(animated: true, completion: nil)
        
        // ユーザーがカメラで撮影した or 写真から選んだ、画像がある場合.
        if var image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            // このアプリでは勝手に正方形にトリミングしちゃう.
            image = self.cropToRect(image: image)
            // 画面に表示.
            self.userImageView.image = image
            // 設定済みをマーク.
            self.imageSelected = true
        }
    }
    
    // 画像を勝手に、上下中央で正方形にトリミングする.
    fileprivate func cropToRect(image: UIImage) -> UIImage {
        
        var image = image
        
        // 天地の調整.
        UIGraphicsBeginImageContext(image.size)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        let _image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let __image = _image {
            image = __image
        }

        // 正方形にする処理.
        if image.size.width != image.size.height {
            var x: CGFloat = 0, y: CGFloat = 0, w = image.size.width, h = image.size.height
            if w > h { // landscape.
                x = (w - h) / 2
                w = h
            } else {  // portrait.
                y = (h - w) / 2
                h = w
            }
            let rect = CGRect(x: x, y: y, width: w, height: h)
            let ref = image.cgImage?.cropping(to: rect)
            image = UIImage(cgImage: ref!)
        }
        
        // サイズの調整.
        let newSize = CGSize(width: 720, height: 720)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

// UITextViewDelegate
extension PostViewController: UITextViewDelegate {
    
    // 書き始める時に、デフォルトメッセージがあれば削除する.
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == defaultPostMessage {
            textView.text = ""
        }
    }
    
    // 改行が入力されたらバーチャルキーボードを閉じる.
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            self.textView.resignFirstResponder()
            return false
        }
        return true
    }
}
