//
//  Defines.swift
//  ABCarte2
//
//  Created by Long on 2018/05/15.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import Foundation

//*****************************************************************
// MARK: - Popup Style
//*****************************************************************

enum PopUpType:Int{
    case AddNew = 1
    case Edit = 2
    case Review = 3
}

//*****************************************************************
// MARK: - Document Style
//*****************************************************************

enum DocType:Int{
    case Consent
    case Counseling
}

//*****************************************************************
// MARK: - Document Style
//*****************************************************************

enum ImageResolution:Int{
    case low = 0
    case medium = 1
    case high = 2
}

//*****************************************************************
// MARK: - Functions Type
//*****************************************************************

enum AppFunctions:Int{
    case kMultiLanguage = 1
    case kFreeword = 2
    case kStamp = 3
    case kSecretMemo = 4
    case kCompareTranmission = 5
    case kMorphing = 6
    case kShootingTranmission = 7
    case kTextSticker = 8
    case kDrawingPrinter = 9
    case kComparePrinter = 10
    case kCounselling = 11
    case kConsent = 12
    case kJBrowOperation = 13
    case kJBrowPractice = 14
    case kFullStampSticker = 15
    case kMosaic = 16
    case kPenSize = 17
}
