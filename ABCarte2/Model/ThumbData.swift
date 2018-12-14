//
//  ThumbData.swift
//  ABCarte2
//
//  Created by Long on 2018/09/28.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

@objcMembers class ThumbData: Object {
    
    //Variable
    dynamic var date: String = ""
    
    var medias = List<MediaData>()
}
