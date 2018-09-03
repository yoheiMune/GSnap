//
//  DetailViewController.swift
//  GSnap
//
//  Created by Munesada Yohei on 2018/08/30.
//  Copyright © 2018 Munesada Yohei. All rights reserved.
//

import UIKit

/**
    コメント一覧ViewController.
 */
class CommentViewController: UITableViewController {
    
    // コメント対象の投稿データ.
    var post: [String: Any]!
    
    // コメント一覧.
    var comments : [[String: Any]] = []
    
    override func viewDidLoad() {
        // タイトルを指定.
        self.title = "コメント一覧"
        
        // APIからコメント一覧を取得する.
        self.fetchData()
        
        // ナビゲーション右上に「+」ボタンを追加.
        // タップしたら onTapAddComment メソッドを呼び出す.
        let navItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(CommentViewController.onTapAddComment))
        self.navigationItem.setRightBarButton(navItem, animated: true)
        
    }
    
    // ナビゲーションバーの「+」ボタンがタップされた.
    @objc func onTapAddComment() {
        
        // アラートの作成.
        let alertController = UIAlertController(title: "", message: "コメントを入力してください。", preferredStyle: .alert)
        
        // 入力フィールドを追加.
        alertController.addTextField { (textField) in
            textField.placeholder = "コメント"
        }
        
        // 「投稿する」ボタンを設置.
        let confirmAction = UIAlertAction(title: "投稿する", style: .default) { (_) in
            // タップされたら、入力内容を取得する.
            let comment = alertController.textFields?[0].text
            // API経由でコメントを追加.
            ApiManager.shared.addComment(postId: self.post["id"] as! Int, comment: comment!) { errorInfo in
                if let errorInfo = errorInfo {
                    self.showAlert(message: errorInfo["message"]!)
                    return
                }
                // コメントデータの再読み込み.
                self.fetchData()
            }
        }
        alertController.addAction(confirmAction)

        // 「キャンセル」ボタンを設置.
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (_) in }
        alertController.addAction(cancelAction)

        // アラートを表示する.
        self.present(alertController, animated: true, completion: nil)
    }
}

extension CommentViewController {
    
    // セクション数.
    override func numberOfSections(in tableView: UITableView) -> Int {
        // セクションは2つ（1つ目：投稿内容、2つ目：コメント一覧）
        return 2
    }
    
    // セクションごとの行数.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // セクション1：投稿内容.
        if section == 0 {
            // 1行固定.
            return 1
        }
        // セクション2：コメント一覧は、行数=コメント数.
        return self.comments.count
    }

    // TableCellの作成.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 新規にテーブルセルを作成.
        let cell = UITableViewCell()
        
        // セクション1(=投稿)の場合.
        if indexPath.section == 0 {
            // 投稿内容を表示する.
            if let body = self.post["body"] as? String {
                cell.textLabel?.text = body
            }
        
        // セクション2(=コメント一覧)の場合.
        } else {
            // コメント内容 + ユーザー名 を表示.
            let comment = comments[indexPath.row]
            let userName = (comment["user"] as! [String: Any])["name"] as! String
            let content = comment["comment"] as! String
            cell.textLabel?.text = "\(content) (by \(userName))"
        }
        
        return cell
    }
}

extension CommentViewController {
    
    // APIからコメント一覧を取得する.
    func fetchData() {
        // API実行.
        ApiManager.shared.getComments(postId: post["id"] as! Int) { (errorInfo, data) in
            
            // エラー処理.
            if let errorInfo = errorInfo {
                self.showAlert(message: errorInfo["message"]!)
                return
            }
            
            // コメントデータの設定.
            self.comments = data!
            
            // 表示データを再描画.
            self.tableView.reloadData()
        }
    }
}


