//
//  Utils.swift
//  ABCarte2
//
//  Created by Long on 2018/05/09.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift
import Fabric
import Crashlytics
import SystemConfiguration
import SystemConfiguration.CaptiveNetwork
import Alamofire
import SwiftyJSON
import Accelerate

struct tupleR {
    var result: Bool
    var message: String
}

//*****************************************************************
// MARK: - Convert Bytes
//*****************************************************************

public struct Units {
    
    public let bytes: Int64
    
    public var kilobytes: Double {
        return Double(bytes) / 1_024
    }
    
    public var megabytes: Double {
        return kilobytes / 1_024
    }
    
    public var gigabytes: Double {
        return megabytes / 1_024
    }
    
    public init(bytes: Int64) {
        self.bytes = bytes
    }
    
    public func getReadableUnit() -> String {
        
        switch bytes {
        case 0..<1_024:
            return "\(bytes) bytes"
        case 1_024..<(1_024 * 1_024):
            return "\(String(format: "%.2f", kilobytes)) kb"
        case 1_024..<(1_024 * 1_024 * 1_024):
            return "\(String(format: "%.2f", megabytes)) mb"
        case (1_024 * 1_024 * 1_024)...Int64.max:
            return "\(String(format: "%.2f", gigabytes)) gb"
        default:
            return "\(bytes) bytes"
        }
    }
}

//*****************************************************************
// MARK: - Detect Device Info
//*****************************************************************

public enum Model : String {
    case simulator     = "simulator/sandbox",
    //iPod
    iPod1              = "iPod 1",
    iPod2              = "iPod 2",
    iPod3              = "iPod 3",
    iPod4              = "iPod 4",
    iPod5              = "iPod 5",
    //iPad
    iPad2              = "iPad 2",
    iPad3              = "iPad 3",
    iPad4              = "iPad 4",
    iPadAir            = "iPad Air ",
    iPadAir2           = "iPad Air 2",
    iPad5              = "iPad 5", //aka iPad 2017
    iPad6              = "iPad 6", //aka iPad 2018
    //iPad mini
    iPadMini           = "iPad Mini",
    iPadMini2          = "iPad Mini 2",
    iPadMini3          = "iPad Mini 3",
    iPadMini4          = "iPad Mini 4",
    //iPad pro
    iPadPro9_7         = "iPad Pro 9.7\"",
    iPadPro10_5        = "iPad Pro 10.5\"",
    iPadPro12_9        = "iPad Pro 12.9\"",
    iPadPro2_12_9      = "iPad Pro 2 12.9\"",
    //iPhone
    iPhone4            = "iPhone 4",
    iPhone4S           = "iPhone 4S",
    iPhone5            = "iPhone 5",
    iPhone5S           = "iPhone 5S",
    iPhone5C           = "iPhone 5C",
    iPhone6            = "iPhone 6",
    iPhone6plus        = "iPhone 6 Plus",
    iPhone6S           = "iPhone 6S",
    iPhone6Splus       = "iPhone 6S Plus",
    iPhoneSE           = "iPhone SE",
    iPhone7            = "iPhone 7",
    iPhone7plus        = "iPhone 7 Plus",
    iPhone8            = "iPhone 8",
    iPhone8plus        = "iPhone 8 Plus",
    iPhoneX            = "iPhone X",
    iPhoneXS           = "iPhone XS",
    iPhoneXSMax        = "iPhone XS Max",
    iPhoneXR           = "iPhone XR",
    //Apple TV
    AppleTV            = "Apple TV",
    AppleTV_4K         = "Apple TV 4K",
    unrecognized       = "?unrecognized?"
}

// #-#-#-#-#-#-#-#-#-#-#-#-#-#-#
//MARK: UIDevice extensions
// #-#-#-#-#-#-#-#-#-#-#-#-#-#-#

