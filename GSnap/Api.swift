//
//  Api.swift
//  GSnap
//
//  Created by Munesada Yohei on 2018/08/06.
//  Copyright © 2018 Munesada Yohei. All rights reserved.
//

import Foundation
import Alamofire

let apiRoot = "http://localhost:5000"

class ApiManager {
    
    static let shared = ApiManager()
    
    func login(loginId: String, password: String, callback: @escaping (([String: String]?) -> Void)) {
        
        let url = apiRoot + "/api/login"
        let headers: HTTPHeaders = [ "ContentType" : "application/json" ]
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
                    // APIトークンを保存しておく.
                    if let apiToken = data["api_token"] as? String {
                        UserDefaults.standard.set(apiToken, forKey: "apiToken")
                    }
                }
                callback(nil)
        }
        
    }
}
