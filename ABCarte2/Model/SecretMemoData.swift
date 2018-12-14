//
//  SecretMemoData.swift
//  ABCarte2
//
//  Created by Long on 2018/08/30.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers class SecretMemoData: Object {
    //Variable
    dynamic var id: Int = 0
    dynamic var secret_id: String = ""
    dynamic var fc_customer_id: Int = 0
    dynamic var fc_customer_customer_id: String = ""
    dynamic var date: Int = 0
    dynamic var content: String = ""
    dynamic var status: Int = 0
    dynamic var created_at: Int = 0
    dynamic var updated_at: Int = 0
    dynamic var fc_account_id: Int = 0
}