public extension UIDevice {
    public var type: Model {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
                
            }
        }
        var modelMap : [ String : Model ] = [
            "i386"      : .simulator,
            "x86_64"    : .simulator,
            //iPod
            "iPod1,1"   : .iPod1,
            "iPod2,1"   : .iPod2,
            "iPod3,1"   : .iPod3,
            "iPod4,1"   : .iPod4,
            "iPod5,1"   : .iPod5,
            //iPad
            "iPad2,1"   : .iPad2,
            "iPad2,2"   : .iPad2,
            "iPad2,3"   : .iPad2,
            "iPad2,4"   : .iPad2,
            "iPad3,1"   : .iPad3,
            "iPad3,2"   : .iPad3,
            "iPad3,3"   : .iPad3,
            "iPad3,4"   : .iPad4,
            "iPad3,5"   : .iPad4,
            "iPad3,6"   : .iPad4,
            "iPad4,1"   : .iPadAir,
            "iPad4,2"   : .iPadAir,
            "iPad4,3"   : .iPadAir,
            "iPad5,3"   : .iPadAir2,
            "iPad5,4"   : .iPadAir2,
            "iPad6,11"  : .iPad5, //aka iPad 2017
            "iPad6,12"  : .iPad5,
            "iPad7,5"   : .iPad6, //aka iPad 2018
            "iPad7,6"   : .iPad6,
            //iPad mini
            "iPad2,5"   : .iPadMini,
            "iPad2,6"   : .iPadMini,
            "iPad2,7"   : .iPadMini,
            "iPad4,4"   : .iPadMini2,
            "iPad4,5"   : .iPadMini2,
            "iPad4,6"   : .iPadMini2,
            "iPad4,7"   : .iPadMini3,
            "iPad4,8"   : .iPadMini3,
            "iPad4,9"   : .iPadMini3,
            "iPad5,1"   : .iPadMini4,
            "iPad5,2"   : .iPadMini4,
            //iPad pro
            "iPad6,3"   : .iPadPro9_7,
            "iPad6,4"   : .iPadPro9_7,
            "iPad7,3"   : .iPadPro10_5,
            "iPad7,4"   : .iPadPro10_5,
            "iPad6,7"   : .iPadPro12_9,
            "iPad6,8"   : .iPadPro12_9,
            "iPad7,1"   : .iPadPro2_12_9,
            "iPad7,2"   : .iPadPro2_12_9,
            //iPhone
            "iPhone3,1" : .iPhone4,
            "iPhone3,2" : .iPhone4,
            "iPhone3,3" : .iPhone4,
            "iPhone4,1" : .iPhone4S,
            "iPhone5,1" : .iPhone5,
            "iPhone5,2" : .iPhone5,
            "iPhone5,3" : .iPhone5C,
            "iPhone5,4" : .iPhone5C,
            "iPhone6,1" : .iPhone5S,
            "iPhone6,2" : .iPhone5S,
            "iPhone7,1" : .iPhone6plus,
            "iPhone7,2" : .iPhone6,
            "iPhone8,1" : .iPhone6S,
            "iPhone8,2" : .iPhone6Splus,
            "iPhone8,4" : .iPhoneSE,
            "iPhone9,1" : .iPhone7,
            "iPhone9,3" : .iPhone7,
            "iPhone9,2" : .iPhone7plus,
            "iPhone9,4" : .iPhone7plus,
            "iPhone10,1" : .iPhone8,
            "iPhone10,4" : .iPhone8,
            "iPhone10,2" : .iPhone8plus,
            "iPhone10,5" : .iPhone8plus,
            "iPhone10,3" : .iPhoneX,
            "iPhone10,6" : .iPhoneX,
            "iPhone11,2" : .iPhoneXS,
            "iPhone11,4" : .iPhoneXSMax,
            "iPhone11,6" : .iPhoneXSMax,
            "iPhone11,8" : .iPhoneXR,
            //AppleTV
            "AppleTV5,3" : .AppleTV,
            "AppleTV6,2" : .AppleTV_4K
        ]
        
        if let model = modelMap[String.init(validatingUTF8: modelCode!)!] {
            if model == .simulator {
                if let simModelCode = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
                    if let simModel = modelMap[String.init(validatingUTF8: simModelCode)!] {
                        return simModel
                    }
                }
            }
            return model
        }
        return Model.unrecognized
    }
}

//*****************************************************************
// MARK: - Fabric Log User Info
//*****************************************************************

public func logUserInfo(userName:String,userID:String) {
    Crashlytics.sharedInstance().setUserName(userName)
    Crashlytics.sharedInstance().setUserIdentifier(userID)
}

//*****************************************************************
// MARK: - Lock Screen Orientation
//*****************************************************************

struct AppUtility {
    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    
    /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
        
        self.lockOrientation(orientation)
        
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
    }
    
}

//*****************************************************************
// MARK: - UIView Convert UIImage
//*****************************************************************

