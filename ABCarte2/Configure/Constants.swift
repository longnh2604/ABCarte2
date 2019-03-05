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
enum DeviceOrientation {
    static let kLandscape = UIDevice.current.orientation.isLandscape
    static let kPortrait = UIDevice.current.orientation.isPortrait
}

//Color Set
enum COLOR_SET {
    static let kNAVIGATION_BAR_COLOR = UIColor(red: 17/255.0, green: 42/255.0, blue: 64/255.0, alpha: 1)
    static let kFEMALE_COLOR = UIColor(red: 241/255.0, green: 153/255.0, blue: 144/255.0, alpha: 1)
    static let kMALE_COLOR = UIColor(red: 94/255.0, green: 136/255.0, blue: 198/255.0, alpha: 1)
    static let kBROWN = UIColor(red: 246/255.0, green: 240/255.0, blue: 230/255.0, alpha: 1)
    static let kBLUE = UIColor(red: 0/255.0, green: 84/255.0, blue: 147/255.0, alpha: 1)
    static let kBLUENAVY = UIColor(red: 17/255.0, green: 76/255.0, blue: 108/255.0, alpha: 1)
    static let kPENSELECT = UIColor(red: 255/255.0, green: 182/255.0, blue: 172/255.0, alpha: 1)
    static let kPENUNSELECT = UIColor(red: 255/255.0, green: 219/255.0, blue: 213/255.0, alpha: 1)
    static let kCountDown_COLOR = UIColor(red: 0/255, green: 150/255, blue: 255/255, alpha: 1)
    static let kLINE_CORRECT_COLOR = UIColor(red: 10/255, green: 175/255, blue: 200/255, alpha: 1)
    static let kGREEN = UIColor(red: 26/255, green: 188/255, blue: 156/255, alpha: 1)
    static let kMEMO_SELECT_COLOR = UIColor(red: 255/255, green: 182/255, blue: 172/255, alpha: 1)
    static let kMEMO_HAS_CONTENT_COLOR = UIColor(red: 10/255, green: 175/255, blue: 200/255, alpha: 1)
    static let kBACKGROUND_LIGHT_GRAY = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1)
}

enum COLOR_SET000 {
    static let kHEADER_BACKGROUND_COLOR_UP = UIColor(red: 0/255.0, green: 65/255.0, blue: 106/255.0, alpha: 1)
    static let kHEADER_BACKGROUND_COLOR_DOWN = UIColor(red: 0/255.0, green: 152/255.0, blue: 163/255.0, alpha: 1)
    static let kCOMMAND_BUTTON_BACKGROUND_COLOR = UIColor(red: 180/255.0, green: 220/255.0, blue: 224/255.0, alpha: 1)
    static let kSELECT_BACKGROUND_COLOR = UIColor(red: 248/255.0, green: 243/255.0, blue: 221/255.0, alpha: 1)
    static let kEDIT_SCREEN_BACKGROUND_COLOR = UIColor(red: 17/255.0, green: 43/255.0, blue: 62/255.0, alpha: 1)
    static let kACCENT_COLOR = UIColor(red: 236/255.0, green: 120/255.0, blue: 124/255.0, alpha: 1)
    static let kSTANDARD_TEXT_COLOR = UIColor(red: 56/255.0, green: 55/255.0, blue: 55/255.0, alpha: 1)
    static let kSTANDARD_VER_COLOR = UIColor(red: 225/255.0, green: 229/255.0, blue: 232/255.0, alpha: 1)
}

enum COLOR_SET001 {
    static let kHEADER_BACKGROUND_COLOR_UP = UIColor(red: 68/255.0, green: 15/255.0, blue: 8/255.0, alpha: 1)
    static let kHEADER_BACKGROUND_COLOR_DOWN = UIColor(red: 161/255.0, green: 121/255.0, blue: 88/255.0, alpha: 1)
    static let kCOMMAND_BUTTON_BACKGROUND_COLOR = UIColor(red: 255/255.0, green: 204/255.0, blue: 194/255.0, alpha: 1)
    static let kSELECT_BACKGROUND_COLOR = UIColor(red: 245/255.0, green: 240/255.0, blue: 230/255.0, alpha: 1)
    static let kEDIT_SCREEN_BACKGROUND_COLOR = UIColor(red: 17/255.0, green: 42/255.0, blue: 64/255.0, alpha: 1)
    static let kACCENT_COLOR = UIColor(red: 26/255.0, green: 185/255.0, blue: 181/255.0, alpha: 1)
    static let kSTANDARD_TEXT_COLOR = UIColor(red: 56/255.0, green: 55/255.0, blue: 55/255.0, alpha: 1)
    static let kSTANDARD_VER_COLOR = UIColor(red: 225/255.0, green: 229/255.0, blue: 232/255.0, alpha: 1)
}

