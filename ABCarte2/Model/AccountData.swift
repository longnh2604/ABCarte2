//
//  AccountData.swift
//  ABCarte2
//
//  Created by Long on 2018/05/09.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

@objcMembers class AccountData: Object {
    //Variable
    dynamic var id: Int = 0
    dynamic var sub_acc: String = ""
    dynamic var max_device: Int = 0
    dynamic var group_group_id: String = ""
    dynamic var group_id: Int = 0
    dynamic var account_id: String = ""
    dynamic var acc_memo_max: Int = 0
    dynamic var acc_parent: Int = 0
    dynamic var acc_child: Int = 0
    dynamic var parent_sub_acc: String = ""
    dynamic var secret_memo_password: String = ""
    dynamic var acc_free_memo_max: Int = 0
    dynamic var acc_stamp_memo_max: Int = 0
    dynamic var acc_name_kana: String = ""
    dynamic var acc_disk_size: String = ""
    dynamic var favorite_colors: String = ""
    dynamic var created_at: Int = 0
    dynamic var acc_function: Int = 0
    dynamic var status: Int = 0
    dynamic var acc_name: String = ""
    dynamic var acc_limit: String = ""
    dynamic var updated_at: Int = 0
}