extension UIView {
    
    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

//*****************************************************************
// MARK: - Get Document Directory Path
//*****************************************************************

public func getDocumentPath() -> String {
    let documentPaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,
                                                            FileManager.SearchPathDomainMask.userDomainMask, true)
    let documnetPath = documentPaths[0]
    return  documnetPath
}

//*****************************************************************
// MARK: - Delay
//*****************************************************************

public func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

//*****************************************************************
// MARK: - Show Alert
//*****************************************************************

public func showAlert(message :String,view:UIViewController) {
    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    let confirm = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    alert.addAction(confirm)
    DispatchQueue.main.async {
        view.present(alert, animated: true, completion: nil)
    }
}

//*****************************************************************
// MARK: - DateTime Convert
//*****************************************************************

public func convertUnixTimestampUK(time: Int)->String {
    let date = NSDate(timeIntervalSince1970: TimeInterval(time))
    let dayTimePeriodFormatter = DateFormatter()
    dayTimePeriodFormatter.locale = Locale(identifier: "ja_JP")
    dayTimePeriodFormatter.dateFormat = "YYYY-MM-dd"
    let dateString = dayTimePeriodFormatter.string(from: date as Date)
    
    return dateString
}

public func convertUnixTimestamp(time: Int)->String {
    let date = NSDate(timeIntervalSince1970: TimeInterval(time))
    let dayTimePeriodFormatter = DateFormatter()
    dayTimePeriodFormatter.locale = Locale(identifier: "ja_JP")
    dayTimePeriodFormatter.dateFormat = "yyyy年MM月dd日"
    let dateString = dayTimePeriodFormatter.string(from: date as Date)
    
    return dateString
}

public func convertUnixTimestampDT(time: Int)->String {
    let date = NSDate(timeIntervalSince1970: TimeInterval(time))
    let dayTimePeriodFormatter = DateFormatter()
    dayTimePeriodFormatter.locale = Locale(identifier: "ja_JP")
    dayTimePeriodFormatter.dateFormat = "yyyy年MM月dd日 HH時mm分ss秒"
    let dateString = dayTimePeriodFormatter.string(from: date as Date)
    
    return dateString
}

public func convertUnixTimestampT(time: Int)->String {
    let date = NSDate(timeIntervalSince1970: TimeInterval(time))
    let dayTimePeriodFormatter = DateFormatter()
    dayTimePeriodFormatter.locale = Locale(identifier: "ja_JP")
    dayTimePeriodFormatter.dateFormat = "HH時mm分ss秒"
    let dateString = dayTimePeriodFormatter.string(from: date as Date)
    
    return dateString
}

//*****************************************************************
// MARK: - Day Convert
//*****************************************************************

public func getDayOfWeek(_ day:String) -> String? {
//    let formatter  = DateFormatter()
//    formatter.dateFormat = "yyyy年MM月dd日"
//    formatter.locale = Locale(identifier: "ja_JP")
//    guard let todayDate = formatter.date(from: day) else { return nil }
//    let myCalendar = Calendar(identifier: .gregorian)
//    let weekDay = myCalendar.component(.weekday, from: todayDate)
//
//    let stringWeekDay = checkWeekDay(weekday: weekDay)
//    return stringWeekDay
    return ""
}

func checkWeekDay(weekday:Int) -> String{
    switch weekday {
    case 1:
        return " 日曜日"
    case 2:
        return " 月曜日"
    case 3:
        return " 火曜日"
    case 4:
        return " 水曜日"
    case 5:
        return " 木曜日"
    case 6:
        return " 金曜日"
    case 7:
        return " 土曜日"
    default:
        return " エラー"
    }
}

//*****************************************************************
// MARK: - BloodType Convert
//*****************************************************************

public func checkBloodType(type:Int) -> String{
    switch type {
    case 0:
        return "不明"
    case 1:
        return " A 型"
    case 2:
        return " B 型"
    case 3:
        return " O 型"
    case 4:
        return " AB 型"
    default:
        return "不明"
    }
}

//*****************************************************************
// MARK: - UIImageView Handler
//*****************************************************************

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}

public func roundImage(with Image: UIImageView) {
    Image.contentMode = UIViewContentMode.scaleAspectFill
    Image.layer.borderWidth = 1.0
    Image.layer.masksToBounds = false
    Image.layer.borderColor = UIColor.white.cgColor
    Image.layer.cornerRadius = (Image.frame.width)/2
    Image.clipsToBounds = true
}

