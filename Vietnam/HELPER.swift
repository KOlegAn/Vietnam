
//
//  SwitchCategory.swift
//  Vietnam
//
//  Created by Oleg Kuplin on 29.11.16.
//  Copyright © 2016 Oleg Kuplin. All rights reserved.
//

import Foundation
import CoreData
import Alamofire


public struct HELPER {
    
        
    
    public static func switchCatLang(categoryRName: String) -> String {
        
        switch categoryRName {
        case "Работа":
            return "Jobs"
        case "Жилье":
            return "Lodging"
        case "Услуги":
            return "Service"
        case "Мото":
            return "Moto"
        case "Нужна помощь":
            return "NeedHelp"
        case "Обмен":
            return "Exchange"
        case "Привезти":
            return "Bring"
        case "Бюро находок":
            return "LostAndFound"
        case "Обучение":
            return "Education"
        case "Электроника":
            return "Electronics"
        case "Животные":
            return "Animals"
        case "Другие":
            return "Others"
        default:
            return ""
        }
    }
    
    
    public static func getSubcategory(categoryName: String) -> [String] {
        
        var result = [String]()
        
        switch categoryName {
        case "Работа":
            result = ["Вакансия", "Резюме"]
            break
        case "Жилье":
            result = ["Сдам", "Сниму"]
            break
        case "Услуги":
            result = ["Предлагаю", "Ищу"]
            break
        case "Мото":
            result = ["Сдам в аренду", "Сниму в аренду", "Куплю", "Продам"]
            break
        case "Привезти":
            result = ["Привезти", "Передать"]
            break
        case "Бюро находок":
            result = ["Найдено", "Потеряно"]
            break
        case "Обучение":
            result = ["Обучу", "Научусь"]
            break
        case "Электроника":
            result = ["Куплю", "Продам"]
            break
        default:
            result = []
            break
        }
        return result
    
    }


    public static func switchItemName(itemName: String) -> String {
        switch itemName {
        case "Имя":
            return "firstname"
        case "Ник":
            return "nickname"
        case "Пол":
            return "sex"
        case "Тел. Номер":
            return "telnum"
        default:
            return ""
        }
        
    }
    
    
    public static func checkString(stringForCheck: String) -> String {
        
        var finalString = (stringForCheck as NSString).replacingOccurrences(of: "&", with: "aNdApPeNdSigN")
        finalString = (finalString as NSString).replacingOccurrences(of: "\\", with: "SeParEteBucKSiGn")
        finalString = (finalString as NSString).replacingOccurrences(of: "'", with: "QuOtaTioNMarK")
        finalString = (finalString as NSString).replacingOccurrences(of: "+", with: "PlUsSiGnN")

        
        
        return finalString
    }
    
    
    public static func returnString(stringForReturn: String) -> String {
        
        var finalString = (stringForReturn as NSString).replacingOccurrences(of: "aNdApPeNdSigN", with: "&")
        finalString = (finalString as NSString).replacingOccurrences(of: "SeParEteBucKSiGn", with: "\\")
        finalString = (finalString as NSString).replacingOccurrences(of: "QuOtaTioNMarK", with: "'")
        finalString = (finalString as NSString).replacingOccurrences(of: "PlUsSiGnN", with: "+")

        
        return finalString
    }
    
    
    public static func loadAds() {
        
        let url = "http://invietnam.website/vietnam/ads.php?request=getjson"
        Alamofire.request(url).responseJSON { response in
            //to get status code
            if let status = response.response?.statusCode {
                switch(status){
                case 201:
                    print("example success")
                default:
                    print("Error")
                    
                }
            }
            //to get JSON return value
            if let result = response.result.value {
                
                let jsonData = JSON(data: response.data!)
                let ads = jsonData.arrayObject as! Array<NSObject>
                let defaults = UserDefaults.standard
                defaults.set(ads, forKey: "ads")

                print("DONE")
                
            }
            
        }
        
    }
    
    
    public static func getAds() -> Array<NSObject> {
        
        let defaults = UserDefaults.standard
        var ads = defaults.value(forKey: "ads") as! Array<NSObject>
        
        ads = ads.sorted(by: {($0.value(forKey: "date") as! String) > ($1.value(forKey: "date") as! String)})

        return ads
    }
    
    
    
    
    public static func managedObjectContext() -> NSManagedObjectContext{
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var context: NSManagedObjectContext?
        if #available(iOS 10.0, *) {
            context = appDelegate.persistentContainer.viewContext
        } else {
            context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        }
        
