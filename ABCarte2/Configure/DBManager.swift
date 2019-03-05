//
//  DBManager.swift
//  ABCarte2
//
//  Created by Long on 2018/08/02.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

//get the account data
func getAccountData(data:JSON, completion: (Bool) -> ()) {
    let newAccount = AccountData()
    newAccount.id = data["id"].intValue
    newAccount.acc_parent = data["acc_parent"].intValue
    newAccount.sub_acc = data["sub_acc"].stringValue
    newAccount.max_device = data["max_device"].intValue
    newAccount.group_group_id = data["group_group_id"].stringValue
    newAccount.group_id = data["group_id"].intValue
    newAccount.account_id = data["account_id"].stringValue
    newAccount.acc_memo_max = data["acc_memo_max"].intValue
    newAccount.acc_child = data["acc_child"].intValue
    newAccount.parent_sub_acc = data["parent_sub_acc"].stringValue
    newAccount.acc_free_memo_max = data["acc_free_memo_max"].intValue
    newAccount.secret_memo_password = data["secret_memo_password"].stringValue
    newAccount.acc_stamp_memo_max = data["acc_stamp_memo_max"].intValue
    newAccount.acc_name_kana = data["acc_name_kana"].stringValue
    newAccount.acc_disk_size = data["acc_disk_size"].stringValue
    newAccount.created_at = data["created_at"].intValue
    newAccount.acc_function = data["acc_function"].intValue
    newAccount.status = data["acc_function"].intValue
    newAccount.acc_name = data["acc_name"].stringValue
    newAccount.pic_limit = data["pic_limit"].intValue
    
    GlobalVariables.sharedManager.comName = data["acc_name"].stringValue
    
    newAccount.updated_at = data["updated_at"].intValue
    
    newAccount.acc_limit = data["acc_limit"].stringValue
    if data["acc_limit"].stringValue != "" {
        let arr = newAccount.acc_limit.components(separatedBy: ",")
        let intArray = arr.map { Int($0)!}
        GlobalVariables.sharedManager.appLimitation = intArray
    } else {
        GlobalVariables.sharedManager.appLimitation.removeAll()
    }
    
    newAccount.favorite_colors = data["favorite_colors"].stringValue
    if data["favorite_colors"].stringValue != "" {
        let arr = newAccount.favorite_colors.components(separatedBy: ",")
        GlobalVariables.sharedManager.accFavoriteColors = arr
    } else {
        GlobalVariables.sharedManager.accFavoriteColors.removeAll()
        //add color templates
        let colors = ["#ff0000","#ffbf00","#40ff00","#0080ff","#8000ff"]
        
        GlobalVariables.sharedManager.accFavoriteColors.append(contentsOf: colors)
    }
    
    RealmServices.shared.create(newAccount)
    
    let status : Bool?
    if data["status"].intValue == 10 {
        status = true
    } else {
        if (data["status"].null != nil) {
            status = true
        } else {
            status = false
        }
    }
    
    completion(status!)
}

