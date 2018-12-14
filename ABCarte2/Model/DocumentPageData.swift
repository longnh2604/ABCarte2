//
//  DocumentPageData.swift
//  ABCarte2
//
//  Created by Long on 2018/11/21.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

@objcMembers class DocumentPageData: Object {
    //Variable
    dynamic var id: Int = 0
    dynamic var fc_document_id: Int = 0
    dynamic var page: Int = 0
    dynamic var url_edit: String = ""
    dynamic var url_original: String = ""
    dynamic var fc_account_id: Int = 0
    dynamic var status: Int = 0
    dynamic var is_edited: Int = 0
    dynamic var created_at: Int = 0
    dynamic var updated_at: Int = 0
}