        return context!
    }
    
    public static func saveUser(email: String, vkid: String, telnum: String, name: String, nickname: String, sex: String, id: String, state: Int) {

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Isregistered")
        let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        let fetchRequest1 = NSFetchRequest<NSFetchRequestResult>(entityName: "Avatar")
        let request1 = NSBatchDeleteRequest(fetchRequest: fetchRequest1)
        
        do {
            _ = try HELPER.managedObjectContext().execute(request)
            _ = try HELPER.managedObjectContext().execute(request1)
            
        } catch {
            print("Error")
        }
        print("Deleted")
        
        print("Saving user")
        let newUser = NSEntityDescription.insertNewObject(forEntityName: "Isregistered", into: HELPER.managedObjectContext())
        newUser.setValue(email, forKey: "email")
        newUser.setValue(name, forKey: "name")
        newUser.setValue(sex, forKey: "sex")
        newUser.setValue(state, forKey: "state")
        newUser.setValue(vkid, forKey: "vkid")
        newUser.setValue(telnum, forKey: "telnum")
        newUser.setValue(id, forKey: "id")
        newUser.setValue(nickname, forKey: "nickname")
        
        print("New user saved")
        
    }
    
    
    public static func deleteUser(){

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Isregistered")
        let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        let fetchRequest1 = NSFetchRequest<NSFetchRequestResult>(entityName: "Avatar")
        let request1 = NSBatchDeleteRequest(fetchRequest: fetchRequest1)
        
        do {
            _ = try HELPER.managedObjectContext().execute(request)
            _ = try HELPER.managedObjectContext().execute(request1)

        } catch {
            print("Error")
        }
        print("Deleted")
    }
    
    public static func getUser() -> NSObject {
        
        var user = NSObject()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Isregistered")
        
        do {
            let fetchedResult = try HELPER.managedObjectContext().fetch(fetchRequest)
            let model = fetchedResult as! [NSManagedObject]
            print("I have \(model.count) users now oO")
            if model.count == 0 {
                
            } else {
                user = model[0]
            }
            
        } catch {
            print("Error while fetching occured")
        }
        
        return user
        
    }
    
    
    public static func getUserAvatar() -> UIImage {
        
        var user = UIImage()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Avatar")
        
        do {
            let fetchedResult = try HELPER.managedObjectContext().fetch(fetchRequest)
            let avatar = fetchedResult as! [NSManagedObject]
            if avatar.count == 0 {
                
            } else {
                let avatarData = avatar[0].value(forKey: "avatar") as! Data
                user = UIImage(data: avatarData)!
            }
            
        } catch {
            print("Error while fetching occured")
        }
        
        return user
        
    }
    
    
    public static func changeUserAvatar() -> NSObject {
        
        var user = NSObject()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Avatar")
        
        do {
            let fetchedResult = try HELPER.managedObjectContext().fetch(fetchRequest)
            let avatar = fetchedResult as! [NSManagedObject]
            if avatar.count == 0 {
                
            } else {
//                let avatarData = avatar[0].value(forKey: "avatar") as! Data
//                user = UIImage(data: avatarData)!
                user = avatar[0]
            }
            
        } catch {
            print("Error while fetching occured")
        }
        
        return user
        
    }
    
    
    public static func saveUserAvatar(userId: String) {
        
        if let url = URL(string: "http://invietnam.website/vietnam/userspics/\(userId).png") {
            print(url)
            DispatchQueue.global().async {
                
                if let data = try? Data(contentsOf: url) != nil {
                    DispatchQueue.main.async {
                        let trueData = try? Data(contentsOf: url)
                        let image = UIImage(data: trueData!)
                        let avatar = NSData(data: UIImagePNGRepresentation(image!)!)
                        
//                        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Avatar")
//                        let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                        
                        do {
                            //_ = try HELPER.managedObjectContext().execute(request)
                        } catch {
                            print("Error")
                        }
                        
                        
                        print("Saving user")
                        let newUser = NSEntityDescription.insertNewObject(forEntityName: "Avatar", into: HELPER.managedObjectContext())
                        newUser.setValue(avatar, forKey: "avatar")
                        print("Avatar saved")
                        
                    }
                } else {
                    let image = #imageLiteral(resourceName: "me")
                    let avatar = NSData(data: UIImagePNGRepresentation(image)!)
                    
                    print("Saving user")
                    let newUser = NSEntityDescription.insertNewObject(forEntityName: "Avatar", into: HELPER.managedObjectContext())
                    newUser.setValue(avatar, forKey: "avatar")
                    print("Avatar saved")
                    print("Don't have data")
                }
            }
        }
    }
    
    
    public static func saveNewFavorite(id: String, name: String, nickname: String, date: String, body: String, header: String, city: String, category: String, subcategory: String, telnum: String, info: String, pictures: String) {
        
        print("Saving favorite")
        let newFavorite = NSEntityDescription.insertNewObject(forEntityName: "Favorites", into: HELPER.managedObjectContext())

        newFavorite.setValue(id, forKey: "id")
        newFavorite.setValue(name, forKey: "name")
        newFavorite.setValue(nickname, forKey: "nickname")
        newFavorite.setValue(date, forKey: "date")
        newFavorite.setValue(body, forKey: "body")
        newFavorite.setValue(header, forKey: "header")
        newFavorite.setValue(city, forKey: "city")
        newFavorite.setValue(category, forKey: "category")
        newFavorite.setValue(subcategory, forKey: "subcategory")
        newFavorite.setValue(telnum, forKey: "telnum")
        newFavorite.setValue(info, forKey: "info")
        newFavorite.setValue(pictures, forKey: "pictures")
        

        
        print("New favorite saved")
        
    }

    
    public static func deleteFavorite(favorite: NSManagedObject) {
        
        print("Deleting favorite")
        let managedContext = HELPER.managedObjectContext()
        
        managedContext.delete(favorite)
            
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Error While Deleting Note: \(error.userInfo)")
        }
            
        print("Deleted")

    }
    
    
    public static func clearFavorites(){
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorites")
        let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            _ = try HELPER.managedObjectContext().execute(request)
        } catch {
            print("Error")
        }
        print("Deleted")
    }
    
    
    
    public static func readyToGo(navCon: UINavigationController) {
        let delayTime = DispatchTime.now() + 1.5
        DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
            navCon.popToRootViewController(animated: true)
        })
    }
    
    public static func showToast(view: UIView, text: String) {
        
        view.makeToast(text, duration: 1.5, position: CGPoint(x: (view.frame.width / 2), y: 88))
        
    }
    
    public static func uicolorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
    
    
    
}

