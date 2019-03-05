//
//  API.swift
//  ABCarte2
//
//  Created by Long on 2018/08/02.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import Foundation

//*****************************************************************
// MARK: - APP URL
//*****************************************************************

//main app url
//let kAPI_URL = "http://api.autofree.top/"

//#if DEBUG
//let kAPI_URL = "http://133.167.107.147/"
//#else
let kAPI_URL = "http://160.16.137.252/"
//#endif

//amazon
//#if DEBUG
//let kAPI_URL_AWS = "https://s3-ap-northeast-1.amazonaws.com/abcarte-dev/"
//#else
let kAPI_URL_AWS = "https://s3-ap-northeast-1.amazonaws.com/abcarte/"
//#endif

//*****************************************************************
// MARK: - ACCOUNT & DEVICE
//*****************************************************************

//Token
let kAPI_TOKEN = "v1/request-access-token"

//Account
let kAPI_ACC = "v1/fc-accounts"

//*****************************************************************
// MARK: - CUSTOMER
//*****************************************************************

//CUSTOMER
let kAPI_CUS = "v1/fc-customers"

//*****************************************************************
// MARK: - SEARCH
//*****************************************************************

let kAPI_CUS_SEARCH = "v1/fc-customers/search"

let kAPI_CUS_SELECT_DATE_SEARCH = "v1/fc-customers/search-by-carte-select-date"

//*****************************************************************
// MARK: - CARTE
//*****************************************************************

//CARTE
let kAPI_CARTE = "v1/fc-customer-cartes"

//*****************************************************************
// MARK: - MEDIA
//*****************************************************************

//MEDIA
let kAPI_MEDIA = "v1/fc-user-media"

//*****************************************************************
// MARK: - MEMO
//*****************************************************************

//MEMO
let kAPI_MEMO = "v1/fc-user-memos"
//STAMP CONFIG
let kAPI_STAMP = "v1/memo-content-cfgs"
//CATEGORY
let kAPI_STAMP_CATEGORY = "v1/fc-categories"
//keyword
let kAPI_KEYWORD = "v1/fc-keywords"
//free memo
let kAPI_FREE_MEMO = "v1/fc-free-memos"
//stamp memo
let kAPI_STAMP_MEMO = "v1/fc-stamp-memos"

//SECRET_MEMO
let kAPI_SECRET_MEMO = "v1/fc-secret-memos"

//*****************************************************************
// MARK: - DOCUMENT
//*****************************************************************

//DOCUMENT
let kAPI_DOCUMENT = "v1/fc-document"

let kAPI_DOCUMENTS = "v1/fc-documents"

//DOCUMENT_PAGE
let kAPI_DOCUMENT_PAGE = "v1/fc-document-pages"
