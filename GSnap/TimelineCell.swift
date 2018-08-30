//
//  TimelineCell.swift
//  GSnap
//
//  Created by Munesada Yohei on 2018/08/06.
//  Copyright © 2018 Munesada Yohei. All rights reserved.
//

import UIKit

class TimelineCell : UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var bodyLabel: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    
    var post: [String: Any]? {
        didSet {
            
            guard let post = post else {
                return
            }

            // 画像は一旦初期化.
            self.photoImageView.image = UIImage(named: "default")
            
            if let user = post["user"] as? [String: Any] {
                if let avatarUrl = user["avatar_url"] as? String {
                    let url = apiRoot + avatarUrl
                    self.avatarImageView.downloadedFrom(link: url)
                }
                if let userName = user["name"] as? String {
                    self.userNameLabel.text = userName
                }
            }
            
            if let imageUrl = post["image_url"] as? String {
                let url = apiRoot + imageUrl
                print("url: \(url)")
                self.photoImageView.downloadedFrom(link: url)
            }
            
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
    
    @IBAction func onLike(_ sender: Any) {
        
        guard var post = self.post else {
            return
        }
        
        if let liked = post["liked"] as? Bool {
            if liked {
                self.post!["liked"] = false
                self.likeButton.setImage(UIImage(named: "like"), for: .normal)
                ApiManager.shared.removeLike(postId: post["id"] as! Int) { errorInfo in
                    if let errorInfo = errorInfo {
                        print("error: \(errorInfo)")
                    }
                    print("OK unlike.")
                }
            } else {
                self.post!["liked"] = true
                self.likeButton.setImage(UIImage(named: "like-on"), for: .normal)
                ApiManager.shared.addLike(postId: post["id"] as! Int) { errorInfo in
                    if let errorInfo = errorInfo {
                        print("error: \(errorInfo)")
                    }
                    print("OK like.")
                }
            }
        }

    }
    
    
    
    
    
    
}