enum COLOR_SET002 {
    static let kHEADER_BACKGROUND_COLOR_UP = UIColor(red: 148/255.0, green: 0/255.0, blue: 117/255.0, alpha: 1)
    static let kHEADER_BACKGROUND_COLOR_DOWN = UIColor(red: 212/255.0, green: 84/255.0, blue: 150/255.0, alpha: 1)
    static let kCOMMAND_BUTTON_BACKGROUND_COLOR = UIColor(red: 252/255.0, green: 197/255.0, blue: 210/255.0, alpha: 1)
    static let kSELECT_BACKGROUND_COLOR = UIColor(red: 255/255.0, green: 242/255.0, blue: 236/255.0, alpha: 1)
    static let kEDIT_SCREEN_BACKGROUND_COLOR = UIColor(red: 60/255.0, green: 5/255.0, blue: 0/255.0, alpha: 1)
    static let kACCENT_COLOR = UIColor(red: 199/255.0, green: 0/255.0, blue: 96/255.0, alpha: 1)
    static let kSTANDARD_TEXT_COLOR = UIColor(red: 56/255.0, green: 55/255.0, blue: 55/255.0, alpha: 1)
    static let kSTANDARD_VER_COLOR = UIColor(red: 225/255.0, green: 229/255.0, blue: 232/255.0, alpha: 1)
}

enum COLOR_SET003 {
    static let kHEADER_BACKGROUND_COLOR_UP = UIColor(red: 0/255.0, green: 109/255.0, blue: 134/255.0, alpha: 1)
    static let kHEADER_BACKGROUND_COLOR_DOWN = UIColor(red: 77/255.0, green: 139/255.0, blue: 155/255.0, alpha: 1)
    static let kCOMMAND_BUTTON_BACKGROUND_COLOR = UIColor(red: 189/255.0, green: 217/255.0, blue: 203/255.0, alpha: 1)
    static let kSELECT_BACKGROUND_COLOR = UIColor(red: 248/255.0, green: 242/255.0, blue: 226/255.0, alpha: 1)
    static let kEDIT_SCREEN_BACKGROUND_COLOR = UIColor(red: 20/255.0, green: 46/255.0, blue: 64/255.0, alpha: 1)
    static let kACCENT_COLOR = UIColor(red: 226/255.0, green: 137/255.0, blue: 212/255.0, alpha: 1)
    static let kSTANDARD_TEXT_COLOR = UIColor(red: 56/255.0, green: 55/255.0, blue: 55/255.0, alpha: 1)
    static let kSTANDARD_VER_COLOR = UIColor(red: 225/255.0, green: 229/255.0, blue: 232/255.0, alpha: 1)
}

enum COLOR_SET004 {
    static let kHEADER_BACKGROUND_COLOR_UP = UIColor(red: 59/255.0, green: 23/255.0, blue: 144/255.0, alpha: 1)
    static let kHEADER_BACKGROUND_COLOR_DOWN = UIColor(red: 130/255.0, green: 124/255.0, blue: 174/255.0, alpha: 1)
    static let kCOMMAND_BUTTON_BACKGROUND_COLOR = UIColor(red: 219/255.0, green: 182/255.0, blue: 242/255.0, alpha: 1)
    static let kSELECT_BACKGROUND_COLOR = UIColor(red: 224/255.0, green: 229/255.0, blue: 250/255.0, alpha: 1)
    static let kEDIT_SCREEN_BACKGROUND_COLOR = UIColor(red: 33/255.0, green: 13/255.0, blue: 75/255.0, alpha: 1)
    static let kACCENT_COLOR = UIColor(red: 125/255.0, green: 195/255.0, blue: 164/255.0, alpha: 1)
    static let kSTANDARD_TEXT_COLOR = UIColor(red: 56/255.0, green: 55/255.0, blue: 55/255.0, alpha: 1)
    static let kSTANDARD_VER_COLOR = UIColor(red: 225/255.0, green: 229/255.0, blue: 232/255.0, alpha: 1)
}

