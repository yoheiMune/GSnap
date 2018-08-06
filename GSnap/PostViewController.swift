//
//  PostViewController.swift
//  GSnap
//
//  Created by Munesada Yohei on 2018/08/06.
//  Copyright © 2018 Munesada Yohei. All rights reserved.
//

import UIKit

class PostViewController: UIViewController {
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        self.title = "投稿"
        self.textView.delegate = self
    }
    
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
    
    
    @IBAction func onTapPost(_ sender: Any) {
        
        // 入力チェック.
        guard let image = userImageView.image else {
            self.showAlert(message: "投稿する画像を選択してください。")
            return
        }
        guard let text = textView.text else {
            self.showAlert(message: "投稿する文言を入力してください。")
            return
        }
        
        // APIで投稿.
        self.showProgress()
        ApiManager.shared.post(image: image, text: text) { [weak self] errorInfo in
            
            self?.hideProgress()
            
            if let errorInfo = errorInfo {
                if let message = errorInfo["message"] as? String {
                    self?.showAlert(message: message)
                } else {
                    self?.showAlert(message: "エラーが発生しました。")
                }
                return
            }
            
            self?.showAlert(message: "投稿しました。")
            
            // タイムラインを表示.
            self?.navigationController?.tabBarController?.selectedIndex = 0
        }
    }
}

extension PostViewController: UINavigationControllerDelegate {}

extension PostViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // 閉じる.
        picker.dismiss(animated: true, completion: nil)
        
        if var image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            // このアプリでは勝手に正方形にトリミングしちゃう.
            image = self.cropToRect(image: image)
            // 画面に表示.
            self.userImageView.image = image
        }
    }
    
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

extension PostViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "ここをタップしてメッセージを書こう！" {
            textView.text = ""
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            self.textView.resignFirstResponder()
            return false
        }
        return true
    }
}












