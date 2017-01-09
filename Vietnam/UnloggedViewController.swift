//
//  UnloggedViewController.swift
//  Vietnam
//
//  Created by Oleg Kuplin on 12.11.16.
//  Copyright © 2016 Oleg Kuplin. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class UnloggedViewController: UIViewController, VKSdkUIDelegate, VKSdkDelegate, UIGestureRecognizerDelegate {

    let SCOPE = [VK_PER_NOTIFY, VK_PER_FRIENDS, VK_PER_OFFLINE, VK_PER_EMAIL]
    var result = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true

        VKSdk.initialize(withAppId: "5721752").register(self)
        VKSdk.instance().register(self)
        VKSdk.instance().uiDelegate = self
        print("In unlogged menu")
        VKSdk.wakeUpSession(SCOPE, complete: {
            state, error in
            
            if state == VKAuthorizationState.authorized {
               
                print("ready to go, adn it's true")
                
            } else {
              
                print("In else now")
                //VKSdk.authorize(self.SCOPE)
                
            }
        })
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
    }
    
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return false
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        self.navigationController?.navigationBar.isHidden = true
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        self.isLogged()
    }
    
    
    func isLogged(){
        
        let managedContext = self.managedObjectContext()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Isregistered")
        
        do {
            let fetchedResult = try managedContext.fetch(fetchRequest)
            let model = fetchedResult as! [NSManagedObject]
            print("I have \(model.count) users now oO")
            if model.count == 0 {

            } else {
                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
                self.navigationController?.navigationBar.isHidden = false
                _ = self.navigationController?.popToRootViewController(animated: true)
                
                
                print("Not empty")
            }
            
        } catch {
            print("Error while fetching occured")
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    //VK funcs
    
    func vkSdkShouldPresent(_ controller: UIViewController!) {
        print("We are in should present")
        
        self.present(controller, animated: true, completion: nil)
        
    }
    
    func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
        print("In need captcha enter")
        
        let captchaController = VKCaptchaViewController.captchaControllerWithError(captchaError)
        captchaController?.present(in: self.navigationController?.topViewController)
    }
    
    
    
    func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
        print("We are in vksdk access auth finished func")
        if ((result.token) != nil) {
            
            
            //if user have email
            if result.token.email != nil {
                
                OperationQueue.main.addOperation {
                    MBProgressHUD.showAdded(to: self.view, animated: true)
                }
                
                let userID = result.token.userId
                let usersGet = VKRequest(method: "users.get", parameters: ["user_ids" : userID!, "fields" : "sex"])
                
                
                usersGet?.execute(resultBlock: { response in
                    
                    let info = self.getInfo(responseString: (response?.responseString)!)
                    let name = info[0]
                    let sexS = info[1]
                    print(sexS)
                    var sex = ""
                    if sexS == "2" {
                        sex = "Муж"
                    } else {
                        sex = "Жен"
                    }
                    let email = result.token.email
                   
                    
                    let url = "http://invietnam.website/vietnam/userreg.php?request=2&email=\(email!)&vkid=\(userID!)&name=\(name)&sex=\(sex)"
                    print(url)
                    Alamofire.request(url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
                        .responseJSON { response in
                            //to get status code
                            
                            
                            if let status = response.response?.statusCode {
                                switch(status){
                                case 201:
                                    print("example success")
                                default:
                                    print("Error")
                                    OperationQueue.main.addOperation {
                                        MBProgressHUD.hide(for: self.view, animated: true)
                                    }
                                    
                                }
                            }
                            //to get JSON return value
                            if let result = response.result.value {
                                print(result)
                                let jsonData = JSON(data: response.data!)
                                print(jsonData)
                                let responseArray = jsonData.object as! NSObject
                                print(responseArray)
                                self.result = responseArray.value(forKey: "result") as! String
                                
                                
                                if self.result == "userexist" {
                                    OperationQueue.main.addOperation {
                                        MBProgressHUD.hide(for: self.view, animated: true)
                                    }
                                    let id = responseArray.value(forKey: "id") as! String
                                    HELPER.saveUserAvatar(userId: id)
                                    let nickname = responseArray.value(forKey: "nickname") as! String
                                    HELPER.showToast(view: self.view, text: "Рады, что вы вернулись \(name)")
                                    
                                    HELPER.saveUser(email: email!, vkid: userID!, telnum: "", name: name, nickname: nickname, sex: sex, id: id, state: 21)
                                    HELPER.readyToGo(navCon: self.navigationController!)
                                    
                                } else if self.result == "success" {
                                    OperationQueue.main.addOperation {
                                        MBProgressHUD.hide(for: self.view, animated: true)
                                    }
                                    let id = responseArray.value(forKey: "id") as! String
                                    HELPER.saveUserAvatar(userId: id)
                                    HELPER.saveUser(email: email!, vkid: userID!, telnum: "", name: name, nickname: "", sex: sex, id: id, state: 21)
                                    HELPER.showToast(view: self.view, text: "Добро пожаловать, \(name)")
                                    HELPER.readyToGo(navCon: self.navigationController!)
                                }
                            }
                    }
                    
                }, errorBlock: {error in
                    print("Error")
                    HELPER.showToast(view: self.view, text: "Ошибка интернет соединения")

                })
                
                //User don't have email
            } else {

                
                OperationQueue.main.addOperation {
                    MBProgressHUD.showAdded(to: self.view, animated: true)
                }
                
                
                let userID = result.token.userId
                let usersGet = VKRequest(method: "users.get", parameters: ["user_ids" : userID!, "fields" : "sex"])
                
                
                
                usersGet?.execute(resultBlock: { response in
                    
                    let info = self.getInfo(responseString: (response?.responseString)!)
                    let name = info[0]
                    let sexS = info[1]
                    print(sexS)
                    var sex = ""
                    if sexS == "2" {
                        sex = "Муж"
                    } else {
                        sex = "Жен"
                    }
   
                    let url = "http://invietnam.website/vietnam/userreg.php?request=4&vkid=\(userID!)&name=\(name)&sex=\(sex)"
                    print(url)
                    Alamofire.request(url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
                        .responseJSON { response in
                            //to get status code
                            
                            
                            if let status = response.response?.statusCode {
                                switch(status){
                                case 201:
                                    print("example success")
                                default:
                                    print("Error")
                                    OperationQueue.main.addOperation {
                                        MBProgressHUD.hide(for: self.view, animated: true)
                                    }
                                    
                                }
                            }
                            //to get JSON return value
                            if let result = response.result.value {
                                print(result)
                                let jsonData = JSON(data: response.data!)
                                print(jsonData)
                                let responseArray = jsonData.object as! NSObject
                                print(responseArray)
                                self.result = responseArray.value(forKey: "result") as! String
                                
                                if self.result == "userexist" {
                                    OperationQueue.main.addOperation {
                                        MBProgressHUD.hide(for: self.view, animated: true)
                                    }
                                    let id = responseArray.value(forKey: "id") as! String
                                    HELPER.saveUserAvatar(userId: id)
                                    var nickname = ""
                                    if (responseArray.value(forKey: "nickname") as! String) != nil {
                                        nickname = responseArray.value(forKey: "nickname") as! String
                                    }
                                    HELPER.showToast(view: self.view, text: "Рады, что вы вернулись \(name)")
                                    HELPER.saveUser(email: "", vkid: userID!, telnum: "", name: name, nickname: nickname, sex: sex, id: id, state: 20)
                                    HELPER.readyToGo(navCon: self.navigationController!)

                                    
                                } else if self.result == "success" {
                                    OperationQueue.main.addOperation {
                                        MBProgressHUD.hide(for: self.view, animated: true)
                                    }
                                    let id = responseArray.value(forKey: "id") as! String
                                    HELPER.saveUserAvatar(userId: id)
                                    HELPER.saveUser(email: "", vkid: userID!, telnum: "", name: name, nickname: "", sex: sex, id: id, state: 20)
                                    HELPER.showToast(view: self.view, text: "Добро пожаловать, \(name)")
                                    HELPER.readyToGo(navCon: self.navigationController!)

                                }
                            }
                    }

                    
                    
                    
                    
                }, errorBlock: {error in
                    print("Error")
                })
                
            }
            
            
            
            
        } else if ((result.error) != nil) {
            print("Error: \(result.error)")
        }
        
    }
    
    
    
    
    func vkSdkUserAuthorizationFailed() {
        print("Authorization failed")
        
    }
    
    func vkSdkTokenHasExpired(_ expiredToken: VKAccessToken!) {
        
        print("Token has expired")
    }
    
    func vkSdkAuthorizationStateUpdated(with result: VKAuthorizationResult!) {
        print("In auth state update")
        print(result)
    }
    
    func vkSdkAccessTokenUpdated(_ newToken: VKAccessToken!, oldToken: VKAccessToken!) {
        print("In acces token updated")
    }

    
    @IBAction func vkLogIn(_ sender: Any) {
        VKSdk.authorize(self.SCOPE) 
    }
    

    
    
    func getInfo(responseString: String) -> [String] {
        
        
        print(responseString)
        let parsedString = responseString.components(separatedBy: ",")
        let names = parsedString[1].components(separatedBy: ":")
        let string = names[1]
        print(names)
        print(names[1])
        let regex = try! NSRegularExpression(pattern:"\"(.*?)\"", options: [])
        let tmp = string as NSString
        var results = [String]()
        
        regex.enumerateMatches(in: string, options: [], range: NSMakeRange(0, string.characters.count)) { result, flags, stop in
            if let range = result?.rangeAt(1) {
                results.append(tmp.substring(with: range))
            }
        }
        
        
        
        let name = results[0]
        
        
        
        let sexSep = parsedString[3].components(separatedBy: ":")
        let sexs = sexSep[1]
        let sex = String(sexs.characters.first!)
        let result = [name, sex]
        return result
    }
    
    
    
    func managedObjectContext() -> NSManagedObjectContext{
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        if #available(iOS 10.0, *) {
            context = appDelegate.persistentContainer.viewContext
        } else {
            
        }
        
        return context
    }
    
    

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}



