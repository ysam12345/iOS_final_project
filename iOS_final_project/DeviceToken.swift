//
//  DeviceToken.swift
//  iOS_final_project
//
//  Created by yochien on 2019/1/9.
//  Copyright © 2019 yochien. All rights reserved.
//

import Foundation

struct DeviceToken: Codable {
    var token: String
    
    static func read() -> DeviceToken? {
        if let data = UserDefaults.standard.data(forKey: "deviceToken"), let deviceToken = try? PropertyListDecoder().decode(DeviceToken.self, from: data) {
            return deviceToken
        } else {
            return nil
        }
    }
    
    static func save(deviceToken: DeviceToken) {
        let encoder = PropertyListEncoder()
        if let data = try? encoder.encode(deviceToken) {
            UserDefaults.standard.set(data, forKey: "deviceToken")
            
        }
    }
}
