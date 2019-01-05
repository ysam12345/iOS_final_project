//
//  NotificationData.swift
//  iOS_final_project
//
//  Created by yochien on 2019/1/5.
//  Copyright © 2019 yochien. All rights reserved.
//

import Foundation

struct NotificationListData: Codable {
    struct NotificationData: Codable {
        struct Data: Codable {
            var lat: Float64
            var lon: Float64
            var radius: Int
            var time: String
        }
        var facebook_id: String
        var data: Data
    }
    var code: String
    var status: String
    var data: [NotificationData]
}