public func saveImageToLocal(imageDownloaded:UIImage,name:String)->URL {
    // get the documents directory url
    let fileManger = FileManager.default
    let documentsDirectory = fileManger.urls(for: .documentDirectory, in: .userDomainMask).first!
    // choose a name for your image
    let fileName = "\(name).jpg"
    // create the destination file url to save your image
    let fileURL = documentsDirectory.appendingPathComponent(fileName)
    // get your UIImage jpeg data representation and check if the destination file url already exists
    let data = UIImagePNGRepresentation(imageDownloaded)

    if fileManger.fileExists(atPath: fileURL.path){
        do{
//            try fileManger.removeItem(atPath: fileURL.path)
            try data?.write(to: fileURL)
        }catch {
            print("error occurred, here are the details:\n \(error)")
        }
    } else {
        do{
            try data?.write(to: fileURL)
        }catch {
            print("error occurred, here are the details:\n \(error)")
        }
    }

    return fileURL
}

//*****************************************************************
// MARK: - Check Number Valid
//*****************************************************************

public extension String {
    func isNumber() -> Bool {
        let numberCharacters = NSCharacterSet.decimalDigits.inverted
        return !self.isEmpty && self.rangeOfCharacter(from: numberCharacters) == nil
    }

    var isPhoneNumber: Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSMakeRange(0, self.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == self.count
            } else {
                return false
            }
        } catch {
            return false
        }
    }
}

//*****************************************************************
// MARK: - Gradient View
//*****************************************************************

extension UIView {
    func applyGradient(colours: [UIColor]) -> Void {
        self.applyGradient(colours: colours, locations: nil)
    }
    
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> Void {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
    }
}

//*****************************************************************
// MARK: - Gradient Navigation
//*****************************************************************

extension UINavigationBar
{
    /// Applies a background gradient with the given colors
    func apply(gradient colors : [UIColor]) {
        var frameAndStatusBar: CGRect = self.bounds
        frameAndStatusBar.size.height += 20 // add 20 to account for the status bar
        
        setBackgroundImage(UINavigationBar.gradient(size: frameAndStatusBar.size, colors: colors), for: .default)
    }
    
    /// Creates a gradient image with the given settings
    static func gradient(size : CGSize, colors : [UIColor]) -> UIImage?
    {
        // Turn the colors into CGColors
        let cgcolors = colors.map { $0.cgColor }
        
        // Begin the graphics context
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        
        // If no context was retrieved, then it failed
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // From now on, the context gets ended if any return happens
        defer { UIGraphicsEndImageContext() }
        
        // Create the Coregraphics gradient
        var locations : [CGFloat] = [0.0, 1.0]
        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: cgcolors as NSArray as CFArray, locations: &locations) else { return nil }
        
        // Draw the gradient
        context.drawLinearGradient(gradient, start: CGPoint(x: size.width/2, y: 0.0), end: CGPoint(x: size.width/2, y: size.height), options: [])
        
        // Generate the image (the defer takes care of closing the context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

public func addNavigationBarColor(navigation: UINavigationController,type:Int) {
    switch type {
    case 0:
        navigation.navigationBar.apply(gradient: [COLOR_SET000.kHEADER_BACKGROUND_COLOR_UP,COLOR_SET000.kHEADER_BACKGROUND_COLOR_DOWN])
    case 1:
        navigation.navigationBar.apply(gradient: [COLOR_SET001.kHEADER_BACKGROUND_COLOR_UP,COLOR_SET001.kHEADER_BACKGROUND_COLOR_DOWN])
    case 2:
        navigation.navigationBar.apply(gradient: [COLOR_SET002.kHEADER_BACKGROUND_COLOR_UP,COLOR_SET002.kHEADER_BACKGROUND_COLOR_DOWN])
    case 3:
        navigation.navigationBar.apply(gradient: [COLOR_SET003.kHEADER_BACKGROUND_COLOR_UP,COLOR_SET003.kHEADER_BACKGROUND_COLOR_DOWN])
    case 4:
        navigation.navigationBar.apply(gradient: [COLOR_SET004.kHEADER_BACKGROUND_COLOR_UP,COLOR_SET004.kHEADER_BACKGROUND_COLOR_DOWN])
    case 5:
        navigation.navigationBar.apply(gradient: [COLOR_SET005.kHEADER_BACKGROUND_COLOR_UP,COLOR_SET005.kHEADER_BACKGROUND_COLOR_DOWN])
    case 6:
        navigation.navigationBar.apply(gradient: [COLOR_SET006.kHEADER_BACKGROUND_COLOR_UP,COLOR_SET006.kHEADER_BACKGROUND_COLOR_DOWN])
    case 7:
        navigation.navigationBar.apply(gradient: [COLOR_SET007.kHEADER_BACKGROUND_COLOR_UP,COLOR_SET007.kHEADER_BACKGROUND_COLOR_DOWN])
    default:
        break
    }
}

//*****************************************************************
// MARK: - Compare Date
//*****************************************************************

extension Date {
    func isInSameWeek(date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .weekOfYear)
    }
    func isInSameMonth(date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .month)
    }
    func isInSameYear(date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .year)
    }
    func isInSameDay(date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .day)
    }
    var isInThisWeek: Bool {
        return isInSameWeek(date: Date())
    }
    var isInToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    var isInTheFuture: Bool {
        return Date() < self
    }
    var isInThePast: Bool {
        return self < Date()
    }
    static var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: Date().noon)!
    }
    static var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: Date().noon)!
    }
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
}

