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
        self.tableView.register(UINib(nibName: "TimelineCell", bundle: nil), forCellReuseIdentifier: "TimelineCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineCell", for: indexPath) as! TimelineCell
        cell.post = self.posts[indexPath.row]
        return cell
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
