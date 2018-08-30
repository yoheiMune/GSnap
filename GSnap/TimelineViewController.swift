//
//  TimelineViewController.swift
//  GSnap
//
//  Created by Munesada Yohei on 2018/08/06.
//  Copyright © 2018 Munesada Yohei. All rights reserved.
//

import UIKit

/**
    タイムラインを表示するViewController.
 */
class TimelineViewController: UITableViewController {
    
    // 投稿データ一覧（APIから取得する）
    var posts: [[String : Any]] = []
    
    // ViewControllerが読み込まれた時.
    override func viewDidLoad() {
        
        // NavigationBarにタイトルを設定する.
        self.title = "タイムライン"
        
        // 利用するカスタムTableViewCellを登録する.
        self.tableView.register(UINib(nibName: "TimelineCell", bundle: nil), forCellReuseIdentifier: "TimelineCell")
    }
    
    // ViewControllerが表示される時に毎回呼び出される.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // APIから投稿一覧を取得する.
        self.fetchData()
    }
    
    // Segueでの画面遷移時に呼び出される.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // コメント一覧への遷移の場合.
        if segue.identifier == "comments" {
            // 選択された投稿データをコメントViewControllerへ渡す.
            if let post = sender as? [String: Any] {
                let vc = segue.destination as! CommentViewController
                vc.post = post
            }
        }
    }
}

// TableViewDatasouce関連の処理.
extension TimelineViewController {
    // 各セクションの行数（今回はセクション数は1、行数は投稿一覧の数）.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    // 指定行のTableViewCellを作成する.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 事前に登録したカスタムTableViewCellからインスタンスを取得.
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineCell", for: indexPath) as! TimelineCell
        
        // 表示する投稿データを設定（TableViewCellでは設定されたら画面へ描画する処理を行っている）.
        cell.post = self.posts[indexPath.row]
        
        // TableViewCellを返却.
        return cell
    }
}

// UITableViewDelegate関連の処理.
extension TimelineViewController {
    
    // 行がタップされた時.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // 選択状態を非表示にする.
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 選択対象の投稿を取得する.
        let post = self.posts[indexPath.row]
        
        // コメント一覧へ遷移する.
        self.performSegue(withIdentifier: "comments", sender: post)
    }
}

// その他、Priavateないろいろな処理.
extension TimelineViewController {
    
    // APIから投稿一覧を取得する.
    fileprivate func fetchData() {
        
        // APIを実行.
        ApiManager.shared.getTimeline() { error, posts in
            
            // エラーがある場合は、それをAlertで表示.
            if let error = error {
                if let message = error["message"] as? String {
                    // エラー情報に message プロパティがあればそれを表示.
                    self.showAlert(message: message)
                } else {
                    // message がない場合は、固定文言で表示.
                    self.showAlert(message: "不明なエラーが発生しました")
                }
                return
            }
            
            // 投稿データをフィールドにセット.
            if let posts = posts {
                self.posts = posts
            }
            
            // 表示する.
            self.tableView.reloadData()
        }
    }
}