//get the customer data
func getCustomerData(data:JSON) {
    let newCustomer = CustomerData()
    newCustomer.id = data["id"].intValue
    newCustomer.fc_account_id = data["fc_account_id"].intValue
    newCustomer.fc_account_account_id = data["fc_account_account_id"].stringValue
    newCustomer.first_name = data["first_name"].stringValue
    newCustomer.last_name = data["last_name"].stringValue
    newCustomer.first_name_kana = data["first_name_kana"].stringValue
    newCustomer.last_name_kana = data["last_name_kana"].stringValue
    newCustomer.gender = data["gender"].intValue
    newCustomer.bloodtype = data["bloodtype"].intValue
    newCustomer.customer_no = data["customer_no"].stringValue
    
//    #if DEBUG
    if data["pic_url"].stringValue == "" {
        newCustomer.pic_url = data["pic_url"].stringValue
        newCustomer.thumb = newCustomer.pic_url
    } else {
        newCustomer.pic_url = kAPI_URL_AWS + data["pic_url"].stringValue

        let linkPath = (data["pic_url"].stringValue as NSString).deletingLastPathComponent
        let lastPath = (data["pic_url"].stringValue as NSString).lastPathComponent

        newCustomer.thumb = kAPI_URL_AWS + "\(linkPath)/thumb_\(lastPath)"
    }
//    #else
//    if data["pic_url"].stringValue == "" {
//        newCustomer.pic_url = data["pic_url"].stringValue
//        newCustomer.thumb = newCustomer.pic_url
//    } else {
//        newCustomer.pic_url = kAPI_URL + data["pic_url"].stringValue
//
//        let linkPath = (data["pic_url"].stringValue as NSString).deletingLastPathComponent
//        let lastPath = (data["pic_url"].stringValue as NSString).lastPathComponent
//
//        newCustomer.thumb = kAPI_URL + "\(linkPath)/thumb_\(lastPath)"
//    }
//    #endif
    
    newCustomer.birthday = data["birthday"].intValue
    newCustomer.hobby = data["hobby"].stringValue
    newCustomer.email = data["email"].stringValue
    newCustomer.postal_code = data["postal_code"].stringValue
    newCustomer.address1 = data["address1"].stringValue
    newCustomer.address2 = data["address2"].stringValue
    newCustomer.address3 = data["address3"].stringValue
    newCustomer.responsible = data["responsible"].stringValue
    newCustomer.mail_block = data["mail_block"].intValue
    newCustomer.first_daycome = data["first_daycome"].intValue
    newCustomer.last_daycome = data["last_daycome"].intValue
    newCustomer.update_date = data["update_date"].intValue
    newCustomer.urgent_no = data["urgent_no"].stringValue
    newCustomer.memo1 = data["memo1"].stringValue
    newCustomer.memo2 = data["memo2"].stringValue
    newCustomer.created_at = data["created_at"].intValue
    newCustomer.updated_at = data["updated_at"].intValue
    newCustomer.selected_status = 0
    
//    #if DEBUG
//    if data["document_1"].stringValue != "" {
//        newCustomer.document_1 = kAPI_URL_AWS + data["document_1"].stringValue
//    }
//    if data["document_2"].stringValue != "" {
//        newCustomer.document_2 = kAPI_URL_AWS + data["document_2"].stringValue
//    }
//    if data["document_consent"].stringValue != "" {
//        newCustomer.document_consent = kAPI_URL_AWS + data["document_consent"].stringValue
//    }
//    #else
//    if data["document_1"].stringValue != "" {
//        newCustomer.document_1 = kAPI_URL + data["document_1"].stringValue
//    }
//    if data["document_2"].stringValue != "" {
//        newCustomer.document_2 = kAPI_URL + data["document_2"].stringValue
//    }
//    if data["document_consent"].stringValue != "" {
//        newCustomer.document_consent = kAPI_URL + data["document_consent"].stringValue
//    }
//    #endif
    
    if data["fcSecretMemos"].count > 0 {
        newCustomer.onSecret = 1
    } else {
        newCustomer.onSecret = 0
    }
    RealmServices.shared.create(newCustomer)
}