//*****************************************************************
// MARK: - Image Resize (width)
//*****************************************************************

public func imageWithImage (sourceImage:UIImage, scaledToWidth: CGFloat) -> UIImage {
    let oldWidth = sourceImage.size.width
    let scaleFactor = scaledToWidth / oldWidth
    
    let newHeight = sourceImage.size.height * scaleFactor
    let newWidth = oldWidth * scaleFactor
    
    UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
    sourceImage.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage!
}

//*****************************************************************
// MARK: - Merge Two UIImage
//*****************************************************************

public func mergeTwoUIImage(topImage:UIImage,bottomImage:UIImage,width:CGFloat,height:CGFloat)->UIImage {
    let botImg = bottomImage
    let topImg = topImage

    let size = CGSize(width: width, height: height)
    UIGraphicsBeginImageContext(size)
    
    let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    botImg.draw(in: areaSize)
    topImg.draw(in: areaSize, blendMode: .normal, alpha: 1)
    
    let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return newImage
}

//*****************************************************************
// MARK: - UIImage Fix Orientation
//*****************************************************************

extension UIImage {
    
    func crop(to:CGSize) -> UIImage {
        guard let cgimage = self.cgImage else { return self }
        
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        
        let contextSize: CGSize = contextImage.size
        
        //Set to square
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        let cropAspect: CGFloat = to.width / to.height
        
        var cropWidth: CGFloat = to.width
        var cropHeight: CGFloat = to.height
        
        if to.width > to.height { //Landscape
            cropWidth = contextSize.width
            cropHeight = contextSize.width / cropAspect
            posY = (contextSize.height - cropHeight) / 2
        } else if to.width < to.height { //Portrait
            cropHeight = contextSize.height
            cropWidth = contextSize.height * cropAspect
            posX = (contextSize.width - cropWidth) / 2
        } else { //Square
            if contextSize.width >= contextSize.height { //Square on landscape (or square)
                cropHeight = contextSize.height
                cropWidth = contextSize.height * cropAspect
                posX = (contextSize.width - cropWidth) / 2
            }else{ //Square on portrait
                cropWidth = contextSize.width
                cropHeight = contextSize.width / cropAspect
                posY = (contextSize.height - cropHeight) / 2
            }
        }
        
        let rect: CGRect = CGRect(x : posX, y : posY, width : cropWidth, height : cropHeight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let cropped: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        
        cropped.draw(in: CGRect(x : 0, y : 0, width : to.width, height : to.height))
        
        return cropped
    }
    
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in:UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: image!.cgImage!)
    }
    
    func updateImageOrientionUpSide() -> UIImage? {
        if self.imageOrientation == .up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        if let normalizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        }
        UIGraphicsEndImageContext()
        return nil
    }
    
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func resizeImageUsingVImage(size:CGSize) -> UIImage? {
        let cgImage = self.cgImage!
        var format = vImage_CGImageFormat(bitsPerComponent: 8, bitsPerPixel: 32, colorSpace: nil, bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue), version: 0, decode: nil, renderingIntent: CGColorRenderingIntent.defaultIntent)
        var sourceBuffer = vImage_Buffer()
        defer {
            free(sourceBuffer.data)
        }
        var error = vImageBuffer_InitWithCGImage(&sourceBuffer, &format, nil, cgImage, numericCast(kvImageNoFlags))
        guard error == kvImageNoError else { return nil }
        // create a destination buffer
        let scale = self.scale
        let destWidth = Int(size.width)
        let destHeight = Int(size.height)
        let bytesPerPixel = self.cgImage!.bitsPerPixel/8
        let destBytesPerRow = destWidth * bytesPerPixel
        let destData = UnsafeMutablePointer<UInt8>.allocate(capacity: destHeight * destBytesPerRow)
        defer {
            destData.deallocate()
//            destData.deallocate(capacity: destHeight * destBytesPerRow)
        }
        var destBuffer = vImage_Buffer(data: destData, height: vImagePixelCount(destHeight), width: vImagePixelCount(destWidth), rowBytes: destBytesPerRow)
        // scale the image
        error = vImageScale_ARGB8888(&sourceBuffer, &destBuffer, nil, numericCast(kvImageHighQualityResampling))
        guard error == kvImageNoError else { return nil }
        // create a CGImage from vImage_Buffer
        var destCGImage = vImageCreateCGImageFromBuffer(&destBuffer, &format, nil, nil, numericCast(kvImageNoFlags), &error)?.takeRetainedValue()
        guard error == kvImageNoError else { return nil }
        // create a UIImage
        let resizedImage = destCGImage.flatMap { UIImage(cgImage: $0, scale: 0.0, orientation: self.imageOrientation) }
        destCGImage = nil
        return resizedImage
    }
}

