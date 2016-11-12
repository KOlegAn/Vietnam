//
//  RegistrationViewController.swift
//  Vietnam
//
//  Created by Oleg Kuplin on 10.11.16.
//  Copyright © 2016 Oleg Kuplin. All rights reserved.
//

import UIKit
import Alamofire

class RegistrationViewController: UIViewController {

    @IBOutlet weak var sendKeyButton: UIButton!
    
    @IBOutlet weak var telNumTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var secKeyTF: UITextField!
    
    
    var timer = Timer()
    var counter = 59
    var result = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissKeyboard(_ sender: Any) {
        self.resignFirstResponder()
    }

    
    @IBAction func sendKey(_ sender: Any) {
        
        self.sendKeyButton.isEnabled = false
        
        showProhressHUD(text: "Письмо с кодом отправлено")
        UIView .setAnimationsEnabled(false)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.countButton), userInfo: nil, repeats: true)
        
        Alamofire.request("").responseJSON(completionHandler: {
            response in
            
            let jsonData = JSON(data: response.data!)
            print(jsonData)
            let responseArray = jsonData.object as! NSObject
            
            //self.result = responseArray.value(forKey: "result") as! String
            
            
            
            if self.result == "1" {
                print("Succesed")
            } else {
                self.showProhressHUD(text: self.result)
            }
        })
        
    }
    
    func countButton() {
        
        self.sendKeyButton.setTitle("Повторить через \(self.counter)s", for: .normal)
        self.sendKeyButton.backgroundColor = UIColor.lightGray
        self.counter -= 1
        
        if self.counter == -1 {
            timer.invalidate()
            self.counter = 60
            self.sendKeyButton.isEnabled = true
            self.sendKeyButton.setTitle("Отправить код", for: .normal)
            self.sendKeyButton.backgroundColor = UIColor(red: 42.0/255.0, green: 161.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            UIView .setAnimationsEnabled(true)
        }
        
    }
    
    
    
    
    
    @IBAction func confirmRegistration(_ sender: Any) {
        let password = self.passwordTF.text
        
        if (password?.characters.count)! < 6{
            showProhressHUD(text: "Пароль должен быть не менее 6 знаков")
        } else if (password?.characters.count)! > 12 {
            showProhressHUD(text: "Пароль должен быть не более 12 знаков")
        } else {
            Alamofire.request("").responseJSON(completionHandler: {
                response in
                
                let jsonData = JSON(data: response.data!)
                print(jsonData)
                let responseArray = jsonData.object as! NSObject
                
                self.result = responseArray.value(forKey: "result") as! String
                
                
                
                if self.result == "1" {
                    print("Succesed")
                } else {
                    self.showProhressHUD(text: self.result)
                }
            })
        }
        
        
    }
    
    
    
    
    
    func showProhressHUD(text: String) {
        
        let mb = MBProgressHUD.showAdded(to: (self.view)!, animated: true)
        mb.mode = MBProgressHUDMode.text
        mb.label.text = text
        mb.margin = 10.0
        mb.offset.y = self.view.frame.height/5
        mb.removeFromSuperViewOnHide = true
        mb .hide(animated: true, afterDelay: 1.0)
        
        
    }
    
 
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
