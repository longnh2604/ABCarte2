//
//  StampData.swift
//  ABCarte2
//
//  Created by Long on 2018/08/29.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers class StampData: Object {
    //Variable
    dynamic var id: Int = 0
    dynamic var content: String = ""
    dynamic var category: Int = 0
    dynamic var type: Int = 0
    dynamic var category_name: String = ""

}
