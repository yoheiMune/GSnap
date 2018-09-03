//
//  Ext.swift
//  GSnap
//
//  Created by Munesada Yohei on 2018/08/06.
//  Copyright © 2018 Munesada Yohei. All rights reserved.
//

import UIKit

// UIViewControllerを拡張します.
extension UIViewController {

    // アラート表示を行う機能.
    func showAlert(message: String) {
        // UIAlertControllerのインスタンスを作成します.
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        // OKボタンを追加します.
        alert.addAction(UIAlertAction(title: "OK", style: .default) { action in
            // OKボタンを押されたら、アラートダイアログを非表示にします.
            alert.dismiss(animated: true, completion: nil)
        })
        // アラートダイアログを表示します.
        self.present(alert, animated: true)
    }
    
    // 進捗表示（=ローディング）を行う機能.
    func showProgress() {
        // ローディング用のViewをインスタンス化します.
        let indicator = UIActivityIndicatorView()
        // サイズは 50px x 50px とします。
        indicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        // 表示位置を画面の中央に設定します.
        indicator.center = self.view.center
        // tagに番号を指定します（閉じるときにこのIDから、ローディング用のViewを取得します）.
        indicator.tag = 837192
        // ビューに追加して表示します.
        self.view.addSubview(indicator)
        // ローディング開始.
        indicator.startAnimating()
    }
    
    // 進捗表示（=ローディング）を削除する機能.
    func hideProgress() {
        // tag番号からローディング用のViewを取得します.
        if let indicator = self.view.viewWithTag(837192) {
            // もし取得できれば、それをビューから削除して非表示にします.
            indicator.removeFromSuperview()
        }
    }
}

// UIImageViewの拡張.
extension UIImageView {
    // 指定URLから画像をダウンロードして、表示します.
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        // ダウンロード先にリクエストを発行します.
        URLSession.shared.dataTask(with: url) { data, response, error in
            // 正しくHTTP通信ができたことを確認します.
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                // メインスレッドで、表示する画像の更新を行います.
                self.image = image
            }
            }.resume()
    }
    
    // 指定URLから画像をダウンロードして、表示します（ダウンロード先を文字列で指定）.
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}
