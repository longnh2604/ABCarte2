//
//  Constants.swift
//  ABCarte2
//
//  Created by Long on 2018/05/09.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import Foundation
import UIKit

//Device rotation
let kLandscape = UIDevice.current.orientation.isLandscape
let kPortrait = UIDevice.current.orientation.isPortrait
//Color Set
let kNAVIGATION_BAR_COLOR = UIColor.init(red: 17/255.0, green: 42/255.0, blue: 64/255.0, alpha: 1).cgColor
let kFEMALE_COLOR = UIColor.init(red: 241/255.0, green: 153/255.0, blue: 144/255.0, alpha: 1)
let kMALE_COLOR = UIColor.init(red: 94/255.0, green: 136/255.0, blue: 198/255.0, alpha: 1)
let kBROWN = UIColor.init(red: 246/255.0, green: 240/255.0, blue: 230/255.0, alpha: 1)
let kBLUE = UIColor.init(red: 139/255.0, green: 175/255.0, blue: 198/255.0, alpha: 1)
let kBLUENAVY = UIColor.init(red: 17/255.0, green: 76/255.0, blue: 108/255.0, alpha: 1)
let kPENSELECT = UIColor.init(red: 255/255.0, green: 182/255.0, blue: 172/255.0, alpha: 1)
let kPENUNSELECT = UIColor.init(red: 255/255.0, green: 219/255.0, blue: 213/255.0, alpha: 1)
let kCountDown_COLOR = UIColor.init(red: 0/255, green: 150/255, blue: 255/255, alpha: 1)
let kLINE_CORRECT_COLOR = UIColor.init(red: 10/255, green: 175/255, blue: 200/255, alpha: 1)
let kGREEN = UIColor.init(red: 26/255, green: 188/255, blue: 156/255, alpha: 1)
let kMEMO_SELECT_COLOR = UIColor.init(red: 255/255, green: 182/255, blue: 172/255, alpha: 1)
let kMEMO_HAS_CONTENT_COLOR = UIColor.init(red: 10/255, green: 175/255, blue: 200/255, alpha: 1)
let kBACKGROUND_LIGHT_GRAY = UIColor.init(red: 239/255, green: 239/255, blue: 244/255, alpha: 1)

//*****************************************************************
// MARK: - Message
//*****************************************************************

//general
let kALERT_FUNCTION_UNDER_CONSTRUCTION = "この機能は建設中です。"
let kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN = "ネットワークに接続できませんでした。 再度ネットワークの状態を確認してください。"
let kALERT_WRONG_PASSWORD = "パスワードが間違っています。正しいパスワードを入力してください。"
let kALERT_INPUT_PASSWORD = "パスワードを入力してください。"
let kALERT_INPUT_ACCOUNT_PASSWORD = "ログインパスワードを入力してください。"
let kALERT_INPUT_EMAIL = "メールアドレスを入力してください。"
let kALERT_INPUT_PHONE = "電話番号を入力してください。"
let kALERT_INPUT_DATE = "日付を入力してください"
let kALERT_AT_LEAST_INPUT_DATE_IN_A_ROW = "少なくとも1行に日付を入力してください"
let kALERT_INPUT_DATA = "データを入力してください"
let kALERT_SAVE_PHOTO_NOTIFICATION = "編集した画像を破棄しますよろしいですか?"
let kALERT_SAVE_MEMO_NOTIFICATION = "編集したメモを破棄しますよろしいですか?"
let kALERT_SAVE_DOCUMENT_NOTIFICATION = "編集したドキュメントを破棄しますよろしいですか?"

//account
let kALERT_CANT_GET_ACCOUNT_INFO_PLEASE_CONTACT_SUPPORTER = "お客様情報を取得できませんでした。 サポートダイヤルへご連絡ください。"
let kALERT_ACCOUNT_CANT_ACCESS = "このアカウントはこれにアクセスできません。"

//customer
let kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK = "お客様の情報の読み込みに失敗しました。ネットワークの状態を確認してください。"
let kALERT_SEARCH_RESULTS_NOTHING = "検索結果がありませんでした。"
let kALERT_SELECT_CUSTOMER_2_DELETE = "削除するお客様を選択してください。"
let kALERT_CREATE_CUSTOMER_FIRST_ADD_SECRET_LATER = "シークレットメモを登録するには、先にお客様の登録を完了してください。"
let kALERT_INPUT_LAST_FIRST_NAME = "姓・名を入力してください。"
let kALERT_INPUT_LAST_FIRST_NAME_KANA = "姓 (かな) ・ 名 (かな) を入力してください。"
let kALERT_UPDATE_CUSTOMER_INFO_SUCCESS = "顧客情報を更新しました。"
let kALERT_CREATE_CUSTOMER_INFO_SUCCESS = "顧客情報を登録しました。"

//carte
let kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK = "カルテの読み込みに失敗しました。ネットワークの状態を確認してください。"
let kALERT_CARTE_EXISTS_ALREADY = "既にカルテが存在しています。"
let kALERT_SELECT_CARTE_2_DELETE = "削除するカルテを選択してください。"
let kALERT_REGISTER_CARTE_REPRESENTATIVE_SUCCESS = "カルテの代表画像を登録しました。"

//memo
let kALERT_CANT_GET_MEMO_INFO_PLEASE_CHECK_NETWORK = "メモの読込に失敗しました。ネットワークの状態を確認してください。"
//stamp
let kALERT_CANT_GET_STAMP_INFO_PLEASE_CHECK_NETWORK = "スタンプを取得できませんでした。 サポートダイヤルへご連絡ください。"
let kALERT_INPUT_TITLE = "タイトルを入力してください。"
let kALERT_INPUT_CONTENT = "内容を入力してください。"
let kALERT_SELECT_TITLE_EDIT = "編集するタイトルを選択してください。"
let kALERT_CANT_SAVE_TITLE = "タイトルの保存に失敗しました。再度登録をしてください。"
let kALERT_UPDATE_TITLE_SUCCESS = "タイトルの保存が完了しました。"

//keyword
let kALERT_SELECT_KEYWORD_DELETE = "削除するキーワードを選択してください。"
let kALERT_CANT_DELETE_KEYWORD = "削除するキーワードを選択してください。"
let kALERT_ADD_KEYWORD_SUCCESS = "キーワードの保存が完了しました。"
let kALERT_CANT_SAVE_KEYWORD = "キーワードの保存に失敗しました。再度登録をしてください。"

//shooting
let kALERT_SHOOTING_TRANMISSION_NOT_SATISFY = "透過撮影をする場合は、画像を1枚だけ選択してください。"

//photo
let kALERT_CANT_GET_PHOTO_INFO_PLEASE_CHECK_NETWORK = "画像の保存に失敗しました。ネットワークの状態を確認してください。"
let kALERT_PLEASE_SELECT_PHOTO = "写真を選択してください。"
let kALERT_CANT_SAVE_PHOTO = "画像の保存に失敗しました。ネットワークの状態を確認してください。"

//drawing
let kALERT_DRAWING_ACCESS_NOT_SATISFY = "描画する画像を1枚選択してください。"
let kALERT_CHOOSE_2_TO_12_PHOTOS = "画像を2～12枚まで選択してください。"

//documents
let kALERT_CANT_GET_DOCUMENT_INFO_PLEASE_CHECK_NETWORK = "ドキュメントの読み込みに失敗しました。ネットワークの状態を確認してください。"
let kALERT_SAME_TYPE_DOCUMENT = "同じデータが既に作成されています。"

