//
//  CustomerData.swift
//  ABCarte2
//
//  Created by Long on 2018/05/09.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

@objcMembers class CustomerData: Object {
    //Variable
    dynamic var id: Int = 0
    dynamic var fc_account_id: Int = 0
    dynamic var fc_account_account_id: String = ""
    dynamic var first_name: String = ""
    dynamic var last_name: String = ""
    dynamic var first_name_kana: String = ""
    dynamic var last_name_kana: String = ""
    dynamic var gender: Int = 0
    dynamic var bloodtype : Int = 0
    dynamic var first_daycome: Int = 0
    dynamic var last_daycome: Int = 0
    dynamic var update_date : Int = 0
    dynamic var pic_url: String = ""
    dynamic var birthday: Int = 0
    dynamic var hobby: String = ""
    dynamic var email: String = ""
    dynamic var postal_code: String = ""
    dynamic var address1: String = ""
    dynamic var address2: String = ""
    dynamic var address3: String = ""
    dynamic var responsible: String = ""
    dynamic var mail_block: Int = 0
    dynamic var urgent_no: String = ""
    dynamic var memo1: String = ""
    dynamic var memo2: String = ""
    dynamic var created_at: Int = 0
    dynamic var updated_at: Int = 0
    dynamic var selected_status: Int = 0
    dynamic var thumb: String = ""
    dynamic var resize: String = ""
    dynamic var onSecret: Int = 0
    dynamic var document_1:String = ""
    dynamic var document_2:String = ""
    dynamic var document_consent:String = ""
    dynamic var customer_no:String = ""
}