enum COLOR_SET005 {
    static let kHEADER_BACKGROUND_COLOR_UP = UIColor(red: 234/255.0, green: 0/255.0, blue: 85/255.0, alpha: 1)
    static let kHEADER_BACKGROUND_COLOR_DOWN = UIColor(red: 255/255.0, green: 92/255.0, blue: 85/255.0, alpha: 1)
    static let kCOMMAND_BUTTON_BACKGROUND_COLOR = UIColor(red: 226/255.0, green: 196/255.0, blue: 141/255.0, alpha: 1)
    static let kSELECT_BACKGROUND_COLOR = UIColor(red: 241/255.0, green: 245/255.0, blue: 244/255.0, alpha: 1)
    static let kEDIT_SCREEN_BACKGROUND_COLOR = UIColor(red: 60/255.0, green: 27/255.0, blue: 0/255.0, alpha: 1)
    static let kACCENT_COLOR = UIColor(red: 255/255.0, green: 90/255.0, blue: 66/255.0, alpha: 1)
    static let kSTANDARD_TEXT_COLOR = UIColor(red: 56/255.0, green: 55/255.0, blue: 55/255.0, alpha: 1)
    static let kSTANDARD_VER_COLOR = UIColor(red: 225/255.0, green: 229/255.0, blue: 232/255.0, alpha: 1)
}

enum COLOR_SET006 {
    static let kHEADER_BACKGROUND_COLOR_UP = UIColor(red: 28/255.0, green: 4/255.0, blue: 22/255.0, alpha: 1)
    static let kHEADER_BACKGROUND_COLOR_DOWN = UIColor(red: 13/255.0, green: 83/255.0, blue: 124/255.0, alpha: 1)
    static let kCOMMAND_BUTTON_BACKGROUND_COLOR = UIColor(red: 174/255.0, green: 174/255.0, blue: 196/255.0, alpha: 1)
    static let kSELECT_BACKGROUND_COLOR = UIColor(red: 241/255.0, green: 245/255.0, blue: 244/255.0, alpha: 1)
    static let kEDIT_SCREEN_BACKGROUND_COLOR = UIColor(red: 0/255.0, green: 15/255.0, blue: 28/255.0, alpha: 1)
    static let kACCENT_COLOR = UIColor(red: 177/255.0, green: 0/255.0, blue: 66/255.0, alpha: 1)
    static let kSTANDARD_TEXT_COLOR = UIColor(red: 56/255.0, green: 55/255.0, blue: 55/255.0, alpha: 1)
    static let kSTANDARD_VER_COLOR = UIColor(red: 225/255.0, green: 229/255.0, blue: 232/255.0, alpha: 1)
}

enum COLOR_SET007 {
    static let kHEADER_BACKGROUND_COLOR_UP = UIColor(red: 0/255.0, green: 128/255.0, blue: 127/255.0, alpha: 1)
    static let kHEADER_BACKGROUND_COLOR_DOWN = UIColor(red: 105/255.0, green: 174/255.0, blue: 151/255.0, alpha: 1)
    static let kCOMMAND_BUTTON_BACKGROUND_COLOR = UIColor(red: 196/255.0, green: 226/255.0, blue: 184/255.0, alpha: 1)
    static let kSELECT_BACKGROUND_COLOR = UIColor(red: 251/255.0, green: 239/255.0, blue: 215/255.0, alpha: 1)
    static let kEDIT_SCREEN_BACKGROUND_COLOR = UIColor(red: 70/255.0, green: 35/255.0, blue: 0/255.0, alpha: 1)
    static let kACCENT_COLOR = UIColor(red: 242/255.0, green: 131/255.0, blue: 142/255.0, alpha: 1)
    static let kSTANDARD_TEXT_COLOR = UIColor(red: 56/255.0, green: 55/255.0, blue: 55/255.0, alpha: 1)
    static let kSTANDARD_VER_COLOR = UIColor(red: 225/255.0, green: 229/255.0, blue: 232/255.0, alpha: 1)
}

