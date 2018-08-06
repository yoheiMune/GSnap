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
    
    var post: [String: Any]? {
        didSet {
            
            guard let post = post else {
                return
            }
            
            print("post!! \(post)")
            
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
        }
    }
}
