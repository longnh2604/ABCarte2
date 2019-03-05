//
//  NotificationData.swift
//  ABCarte2
//
//  Created by Long on 2018/12/25.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers class NotificationData: Object {
    //Variable
    dynamic var id: Int = 0
    dynamic var content: String = ""
    dynamic var category_id: Int = 0
}
