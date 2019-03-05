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
    case Counselling
    case Handwritting
    case Outline
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
//    case kFreeword = 2
//    case kStamp = 3
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
    case kCalendar = 18
    case kPhotoResolution = 19
    case kSilhouette = 20
    case kEyeDrop = 21
    case kOpacity = 22
    case kCarteDocs = 23
    case kAdditionalDoc = 24
}

//*****************************************************************
// MARK: - Functions Type
//*****************************************************************

enum alphabetIndex: Int {
    case A = 1
    case Ka = 2
    case Sa = 3
    case Ta = 4
    case Na = 5
    case Ha = 6
    case Ma = 7
    case Ya = 8
    case Ra = 9
    case Wa = 10
    case AG = 11
    case HN = 12
    case OU = 13
    case VZ = 14
    case All = 15
}
