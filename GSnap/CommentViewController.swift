//
//  DetailViewController.swift
//  GSnap
//
//  Created by Munesada Yohei on 2018/08/30.
//  Copyright © 2018年 Munesada Yohei. All rights reserved.
//

import UIKit

class CommentViewController: UITableViewController {
    
    var post: [String: Any]!
    
    var comments : [[String: Any]] = []
    
    override func viewDidLoad() {
        self.title = "コメント一覧"
        self.fetchData()
        
        let navItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(CommentViewController.onTapAddComment))
        self.navigationItem.setRightBarButton(navItem, animated: true)
        
    }
    
    @objc func onTapAddComment() {
        let alertController = UIAlertController(title: "", message: "コメントを入力してください。", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "コメント"
        }
        let confirmAction = UIAlertAction(title: "投稿する", style: .default) { (_) in
            let comment = alertController.textFields?[0].text
            print("comment: \(comment)")
            ApiManager.shared.addComment(postId: self.post["id"] as! Int, comment: comment!) { errorInfo in
                if let errorInfo = errorInfo {
                    self.showAlert(message: errorInfo["message"] as! String)
                    return
                }
                // 再読み込み.
                self.fetchData()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)


        
        self.present(alertController, animated: true, completion: nil)
    }
}

extension CommentViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return self.comments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        
        if indexPath.section == 0 {
            if let body = self.post["body"] as? String {
                cell.textLabel?.text = body
            }
        
        } else {
            let comment = comments[indexPath.row]
            let userName = (comment["user"] as! [String: Any])["name"] as! String
            let content = comment["comment"] as! String
            cell.textLabel?.text = "\(content) (by \(userName))"
        }
        
        return cell
    }
}

extension CommentViewController {
    
    func fetchData() {
        ApiManager.shared.getComments(postId: post["id"] as! Int) { (errorInfo, data) in
            
            if let errorInfo = errorInfo {
                self.showAlert(message: errorInfo["message"]!)
                return
            }
            
            self.comments = data!
            self.tableView.reloadData()
        }
    }
}


