//
//  APIRequest.swift
//  ABCarte2
//
//  Created by Long on 2018/08/02.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift

//alias
typealias StringCompletion = (_ success: Bool, _ string: String) -> Void
typealias ArrayCompletion = (_ success: Bool, _ arrData: JSON) -> Void

//*****************************************************************
// MARK: - Authentication
//*****************************************************************

//Authentication by QR Code (get Acc Name)
func QRauthenticateServer(accID:String,completion: @escaping StringCompletion) {
  
    let headers = [
        "Content-Type": "application/x-www-form-urlencoded"
    ]
    let parameters = [
        "account_id": accID
    ]
    
    let url = kAPI_URL + kAPI_TOKEN + "?qr=true"
    
    Alamofire.request(url, method: .post, parameters: parameters, encoding:  URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        switch(response.result) {
            
        case.success(let data):
            let json = JSON(data)
            
            let msg = json["message"]
            
            if msg.stringValue == "account_id not found" {
                completion(false,"ユーザー名がありません。")
                return
            }
            
            let accN = json["acc_name"].stringValue
            GlobalVariables.sharedManager.comName = accN
            
            completion(true,accN)
            
        case.failure(let error):
            print(error)
            completion(false,"ログインに失敗しました。ネットワークの状態を確認してください。")
        }
    }
}

//Normally Authentication
func authenticateServer(accID:String,accPassword:String,appVer:String,iOSVer:String,completion: @escaping StringCompletion) {
    //get uuid
    let uuid: String = (UIDevice.current.identifierForVendor?.uuidString)!
    //store or get the key from keychain
    if let receivedData = KeyChain.load(key: "MyNumber") {
        let result = receivedData.to(type: Int.self)
        print("result: ", result)
    } else {
        let data = Data(from: uuid)
        let status = KeyChain.save(key: "MyNumber", data: data)
        print("status: ", status)
    }
    
    guard let result = KeyChain.load(key: "MyNumber")?.to(type: Int.self) else {
        return
    }
    
    let headers = [
        "Content-Type": "application/x-www-form-urlencoded"
    ]
    
    let parameters = [
        "account_id": accID,
        "acc_password": accPassword,
        "mac_address": String(result),
        "app_ver":appVer,
        "os_ver":iOSVer
    ]
    let url = kAPI_URL + kAPI_TOKEN
    
    Alamofire.request(url, method: .post, parameters: parameters, encoding:  URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        switch(response.result) {

        case.success(let data):
            let json = JSON(data)

            let msg = json["message"]
            
            if msg.stringValue == "No license for this device" {
                completion(false,"使用できるライセンスがいっぱいです。これ以上の端末ではログインできません。")
                return
            }
            
            for i in 0 ..< msg.count {
                if msg[i].stringValue == "No license for this device" {
                    completion(false,"使用できるライセンスがいっぱいです。これ以上の端末ではログインできません。")
                    return
                }
            }
            
            let msgAccID = json["account_id"]
            
            for i in 0 ..< msgAccID.count {
                if msgAccID[i].stringValue == "Account Id cannot be blank." {
                    completion(false,"ユーザー名またはパスワードが空白です")
                    return
                }
            }
            
            let msgAccPass = json["acc_password"]
            
            for i in 0 ..< msgAccPass.count {
                if msgAccPass[i].stringValue == "Acc Password cannot be blank." {
                    completion(false,"ユーザー名またはパスワードが空白です")
                    return
                }
                
                if msgAccPass[i].stringValue == "Incorrect username or password." {
                    completion(false,"ユーザー名またはパスワードが違います")
                    return
                }
            }
            
            let realm = try! Realm()
            try! realm.write {
                realm.delete(realm.objects(AccountData.self))
            }
            
            //Save to UserDefaults
            let tok = json["access_token"].stringValue
            let deviceID = json["mac_address"].stringValue
            
            UserDefaults.standard.set(tok, forKey: "token")
            UserDefaults.standard.set(deviceID, forKey: "mac_address")
            UserDefaults.standard.set(accID, forKey: "collectu-usr")
            UserDefaults.standard.set(accPassword, forKey: "collectu-pwd")
            UserDefaults.standard.set("logined", forKey: "collectu-status")
            
            //save user info to Fabric
            let name = json["fc_account_acount_id"].stringValue
            let id = json["id"].intValue
            
            logUserInfo(userName: name, userID: String(id))
            
            getAccountInfo(completion: { (success) in
                if success {
                    completion(true,"")
                } else {
                    completion(false,"ログインに失敗しました。ネットワークの状態を確認してください。")
                }
            })
        case.failure(let error):
            print(error)
            completion(false,"ログインに失敗しました。ネットワークの状態を確認してください。")
        }
    }
}

//delete device
func onEraseDeviceToken(userName:String,userPass:String,deviceID:String,token:String,completion: @escaping StringCompletion) {
    
    let url = kAPI_URL + kAPI_ACC + "/token-set-expired"

    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear,"Content-Type": "application/x-www-form-urlencoded"]

    let parameters = [
        "account_id": userName,
        "acc_password": userPass,
        "mac_address": deviceID,
        "token": token
    ]

    Alamofire.request(url, method: .post, parameters: parameters, encoding:  URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        switch(response.result) {

        case.success(let data):
            let json = JSON(data)
            
            if json.intValue == 1 {
                completion(true,"Complete")
            } else {
                completion(false,kALERT_WRONG_PASSWORD)
            }

        case.failure(let error):
            print(error)
            completion(false,kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN)
        }
    }
}

//*****************************************************************
// MARK: - Account
//*****************************************************************

