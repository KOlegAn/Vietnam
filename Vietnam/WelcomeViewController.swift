//
//  ViewController.swift
//  Vietnam
//
//  Created by Oleg Kuplin on 09.11.16.
//  Copyright © 2016 Oleg Kuplin. All rights reserved.
//

import UIKit
import Alamofire
import CoreData


class WelcomeViewController: UIViewController, VKSdkUIDelegate, VKSdkDelegate {
    
    
    
    @IBOutlet weak var telNumberTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var fbLogBut = FBSDKLoginButton()
    
    var isLog = false
    var result = ""
    let SCOPE = [VK_PER_NOTIFY, VK_PER_FRIENDS, VK_PER_OFFLINE, VK_PER_EMAIL]
    var activityIndicator = UIActivityIndicatorView()

    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isHidden = true
        activityIndicator = createActivityIndicator()

        
        VKSdk.initialize(withAppId: "5721752").register(self)
        VKSdk.instance().register(self)
        VKSdk.instance().uiDelegate = self
        
        print("VK initialized")
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        VKSdk.wakeUpSession(SCOPE, complete: {
            state, error in
            
            if state == VKAuthorizationState.authorized {
                self.goToMain()
                self.isLog = true
                print("ready to go, adn it's true")
                print(self.isLog)
                
            } else {
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
                print("In else now")
                //VKSdk.authorize(self.SCOPE)
                
            }
        })

    }

    
    
    
    func goToMain(){
        print("We are in goToMain")

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let mainVC = storyboard.instantiateViewController(withIdentifier: "mainScreen") 
        self.navigationController?.pushViewController(mainVC, animated: true)
        //self.performSegue(withIdentifier: "mainScreen", sender: self)
    }
    
    func vkSdkShouldPresent(_ controller: UIViewController!) {
        print("We are in should present")

        self.present(controller, animated: true, completion: nil)
        //self.navigationController?.topViewController?.present(controller, animated: true, completion: nil)
    }
    
    func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
        print("In need captcha enter")

        let captchaController = VKCaptchaViewController.captchaControllerWithError(captchaError)
        captchaController?.present(in: self.navigationController?.topViewController)
    }
    
    
    
    func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
        print("We are in vksdk access auth finished func")
        if ((result.token) != nil) {
            self.goToMain()
            print("Token: \(result.token)")
            // Пользователь успешно авторизован
        } else if ((result.error) != nil) {
            print("Error: \(result.error)")
            // Пользователь отменил авторизацию или произошла ошибка
        }
        
    }
    
    
    func vkSdkUserAuthorizationFailed() {
        print("Authorization failed")
        _ = self.navigationController?.popToRootViewController(animated: true)
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    
    
    @IBAction func resignFirstResponder(_ sender: Any) {
        self.resignFirstResponder()
    }
    
    
    
    
    @IBAction func logIn(_ sender: Any) {
        
        self.telNumberTF.resignFirstResponder()
        self.passwordTF.resignFirstResponder()
        let login = self.telNumberTF.text
        let password = self.passwordTF.text
        
        if login == "" {
            showProhressHUD(text: "Введите свой номер телефона")
        } else if password == "" {
            showProhressHUD(text: "Введите пароль")
        } else {
            let logins = "http://188.166.219.161/vietnam/userslogin.php?login=" as NSMutableString
            logins.append(login!)
            logins.append("&password=")
            logins.append(password!)
            let finalString = logins as String
        
            Alamofire.request(finalString).responseJSON(completionHandler: {
                response in
            
                let jsonData = JSON(data: response.data!)
                print(jsonData)
                let responseArray = jsonData.object as! NSObject
            
                self.result = responseArray.value(forKey: "result") as! String
            
                print(self.result)
            
                if self.result == "1" {
                    print("Succesed")
                } else {
                    self.showProhressHUD(text: self.result)
                }
            })
        
        }

    }

    
    
    
    @IBAction func vkAuthorize(_ sender: Any) {
        print("VK Auth button")
        
        
        VKSdk.authorize(SCOPE)

        print("Authorized")
    }
    
    
    
    
    func showProhressHUD(text: String) {
        
        let mb = MBProgressHUD.showAdded(to: (self.view)!, animated: true)
        mb.mode = MBProgressHUDMode.text
        mb.label.text = text
        mb.margin = 10.0
        mb.offset.y = -self.view.frame.height/2 + 88
        mb.removeFromSuperViewOnHide = true
        mb .hide(animated: true, afterDelay: 1.5)
        
        
    }
    
    func createActivityIndicator() -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2, y: self.view.frame.height / 2, width: 40, height: 40))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        indicator.center = self.view.center
        indicator.backgroundColor = UIColor.clear
        self.view.addSubview(indicator)
        return indicator
    }
    
    
    
}