//*****************************************************************
// MARK: - UIApplication
//*****************************************************************

extension UIApplication {
    class func tryURL(urls: [String]) {
        let application = UIApplication.shared
        for url in urls {
            if application.canOpenURL(URL(string: url)!) {
                application.open(URL(string: url)!, options: [:], completionHandler: nil)
                return
            }
        }
    }
}

//*****************************************************************
// MARK: - Email Validation
//*****************************************************************

public func isValidEmail(email:String) -> Bool {
  
    let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    let result = emailTest.evaluate(with: email)
    return result
}

//*****************************************************************
// MARK: - Phone Validation
//*****************************************************************

func isValidPhone(phone: String) -> Bool {
    let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
    let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
    let result =  phoneTest.evaluate(with: phone)
    return result
}

//*****************************************************************
// MARK: - Color Hex Convert
//*****************************************************************

extension UIColor {
    var hexString: String {
        let colorRef = cgColor.components
        let r = colorRef?[0] ?? 0
        let g = colorRef?[1] ?? 0
        let b = ((colorRef?.count ?? 0) > 2 ? colorRef?[2] : g) ?? 0
        let a = cgColor.alpha
        
        var color = String(
            format: "#%02lX%02lX%02lX",
            lroundf(Float(r * 255)),
            lroundf(Float(g * 255)),
            lroundf(Float(b * 255))
        )
        
        if a < 1 {
            color += String(format: "%02lX", lroundf(Float(a)))
        }
        
        return color
    }
}

func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

//*****************************************************************
// MARK: - Display App 's Info
//*****************************************************************

func displayInfo(acc_name:String,acc_id:String,view:UIViewController) {
    let version = Bundle.main.infoDictionary!["CFBundleVersion"]!
    let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
    
    let alert = UIAlertController(title: "アプリ情報", message: "\n\(appName) ver \(version)", preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    
    DispatchQueue.main.async {
        view.present(alert, animated: true, completion: nil)
    }
}

//*****************************************************************
// MARK: - Check Internet Connection
//*****************************************************************

//Get Wifi Connected's Name
func getWiFiSsid() -> String? {
    var ssid: String?
    if let interfaces = CNCopySupportedInterfaces() as NSArray? {
        for interface in interfaces {
            if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                break
            }
        }
    }
    return ssid
}

//Check Internet Connection
//public class Reachability {
//    
//    class func isConnectedToNetwork() -> Bool {
//        
//        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
//        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
//        zeroAddress.sin_family = sa_family_t(AF_INET)
//        
//        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
//            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
//                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
//            }
//        }
//        
//        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
//        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
//            return false
//        }
//        
//        /* Only Working for WIFI
//         let isReachable = flags == .reachable
//         let needsConnection = flags == .connectionRequired
//         
//         return isReachable && !needsConnection
//         */
//        
//        // Working for Cellular and WIFI
//        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
//        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
//        let ret = (isReachable && !needsConnection)
//        
//        return ret
//        
//    }
//}