//*****************************************************************
// MARK: - Message
//*****************************************************************

//general
enum MSG_ALERT {
    static let kALERT_FUNCTION_UNDER_CONSTRUCTION = "この機能は作成中です。"
    static let kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN = "ネットワークに接続できませんでした。 再度ネットワークの状態を確認してください。"
    static let kALERT_WRONG_PASSWORD = "パスワードが間違っています。正しいパスワードを入力してください。"
    static let kALERT_INPUT_PASSWORD = "パスワードを入力してください。"
    static let kALERT_INPUT_ACCOUNT_PASSWORD = "ログインパスワードを入力してください。"
    static let kALERT_INPUT_EMAIL = "メールアドレスを入力してください。"
    static let kALERT_INPUT_PHONE = "電話番号を入力してください。"
    static let kALERT_INPUT_DATE = "日付を入力してください"
    static let kALERT_AT_LEAST_INPUT_DATE_IN_A_ROW = "少なくとも1行に日付を入力してください"
    static let kALERT_INPUT_DATA = "データを入力してください"
    static let kALERT_SAVE_PHOTO_NOTIFICATION = "編集した画像を破棄しますよろしいですか?"
    static let kALERT_SAVE_MEMO_NOTIFICATION = "編集したメモを破棄しますよろしいですか?"
    static let kALERT_SAVE_DOCUMENT_NOTIFICATION = "編集したドキュメントを破棄しますよろしいですか?"
    static let kALERT_CANT_GET_DEVICE_STORAGE_LIMIT = "お客様アカウントスートレジの制限の読み込みに失敗しました。ネットワークの状態を確認してください。"
    
    //secret
    static let kALERT_UPDATE_SECRET_PASSWORD_SUCCESS = "シークレットメモのパスワードを更新しました。"
    
    //account
    static let kALERT_CANT_GET_ACCOUNT_INFO_PLEASE_CONTACT_SUPPORTER = "お客様情報を取得できませんでした。 サポートダイヤルへご連絡ください。"
    static let kALERT_ACCOUNT_CANT_ACCESS = "この機能はご利用いただけません。"
    static let kALERT_SERMENT_CANT_ACCESS = "選択された写真の枚数では、この動作を行う事は出来ません。"
    
    //customer
    static let kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK = "お客様の情報の読み込みに失敗しました。ネットワークの状態を確認してください。"
    static let kALERT_SEARCH_RESULTS_NOTHING = "検索結果がありませんでした。"
    static let kALERT_SELECT_CUSTOMER_2_DELETE = "削除するお客様を選択してください。"
    static let kALERT_CREATE_CUSTOMER_FIRST_ADD_SECRET_LATER = "シークレットメモを登録するには、先にお客様の登録を完了してください。"
    static let kALERT_INPUT_LAST_FIRST_NAME = "姓・名を入力してください。"
    static let kALERT_INPUT_LAST_FIRST_NAME_KANA = "姓 (かな) ・ 名 (かな) を入力してください。"
    static let kALERT_UPDATE_CUSTOMER_INFO_SUCCESS = "顧客情報を更新しました。"
    static let kALERT_CREATE_CUSTOMER_INFO_SUCCESS = "顧客情報を登録しました。"
    
    //carte
    static let kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK = "カルテの読み込みに失敗しました。ネットワークの状態を確認してください。"
    static let kALERT_CARTE_EXISTS_ALREADY = "既にカルテが存在しています。"
    static let kALERT_SELECT_CARTE_2_DELETE = "削除するカルテを選択してください。"
    static let kALERT_REGISTER_CARTE_REPRESENTATIVE_SUCCESS = "カルテの代表画像を登録しました。"
    static let kALERT_CANT_DELETE_CARTE = "カルテを削除に失敗しました。ネットワークの状態を確認してください。"
    