//Get cus data and return
func getACustomerData(data:JSON)->CustomerData {
    let newCustomer = CustomerData()
    newCustomer.id = data["id"].intValue
    newCustomer.fc_account_id = data["fc_account_id"].intValue
    newCustomer.fc_account_account_id = data["fc_account_account_id"].stringValue
    newCustomer.first_name = data["first_name"].stringValue
    newCustomer.last_name = data["last_name"].stringValue
    newCustomer.first_name_kana = data["first_name_kana"].stringValue
    newCustomer.last_name_kana = data["last_name_kana"].stringValue
    newCustomer.gender = data["gender"].intValue
    newCustomer.bloodtype = data["bloodtype"].intValue
    newCustomer.customer_no = data["customer_no"].stringValue
    
//    #if DEBUG
    if data["pic_url"].stringValue == "" {
        newCustomer.pic_url = data["pic_url"].stringValue
        newCustomer.thumb = newCustomer.pic_url
    } else {
        newCustomer.pic_url = kAPI_URL_AWS + data["pic_url"].stringValue

        let linkPath = (data["pic_url"].stringValue as NSString).deletingLastPathComponent
        let lastPath = (data["pic_url"].stringValue as NSString).lastPathComponent

        newCustomer.thumb = kAPI_URL_AWS + "\(linkPath)/thumb_\(lastPath)"

    }
//    #else
//    if data["pic_url"].stringValue == "" {
//        newCustomer.pic_url = data["pic_url"].stringValue
//        newCustomer.thumb = newCustomer.pic_url
//    } else {
//        newCustomer.pic_url = kAPI_URL + data["pic_url"].stringValue
//
//        let linkPath = (data["pic_url"].stringValue as NSString).deletingLastPathComponent
//        let lastPath = (data["pic_url"].stringValue as NSString).lastPathComponent
//
//        newCustomer.thumb = kAPI_URL + "\(linkPath)/thumb_\(lastPath)"
//    }
//    #endif
    
    newCustomer.birthday = data["birthday"].intValue
    newCustomer.hobby = data["hobby"].stringValue
    newCustomer.email = data["email"].stringValue
    newCustomer.postal_code = data["postal_code"].stringValue
    newCustomer.address1 = data["address1"].stringValue
    newCustomer.address2 = data["address2"].stringValue
    newCustomer.address3 = data["address3"].stringValue
    newCustomer.responsible = data["responsible"].stringValue
    newCustomer.mail_block = data["mail_block"].intValue
    newCustomer.first_daycome = data["first_daycome"].intValue
    newCustomer.last_daycome = data["last_daycome"].intValue
    newCustomer.update_date = data["update_date"].intValue
    newCustomer.urgent_no = data["urgent_no"].stringValue
    newCustomer.memo1 = data["memo1"].stringValue
    newCustomer.memo2 = data["memo2"].stringValue
    newCustomer.created_at = data["created_at"].intValue
    newCustomer.updated_at = data["updated_at"].intValue
    
//    #if DEBUG
    if data["document_1"].stringValue != "" {
        newCustomer.document_1 = kAPI_URL_AWS + data["document_1"].stringValue
    }
    if data["document_2"].stringValue != "" {
        newCustomer.document_2 = kAPI_URL_AWS + data["document_2"].stringValue
    }
    if data["document_consent"].stringValue != "" {
        newCustomer.document_consent = kAPI_URL_AWS + data["document_consent"].stringValue
    }
//    #else
//    if data["document_1"].stringValue != "" {
//        newCustomer.document_1 = kAPI_URL + data["document_1"].stringValue
//    }
//    if data["document_2"].stringValue != "" {
//        newCustomer.document_2 = kAPI_URL + data["document_2"].stringValue
//    }
//    if data["document_consent"].stringValue != "" {
//        newCustomer.document_consent = kAPI_URL + data["document_consent"].stringValue
//    }
//    #endif
    
    if data["fcSecretMemos"].count > 0 {
        newCustomer.onSecret = 1
    } else {
        newCustomer.onSecret = 0
    }
    
    return newCustomer
}

//get the customer cartes
func getCartesDataWithCustomer(data:JSON) {
    let newCarte = CarteData()
    newCarte.id = data["id"].intValue
    newCarte.carte_id = data["carte_id"].stringValue
    newCarte.fc_customer_id = data["fc_customer_id"].intValue
    newCarte.fc_customer_customer_id = data["fc_customer_customer_id"].stringValue
    newCarte.create_date = data["create_date"].intValue
    newCarte.select_date = data["select_date"].intValue
    
    if data["carte_photo"].stringValue.isEmpty {
        newCarte.carte_photo = data["carte_photo"].stringValue
    } else {
        if data["carte_photo"].stringValue.contains("160.16.137.252") {
            newCarte.carte_photo = data["carte_photo"].stringValue
        } else {
            newCarte.carte_photo = kAPI_URL_AWS + data["carte_photo"].stringValue
        }
    }
    
    newCarte.status = data["status"].intValue
    newCarte.selected_status = 0
    
    let dayCome = convertUnixTimestampUK(time: data["select_date"].intValue)
    newCarte.date_converted = dayCome
    
    if data["fcCustomer"].count > 0 {
        let cus = data["fcCustomer"]
        let newCus = CustomerData()
        newCus.id = cus["id"].intValue
        newCus.first_name = cus["first_name"].stringValue
        newCus.first_name_kana = cus["first_name_kana"].stringValue
        newCus.last_name = cus["last_name"].stringValue
        newCus.last_name_kana = cus["last_name_kana"].stringValue
        newCus.gender = cus["gender"].intValue
        newCus.urgent_no = cus["urgent_no"].stringValue
       
//        #if DEBUG
        if cus["pic_url"].stringValue == "" {
            newCus.pic_url = cus["pic_url"].stringValue
            newCus.thumb = newCus.pic_url
        } else {
            newCus.pic_url = kAPI_URL_AWS + cus["pic_url"].stringValue

            let linkPath = (cus["pic_url"].stringValue as NSString).deletingLastPathComponent
            let lastPath = (cus["pic_url"].stringValue as NSString).lastPathComponent

            newCus.thumb = kAPI_URL_AWS + "\(linkPath)/thumb_\(lastPath)"
        }
//        #else
//        if cus["pic_url"].stringValue == "" {
//            newCus.pic_url = cus["pic_url"].stringValue
//            newCus.thumb = newCus.pic_url
//        } else {
//            newCus.pic_url = kAPI_URL + cus["pic_url"].stringValue
//
//            let linkPath = (cus["pic_url"].stringValue as NSString).deletingLastPathComponent
//            let lastPath = (cus["pic_url"].stringValue as NSString).lastPathComponent
//
//            newCus.thumb = kAPI_URL + "\(linkPath)/thumb_\(lastPath)"
//        }
//        #endif
        
        newCarte.cus.append(newCus)
    }
    
    RealmServices.shared.create(newCarte)
}