//*****************************************************************
// MARK: - Get Location From Postal Code
//*****************************************************************

//Get location from api zipaddress
func getLocationFromPostalCode(postalCode : String,completion: @escaping StringCompletion) {
    
    let url = "https://api.zipaddress.net/?zipcode=\(postalCode)"
    
    Alamofire.request(url, method: .get, parameters: nil, encoding:  JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
        
        switch(response.result) {
            
        case.success(let data):
            let json = JSON(data)
            let code = json["code"]
            if code == 200 {
                
                guard let fulladd = json["data"]["fullAddress"].stringValue as String? else { return }
                
                completion(true,fulladd)
                
            } else {
                
                guard let msg = json["message"].stringValue as String? else { return }
                
                completion(false,msg)
            }
        case.failure(let error):
            print(error)
        }
    }
}

//*****************************************************************
// MARK: - Get Header Key Value from URL Response
//*****************************************************************

func onConvertHeaderResult(res: HTTPURLResponse) {
    
    let keyValues = res.allHeaderFields.map { (String(describing: $0.key).lowercased(), String(describing: $0.value)) }
    
    // Now filter the array, searching for your header-key, also lowercased
    if let myHeaderValue = keyValues.filter({ $0.0 == "X-Pagination-Page-Count".lowercased() }).first {
        GlobalVariables.sharedManager.pageTotal = Int(myHeaderValue.1)
    } else {
        GlobalVariables.sharedManager.pageTotal = 1
    }
    
    //get total customer
    if let myHeaderValue = keyValues.filter({ $0.0 == "X-Pagination-Total-Count".lowercased() }).first {
        GlobalVariables.sharedManager.totalCus = Int(myHeaderValue.1)
    } else {
        GlobalVariables.sharedManager.totalCus = 0
    }
    
    //get current page
    if let myHeaderValue = keyValues.filter({ $0.0 == "X-Pagination-Current-Page".lowercased() }).first {
        GlobalVariables.sharedManager.pageCurr = Int(myHeaderValue.1)
    } else {
        GlobalVariables.sharedManager.pageCurr = 1
    }
}

//*****************************************************************
// MARK: - Printer
//*****************************************************************

func printUrl(_ url: URL) {
    guard (UIPrintInteractionController.canPrint(url)) else {
        Swift.print("Unable to print: \(url)")
        return
    }
    
    showPrintInteraction(url)
}

func showPrintInteraction(_ url: URL) {
    let controller = UIPrintInteractionController.shared
    controller.accessibilityLanguage = "ja"
    controller.printingItem = url
    controller.printInfo = printerInfo(url.lastPathComponent)
    controller.present(animated: true, completionHandler: nil)
}

func printerInfo(_ jobName: String) -> UIPrintInfo {
    let printInfo = UIPrintInfo.printInfo()
    printInfo.outputType = .general
    printInfo.jobName = jobName
    Swift.print("Printing: \(jobName)")
    return printInfo
}

//*****************************************************************
// MARK: - Tableview
//*****************************************************************

extension UITableView {
    
    public func reloadData(_ completion: @escaping ()->()) {
        UIView.animate(withDuration: 0, animations: {
            self.reloadData()
        }, completion:{ _ in
            completion()
        })
    }
    
    func scroll(to: scrollsTo, animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            let numberOfSections = self.numberOfSections
            let numberOfRows = self.numberOfRows(inSection: numberOfSections-1)
            switch to{
            case .top:
                if numberOfRows > 0 {
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.scrollToRow(at: indexPath, at: .top, animated: animated)
                }
                break
            case .bottom:
                if numberOfRows > 0 {
                    let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                    self.scrollToRow(at: indexPath, at: .bottom, animated: animated)
                }
                break
            }
        }
    }
    
    enum scrollsTo {
        case top,bottom
    }
}

//*****************************************************************
// MARK: - Round Corner Top of UIButton
//*****************************************************************

extension UIButton {
    func roundTopCorner(){
        let maskPAth1 = UIBezierPath(roundedRect: self.bounds,
                                     byRoundingCorners: [.topLeft , .topRight],
                                     cornerRadii:CGSize(width:8.0, height:8.0))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = self.bounds
        maskLayer1.path = maskPAth1.cgPath
        self.layer.mask = maskLayer1
    }
}

//*****************************************************************
// MARK: - Color Style
//*****************************************************************

