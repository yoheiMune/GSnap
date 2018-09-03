//
//  MypageViewController.swift
//  GSnap
//
//  Created by Munesada Yohei on 2018/08/06.
//  Copyright © 2018 Munesada Yohei. All rights reserved.
//

import UIKit

/**
    マイページViewController.
 */
class MypageViewController: UICollectionViewController {
    
    // 投稿内容一覧.
    var posts: [[String : Any]] = []
    
    override func viewDidLoad() {
        // ナビゲーションにタイトルを表示.
        self.title = "マイページ"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 画面表示時に、API経由でデータを取得する.
        self.fetchData()
    }
}

// UICollectionViewController関連の処理.
extension MypageViewController {
    
    // セクション数を返却する.
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // 各セクションに含まれるアイテム数を返す.
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    // indexPathに該当するCellを作成して返却する.
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Storyboard上でカスタマイズした、Cellを取得する.
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        // tag番号を用いて（=Storyboard上で指定した）、UIImageViewを取得する.
        if let imageView = cell.viewWithTag(1) as? UIImageView {
            // UIImageViewに画像を指定する.
            if let imageUrl = posts[indexPath.row]["image_url"] as? String {
                imageView.downloadedFrom(link: apiRoot + imageUrl)
            }
        }
        return cell
    }
}

// UICollectionViewのデザインレイアウトを指定する.
extension MypageViewController: UICollectionViewDelegateFlowLayout {
    
    // 1つのセルのサイズを指定する.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 画面横幅の1/2とする（→2カラム表示になる）.
        let width = self.view.bounds.size.width / 2
        // Cellのサイズを返却する.
        return CGSize(width: width, height: width)
    }
}

extension MypageViewController {
    
    // APIからデータを取得する.
    fileprivate func fetchData() {
        // タイムラインAPIを実行（タイムラインViewControllerで使っているものと同じ）.
        ApiManager.shared.getTimeline() { error, posts in
            
            // エラー処理.
            if let error = error {
                if let message = error["message"] as? String {
                    self.showAlert(message: message)
                } else {
                    self.showAlert(message: "不明なエラーが発生しました")
                }
                return
            }
            
            // 投稿一覧を取得できた場合.
            if let posts = posts {
                // 自分の画像にだけ絞りこむ.
                var posts = posts
                let userId = UserDefaults.standard.integer(forKey: "userId")
                posts = posts.filter({ post -> Bool in
                    if let id = post["user_id"] as? Int {
                        return userId == id
                    }
                    return false
                })
                self.posts = posts
            }
            
            // 画面を再描画する.
            self.collectionView?.reloadData()
        }
    }
}