//get the customer cartes included memo
func getCartesDataWithMemo(data:JSON) {
    let newCarte = CarteData()
    newCarte.id = data["id"].intValue
    newCarte.carte_id = data["carte_id"].stringValue
    newCarte.fc_customer_id = data["fc_customer_id"].intValue
    newCarte.fc_customer_customer_id = data["fc_customer_customer_id"].stringValue
    newCarte.create_date = data["create_date"].intValue
    newCarte.select_date = data["select_date"].intValue
    
    if data["carte_photo"].stringValue.isEmpty {
        newCarte.carte_photo = data["carte_photo"].stringValue
    } else {
        if data["carte_photo"].stringValue.contains("160.16.137.252") {
            newCarte.carte_photo = data["carte_photo"].stringValue
        } else {
            newCarte.carte_photo = kAPI_URL_AWS + data["carte_photo"].stringValue
        }
    }
    
    newCarte.status = data["status"].intValue
    newCarte.selected_status = 0
    
    if data["fcFreeMemos"].count > 0 {
        let memos = data["fcFreeMemos"]
        for i in 0 ..< memos.count {
            let newMemo = FreeMemoData()
            newMemo.id = memos[i]["id"].intValue
            newMemo.memo_id = memos[i]["memo_id"].stringValue
            newMemo.fc_customer_carte_id = memos[i]["fc_customer_carte_id"].intValue
            newMemo.fc_customer_carte_carte_id = memos[i]["fc_customer_carte_carte_id"].stringValue
            newMemo.title = memos[i]["title"].stringValue
            newMemo.position = memos[i]["position"].intValue
            newMemo.content = memos[i]["content"].stringValue
            newMemo.date = memos[i]["date"].intValue
            newMemo.type = memos[i]["type"].intValue
            newMemo.fc_customer_id = memos[i]["fc_customer_id"].intValue
            newMemo.fc_account_id = memos[i]["fc_account_id"].intValue
            newMemo.status = memos[i]["status"].intValue
            newMemo.created_at = memos[i]["created_at"].intValue
            newMemo.updated_at = memos[i]["updated_at"].intValue
            
            newCarte.free_memo.append(newMemo)
        }
    }
    
    if data["fcStampMemos"].count > 0 {
        let memos = data["fcStampMemos"]
        for i in 0 ..< memos.count {
            let newMemo = StampMemoData()
            newMemo.id = memos[i]["id"].intValue
            newMemo.memo_id = memos[i]["memo_id"].stringValue
            newMemo.fc_customer_carte_id = memos[i]["fc_customer_carte_id"].intValue
            newMemo.fc_customer_carte_carte_id = memos[i]["fc_customer_carte_carte_id"].stringValue
            newMemo.title = memos[i]["title"].stringValue
            newMemo.position = memos[i]["position"].intValue
            newMemo.content = memos[i]["content"].stringValue
            newMemo.date = memos[i]["date"].intValue
            newMemo.type = memos[i]["type"].intValue
            newMemo.fc_customer_id = memos[i]["fc_customer_id"].intValue
            newMemo.fc_account_id = memos[i]["fc_account_id"].intValue
            newMemo.status = memos[i]["status"].intValue
            newMemo.created_at = memos[i]["created_at"].intValue
            newMemo.updated_at = memos[i]["updated_at"].intValue
            
            newCarte.stamp_memo.append(newMemo)
        }
    }
    
    if data["fcUserMedia"].count > 0 {
        let media = data["fcUserMedia"]
        for i in 0 ..< media.count {
            let newMedia = MediaData()
            newMedia.id = media[i]["id"].intValue
            newMedia.media_id = media[i]["media_id"].stringValue
            newMedia.fc_customer_carte_id = media[i]["fc_customer_carte_id"].intValue
            newMedia.fc_customer_carte_carte_id = media[i]["fc_customer_carte_carte_id"].stringValue
            newMedia.date = media[i]["date"].intValue
            
//            #if DEBUG
            if media[i]["url"].stringValue == "" {
                newMedia.url = media[i]["url"].stringValue
                newMedia.thumb = newMedia.url
            } else {
                newMedia.url = kAPI_URL_AWS + media[i]["url"].stringValue

                let linkPath = (media[i]["url"].stringValue as NSString).deletingLastPathComponent
                let lastPath = (media[i]["url"].stringValue as NSString).lastPathComponent

                newMedia.thumb = kAPI_URL_AWS + "\(linkPath)/thumb_\(lastPath)"
            }
//            #else
//            if media[i]["url"].stringValue == "" {
//                newMedia.url = media[i]["url"].stringValue
//                newMedia.thumb = newMedia.url
//            } else {
//                newMedia.url = kAPI_URL + media[i]["url"].stringValue
//
//                let linkPath = (media[i]["url"].stringValue as NSString).deletingLastPathComponent
//                let lastPath = (media[i]["url"].stringValue as NSString).lastPathComponent
//
//                newMedia.thumb = kAPI_URL + "\(linkPath)/thumb_\(lastPath)"
//            }
//            #endif
            
            newMedia.title = media[i]["title"].stringValue
            newMedia.comment = media[i]["comment"].stringValue
            newMedia.tag = media[i]["tag"].stringValue
            newMedia.type = media[i]["type"].intValue
            newMedia.status = media[i]["status"].intValue
            newMedia.created_at = media[i]["created_at"].intValue
            newMedia.updated_at = media[i]["updated_at"].intValue
            newMedia.fc_account_id = media[i]["fc_account_id"].intValue
            
            newCarte.medias.append(newMedia)
        }
    }
    
    RealmServices.shared.create(newCarte)
}