//Update Account Secret Memo Pass
func getAccountInfo(completion:@escaping(Bool) -> ()) {
    
    let url = kAPI_URL + kAPI_ACC
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        switch(response.result) {
        case.success(let data):
            let json = JSON(data)
            
            if (json.count > 0) {
                getAccountData(data: json[0], completion: { (success) -> Void in
                    if success {
                    
                        completion(true)
                    } else {
         
                        completion(false)
                    }
                })
            } else {
                completion(false)
            }
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//Update Account Secret Memo Pass
func updateAccountPass(currentP:String,newP:String,completion:@escaping(Bool) -> ()) {
    
    let url = kAPI_URL + kAPI_ACC + "/reset-password"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    let parameters = [
        "old_password": currentP,
        "new_password": newP,
        "confirm_new_password": newP
        ] as [String : Any]
    
    Alamofire.request(url, method: .put, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        switch(response.result) {
        case.success(let data):
            let json = JSON(data)

            if json.count > 0 {
                completion(false)
            } else {
                completion(true)
            }
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//Update Account Favorite Colors
func updateAccountFavoriteColors(accountID:Int,favColors:String,completion:@escaping(Bool) -> ()) {
    
    let url = kAPI_URL + kAPI_ACC + "/\(accountID)"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    let parameters = [
        "favorite_colors": favColors
        ] as [String : Any]
    
    Alamofire.request(url, method: .put, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        switch(response.result) {
        case.success(let data):
            _ = JSON(data)
            
            completion(true)
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//Access Secret Memo
func getAccessAccount(password:String,completion:@escaping(Bool) -> ()) {
    
    let url = kAPI_URL + kAPI_ACC + "/secret-memo-auth"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear,"Content-Type": "application/x-www-form-urlencoded"]
    
    let parameters = [
        "password": password
    ]
    
    Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        switch(response.result) {
        case.success(let data):
            let json = JSON(data)
            let code = json["code"]
            if code == 0 {
                completion(false)
            } else {
                completion(true)
            }
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//Update Account Secret Memo Pass
func updateAccountSecretMemoPass(password:String,completion:@escaping(Bool) -> ()) {
    
    let url = kAPI_URL + kAPI_ACC + "/update-secret-memo-password"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    let parameters = [
        "password": password
    ]
    
    Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        switch(response.result) {
        case.success( _):
            completion(true)
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//*****************************************************************
// MARK: - Customers
//*****************************************************************

//Get Customers
func searchCustomers(completion:@escaping(Bool) -> ()) {
    
    let url = kAPI_URL + kAPI_CUS_SEARCH
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        switch(response.result) {
        case.success( _):
            completion(true)
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//View Customer
func onViewCustomer(cusID:Int,completion:@escaping(CustomerData)->()) {
    
    let url = kAPI_URL + kAPI_CUS + "/\(cusID)?expand=fcSecretMemos"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        switch(response.result) {
        case.success(let data):
            let json = JSON(data)
            if (json.count > 0) {
                
                completion(getACustomerData(data: json))
                
            } else {
            
            }
        case.failure(let error):
            print(error)
            
        }
    }
}

//Get Customers
func getCustomers(page:Int,completion: @escaping(Bool) -> ()) {

    var url = kAPI_URL + kAPI_CUS
    //first call
    if page == 1 {
        url.append("?expand=fcSecretMemos")
    } else {
        url.append("?page=\(page)&expand=fcSecretMemos")
    }
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        let keyValues = response.response?.allHeaderFields.map { (String(describing: $0.key).lowercased(), String(describing: $0.value)) }
        
        // Now filter the array, searching for your header-key, also lowercased
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Page-Count".lowercased() }).first {
            GlobalVariables.sharedManager.pageTotal = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.pageTotal = 1
        }
        
        //get total customer
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Total-Count".lowercased() }).first {
            GlobalVariables.sharedManager.totalCus = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.totalCus = 0
        }
        
        //get current page
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Current-Page".lowercased() }).first {
            GlobalVariables.sharedManager.pageCurr = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.pageCurr = 1
        }
        
        switch(response.result) {
        case.success(let data):
            let json = JSON(data)
            if (json.count > 0) {
             
                for i in 0 ..< json.count {
                    getCustomerData(data: json[i])
                }
                completion(true)
            } else {
         
                completion(true)
            }
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//Add Customer
func addCustomer(first_name:String,last_name:String,first_name_kana:String,last_name_kana:String,gender:Int,bloodtype:Int,avatar_image:Data,birthday:Int,hobby:String,email:String,postal_code:String,address1:String,address2:String,address3:String,responsible:String,mail_block:Int,urgent_no:String,memo1:String,memo2:String,cusNo:String,completion:@escaping(Bool) -> ()) {
    let url = kAPI_URL + kAPI_CUS
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    let parameters = [
        "first_name": first_name,
        "last_name": last_name,
        "first_name_kana": first_name_kana,
        "last_name_kana": last_name_kana,
        "gender": gender,
        "bloodtype": bloodtype,
        "birthday": birthday,
        "hobby": hobby,
        "email": email,
        "postal_code": postal_code,
        "address1": address1,
        "address2": address2,
        "address3": address3,
        "responsible": responsible,
        "mail_block": mail_block,
        "urgent_no": urgent_no,
        "memo1": memo1,
        "memo2": memo2,
        "customer_no":cusNo
        ] as [String : Any]
    
    Alamofire.upload(multipartFormData: { (multipartFormData) in
        for (key, value) in parameters {
            multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
        }
        
        multipartFormData.append(avatar_image, withName: "avatar_image", fileName: "avatar.jpg", mimeType: "image/jpg")
        
    }, usingThreshold: UInt64.init(),to: url, method: .post, headers: headers) { (result) in
        switch result{
        case .success(let upload, _, _):
            upload.responseJSON { response in
                print("Succesfully uploaded  = \(response)")
                completion(true)
                if let err = response.error{
                    
                    print(err)
                    completion(false)
                }
                
            }
        case .failure(let error):
            print("Error in upload: \(error.localizedDescription)")
            completion(false)
        }
    }
}

//Edit Customer Info
func editCustomerInfo(cusID:Int,first_name:String,last_name:String,first_name_kana:String,last_name_kana:String,gender:Int,bloodtype:Int,birthday:Int,hobby:String,email:String,postal_code:String,address1:String,address2:String,address3:String,responsible:String,mail_block:Int,urgent_no:String,memo1:String,memo2:String,cusNo:String,completion:@escaping(Bool) -> ()) {
    let url = kAPI_URL + kAPI_CUS + "/\(cusID)"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
    
    let parameters = [
        "first_name": first_name,
        "last_name": last_name,
        "first_name_kana": first_name_kana,
        "last_name_kana": last_name_kana,
        "gender": gender,
        "bloodtype": bloodtype,
        "birthday": birthday,
        "hobby": hobby,
        "email": email,
        "postal_code": postal_code,
        "address1": address1,
        "address2": address2,
        "address3": address3,
        "responsible": responsible,
        "mail_block": mail_block,
        "urgent_no": urgent_no,
        "memo1": memo1,
        "memo2": memo2,
        "customer_no":cusNo
        ] as [String : Any]
    
    Alamofire.request(url, method: .put, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        switch(response.result) {
        case.success(let data):
            let json = JSON(data)
            
            if (json.count > 0) {
               
                completion(true)
            } else {
              
                completion(false)
            }
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//Edit customer info with Avatar
func editCustomerInfowAvatar(cusID:Int,first_name:String,last_name:String,first_name_kana:String,last_name_kana:String,gender:Int,bloodtype:Int,avatar_image:Data,birthday:Int,hobby:String,email:String,postal_code:String,address1:String,address2:String,address3:String,responsible:String,mail_block:Int,urgent_no:String,memo1:String,memo2:String,cusNo:String,completion:@escaping(Bool) -> ()) {
    let url = kAPI_URL + kAPI_CUS + "/update-with-avatar?id=\(cusID)"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    let parameters = [
        "first_name": first_name,
        "last_name": last_name,
        "first_name_kana": first_name_kana,
        "last_name_kana": last_name_kana,
        "gender": gender,
        "bloodtype": bloodtype,
        "birthday": birthday,
        "hobby": hobby,
        "email": email,
        "postal_code": postal_code,
        "address1": address1,
        "address2": address2,
        "address3": address3,
        "responsible": responsible,
        "mail_block": mail_block,
        "urgent_no": urgent_no,
        "memo1": memo1,
        "memo2": memo2,
        "customer_no":cusNo
        ] as [String : Any]
    
    Alamofire.upload(multipartFormData: { (multipartFormData) in
        for (key, value) in parameters {
            multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
        }
        
        multipartFormData.append(avatar_image, withName: "avatar_image", fileName: "avatar.jpg", mimeType: "image/jpg")
        
    }, usingThreshold: UInt64.init(),to: url, method: .post, headers: headers) { (result) in
        switch result{
        case .success(let upload, _, _):
            upload.responseJSON { response in
                print("Succesfully uploaded  = \(response)")
                completion(true)
                if let err = response.error{
                    
                    print(err)
                    completion(false)
                }
                
            }
        case .failure(let error):
            print("Error in upload: \(error.localizedDescription)")
            completion(false)
        }
    }
}

//Delete Customer
func deleteCustomer(ids:[Int],completion:@escaping(Bool) -> ()) {
    let url = kAPI_URL + kAPI_CUS + "/bulk-delete"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
    
    let parameters = ["ids":ids]
    
    Alamofire.request(url, method: .delete, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        switch(response.result) {
        case.success(_ ):
            completion(true)
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//*****************************************************************
// MARK: - Cartes
//*****************************************************************

//Get All Cartes
func getAllCartes(page:Int?,completion:@escaping(Bool) -> ()) {
    
    var url = kAPI_URL + kAPI_CARTE
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    if page != nil {
        url.append("?page=\(page!)")
    }
    
    Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        let keyValues = response.response?.allHeaderFields.map { (String(describing: $0.key).lowercased(), String(describing: $0.value)) }
        
        // Now filter the array, searching for your header-key, also lowercased
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Page-Count".lowercased() }).first {
            GlobalVariables.sharedManager.pageTotal = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.pageTotal = 1
        }
        
        //get total customer
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Total-Count".lowercased() }).first {
            GlobalVariables.sharedManager.totalCus = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.totalCus = 0
        }
        
        //get current page
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Current-Page".lowercased() }).first {
            GlobalVariables.sharedManager.pageCurr = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.pageCurr = 1
        }
        
        switch(response.result) {
        case.success(let data):
            
            let json = JSON(data)
            
            if (json.count > 0) {
                
                for i in 0 ..< json.count {
                    getCartesData(data: json[i])
                }
                
                if GlobalVariables.sharedManager.pageCurr! < GlobalVariables.sharedManager.pageTotal! {
          
                    getAllCartes(page: GlobalVariables.sharedManager.pageCurr! + 1, completion: completion)
                } else {
             
                    completion(true)
                }
            } else {
               completion(true)
            }
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//Get Cartes
func getCustomerCartesWithDocument(carteID:Int,completion:@escaping(Bool) -> ()) {
    let url = kAPI_URL + kAPI_CARTE + "/\(carteID)?expand=fcDocuments"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        switch(response.result) {
        case.success(let data):
            let json = JSON(data)
            
            if (json.count > 0) {
                
                let doc = json["fcDocuments"]
                for i in 0 ..< doc.count {
                    getDocumentsData(data: doc[i])
                }
            }
            
            completion(true)
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//Get Cartes with Memo
func getCustomerCartesWithMemos(cusID:Int,completion:@escaping(Bool) -> ()) {
    let url = kAPI_URL + kAPI_CUS + "/\(cusID)?expand=customerCartesWithMemos"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        switch(response.result) {
        case.success(let data):
            let json = JSON(data)
            
            if (json.count > 0) {
                
                let cart = json["customerCartesWithMemos"]
                for i in 0 ..< cart.count {
                    getCartesDataWithMemo(data: cart[i])
                }
                completion(true)
            } else {
                
                completion(false)
            }
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//Add Cartes
func addCarte(cusID:Int,date:Int,completion:@escaping(Bool) -> ()) {
    let url = kAPI_URL + kAPI_CARTE
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
    
    let parameters = [
        "fc_customer_id": cusID,
        "FcCustomerCarte[select_date]": date,
        ] as [String : Any]
    
    Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        switch(response.result) {
        case.success(let data):
            let json = JSON(data)
            
            if (json.count > 0) {
         
                completion(true)
            } else {
       
                completion(false)
            }
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//Add Cartes
func addCarteWithIDReturn(cusID:Int,date:Int,completion:@escaping(_ carteID: Int) -> ()) {
    let url = kAPI_URL + kAPI_CARTE
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
    
    let parameters = [
        "fc_customer_id": cusID,
        "FcCustomerCarte[select_date]": date,
        ] as [String : Any]
    
    Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        var id = 0
        
        switch(response.result) {
        case.success(let data):
            let json = JSON(data)
            
            if (json.count > 0) {
      
                id = json["id"].intValue
                completion(id)
            } else {
     
                completion(id)
            }
        case.failure(let error):
            print(error)
            completion(id)
        }
    }
}

//Edit Cartes
func editCarte(carteID:Int,mediaURL:String,completion:@escaping(Bool) -> ()) {
    let url = kAPI_URL + kAPI_CARTE + "/\(carteID)"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
    
    let parameters = [
        "FcCustomerCarte[carte_photo]": mediaURL
        ] as [String : Any]
    
    Alamofire.request(url, method: .put, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        switch(response.result) {
        case.success(let data):
            _ = JSON(data)
            completion(true)
            
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//Delete Cartes
func deleteCarte(ids:[Int],completion:@escaping(Bool) -> ()) {
    let url = kAPI_URL + kAPI_CARTE + "/bulk-delete"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
    
    let parameters = ["ids":ids]
    
    Alamofire.request(url, method: .delete, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        switch(response.result) {
        case.success( _):
            completion(true)
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//get documents from carte
func onGetDocumentsFromCarte(carteID:Int,completion:@escaping(Bool) -> ()) {
    
    let url = kAPI_URL + kAPI_CARTE + "/\(carteID)?expand=fcDocuments"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        switch(response.result) {
            
        case.success(let data):
            
            let json = JSON(data)
            
            if (json.count > 0) {
                
                for i in 0 ..< json.count {
                    getDocumentsData(data: json[i])
                }
                
            }
            completion(true)
            
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//get stamp from carte
func onGetStampFromCarte(carteID:Int,completion:@escaping(Bool) -> ()) {
    
    let url = kAPI_URL + kAPI_CARTE + "/\(carteID)?expand=fcFreeMemos,fcStampMemos"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        switch(response.result) {
            
        case.success(let data):
            
            let realm = try! Realm()
            try! realm.write {
                realm.delete(realm.objects(StampMemoData.self))
            }
            
            let json = JSON(data)
            
            if (json.count > 0) {
                
                let sm = json["fcStampMemos"]
                for i in 0 ..< sm.count {
                    getStampMemosData(data: sm[i])
                }
                
                completion(true)
            } else {
         
                completion(false)
            }
            
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//*****************************************************************
// MARK: - Media
//*****************************************************************

//Get Media by Customer
func getCustomerMedias(cusID:Int,completion:@escaping(Bool) -> ()) {
    let url = kAPI_URL + kAPI_CUS + "/\(cusID)?expand=mediaInCartes"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        switch(response.result) {
            
        case.success(let data):
            let json = JSON(data)
            
            if (json.count > 0) {
            
                for (key, subJson) in json["mediaInCartes"] {
                    getMediasDataCus(data: subJson ,date: key)
                }
                completion(true)
            } else {
                completion(true)
            }
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//Get Medias by Carte
func getCarteMedias(carteID:Int,completion:@escaping(Bool) -> ()) {
    let url = kAPI_URL + kAPI_CARTE + "/\(carteID)?expand=fcUserMedias"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        switch(response.result) {

        case.success(let data):
            let json = JSON(data)
            
            if (json.count > 0) {
                let media = json["fcUserMedias"]
                for i in 0 ..< media.count {
                    getMediasData(data: media[i])
                }
                completion(true)
            } else {
                completion(false)
            }
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//Add Media
func addMedias(cusID:Int,carteID:Int,mediaData:Data,completion:@escaping(Bool) -> ()) {
    let url = kAPI_URL + kAPI_CARTE + "/media"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
    
    let parameters = [
        "fc_customer_id": cusID
        ] as [String : Any]
    
    Alamofire.upload(multipartFormData: { (multipartFormData) in
        for (key, value) in parameters {
            multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
        }
        
        multipartFormData.append(mediaData, withName: "media_files", fileName: "media.jpg", mimeType: "image/jpg")
        
    }, usingThreshold: UInt64.init(),to: url, method: .post, headers: headers) { (result) in
        switch result {
        case .success(let upload, _, _):
            upload.responseJSON { response in
                switch(response.result) {
                    case .success(let data):
                    let json = JSON(data)
                    
                    if (json.count > 0) {
                        let data = json[0]
                        let id = data["id"].intValue
                        
                        addMediaIntoCarte(carteID: carteID, mediaID: id, completion: { (success) in
                            if success {
                                completion(true)
                            } else {
                                completion(false)
                            }
                        })
                    } else {
                        completion(false)
                    }
                    case.failure(let error):
                    print(error)
                    completion(false)
                }
            }
        case .failure(let error):
            print("Error in upload: \(error.localizedDescription)")
            completion(false)
        }
    }
}

//updateMediaIntoCarte
func addMediaIntoCarte(carteID:Int,mediaID:Int,completion:@escaping(Bool) -> ()) {
    let url = kAPI_URL + kAPI_MEDIA + "/\(mediaID)"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
    
    let parameters = [
        "fc_customer_carte_id": carteID
        ] as [String : Any]
    
    Alamofire.request(url, method: .put, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        switch(response.result) {
        case.success(let data):
            let json = JSON(data)
            
            if (json.count > 0) {
                completion(true)
            } else {
                completion(false)
            }
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//Delete Cartes
func deleteMedias(ids:[Int],completion:@escaping(Bool) -> ()) {
    let url = kAPI_URL + kAPI_MEDIA + "/bulk-delete"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
    
    let parameters = ["ids":ids]
    
    Alamofire.request(url, method: .delete, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        switch(response.result) {
        case.success( _):
            completion(true)
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//*****************************************************************
// MARK: - Memos
//*****************************************************************

//Get Memos
func getCarteMemos(carteID:Int,completion:@escaping(Bool) -> ()) {
    let url = kAPI_URL + kAPI_CARTE + "/\(carteID)?expand=fcFreeMemos,fcStampMemos"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    let realm = try! Realm()
    try! realm.write {
        realm.delete(realm.objects(MemoData.self))
    }
    
    Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        switch(response.result) {
            
        case.success(let data):
            let json = JSON(data)
            
            if (json.count > 0) {
                
                let fm = json["fcFreeMemos"]
                for i in 0 ..< fm.count {
                    getFreeMemosData(data: fm[i])
                }
                
                let sm = json["fcStampMemos"]
                for i in 0 ..< sm.count {
                    getStampMemosData(data: sm[i])
                }
                
                completion(true)
            } else {
                completion(false)
            }
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//Get Memos
func addCarteMemos(cusID:Int,carteID:Int,title:String,content:String,position:Int,type:Int,completion:@escaping(Bool) -> ()) {
    
    let url = kAPI_URL + kAPI_MEMO
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    let parameters = [
        "fc_customer_id": cusID,
        "fc_customer_carte_id": carteID,
        "title": title,
        "content": content,
        "position": position,
        "type": type
        ] as [String : Any]
    
    Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        switch(response.result) {
            
        case.success(let data):
            let json = JSON(data)
            
            if (json.count > 0) {
                completion(true)
            } else {
                completion(false)
            }
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//Edit Carte Memo
func editCarteMemos(memoID:Int,title:String,content:String,completion:@escaping(Bool) -> ()) {
    let url = kAPI_URL + kAPI_FREE_MEMO + "/\(memoID)"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
    
    let parameters = [
        "title":title,
        "content":content
        ] as [String : Any]
    
    Alamofire.request(url, method: .put, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        switch(response.result) {
        case.success(let data):
            let json = JSON(data)
            
            if (json.count > 0) {
                completion(true)
            } else {
                completion(false)
            }
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//*****************************************************************
// MARK: - Search
//*****************************************************************

//Get Syllabary
func onSearchSyllabary(characters:[String],page:Int?,completion:@escaping(Bool) -> ()) {
    
    var searchParams = ""
    for i in 0 ..< characters.count {
        var stringS = ""
        if i == 0 {
            stringS = "last_name_kana[]=" + characters[i]
        } else {
            stringS = "&last_name_kana[]=" + characters[i]
        }
     
        searchParams.append(stringS)
    }
    
    var url = kAPI_URL + kAPI_CUS_SEARCH + "?" + searchParams
    
    if page != nil {
        url.append("&page=\(page!)")
    }
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    let encodedURL = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
    
    Alamofire.request(encodedURL!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
        
        debugPrint(response)
        
        let keyValues = response.response?.allHeaderFields.map { (String(describing: $0.key).lowercased(), String(describing: $0.value)) }
        
        // Now filter the array, searching for your header-key, also lowercased
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Page-Count".lowercased() }).first {
            GlobalVariables.sharedManager.pageTotal = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.pageTotal = 1
        }
        
        //get total customer
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Total-Count".lowercased() }).first {
            GlobalVariables.sharedManager.totalCus = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.totalCus = 0
        }
        
        //get current page
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Current-Page".lowercased() }).first {
            GlobalVariables.sharedManager.pageCurr = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.pageCurr = 1
        }
        
        switch(response.result) {
            
        case.success(let data):
            let json = JSON(data)
            
            if (json.count > 0) {
               
                for i in 0 ..< json.count {
                    getCustomerData(data: json[i])
                }
                
                if GlobalVariables.sharedManager.pageCurr! < GlobalVariables.sharedManager.pageTotal! {
                    onSearchSyllabary(characters: characters, page: GlobalVariables.sharedManager.pageCurr! + 1, completion: completion)
                } else {
                    completion(true)
                }
        
            } else {
                completion(true)
            }
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//Mobile
func onSearchName(LName1:String,FName1:String,LNameKana1:String,FNameKana1:String,LName2:String,FName2:String,LNameKana2:String,FNameKana2:String,LName3:String,FName3:String,LNameKana3:String,FNameKana3:String,page:Int?,completion:@escaping(Bool) -> ()) {
    
    var searchParams = "?search_by_carte=true"
    if LName1 != "" {
        let stringS = "&last_name_1=" + LName1
        searchParams.append(stringS)
    }
    if FName1 != "" {
        let stringS = "&first_name_1=" + FName1
        searchParams.append(stringS)
    }
    if LNameKana1 != "" {
        let stringS = "&last_name_kana_1=" + LNameKana1
        searchParams.append(stringS)
    }
    if FNameKana1 != "" {
        let stringS = "&first_name_kana_1=" + FNameKana1
        searchParams.append(stringS)
    }
    if LName2 != "" {
        let stringS = "&last_name_2=" + LName2
        searchParams.append(stringS)
    }
    if FName2 != "" {
        let stringS = "&first_name_2=" + FName2
        searchParams.append(stringS)
    }
    if LNameKana2 != "" {
        let stringS = "&last_name_kana_2=" + LNameKana2
        searchParams.append(stringS)
    }
    if FNameKana2 != "" {
        let stringS = "&first_name_kana_2=" + FNameKana2
        searchParams.append(stringS)
    }
    if LName3 != "" {
        let stringS = "&last_name_3=" + LName3
        searchParams.append(stringS)
    }
    if FName3 != "" {
        let stringS = "&first_name_3=" + FName3
        searchParams.append(stringS)
    }
    if LNameKana3 != "" {
        let stringS = "&last_name_kana_3=" + LNameKana3
        searchParams.append(stringS)
    }
    if FNameKana3 != "" {
        let stringS = "&first_name_kana_3=" + FNameKana3
        searchParams.append(stringS)
    }
    
    var url = kAPI_URL + kAPI_CUS_SEARCH + searchParams
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    if page != nil {
        url.append("&page=\(page!)")
    }
    
    guard let encodedURL = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) else {
        return
    }
    
    Alamofire.request(encodedURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
        
        debugPrint(response)
        
        let keyValues = response.response?.allHeaderFields.map { (String(describing: $0.key).lowercased(), String(describing: $0.value)) }
        
        // Now filter the array, searching for your header-key, also lowercased
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Page-Count".lowercased() }).first {
            GlobalVariables.sharedManager.pageTotal = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.pageTotal = 1
        }
        
        //get total customer
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Total-Count".lowercased() }).first {
            GlobalVariables.sharedManager.totalCus = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.totalCus = 0
        }
        
        //get current page
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Current-Page".lowercased() }).first {
            GlobalVariables.sharedManager.pageCurr = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.pageCurr = 1
        }
  
        switch(response.result) {
            
        case.success(let data):
            let json = JSON(data)
            
            if (json.count > 0) {
              
                for i in 0 ..< json.count {
                    getCustomerData(data: json[i])
                }
                
                if GlobalVariables.sharedManager.pageCurr! < GlobalVariables.sharedManager.pageTotal! {
               
                    onSearchName(LName1: LName1, FName1: FName1, LNameKana1: LNameKana1, FNameKana1: FNameKana1, LName2: LName2, FName2: FName2, LNameKana2: LNameKana2, FNameKana2: FNameKana2, LName3: LName3, FName3: FName3, LNameKana3: LNameKana3, FNameKana3: FNameKana3, page: GlobalVariables.sharedManager.pageCurr! + 1, completion: completion)
                } else {
           
                    completion(true)
                }
                
            } else {
           
                completion(true)
            }
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//Mobile
func onSearchMobile(mobileNo:[String], page:Int?, completion:@escaping(Bool) -> ()) {
    
    var searchParams = ""
    for i in 0 ..< mobileNo.count {
        var stringS = ""
        if i == 0 {
            stringS = "urgent_no[]=" + mobileNo[i]
        } else {
            stringS = "&urgent_no[]=" + mobileNo[i]
        }
        
        searchParams.append(stringS)
    }
    
    var url = kAPI_URL + kAPI_CUS_SEARCH + "?" + searchParams
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    if page != nil {
        url.append("&page=\(page!)")
    }
    
    let encodedURL = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
    
    Alamofire.request(encodedURL!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        let keyValues = response.response?.allHeaderFields.map { (String(describing: $0.key).lowercased(), String(describing: $0.value)) }
        
        // Now filter the array, searching for your header-key, also lowercased
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Page-Count".lowercased() }).first {
            GlobalVariables.sharedManager.pageTotal = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.pageTotal = 1
        }
        
        //get total customer
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Total-Count".lowercased() }).first {
            GlobalVariables.sharedManager.totalCus = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.totalCus = 0
        }
        
        //get current page
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Current-Page".lowercased() }).first {
            GlobalVariables.sharedManager.pageCurr = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.pageCurr = 1
        }
        
        switch(response.result) {
            
        case.success(let data):
            let json = JSON(data)
            
            if (json.count > 0) {
            
                for i in 0 ..< json.count {
                    getCustomerData(data: json[i])
                }
                
                if GlobalVariables.sharedManager.pageCurr! < GlobalVariables.sharedManager.pageTotal! {
                  
                    onSearchMobile(mobileNo: mobileNo, page: GlobalVariables.sharedManager.pageCurr! + 1, completion: completion)
                } else {
            
                    completion(true)
                }
            
            } else {
         
                completion(true)
            }
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//Date
func onSearchDate(params:String,page:Int?,completion:@escaping(Bool) -> ()) {
    
    var url = kAPI_URL + kAPI_CUS_SEARCH + params
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    if page != nil {
        url.append("&page=\(page!)")
    }
    
    let encodedURL = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
    
    Alamofire.request(encodedURL!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        let keyValues = response.response?.allHeaderFields.map { (String(describing: $0.key).lowercased(), String(describing: $0.value)) }
        
        // Now filter the array, searching for your header-key, also lowercased
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Page-Count".lowercased() }).first {
            GlobalVariables.sharedManager.pageTotal = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.pageTotal = 1
        }
        
        //get total customer
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Total-Count".lowercased() }).first {
            GlobalVariables.sharedManager.totalCus = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.totalCus = 0
        }
        
        //get current page
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Current-Page".lowercased() }).first {
            GlobalVariables.sharedManager.pageCurr = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.pageCurr = 1
        }
        
        switch(response.result) {
            
        case.success(let data):
            let json = JSON(data)
            
            if (json.count > 0) {
                
                for i in 0 ..< json.count {
                    getCustomerData(data: json[i])
                }
                
                if GlobalVariables.sharedManager.pageCurr! < GlobalVariables.sharedManager.pageTotal! {
               
                    onSearchDate(params: params, page: GlobalVariables.sharedManager.pageCurr! + 1, completion: completion)
                } else {
           
                    completion(true)
                }
            } else {
          
                completion(false)
            }
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

func onSearchSelectedDate(params:String,completion:@escaping(Bool) -> ()) {
    
    let url = kAPI_URL + kAPI_CUS_SELECT_DATE_SEARCH + params
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    let encodedURL = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
    
    Alamofire.request(encodedURL!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        let keyValues = response.response?.allHeaderFields.map { (String(describing: $0.key).lowercased(), String(describing: $0.value)) }
        
        // Now filter the array, searching for your header-key, also lowercased
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Page-Count".lowercased() }).first {
            GlobalVariables.sharedManager.pageTotal = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.pageTotal = 1
        }
        
        //get total customer
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Total-Count".lowercased() }).first {
            GlobalVariables.sharedManager.totalCus = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.totalCus = 0
        }
        
        //get current page
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Current-Page".lowercased() }).first {
            GlobalVariables.sharedManager.pageCurr = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.pageCurr = 1
        }
        
        switch(response.result) {
            
        case.success(let data):
            let json = JSON(data)
            
            if (json.count > 0) {
              
                for i in 0 ..< json.count {
                    getCustomerData(data: json[i])
                }
                completion(true)
            } else {
        
                completion(true)
            }
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//Search Frequency
func onSearchFrequency(params:String,completion:@escaping(Bool) -> ()) {
    
    let url = kAPI_URL + kAPI_CUS + "/search-by-frequency?" + params
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    let encodedURL = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
    
    Alamofire.request(encodedURL!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        let keyValues = response.response?.allHeaderFields.map { (String(describing: $0.key).lowercased(), String(describing: $0.value)) }
        
        // Now filter the array, searching for your header-key, also lowercased
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Page-Count".lowercased() }).first {
            GlobalVariables.sharedManager.pageTotal = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.pageTotal = 1
        }
        
        //get total customer
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Total-Count".lowercased() }).first {
            GlobalVariables.sharedManager.totalCus = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.totalCus = 0
        }
        
        //get current page
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Current-Page".lowercased() }).first {
            GlobalVariables.sharedManager.pageCurr = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.pageCurr = 1
        }
        
        switch(response.result) {
            
        case.success(let data):
            let json = JSON(data)
            
            if (json.count > 0) {
             
                let realm = try! Realm()
                try! realm.write {
                    realm.delete(realm.objects(CustomerData.self))
                }
                
                for i in 0 ..< json.count {
                    getCustomerData(data: json[i])
                }
                completion(true)
            } else {
       
                completion(false)
            }
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//Search Interval
func onSearchInterval(params:String,page:Int?,completion:@escaping(Bool) -> ()) {
    
    var url = kAPI_URL + kAPI_CUS + "/search-by-last-back?" + params
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    if page != nil {
        url.append("&page=\(page!)")
    }
    
    let encodedURL = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
    
    Alamofire.request(encodedURL!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        let keyValues = response.response?.allHeaderFields.map { (String(describing: $0.key).lowercased(), String(describing: $0.value)) }
        
        // Now filter the array, searching for your header-key, also lowercased
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Page-Count".lowercased() }).first {
            GlobalVariables.sharedManager.pageTotal = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.pageTotal = 1
        }
        
        //get total customer
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Total-Count".lowercased() }).first {
            GlobalVariables.sharedManager.totalCus = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.totalCus = 0
        }
        
        //get current page
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Current-Page".lowercased() }).first {
            GlobalVariables.sharedManager.pageCurr = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.pageCurr = 1
        }
        
        switch(response.result) {
            
        case.success(let data):
            let json = JSON(data)
            
            if (json.count > 0) {
            
                for i in 0 ..< json.count {
                    getCustomerData(data: json[i])
                }
                
                if GlobalVariables.sharedManager.pageCurr! < GlobalVariables.sharedManager.pageTotal! {
                
                    onSearchInterval(params: params, page: GlobalVariables.sharedManager.pageCurr! + 1, completion: completion)
                } else {
                 
                    completion(true)
                }
          
            } else {
             
                completion(true)
            }
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//Gender
func onSearchGender(gender:Int,page:Int?,completion:@escaping(Bool) -> ()) {
    
    var url = kAPI_URL + kAPI_CUS + "/new-search?" + "gender=\(gender)"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    if page != nil {
        url.append("&page=\(page!)")
    }
    
    Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        let keyValues = response.response?.allHeaderFields.map { (String(describing: $0.key).lowercased(), String(describing: $0.value)) }
        
        // Now filter the array, searching for your header-key, also lowercased
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Page-Count".lowercased() }).first {
            GlobalVariables.sharedManager.pageTotal = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.pageTotal = 1
        }
        
        //get total customer
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Total-Count".lowercased() }).first {
            GlobalVariables.sharedManager.totalCus = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.totalCus = 0
        }
        
        //get current page
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Current-Page".lowercased() }).first {
            GlobalVariables.sharedManager.pageCurr = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.pageCurr = 1
        }
        
        switch(response.result) {
            
        case.success(let data):
            
            let json = JSON(data)
            
            if (json.count > 0) {
              
                for i in 0 ..< json.count {
                    getCustomerData(data: json[i])
                }
                
                if GlobalVariables.sharedManager.pageCurr! < GlobalVariables.sharedManager.pageTotal! {
                
                    onSearchGender(gender: gender, page: GlobalVariables.sharedManager.pageCurr! + 1, completion: completion)
                } else {
                  
                    completion(true)
                }
            
            } else {
            
                completion(true)
            }
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//Search Customer Number
func onSearchCustomerNumber(customerNo:String,page:Int?,completion:@escaping(Bool) -> ()) {
    
    var url = kAPI_URL + kAPI_CUS + "/new-search?" + "customer_no=\(customerNo)"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    if page != nil {
        url.append("&page=\(page!)")
    }
    
    let encodedURL = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
    
    Alamofire.request(encodedURL!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        let keyValues = response.response?.allHeaderFields.map { (String(describing: $0.key).lowercased(), String(describing: $0.value)) }
        
        // Now filter the array, searching for your header-key, also lowercased
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Page-Count".lowercased() }).first {
            GlobalVariables.sharedManager.pageTotal = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.pageTotal = 1
        }
        
        //get total customer
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Total-Count".lowercased() }).first {
            GlobalVariables.sharedManager.totalCus = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.totalCus = 0
        }
        
        //get current page
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Current-Page".lowercased() }).first {
            GlobalVariables.sharedManager.pageCurr = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.pageCurr = 1
        }
        
        switch(response.result) {
            
        case.success(let data):
            
            let json = JSON(data)
            
            if (json.count > 0) {
                
                for i in 0 ..< json.count {
                    getCustomerData(data: json[i])
                }
                
                if GlobalVariables.sharedManager.pageCurr! < GlobalVariables.sharedManager.pageTotal! {
           
                    onSearchCustomerNumber(customerNo: customerNo, page: GlobalVariables.sharedManager.pageCurr! + 1, completion: completion)
                } else {
                
                    completion(true)
                }
                
            } else {
             
                completion(true)
            }
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//Search Responsible Number
func onSearchResponsiblePerson(name:String,page:Int?,completion:@escaping(Bool) -> ()) {
    
    var url = kAPI_URL + kAPI_CUS + "/new-search?" + "responsible=\(name)"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    if page != nil {
        url.append("&page=\(page!)")
    }
    
    let encodedURL = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
    
    Alamofire.request(encodedURL!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        let keyValues = response.response?.allHeaderFields.map { (String(describing: $0.key).lowercased(), String(describing: $0.value)) }
        
        // Now filter the array, searching for your header-key, also lowercased
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Page-Count".lowercased() }).first {
            GlobalVariables.sharedManager.pageTotal = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.pageTotal = 1
        }
        
        //get total customer
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Total-Count".lowercased() }).first {
            GlobalVariables.sharedManager.totalCus = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.totalCus = 0
        }
        
        //get current page
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Current-Page".lowercased() }).first {
            GlobalVariables.sharedManager.pageCurr = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.pageCurr = 1
        }
        
        switch(response.result) {
            
        case.success(let data):
            
            let json = JSON(data)
            
            if (json.count > 0) {
               
                for i in 0 ..< json.count {
                    getCustomerData(data: json[i])
                }
                
                if GlobalVariables.sharedManager.pageCurr! < GlobalVariables.sharedManager.pageTotal! {
              
                    onSearchResponsiblePerson(name: name, page: GlobalVariables.sharedManager.pageCurr! + 1, completion: completion)
                } else {
                
                    completion(true)
                }
                
            } else {
        
                completion(true)
            }
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//Search Customer Note
func onSearchCustomerNote(memo1:String,memo2:String,page:Int?,completion:@escaping(Bool) -> ()) {
    
    var url = kAPI_URL + kAPI_CUS + "/new-search?memo1=\(memo1)&memo2=\(memo2)"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    if page != nil {
        url.append("&page=\(page!)")
    }
    
    let encodedURL = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
    
    Alamofire.request(encodedURL!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        let keyValues = response.response?.allHeaderFields.map { (String(describing: $0.key).lowercased(), String(describing: $0.value)) }
        
        // Now filter the array, searching for your header-key, also lowercased
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Page-Count".lowercased() }).first {
            GlobalVariables.sharedManager.pageTotal = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.pageTotal = 1
        }
        
        //get total customer
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Total-Count".lowercased() }).first {
            GlobalVariables.sharedManager.totalCus = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.totalCus = 0
        }
        
        //get current page
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Current-Page".lowercased() }).first {
            GlobalVariables.sharedManager.pageCurr = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.pageCurr = 1
        }
        
        switch(response.result) {
            
        case.success(let data):
            
            let json = JSON(data)
            
            if (json.count > 0) {
                
                for i in 0 ..< json.count {
                    getCustomerData(data: json[i])
                }
                
                if GlobalVariables.sharedManager.pageCurr! < GlobalVariables.sharedManager.pageTotal! {
                    
                    onSearchCustomerNote(memo1: memo1, memo2: memo2, page: GlobalVariables.sharedManager.pageCurr! + 1, completion: completion)
                } else {
                    
                    completion(true)
                }
                
            } else {
                
                completion(true)
            }
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//Search Customer Birthday
func onSearchCustomerBirthday(day:String,page:Int?,completion:@escaping(Bool) -> ()) {
    
    var url = kAPI_URL + kAPI_CUS + "/new-search?" + "birthday=\(day)&birthday_format=d-m-Y"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    if page != nil {
        url.append("&page=\(page!)")
    }
    
    let encodedURL = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
    
    Alamofire.request(encodedURL!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        let keyValues = response.response?.allHeaderFields.map { (String(describing: $0.key).lowercased(), String(describing: $0.value)) }
        
        // Now filter the array, searching for your header-key, also lowercased
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Page-Count".lowercased() }).first {
            GlobalVariables.sharedManager.pageTotal = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.pageTotal = 1
        }
        
        //get total customer
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Total-Count".lowercased() }).first {
            GlobalVariables.sharedManager.totalCus = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.totalCus = 0
        }
        
        //get current page
        if let myHeaderValue = keyValues?.filter({ $0.0 == "X-Pagination-Current-Page".lowercased() }).first {
            GlobalVariables.sharedManager.pageCurr = Int(myHeaderValue.1)
        } else {
            GlobalVariables.sharedManager.pageCurr = 1
        }
        
        switch(response.result) {
            
        case.success(let data):
            
            let json = JSON(data)
            
            if (json.count > 0) {
                
                for i in 0 ..< json.count {
                    getCustomerData(data: json[i])
                }
                
                if GlobalVariables.sharedManager.pageCurr! < GlobalVariables.sharedManager.pageTotal! {
                    
                    onSearchCustomerBirthday(day: day, page: GlobalVariables.sharedManager.pageCurr! + 1, completion: completion)
                } else {
                    
                    completion(true)
                }
                
            } else {
                
                completion(true)
            }
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//*****************************************************************
// MARK: - Stamp Memo and Keyword
//*****************************************************************

//Edit Carte Stamp Memo
func editCarteStampMemo(stampID:Int,content:String,completion:@escaping(Bool) -> ()) {
    let url = kAPI_URL + kAPI_STAMP_MEMO + "/\(stampID)"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
    
    let parameters = [
        "content":content
        ] as [String : Any]
    
    Alamofire.request(url, method: .put, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        switch(response.result) {
        case.success(let data):
            let json = JSON(data)
            
            if (json.count > 0) {
            
                completion(true)
            } else {
             
                completion(false)
            }
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//add stamp category
func onAddNewStampCategory(name:String,completion:@escaping(Bool) -> ()) {
    
    let url = kAPI_URL + kAPI_STAMP_CATEGORY
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
    
    let parameters = [
        "name": name
        ] as [String : Any]
    
    Alamofire.request(url, method: .post, parameters: parameters, encoding:  URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
        
        switch(response.result) {
            
        case.success(let data):
            let json = JSON(data)
            
            if ((json.dictionary?.count) != nil) {
          
                completion(true)
            } else {
      
                completion(false)
            }
            
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//get stamp category
func onGetStampCategory(completion:@escaping(Bool) -> ()) {
    
    let url = kAPI_URL + kAPI_STAMP_CATEGORY
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        switch(response.result) {
            
        case.success(let data):
            
            let realm = try! Realm()
            try! realm.write {
                realm.delete(realm.objects(StampCategoryData.self))
            }
            
            let json = JSON(data)
            
            if (json.count > 0) {
                
                for i in 0 ..< json.count {
                    getStampCategoryData(data: json[i])
                }
                completion(true)
            } else {
            
                completion(true)
            }
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//Add keyword to stamp
func addKeywordToStamp(carteID:Int,cusID:Int,content:String,position:Int,completion:@escaping(Bool) -> ()) {
    let url = kAPI_URL + kAPI_STAMP_MEMO
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    let parameters = [
        "fc_customer_carte_id":carteID,
        "fc_customer_id":cusID,
        "position":position,
        "content":content
        ] as [String : Any]
    
    Alamofire.request(url, method: .put, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        switch(response.result) {
        case.success(let data):
            let json = JSON(data)
            
            if (json.count > 0) {
         
                completion(true)
            } else {
         
                completion(false)
            }
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//Edit Stamp Category
func editStampCategoryTitle(categoryID:Int,title:String,completion:@escaping(Bool) -> ()) {
    let url = kAPI_URL + kAPI_STAMP_CATEGORY + "/\(categoryID)"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
    
    let parameters = [
        "title":title
        ] as [String : Any]
    
    Alamofire.request(url, method: .put, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        switch(response.result) {
        case.success(let data):
            _ = JSON(data)
            
            completion(true)
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//get content of stamp
func onGetContentFromStamp(stampID: Int,completion:@escaping(Bool) -> ()) {
    
    let url = kAPI_URL + kAPI_STAMP_MEMO + "/\(stampID)"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        switch(response.result) {
            
        case.success(let data):
            let json = JSON(data)
            
            let realm = try! Realm()
            try! realm.write {
                realm.delete(realm.objects(StampContentData.self))
            }
            
            for i in 0 ..< json["fcKeyword"].count {
                getStampContent(data: json["fcKeyword"][i])
            }
            completion(true)
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//get key of stamp
func onGetKeyFromCategory(categoryID: Int,completion:@escaping(Bool) -> ()) {
    
    let url = kAPI_URL + kAPI_KEYWORD + "?category_id=\(categoryID)"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    let encodedURL = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
    
    Alamofire.request(encodedURL!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        switch(response.result) {
            
        case.success(let data):
            let json = JSON(data)
            
            let realm = try! Realm()
            try! realm.write {
                realm.delete(realm.objects(StampKeywordData.self))
            }
            
            for i in 0 ..< json.count {
                getStampKeyword(data: json[i])
            }
            completion(true)
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//get stamp data
func onGetStampData(completion:@escaping(Bool) -> ()) {
    
    let url = kAPI_URL + kAPI_STAMP
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    let encodedURL = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
    
    Alamofire.request(encodedURL!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        switch(response.result) {
            
        case.success(let data):
            _ = JSON(data)
            
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//add stamp keyword data
func onAddKeywords(categoryID:Int,content:String,completion:@escaping(Bool) -> ()) {

    let url = kAPI_URL + kAPI_KEYWORD

    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]

    let parameters = [
        "category_id": categoryID,
        "content": content
        ] as [String : Any]

    Alamofire.request(url, method: .post, parameters: parameters, encoding:  URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in

        switch(response.result) {

        case.success(let data):
            let json = JSON(data)

            if ((json.dictionary?.count) != nil) {
  
                completion(true)
            } else {
      
                completion(false)
            }

        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//delete keywords data
func onDeleteKeywords(keywordID:Int,completion:@escaping(Bool) -> ()) {
    
    let url = kAPI_URL + kAPI_KEYWORD + "/\(keywordID)"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
    
    Alamofire.request(url, method: .delete, parameters: nil, encoding:  URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
        
        switch(response.result) {
            
        case.success( _):
            completion(true)
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//Edit Stamp
func editStamp(stampID:Int,content:String,completion:@escaping(Bool) -> ()) {
    let url = kAPI_URL + kAPI_STAMP + "/\(stampID)"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
    
    let parameters = [
        "content":content
        ] as [String : Any]
    
    Alamofire.request(url, method: .put, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        switch(response.result) {
        case.success(let data):
            let json = JSON(data)
            
            if (json.count > 0) {
                
                completion(true)
            } else {
          
                completion(false)
            }
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//add stamp keywords
func onAddNewFreeMemo(carteID:Int,cusID:Int,title:String,content:String,position:Int,completion:@escaping(Bool) -> ()) {
    
    let url = kAPI_URL + kAPI_FREE_MEMO
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
    
    let parameters = [
        "fc_customer_carte_id": carteID,
        "fc_customer_id": cusID,
        "title": title,
        "content": content,
        "position": position
        ] as [String : Any]
    
    Alamofire.request(url, method: .post, parameters: parameters, encoding:  URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
        
        switch(response.result) {
            
        case.success(let data):
            let json = JSON(data)
            
            if ((json.dictionary?.count) != nil) {
         
                completion(true)
            } else {
 
                completion(false)
            }
            
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}


//Edit Stamp
func onEditFreeMemo(memoID:Int,content:String,completion:@escaping(Bool) -> ()) {
    let url = kAPI_URL + kAPI_FREE_MEMO + "/\(memoID)"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
    
    let parameters = [
        "content":content
        ] as [String : Any]
    
    Alamofire.request(url, method: .put, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        switch(response.result) {
        case.success(let data):
            let json = JSON(data)
            
            if (json.count > 0) {
              
                completion(true)
            } else {
            
                completion(false)
            }
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//*****************************************************************
// MARK: - Secret Memo
//*****************************************************************

//Access Secret Memo
func getAccessSecretMemo(password:String,completion:@escaping(Bool) -> ()) {
    
    let url = kAPI_URL + kAPI_ACC + "/secret-memo-auth"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear,"Content-Type": "application/x-www-form-urlencoded"]
    
    let parameters = [
        "password": password
    ]
    
    Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        switch(response.result) {
        case.success(let data):
            let json = JSON(data)
            let code = json["code"]
            if code == 0 {
                completion(false)
            } else {
                completion(true)
            }
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//Get Memos
func getCusSecretMemo(cusID:Int,completion:@escaping(Bool) -> ()) {
    let url = kAPI_URL + kAPI_CUS + "/\(cusID)?expand=fcSecretMemos"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    let realm = try! Realm()
    try! realm.write {
        realm.delete(realm.objects(SecretMemoData.self))
    }
    
    Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        switch(response.result) {
            
        case.success(let data):
            let json = JSON(data)
            
            if (json.count > 0) {
          
                let memo = json["fcSecretMemos"]
                for i in 0 ..< memo.count {
                    getSecretMemoData(data: memo[i])
                }
                completion(true)
            } else {
             
                completion(false)
            }
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//Add Memos
func addSecretMemo(cusID:Int,content:String,auth:String,completion:@escaping(Bool) -> ()) {
    let url = kAPI_URL + kAPI_SECRET_MEMO
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear, "auth_password":auth]
    
    let parameters = [
        "fc_customer_id": cusID,
        "content":content
        ] as [String : Any]
    
    Alamofire.request(url, method: .post, parameters: parameters, encoding:  URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
        
        switch(response.result) {
            
        case.success(let data):
            let json = JSON(data)
            
            if ((json.dictionary?.count) != nil) {
            
                completion(true)
            } else {
            
                completion(false)
            }
            
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//Edit Secret Memo
func editSecretMemo(secretID:Int,content:String,auth:String,completion:@escaping(Bool) -> ()) {
    let url = kAPI_URL + kAPI_SECRET_MEMO + "/\(secretID)"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear,"auth_password":auth]
    
    let parameters = [
        "content":content
        ] as [String : Any]
    
    Alamofire.request(url, method: .put, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        switch(response.result) {
        case.success(let data):
            let json = JSON(data)
            
            if (json.count > 0) {
            
                completion(true)
            } else {
              
                completion(false)
            }
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//Delete Secret
func deleteSecretMemo(memoID:Int,auth:String,completion:@escaping(Bool) -> ()) {
    let url = kAPI_URL + kAPI_SECRET_MEMO + "/\(memoID)"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear,"auth_password":auth]
    
    Alamofire.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        switch(response.result) {
            
        case.success( _):
            completion(true)
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//*****************************************************************
// MARK: - Documents
//*****************************************************************

//get all documents template from account
func onGetDocumentsTemplate(completion:@escaping(Bool) -> ()) {
    
    let url = kAPI_URL + kAPI_DOCUMENT + "/get-all-template"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        switch(response.result) {
            
        case.success(let data):
            
            let json = JSON(data)
            
            if (json.count > 0) {
                
                for i in 0 ..< json.count {
                    getDocumentsData(data: json[i])
                }
                
            }
            
            completion(true)
            
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//get
func onGetDocumentOnEdit(docID:Int,completion:@escaping(Bool) -> ()) {
    
    let url = kAPI_URL + kAPI_DOCUMENTS + "/\(docID)"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        switch(response.result) {
            
        case.success(let data):
            
            let json = JSON(data)
            
            if (json.count > 0) {
                
                for i in 0 ..< json.count {
                    getDocumentsData(data: json[i])
                }
                
            }
            
            completion(true)
            
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//Add Documents to Carte
func addDocumentIntoCarte(documentID:Int,carteID:Int,completion:@escaping ArrayCompletion) {
    
    let url = kAPI_URL + kAPI_DOCUMENT + "/create-with-template"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    let parameters = [
        "fc_document_template_id": documentID,
        "fc_customer_carte_id": carteID,
        ] as [String : Any]
    
    Alamofire.request(url, method: .post, parameters: parameters, encoding:  URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
        
        switch(response.result) {
            
        case.success(let data):
            let json = JSON(data)
            
            if ((json.dictionary?.count) != nil) {
             
                let memo = json["fcDocumentPages"]
                
                completion(true,memo)
            } else {
             
                completion(false,JSON.null)
            }
            
        case.failure(let error):
            print(error)
            completion(false,JSON.null)
        }
    }
}


//Add Documents
func addDocument(cusID:Int,documentType:Int,docData:Data,page:Int,completion:@escaping(Bool) -> ()) {
    
    let url = kAPI_URL + kAPI_MEDIA

    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]

    let parameters = [
        "id": cusID
        ] as [String : Any]

    Alamofire.upload(multipartFormData: { (multipartFormData) in
        for (key, value) in parameters {
            multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
        }

        multipartFormData.append(docData, withName: "media_file", fileName: "doc.jpg", mimeType: "image/jpg")

    }, usingThreshold: UInt64.init(),to: url, method: .post, headers: headers) { (result) in
        switch result {
        case .success(let upload, _, _):
            upload.responseJSON { response in
                switch(response.result) {
                case .success(let data):
                    
                    // First make sure you got back a dictionary if that's what you expect
                    guard let json = data as? [String : AnyObject] else {
                        print("Failed to get expected response from webserver.")
                        completion(false)
                        return
                    }
                    
                    // Then make sure you get the actual key/value types you expect
                    guard let urlDoc = json["url"] as? String else {
                        print("Failed to get expected response from webserver.")
                        completion(false)
                        return
                    }

                    addDocumentIntoCustomer(cusID: cusID, documentType: documentType, pageNo: page, urlD: urlDoc, completion: { (success) in
                        if success {
                            completion(true)
                        } else {
                            completion(false)
                        }
                    })
                    
                case.failure(let error):
                    print(error)
                    completion(false)
                }
            }
        case .failure(let error):
            print("Error in upload: \(error.localizedDescription)")
            completion(false)
        }
    }
}

//update Doc into customer
func addDocumentIntoCustomer(cusID:Int,documentType:Int,pageNo:Int,urlD:String,completion:@escaping(Bool) -> ()) {
    
    let url = kAPI_URL + kAPI_CUS + "/\(cusID)"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    var doc = ""
    switch documentType {
    case 1:
        if pageNo == 1 {
            doc = "document_1"
        } else {
            doc = "document_2"
        }
    case 2:
        doc = "document_consent"
    default:
        break
    }
    let parameters = [
        doc : urlD
        ] as [String : Any]
   
    Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
        debugPrint(response)
        
        switch(response.result) {
        case.success(let data):
            let json = JSON(data)
            
            if (json.count > 0) {
           
                completion(true)
            } else {
            
                completion(false)
            }
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}

//Edit Documents Page
func editDocumentInCarte(documentPageID:Int,page:Int,imageData:Data,isEdited:Int,completion:@escaping(Bool) -> ()) {
    let url = kAPI_URL + kAPI_DOCUMENT_PAGE + "/update-two/\(documentPageID)"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Content-Type": "application/x-www-form-urlencoded","Authorization" : bear]
    
    let parameters = [
        "page": page,
        "is_edited":isEdited
        ] as [String : Any]
    
    Alamofire.upload(multipartFormData: { (multipartFormData) in
        for (key, value) in parameters {
            multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
        }
        
        multipartFormData.append(imageData, withName: "media_file", fileName: "doc.jpg", mimeType: "image/jpg")
        
    }, usingThreshold: UInt64.init(),to: url, method: .post, headers: headers) { (result) in
        switch result{
        case .success(let upload, _, _):
            upload.responseJSON { response in
                print("Succesfully uploaded  = \(response)")
                completion(true)
                if let err = response.error{
                    
                    print(err)
                    completion(false)
                }
                
            }
        case .failure(let error):
            print("Error in upload: \(error.localizedDescription)")
            completion(false)
        }
    }
}

//*****************************************************************
// MARK: - GB Storage
//*****************************************************************

//Count Storage
func countStorage(completion:@escaping(Bool) -> ()) {
    
    let url = kAPI_URL + kAPI_MEDIA + "/check-store"
    
    let secondTok: String = UserDefaults.standard.string(forKey: "token")!
    let bear = "Bearer " + secondTok
    let headers = ["Authorization" : bear]
    
    Alamofire.request(url, method: .post, parameters: nil, encoding:  URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in
        
        switch(response.result) {
            
        case.success(let data):
            _ = JSON(data)
            
            completion(true)
            
        case.failure(let error):
            print(error)
            completion(false)
        }
    }
}
