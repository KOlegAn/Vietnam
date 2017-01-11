//
//  EmailLoginViewController.swift
//  Vietnam
//
//  Created by Oleg Kuplin on 13.11.16.
//  Copyright © 2016 Oleg Kuplin. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import MBProgressHUD
import SwiftyJSON

class EmailLoginViewController: UIViewController {

    
    
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    var result = ""
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isHidden = false
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    
    
    
    @IBAction func logIn(_ sender: Any) {
        
        self.resignFirstResponder()
        MBProgressHUD.showAdded(to: self.view, animated: true)

        let email = self.emailTF.text
        let password = self.passwordTF.text
        
        let url = "http://invietnam.website/vietnam/userreg.php?request=3&email=\(email!)&password=\(password!)"
        
        Alamofire.request(url).responseJSON { response in
                //to get status code
                if let status = response.response?.statusCode {
                    switch(status){
                    case 201:
                        print("example success")
                    default:
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
                    
                    self.result = responseArray.value(forKey: "result") as! String

                    print(self.result)
                    
                    
                        MBProgressHUD.hide(for: self.view, animated: true)
                    
                    
                    if self.result == "success" {
                        
                        print("Succesed")
                        let name = responseArray.value(forKey: "name") as! String
                        let sex = responseArray.value(forKey: "sex") as! String
                        let vkid = responseArray.value(forKey: "vkid") as! String
                        let telnum = responseArray.value(forKey: "telnum") as! String
                        let id = responseArray.value(forKey: "id") as! String
                        let nickname = responseArray.value(forKey: "nickname") as! String
                        
                        HELPER.saveUserAvatar(userId: id)
                        HELPER.saveUser(email: email!, vkid: vkid, telnum: telnum, name: name, nickname: nickname, sex: sex, id: id, state: 1)
                        HELPER.showToast(view: self.view, text: "Здравствуйте \(name), мы скучали по вам")
                        HELPER.readyToGo(navCon: self.navigationController!)
                    } else if self.result == "wrongpass" {
                        HELPER.showToast(view: self.view, text: "Неверный пароль")
                    } else if self.result == "usernotexist" {
                        print(self.view.frame.width/2)
                        HELPER.showToast(view: self.view, text: "Пользователь с таким email не существует")
                    }
                }
            
        }
        
    }
    
    
    
    
    @IBAction func dismissKeyboard(_ sender: Any) {
        self.resignFirstResponder()
    }
    
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.navigationBar.isHidden = true
        _ = self.navigationController?.popViewController(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func showProhressHUD(text: String) {
        
        let mb = MBProgressHUD.showAdded(to: (self.view)!, animated: true)
        mb.mode = MBProgressHUDMode.text
        mb.label.text = text
        mb.margin = 10.0
        mb.offset.y = -self.view.frame.height/2
        mb.removeFromSuperViewOnHide = true
        mb .hide(animated: true, afterDelay: 2.5)
        
        
    }
    

}
