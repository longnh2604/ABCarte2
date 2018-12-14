//
//  StampContentData.swift
//  ABCarte2
//
//  Created by Long on 2018/10/11.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

@objcMembers class StampContentData: Object {
    //Variable
    dynamic var id: Int = 0
    dynamic var content: String = ""
    dynamic var category_id: Int = 0
}
