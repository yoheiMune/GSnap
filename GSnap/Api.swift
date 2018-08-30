//
//  Api.swift
//  GSnap
//
//  Created by Munesada Yohei on 2018/08/06.
//  Copyright © 2018 Munesada Yohei. All rights reserved.
//

import Foundation
import Alamofire

// APIの接続先
//let apiRoot = "http://localhost:5000"
//let apiRoot = "http://100.67.164.251:5000"
let apiRoot = "http://gsnap.yoheim.tech"

/**
    APIを司るクラス.
 */
class ApiManager {
    
    // シングルトンインスタンス.
    static let shared = ApiManager()
    
    /**
     ログインAPI.
    */
    func login(loginId: String, password: String, callback: @escaping (([String: String]?) -> Void)) {
        
        // URLを作成.
        let url = apiRoot + "/api/login"
        
        // リクエストヘッダーを作成.
        let headers: HTTPHeaders = [ "Content-type" : "application/json" ]
        
        // 送信パラメータを作成.
        let params: [String: Any] = [
            "login_id" : loginId,
            "password" : password
        ]
        
        // POST通信でAPIを実行する.
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                
                // ステータスコードを取得.
                let statusCode = response.response!.statusCode
                
                // 失敗した場合.
                if statusCode != 200 {
                    
                    // サーバーからのエラーを取得して、コールバックで戻す.
                    if let errorInfo = response.result.value as? [String : String] {
                        callback(errorInfo)
                    }
                    return
                }
                
                // 成功した場合.
                if let data = response.result.value as? [String : Any] {
                    // ユーザーIDをUserDefaultsに保存しておく（マイページの表示で使う）.
                    if let userId = data["id"] as? Int {
                        UserDefaults.standard.set(userId, forKey: "userId")
                    }
                    // APIトークンをUserDefaultsに保存しておく（ログインが必要なAPIで使う）.
                    if let apiToken = data["api_token"] as? String {
                        UserDefaults.standard.set(apiToken, forKey: "apiToken")
                    }
                }
                callback(nil)
        }
    }
    
    /**
        タイムライン取得API.
    */
    func getTimeline(callback: @escaping ([String: Any]?, [[String: Any]]?) -> Void) {
        
        // APIトークンがない場合はエラー.
        guard let apiToken = UserDefaults.standard.string(forKey: "apiToken") else {
            callback([ "message" : "ログインが必要です"], nil)
            return
        }
        
        // URLを作成する.
        let url = apiRoot + "/api/posts?api_token=" + apiToken
        print(url)

        // GET通信でAPIを実行する.
        Alamofire.request(url).responseJSON { response in

            // ステータスコード取得.
            let statusCode = response.response!.statusCode
            
            // 失敗した場合.
            if statusCode != 200 {
                // コールバックでエラーを戻す.
                callback([ "message" : "サーバーでエラーが発生しました。"], nil)
                return
            }

            // 成功した場合.
            if let data = response.result.value as? [[String : Any]] {
                // コールバックで投稿一覧を戻す.
                print("timeline: \(data)")
                callback(nil, data)
            }
        }
    }
    
    /**
        投稿API.
    */
    func post(image: UIImage, text: String, callback: @escaping ([String: Any]?) -> Void) {

        // APIトークンがない場合はエラー.
        guard let apiToken = UserDefaults.standard.string(forKey: "apiToken") else {
            callback([ "message" : "ログインが必要です"])
            return
        }
        
        // URLを作成.
        let url = apiRoot + "/api/posts?api_token=" + apiToken
        
        // リクエストヘッダーを作成.
        // ここでは multipart/form-data 形式でAPIを実行する.
        let headers : HTTPHeaders = [ "Content-type" : "multipart/form-data" ]
        
        // multipart/form-data でAlamofireを実行.
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            // 送信データを詰める.
            multipartFormData.append(text.data(using: .utf8, allowLossyConversion: true)!, withName: "body")
            multipartFormData.append(UIImageJPEGRepresentation(image, 0.8)!, withName: "file", fileName: "image.png", mimeType: "image/png")
            
        }, usingThreshold: UInt64.init(), to: url, method: .post, headers: headers) { result in
            
            // 結果別に処理する.
            switch result {
                
            // 成功した場合.
            case .success(let upload, _, _):
                // JSON形式でレスポンスを受け取る.
                upload.responseJSON { response in
                    // ステータスコードが成功(201)ではない場合
                    if response.response?.statusCode != 201 {
                        if let result = response.result.value as? [String: Any] {
                            // サーバーからのエラー情報があればそれを返す.
                            callback(result)
                        } else {
                            // なければエラー通知をする.
                            callback([ "message" : "サーバーエラーが発生しました" ])
                        }
                        return
                    }
                    // 成功の場合は、エラーなしで返却する.
                    callback(nil)
                }
                
            // 失敗した場合.
            case .failure(let error):
                // エラーを返却する.
                print(error)
                callback([ "message" : "サーバーエラーが発生しました" ])
            }
        }
    }

    /**
     いいね追加API.
    */
    func addLike(postId: Int, callback: @escaping ([String: Any]?) -> Void) {
        
        // APIトークンがない場合はエラー.
        guard let apiToken = UserDefaults.standard.string(forKey: "apiToken") else {
            callback([ "message" : "ログインが必要です"])
            return
        }
        
        // URLを作成する.
        let url = "\(apiRoot)/api/posts/\(postId)/likes?api_token=\(apiToken)"
        print("POST \(url)")
        
        // POSTでAPIを実行する.
        Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            
            // ステータスコードの取得.
            let statusCode = response.response!.statusCode
            
            // 失敗した場合.
            if statusCode != 201 {
                // エラーを返却する.
                if let errorInfo = response.result.value as? [String : String] {
                    callback(errorInfo)
                }
                return
            }
            
            // 成功した場合.
            callback(nil)
        }
    }

    /**
        いいね削除API.
    */
    func removeLike(postId: Int, callback: @escaping ([String: Any]?) -> Void) {
        
        // APIトークンがない場合はエラー.
        guard let apiToken = UserDefaults.standard.string(forKey: "apiToken") else {
            callback([ "message" : "ログインが必要です"])
            return
        }
        
        // URLを作成する.
        let url = "\(apiRoot)/api/posts/\(postId)/likes?api_token=\(apiToken)"
        print("DELETE \(url)")
        
        // DELETEメソッドでAPIを実行する.
        Alamofire.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            
            // ステータスコード.
            let statusCode = response.response!.statusCode
            
            // 失敗した場合.
            if statusCode != 200 {
                // エラー情報を返却する.
                if let errorInfo = response.result.value as? [String : String] {
                    callback(errorInfo)
                }
                return
            }
            
            // 成功した場合.
            callback(nil)
        }
    }

    /**
        コメント取得API.
    */
    func getComments(postId: Int, callback: @escaping ([String: String]?, [[String: Any]]?) -> Void) {
        
        // APIトークンがない場合はエラー.
        guard let apiToken = UserDefaults.standard.string(forKey: "apiToken") else {
            callback([ "message" : "ログインが必要です"], nil)
            return
        }
        
        // URLを作成する.
        let url = apiRoot + "/api/posts/\(postId)/comments?api_token=" + apiToken
        print(url)
        
        // GETメソッドでAPIを実行する.
        Alamofire.request(url).responseJSON { response in
            
            // ステータスコードの取得.
            let statusCode = response.response!.statusCode
            
            // 失敗した場合.
            if statusCode != 200 {
                // エラー情報を返す.
                if let errorInfo = response.result.value as? [String : String] {
                    callback(errorInfo, nil)
                }
                return
            }
            
            // 成功した場合.
            if let data = response.result.value as? [[String : Any]] {
                print("comments: \(data)")
                callback(nil, data)
            }
        }
    }

    /**
        コメント追加API.
    */
    func addComment(postId: Int, comment: String, callback: @escaping (([String: String]?) -> Void)) {
        
        // APIトークンがない場合はエラー.
        guard let apiToken = UserDefaults.standard.string(forKey: "apiToken") else {
            callback(["message" : "ログインが必要です"])
            return
        }
        
        // URLを作成.
        let url = apiRoot + "/api/posts/\(postId)/comments?api_token=" + apiToken
        print("POST \(url)")

        // リクエストヘッダーを作成.
        let headers: HTTPHeaders = [ "Content-type" : "application/json" ]
        
        // 送信データを作成.
        let params: [String: Any] = [
            "comment" : comment
        ]
        
        // POSTでAPIを実行している.
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                let statusCode = response.response!.statusCode
                
                // 失敗した場合.
                if statusCode != 201 {
                    // エラー情報を返す.
                    if let errorInfo = response.result.value as? [String : String] {
                        callback(errorInfo)
                    }
                    return
                }
                
                // 成功した場合.
                callback(nil)
        }
    }
}