//get the carte medias data
func getMediasDataCus(data:JSON,date:String) {
    let newThumb = ThumbData()
    newThumb.date = date

    for i in 0 ..< data.count {
        let newMedia = MediaData()
        newMedia.id = data[i]["id"].intValue
        newMedia.fc_customer_carte_id = data[i]["fc_customer_carte_id"].intValue
        newMedia.type = data[i]["type"].intValue
        newMedia.comment = data[i]["comment"].stringValue
        newMedia.tag = data[i]["tag"].stringValue
        newMedia.title = data[i]["title"].stringValue
        newMedia.updated_at = data[i]["updated_at"].intValue
        newMedia.status = data[i]["status"].intValue
        newMedia.created_at = data[i]["created_at"].intValue
        
//        #if DEBUG
        if data[i]["url"].stringValue == "" {
            newMedia.url = data[i]["url"].stringValue
            newMedia.thumb = newMedia.url
        } else {
            newMedia.url = kAPI_URL_AWS + data[i]["url"].stringValue

            let linkPath = (data[i]["url"].stringValue as NSString).deletingLastPathComponent
            let lastPath = (data[i]["url"].stringValue as NSString).lastPathComponent

            newMedia.thumb = kAPI_URL_AWS + "\(linkPath)/thumb_\(lastPath)"
        }
//        #else
//        if data[i]["url"].stringValue == "" {
//            newMedia.url = data[i]["url"].stringValue
//            newMedia.thumb = newMedia.url
//        } else {
//            newMedia.url = kAPI_URL + data[i]["url"].stringValue
//
//            let linkPath = (data[i]["url"].stringValue as NSString).deletingLastPathComponent
//            let lastPath = (data[i]["url"].stringValue as NSString).lastPathComponent
//
//            newMedia.thumb = kAPI_URL + "\(linkPath)/thumb_\(lastPath)"
//        }
//        #endif
        
        newMedia.media_id = data[i]["media_id"].stringValue
        newMedia.fc_customer_carte_carte_id = data[i]["fc_customer_carte_carte_id"].stringValue
        newMedia.date = data[i]["date"].intValue
        
        newThumb.medias.append(newMedia)
    }
    
    RealmServices.shared.create(newThumb)
}

