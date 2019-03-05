//
//  CarteData.swift
//  ABCarte2
//
//  Created by Long on 2018/05/09.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

@objcMembers class CarteData: Object {
    
    //Variable
    dynamic var id: Int = 0
    dynamic var carte_id: String = ""
    dynamic var fc_customer_id: Int = 0
    dynamic var fc_customer_customer_id: String = ""
    dynamic var create_date: Int = 0
    dynamic var select_date: Int = 0
    dynamic var carte_photo: String = ""
    dynamic var status: Int = 0
    dynamic var selected_status : Int = 0
    dynamic var date_converted: String = ""
    
    dynamic var free_memo = List<FreeMemoData>()
    dynamic var stamp_memo = List<StampMemoData>()
    dynamic var medias = List<MediaData>()
    dynamic var cus = List<CustomerData>()
}
