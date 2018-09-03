//
//  TimelineCell.swift
//  GSnap
//
//  Created by Munesada Yohei on 2018/08/06.
//  Copyright © 2018 Munesada Yohei. All rights reserved.
//

import UIKit

/**
    タイムラインのTableViewCell.
 */
class TimelineCell : UITableViewCell {
    
    // ユーザー画像.
    @IBOutlet weak var avatarImageView: UIImageView!
    
    // ユーザー名.
    @IBOutlet weak var userNameLabel: UILabel!
    
    // 投稿画像.
    @IBOutlet weak var photoImageView: UIImageView!
    
    // 投稿内容.
    @IBOutlet weak var bodyLabel: UILabel!
    
    // いいねボタン.
    @IBOutlet weak var likeButton: UIButton!
    
    // 投稿データ.
    var post: [String: Any]? {
        
        // 値がセットされた時に呼び出される処理.
        didSet {
            
            // 値がなければ終わり.
            guard let post = post else {
                return
            }

            // 画像表示は一旦初期化.
            self.photoImageView.image = UIImage(named: "default")
            
            // ユーザー名、ユーザー画像の表示.
            if let user = post["user"] as? [String: Any] {
                if let avatarUrl = user["avatar_url"] as? String {
                    let url = apiRoot + avatarUrl
                    self.avatarImageView.downloadedFrom(link: url)
                }
                if let userName = user["name"] as? String {
                    self.userNameLabel.text = userName
                }
            }
            
            // 投稿画像の表示.
            if let imageUrl = post["image_url"] as? String {
                let url = apiRoot + imageUrl
                print("url: \(url)")
                self.photoImageView.downloadedFrom(link: url)
            }
            
            // 投稿本文の表示.
            if let body = post["body"] as? String {
                self.bodyLabel.text = body
            }
            
            // いいねボタンの状態.
            if let liked = post["liked"] as? Bool {
                if liked {
                    self.likeButton.setImage(UIImage(named: "like-on"), for: .normal)
                } else {
                    self.likeButton.setImage(UIImage(named: "like"), for: .normal)
                }
            }
        }
    }
    
    // イイネボタンがタップされた.
    @IBAction func onLike(_ sender: Any) {
        
        // 投稿データがない場合には無視.
        guard var post = self.post else {
            return
        }
        
        // 現在のいいね状態をチェック.
        if let liked = post["liked"] as? Bool {
            // 現在が「いいね」している場合.
            if liked {
                // いいねを解除.
                self.post!["liked"] = false
                self.likeButton.setImage(UIImage(named: "like"), for: .normal)
                // APIでいいねを削除.
                ApiManager.shared.removeLike(postId: post["id"] as! Int) { errorInfo in
                    if let errorInfo = errorInfo {
                        print("error: \(errorInfo)")
                    }
                }
            
            // 現在が「いいね」していない場合.
            } else {
                // 「いいね」にする.
                self.post!["liked"] = true
                self.likeButton.setImage(UIImage(named: "like-on"), for: .normal)
                // APIでいいねを追加.
                ApiManager.shared.addLike(postId: post["id"] as! Int) { errorInfo in
                    if let errorInfo = errorInfo {
                        print("error: \(errorInfo)")
                    }
                }
            }
        }
    }
    
}