//get the carte medias data
func getMediasData(data:JSON) {
    
    let newMedia = MediaData()

    newMedia.id = data["id"].intValue
    newMedia.media_id = data["media_id"].stringValue
    newMedia.fc_customer_carte_id = data["fc_customer_carte_id"].intValue
    newMedia.fc_customer_carte_carte_id = data["fc_customer_carte_carte_id"].stringValue
    newMedia.date = data["date"].intValue
    
//    #if DEBUG
    if data["url"].stringValue == "" {
        newMedia.url = data["url"].stringValue
        newMedia.thumb = newMedia.url
    } else {
        newMedia.url = kAPI_URL_AWS + data["url"].stringValue

        let linkPath = (data["url"].stringValue as NSString).deletingLastPathComponent
        let lastPath = (data["url"].stringValue as NSString).lastPathComponent

        newMedia.thumb = kAPI_URL_AWS + "\(linkPath)/thumb_\(lastPath)"
    }
//    #else
//    if data["url"].stringValue == "" {
//        newMedia.url = data["url"].stringValue
//        newMedia.thumb = newMedia.url
//    } else {
//        newMedia.url = kAPI_URL + data["url"].stringValue
//
//        let linkPath = (data["url"].stringValue as NSString).deletingLastPathComponent
//        let lastPath = (data["url"].stringValue as NSString).lastPathComponent
//        
//        newMedia.thumb = kAPI_URL + "\(linkPath)/thumb_\(lastPath)"
//    }
//    #endif

    newMedia.title = data["title"].stringValue
    newMedia.comment = data["comment"].stringValue
    newMedia.tag = data["tag"].stringValue
    newMedia.type = data["type"].intValue
    newMedia.status = data["status"].intValue
    newMedia.created_at = data["created_at"].intValue
    newMedia.updated_at = data["updated_at"].intValue
    newMedia.fc_account_id = data["fc_account_id"].intValue
    
    RealmServices.shared.create(newMedia)
}

//get the carte memos data
func getMemosData(data:JSON) {
    
    let newMemo = MemoData()
    let fcMemo = data["fcUserMemos"]
    
    newMemo.id = fcMemo["id"].intValue
    newMemo.status = fcMemo["status"].intValue
    newMemo.content = fcMemo["content"].stringValue
    newMemo.title = fcMemo["title"].stringValue
    newMemo.created_at = fcMemo["created_at"].intValue
    newMemo.updated_at = fcMemo["updated_at"].intValue
    newMemo.date = fcMemo["date"].intValue
    newMemo.fc_customer_carte_carte_id = fcMemo["fc_customer_carte_carte_id"].intValue
    newMemo.type = fcMemo["type"].intValue
    newMemo.fc_account_id = fcMemo["fc_account_id"].intValue
    newMemo.memo_id = fcMemo["memo_id"].stringValue
    newMemo.position = fcMemo["position"].intValue
    newMemo.fc_customer_carte_id = fcMemo["fc_customer_carte_id"].intValue
    newMemo.fc_customer_id = fcMemo["fc_customer_id"].intValue
    
    RealmServices.shared.create(newMemo)
}

//get the carte free memos data
func getFreeMemosData(data:JSON) {
    
    let newMemo = FreeMemoData()
    
    newMemo.id = data["id"].intValue
    newMemo.memo_id = data["memo_id"].stringValue
    newMemo.fc_customer_carte_id = data["fc_customer_carte_id"].intValue
    newMemo.fc_customer_carte_carte_id = data["fc_customer_carte_carte_id"].stringValue
    newMemo.title = data["title"].stringValue
    newMemo.position = data["position"].intValue
    newMemo.content = data["content"].stringValue
    newMemo.date = data["date"].intValue
    newMemo.type = data["type"].intValue
    newMemo.fc_customer_id = data["fc_customer_id"].intValue
    newMemo.fc_account_id = data["fc_account_id"].intValue
    newMemo.status = data["status"].intValue
    newMemo.created_at = data["created_at"].intValue
    newMemo.updated_at = data["updated_at"].intValue
    
    RealmServices.shared.create(newMemo)
}

