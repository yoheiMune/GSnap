//
//  MypageViewController.swift
//  GSnap
//
//  Created by Munesada Yohei on 2018/08/06.
//  Copyright © 2018 Munesada Yohei. All rights reserved.
//

import UIKit

class MypageViewController: UICollectionViewController {
    
    var posts: [[String : Any]] = []
    
    override func viewDidLoad() {
        self.title = "マイページ"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchData()
    }
}

extension MypageViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if let imageView = cell.viewWithTag(1) as? UIImageView {
            if let imageUrl = posts[indexPath.row]["image_url"] as? String {
                imageView.downloadedFrom(link: apiRoot + imageUrl)
            }
        }
        return cell
    }
}

extension MypageViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.bounds.size.width / 2
        return CGSize(width: width, height: width)
    }
}

extension MypageViewController {
    
    fileprivate func fetchData() {
        ApiManager.shared.getTimeline() { error, posts in
            
            if let error = error {
                if let message = error["message"] as? String {
                    self.showAlert(message: message)
                } else {
                    self.showAlert(message: "不明なエラーが発生しました")
                }
                return
            }
            
            if let posts = posts {
                // 自分の画像にだけ絞る.
                var posts = posts
                if let userId = UserDefaults.standard.integer(forKey: "userId") as? Int {
                    posts = posts.filter({ post -> Bool in
                        if let id = post["user_id"] as? Int {
                            return userId == id
                        }
                        return false
                    })
                }
                self.posts = posts
            }
            self.collectionView?.reloadData()
        }
    }
}
