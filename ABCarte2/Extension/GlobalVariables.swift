//
//  GlobalVariables.swift
//  ABCarte2
//
//  Created by Long on 2018/05/09.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import Foundation

class GlobalVariables {

    //pagination load
    public var pageTotal: Int?
    public var pageCurr: Int?
    public var totalCus: Int?
    
    //cell selection
    public var selectedImageIds: [String] = []
    
    //checkbox
    public var onMultiSelect: Bool?
    
    //app limition
    public var appLimitation: [Int] = []
    
    //favorite colors
    public var accFavoriteColors: [String] = []
    
    //company name
    public var comName: String?
    
    class var sharedManager: GlobalVariables {
        struct Static{
            static let instance = GlobalVariables()
        }
        return Static.instance
    }
    
    func clearData() {
        
    }
}