//get the carte stamp memos data
func getStampMemosData(data:JSON) {
    
    let newMemo = StampMemoData()
    
    newMemo.id = data["id"].intValue
    newMemo.memo_id = data["memo_id"].stringValue
    newMemo.fc_customer_carte_id = data["fc_customer_carte_id"].intValue
    newMemo.fc_customer_carte_carte_id = data["fc_customer_carte_carte_id"].stringValue
    newMemo.title = data["title"].stringValue
    newMemo.position = data["position"].intValue
    newMemo.content = data["content"].stringValue
    newMemo.date = data["date"].intValue
    newMemo.type = data["type"].intValue
    newMemo.fc_customer_id = data["fc_customer_id"].intValue
    newMemo.fc_account_id = data["fc_account_id"].intValue
    newMemo.status = data["status"].intValue
    newMemo.created_at = data["created_at"].intValue
    newMemo.updated_at = data["updated_at"].intValue
    
    RealmServices.shared.create(newMemo)
}

//get the stamp category data
func getStampCategoryData(data:JSON) {
    let newStampCate = StampCategoryData()
    newStampCate.id = data["id"].intValue
    newStampCate.title = data["title"].stringValue
    newStampCate.fc_account_id = data["fc_account_id"].intValue
    newStampCate.status = data["status"].intValue
    newStampCate.created_at = data["created_at"].intValue
    newStampCate.updated_at = data["updated_at"].intValue
    
    RealmServices.shared.create(newStampCate)
}

//get the stamp data
func getStampKeyword(data:JSON) {
    let newKey = StampKeywordData()
    newKey.id = data["id"].intValue
    newKey.content = data["content"].stringValue
    newKey.category_id = data["category_id"].intValue
    RealmServices.shared.create(newKey)
}

//get the stamp data
func getStampContent(data:JSON) {
    let newContent = StampContentData()
    newContent.id = data["id"].intValue
    newContent.content = data["content"].stringValue
    newContent.category_id = data["category_id"].intValue
    RealmServices.shared.create(newContent)
}

//get the secret memo data
func getSecretMemoData(data:JSON) {
    let newSecret = SecretMemoData()
    newSecret.id = data["id"].intValue
    newSecret.secret_id = data["secret_id"].stringValue
    newSecret.fc_customer_id = data["fc_customer_id"].intValue
    newSecret.fc_customer_customer_id = data["fc_customer_customer_id"].stringValue
    newSecret.date = data["date"].intValue
    newSecret.content = data["content"].stringValue
    newSecret.status = data["status"].intValue
    newSecret.created_at = data["created_at"].intValue
    newSecret.updated_at = data["updated_at"].intValue
    newSecret.fc_account_id = data["fc_account_id"].intValue
    
    RealmServices.shared.create(newSecret)
}

//get the document template
func getDocumentsData(data:JSON) {
    let newDoc = DocumentData()
    newDoc.id = data["id"].intValue
    newDoc.type = data["type"].intValue
    newDoc.sub_type = data["sub_type"].intValue
    newDoc.title = data["title"].stringValue
    newDoc.fc_account_id = data["fc_account_id"].intValue
    newDoc.fc_customer_carte_id = data["fc_customer_carte_id"].intValue
    newDoc.status = data["status"].intValue
    newDoc.created_at = data["created_at"].intValue
    newDoc.updated_at = data["updated_at"].intValue
    newDoc.is_template = data["is_template"].intValue
    
    if data["fcDocumentPages"].count > 0 {
        let page = data["fcDocumentPages"]
        
        for i in 0 ..< page.count {
            let newPage = DocumentPageData()
            newPage.id = page[i]["id"].intValue
            newPage.fc_document_id = page[i]["fc_document_id"].intValue
            newPage.page = page[i]["page"].intValue
            
            if page[i]["url_edit"].stringValue != "" {
                newPage.url_edit = kAPI_URL_AWS + page[i]["url_edit"].stringValue
            }
            
            if page[i]["url_original"].stringValue != "" {
                newPage.url_original = kAPI_URL_AWS + page[i]["url_original"].stringValue
            }
            
            newPage.fc_account_id = page[i]["fc_account_id"].intValue
            newPage.status = page[i]["status"].intValue
            newPage.created_at = page[i]["created_at"].intValue
            newPage.updated_at = page[i]["updated_at"].intValue
            newPage.is_edited = page[i]["is_edited"].intValue
            
            newDoc.document_pages.append(newPage)
        }
    }
    
    RealmServices.shared.create(newDoc)
}
