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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "comments" {
            if let post = sender as? [String: Any] {
                let vc = segue.destination as! CommentViewController
                vc.post = post
            }
        }
    }
}

extension TimelineViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineCell", for: indexPath) as! TimelineCell
        cell.post = self.posts[indexPath.row]
        return cell
    }
}

extension TimelineViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let post = self.posts[indexPath.row]
        self.performSegue(withIdentifier: "comments", sender: post)
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
