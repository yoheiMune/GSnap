//
//  Api.swift
//  GSnap
//
//  Created by Munesada Yohei on 2018/08/06.
//  Copyright © 2018 Munesada Yohei. All rights reserved.
//

import Foundation
import Alamofire

//let apiRoot = "http://localhost:5000"
//let apiRoot = "http://100.67.164.251:5000"
let apiRoot = "http://gsnap.yoheim.tech"

class ApiManager {
    
    static let shared = ApiManager()
    
    func login(loginId: String, password: String, callback: @escaping (([String: String]?) -> Void)) {
        
        let url = apiRoot + "/api/login"
        let headers: HTTPHeaders = [ "Content-type" : "application/json" ]
        let params: [String: Any] = [
            "login_id" : loginId,
            "password" : password
        ]
        
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                let statusCode = response.response!.statusCode
                
                // 失敗した場合.
                if statusCode != 200 {
                    if let errorInfo = response.result.value as? [String : String] {
                        callback(errorInfo)
                    }
                    return
                }
                
                // 成功した場合.
                if let data = response.result.value as? [String : Any] {
                    // ユーザーIDを保存しておく.
                    if let userId = data["id"] as? Int {
                        UserDefaults.standard.set(userId, forKey: "userId")
                    }
                    // APIトークンを保存しておく.
                    if let apiToken = data["api_token"] as? String {
                        UserDefaults.standard.set(apiToken, forKey: "apiToken")
                    }
                }
                callback(nil)
        }
    }
    
    func getTimeline(callback: @escaping ([String: Any]?, [[String: Any]]?) -> Void) {
        
        guard let apiToken = UserDefaults.standard.string(forKey: "apiToken") else {
            callback([ "message" : "ログインが必要です"], nil)
            return
        }
        
        let url = apiRoot + "/api/posts?api_token=" + apiToken

        Alamofire.request(url).responseJSON { response in

            let statusCode = response.response!.statusCode
            
            // 失敗した場合.
            if statusCode != 200 {
                callback([ "message" : "サーバーでエラーが発生しました。"], nil)
                return
            }

            // 成功した場合.
            if let data = response.result.value as? [[String : Any]] {
                callback(nil, data)
            }
        }
    }
    
    func post(image: UIImage, text: String, callback: @escaping ([String: Any]?) -> Void) {

        guard let apiToken = UserDefaults.standard.string(forKey: "apiToken") else {
            callback([ "message" : "ログインが必要です"])
            return
        }
        let url = apiRoot + "/api/posts?api_token=" + apiToken
        let headers : HTTPHeaders = [ "Content-type" : "multipart/form-data" ]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(text.data(using: .utf8, allowLossyConversion: true)!, withName: "body")
            multipartFormData.append(UIImageJPEGRepresentation(image, 0.8)!, withName: "file", fileName: "image.png", mimeType: "image/png")
            
        }, usingThreshold: UInt64.init(), to: url, method: .post, headers: headers) { result in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    if response.response?.statusCode != 201 {
                        if let result = response.result.value as? [String: Any] {
                            callback(result)
                        } else {
                            callback([ "message" : "サーバーエラーが発生しました" ])
                        }
                        return
                    }
                    callback(nil)
                }
            case .failure(let error):
                print(error)
                callback([ "message" : "サーバーエラーが発生しました" ])
            }
        }
    }
    
}




