    //memo
    static let kALERT_CANT_GET_MEMO_INFO_PLEASE_CHECK_NETWORK = "メモの読込に失敗しました。ネットワークの状態を確認してください。"
    static let kALERT_CONFIRM_DELETE_MEMO_SELECTED = "選択されているメモを削除してよろしいですか?"
    static let kALERT_SELECT_MEMO_HAS_CONTENT_TO_DELETE = "内容があるメモを選択して下さい。"
    
    //stamp
    static let kALERT_CANT_GET_STAMP_INFO_PLEASE_CHECK_NETWORK = "スタンプを取得できませんでした。 サポートダイヤルへご連絡ください。"
    static let kALERT_INPUT_TITLE = "タイトルを入力してください。"
    static let kALERT_INPUT_CONTENT = "内容を入力してください。"
    static let kALERT_SELECT_TITLE_EDIT = "編集するタイトルを選択してください。"
    static let kALERT_CANT_SAVE_TITLE = "タイトルの保存に失敗しました。再度登録をしてください。"
    static let kALERT_UPDATE_TITLE_SUCCESS = "タイトルの保存が完了しました。"
    
    //keyword
    static let kALERT_SELECT_KEYWORD = "キーワードを追加する前にスタンプを選択してください。"
    static let kALERT_SELECT_KEYWORD_DELETE = "削除するキーワードを選択してください。"
    static let kALERT_SELECT_KEYWORD_EDIT = "編集するキーワードを選択してください。"
    static let kALERT_CANT_DELETE_KEYWORD = "削除するキーワードを選択してください。"
    static let kALERT_ADD_KEYWORD_SUCCESS = "キーワードの保存が完了しました。"
    static let kALERT_CANT_SAVE_KEYWORD = "キーワードの保存に失敗しました。再度登録をしてください。"
    static let kALERT_UPDATE_KEYWORD = "キーワードの編集が完了しました。"
    
    //shooting
    static let kALERT_CHECK_CAMERA_CONNECTION = "カメラに接続出来ませんでした。"
    static let kALERT_SHOOTING_TRANMISSION_NOT_SATISFY = "透過撮影をする場合は、画像を1枚だけ選択してください。"
    static let kALERT_SHOOTING_TRANMISSION_NOT_ALLOW = "このアカウントでは透過撮影できません。"
    
    //photo
    static let kALERT_CANT_GET_PHOTO_INFO_PLEASE_CHECK_NETWORK = "画像の保存に失敗しました。ネットワークの状態を確認してください。"
    static let kALERT_PLEASE_SELECT_PHOTO = "写真を選択してください。"
    static let kALERT_CANT_SAVE_PHOTO = "画像の保存に失敗しました。ネットワークの状態を確認してください。"
    static let kALERT_REACH_LIMIT_PHOTO = "このアカウントは写真の限界に達しました。"
    static let kALERT_CONFIRM_DELETE_PHOTO_SELECTED = "選択されている画像を削除してよろしいですか?"
    
    //drawing
    static let kALERT_DRAWING_ACCESS_NOT_SATISFY = "描画する画像を1枚選択してください。"
    static let kALERT_CHOOSE_2_TO_12_PHOTOS = "画像を2～12枚まで選択してください。"
    static let kALERT_UNLOCK_BEFORE_DRAWING = "描画する前にロックを解除してください。"
    static let kALERT_CHOOSE_FIGURE_TO_DRAW = "図を選択してください。"
    static let kALERT_SELECT_FAVORITE_COLOR = "好きな色を保存する番号を選択してください。"
    
    //documents
    static let kALERT_CANT_GET_DOCUMENT_INFO_PLEASE_CHECK_NETWORK = "ドキュメントの読み込みに失敗しました。ネットワークの状態を確認してください。"
    static let kALERT_SAME_TYPE_DOCUMENT = "同じデータが既に作成されています。"
    static let kALERT_CHECK_ALL_DOCUMENT_PAGE = "すべてのページを確認してください。"
    
    //comparison
    static let kALERT_SERMENT_2_PHOTOS_LIMITED = "比較画像の選択は2枚までです"
    static let kALERT_CHOOSE_ONLY_2_PHOTOS = "画像を2枚だけ選択してください。"
}
