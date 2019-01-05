//
//  UserData.swift
//  iOS_final_project
//
//  Created by yochien on 2019/1/4.
//  Copyright © 2019 yochien. All rights reserved.
//

import Foundation

struct UserData: Codable {
    var name: String
    var email: String
    var facebookID: String
    var pictureUrl: String
    var facebookAccessToken: String
    
    static func read() -> UserData? {
        if let data = UserDefaults.standard.data(forKey: "userData"), let userData = try? PropertyListDecoder().decode(UserData.self, from: data) {
            return userData
        } else {
            return nil
        }
    }
    
    static func save(userData: UserData) {
        let encoder = PropertyListEncoder()
        if let data = try? encoder.encode(userData) {
            UserDefaults.standard.set(data, forKey: "userData")
            
        }
    }
}
