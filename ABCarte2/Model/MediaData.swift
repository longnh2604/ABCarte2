//
//  MediaData.swift
//  ABCarte2
//
//  Created by Long on 2018/05/16.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

@objcMembers class MediaData: Object {
    
    //Variable
    dynamic var id: Int = 0
    dynamic var media_id: String = ""
    dynamic var fc_customer_carte_id: Int = 0
    dynamic var fc_customer_carte_carte_id: String = ""
    dynamic var date: Int = 0
    dynamic var url: String = ""
    dynamic var title: String = ""
    dynamic var comment: String = ""
    dynamic var tag: String = ""
    dynamic var type: Int = 0
    dynamic var status: Int = 0
    dynamic var created_at: Int = 0
    dynamic var updated_at: Int = 0
    dynamic var fc_account_id: Int = 0
    dynamic var selected_status : Int = 0
    dynamic var thumb: String = ""
    dynamic var resize: String = ""
    
    //init
//    convenience init(id: Int, media_id: String, fc_customer_carte_id: Int, fc_customer_carte_carte_id: String, date: Int, url: String, title: String, comment: String,tag:String,type:Int,status:Int,created_at:Int,updated_at:Int,fc_account_id:Int ) {
//        self.init()
//        self.id = id
//        self.media_id = media_id
//        self.fc_customer_carte_id = fc_customer_carte_id
//        self.fc_customer_carte_carte_id = fc_customer_carte_carte_id
//        self.date = date
//        self.url = url
//        self.title = title
//        self.comment = comment
//        self.tag = tag
//        self.type = type
//        self.status = status
//        self.created_at = created_at
//        self.updated_at = updated_at
//        self.fc_account_id = fc_account_id
//    }
}
