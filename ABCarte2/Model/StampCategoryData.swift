//
//  StampCategoryData.swift
//  ABCarte2
//
//  Created by Long on 2018/10/02.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers class StampCategoryData: Object {
    //Variable
    dynamic var id: Int = 0
    dynamic var title: String = ""
    dynamic var fc_account_id: Int = 0
    dynamic var status: Int = 0
    dynamic var created_at: Int = 0
    dynamic var updated_at: Int = 0
}