extension UIImageView {
    public func avatarFromURL(userID: String) {
        
        if let url = URL(string: "http://invietnam.website/vietnam/userspics/\(userID).png") {
            print(url)
            DispatchQueue.global().async {
                
                if let data = try? Data(contentsOf: url) != nil {
                    DispatchQueue.main.async {
                        let trueData = try? Data(contentsOf: url)
                        self.image = UIImage(data: trueData!)
                        let avatar = NSData(data: UIImagePNGRepresentation(self.image!)!)
                        
                        print("Saving user")
                        let newUser = NSEntityDescription.insertNewObject(forEntityName: "Avatar", into: HELPER.managedObjectContext())
                        newUser.setValue(avatar, forKey: "avatar")
                        print("Avatar saved")
                        
                    }
                } else {
                    self.image = #imageLiteral(resourceName: "check_male")
                    print("Don't have data")
                }
                
            }
        }
    }
}



extension String {
    public func toPhoneNumber() -> String {
        return self.replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d+)", with: "($1) $2-$3", options: .regularExpression, range: nil)
    }
    
    var length : Int {
        return self.characters.count
    }
    
    func digitsOnly() -> String{
        let stringArray = self.components(
            separatedBy: NSCharacterSet.decimalDigits.inverted)
        let newString = stringArray.joined(separator: "")
        
        return newString
    }
    
}


extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        //let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        //let longtap: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        
        
        let swipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboards(_:)))
        swipe.direction = [.down, .up, .left, .right]
        view.addGestureRecognizer(swipe)
    }
    
    func dismissKeyboards(_ gesture: UISwipeGestureRecognizer) {
        view.endEditing(true)
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
            case UISwipeGestureRecognizerDirection.down:
                print("Swiped down")
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
            default:
                break
            }
        }
        
        
    }
}




