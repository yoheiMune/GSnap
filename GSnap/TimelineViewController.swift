//
//  TimelineViewController.swift
//  GSnap
//
//  Created by Munesada Yohei on 2018/08/06.
//  Copyright © 2018 Munesada Yohei. All rights reserved.
//

import UIKit

class TimelineViewController: UITableViewController {
    
    var posts: [[String : Any]] = []
    
    override func viewDidLoad() {
        self.title = "タイムライン"
        self.fetchData()
    }
}

extension TimelineViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if (cell == nil) {
            cell = UITableViewCell()
        }
        cell?.textLabel?.text = self.posts[indexPath.row]["body"] as! String
        return cell!
    }
}

extension TimelineViewController {
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
                self.posts = posts
            }
            self.tableView.reloadData()
        }
    }
}