//Button
public func setButtonColorStyle(button:UIButton,type:Int) {
    if let set = UserDefaults.standard.integer(forKey: "colorset") as Int? {
        switch set {
        case 0:
            if type == 0 {
                button.backgroundColor = COLOR_SET000.kACCENT_COLOR
            } else {
                button.backgroundColor = COLOR_SET000.kCOMMAND_BUTTON_BACKGROUND_COLOR
            }
        case 1:
            if type == 0 {
                button.backgroundColor = COLOR_SET001.kACCENT_COLOR
            } else {
                button.backgroundColor = COLOR_SET001.kCOMMAND_BUTTON_BACKGROUND_COLOR
            }
        case 2:
            if type == 0 {
                button.backgroundColor = COLOR_SET002.kACCENT_COLOR
            } else {
                button.backgroundColor = COLOR_SET002.kCOMMAND_BUTTON_BACKGROUND_COLOR
            }
        case 3:
            if type == 0 {
                button.backgroundColor = COLOR_SET003.kACCENT_COLOR
            } else {
                button.backgroundColor = COLOR_SET003.kCOMMAND_BUTTON_BACKGROUND_COLOR
            }
        case 4:
            if type == 0 {
                button.backgroundColor = COLOR_SET004.kACCENT_COLOR
            } else {
                button.backgroundColor = COLOR_SET004.kCOMMAND_BUTTON_BACKGROUND_COLOR
            }
        case 5:
            if type == 0 {
                button.backgroundColor = COLOR_SET005.kACCENT_COLOR
            } else {
                button.backgroundColor = COLOR_SET005.kCOMMAND_BUTTON_BACKGROUND_COLOR
            }
        case 6:
            if type == 0 {
                button.backgroundColor = COLOR_SET006.kACCENT_COLOR
            } else {
                button.backgroundColor = COLOR_SET006.kCOMMAND_BUTTON_BACKGROUND_COLOR
            }
        case 7:
            if type == 0 {
                button.backgroundColor = COLOR_SET007.kACCENT_COLOR
            } else {
                button.backgroundColor = COLOR_SET007.kCOMMAND_BUTTON_BACKGROUND_COLOR
            }
        default:
            break
        }
    }
}

//View
public func setViewColorStyle(view:UIView,type:Int) {
    if let set = UserDefaults.standard.integer(forKey: "colorset") as Int? {
        switch set {
        case 0:
            if type == 0 {
                view.backgroundColor = COLOR_SET000.kACCENT_COLOR
            } else {
                view.backgroundColor = COLOR_SET000.kCOMMAND_BUTTON_BACKGROUND_COLOR
            }
        case 1:
            if type == 0 {
                view.backgroundColor = COLOR_SET001.kACCENT_COLOR
            } else {
                view.backgroundColor = COLOR_SET001.kCOMMAND_BUTTON_BACKGROUND_COLOR
            }
        case 2:
            if type == 0 {
                view.backgroundColor = COLOR_SET002.kACCENT_COLOR
            } else {
                view.backgroundColor = COLOR_SET002.kCOMMAND_BUTTON_BACKGROUND_COLOR
            }
        case 3:
            if type == 0 {
                view.backgroundColor = COLOR_SET003.kACCENT_COLOR
            } else {
                view.backgroundColor = COLOR_SET003.kCOMMAND_BUTTON_BACKGROUND_COLOR
            }
        case 4:
            if type == 0 {
                view.backgroundColor = COLOR_SET004.kACCENT_COLOR
            } else {
                view.backgroundColor = COLOR_SET004.kCOMMAND_BUTTON_BACKGROUND_COLOR
            }
        case 5:
            if type == 0 {
                view.backgroundColor = COLOR_SET005.kACCENT_COLOR
            } else {
                view.backgroundColor = COLOR_SET005.kCOMMAND_BUTTON_BACKGROUND_COLOR
            }
        case 6:
            if type == 0 {
                view.backgroundColor = COLOR_SET006.kACCENT_COLOR
            } else {
                view.backgroundColor = COLOR_SET006.kCOMMAND_BUTTON_BACKGROUND_COLOR
            }
        case 7:
            if type == 0 {
                view.backgroundColor = COLOR_SET007.kACCENT_COLOR
            } else {
                view.backgroundColor = COLOR_SET007.kCOMMAND_BUTTON_BACKGROUND_COLOR
            }
        default:
            break
        }
    }
}
