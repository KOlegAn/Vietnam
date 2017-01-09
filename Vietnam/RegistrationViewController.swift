//
//  RegistrationViewController.swift
//  Vietnam
//
//  Created by Oleg Kuplin on 10.11.16.
//  Copyright © 2016 Oleg Kuplin. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class RegistrationViewController: UIViewController {

    @IBOutlet weak var sendKeyButton: UIButton!
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var checkPassTF: UITextField!
    @IBOutlet weak var secKeyTF: UITextField!
    @IBOutlet weak var sexController: UISegmentedControl!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    var activityIndicator = UIActivityIndicatorView()
    var timer = Timer()
    var counter = 59
    var result = ""
    var sex = "Муж"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 430, 0)
        self.navigationController?.navigationBar.isHidden = false
        self.activityIndicator = self.createActivityIndicator()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissKeyboard(_ sender: Any) {
        self.resignFirstResponder()
    }

    
    @IBAction func sendKey(_ sender: Any) {
        self.resignFirstResponder()
        let email = self.emailTF.text
        let url = "http://invietnam.website/vietnam/userreg.php?request=0&email=\(email!)"
        print(url)
        if email == "" {
            HELPER.showToast(view: self.view, text: "Введите Email")
        } else {
            OperationQueue.main.addOperation {
                MBProgressHUD.showAdded(to: self.view, animated: true)
            }
            
            Alamofire.request(url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
                .responseJSON { response in
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
                        OperationQueue.main.addOperation {
                            MBProgressHUD.hide(for: self.view, animated: true)
                        }
                        
                        let jsonData = JSON(data: response.data!)
                        print(jsonData)
                        let responseArray = jsonData.object as! NSObject
                        print(responseArray)
                        self.result = responseArray.value(forKey: "result") as! String
                        
                        
                        
                        if self.result == "1" {
                          
                            HELPER.showToast(view: self.view, text: "Код подтверждения выслан вам на email")
                            self.sendKeyButton.isEnabled = false
                            UIView .setAnimationsEnabled(false)
                            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.countButton), userInfo: nil, repeats: true)
                            
                        } else if self.result == "userexist" {
                           
                            HELPER.showToast(view: self.view, text: "Пользователь с таким email уже существует")
                        } else if self.result == "invalidf" {
                           
                            print("\n\nin invaliff\n")
                            HELPER.showToast(view: self.view, text: "Неправильный формат email")
                        } else if self.result == "invalidd" {
                            
                            HELPER.showToast(view: self.view, text: "Указанный домен email не существует")
                        }
                        
                    }
                    
            }
            
            
        }
    
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
        
        
        
        let name = self.nameTF.text
        let password = self.passwordTF.text
        let email = self.emailTF.text
        let checkPass = self.checkPassTF.text
        let verkey = self.secKeyTF.text
        let allowedNameCharacterset = CharacterSet(charactersIn: "абвгдеёжзийклмнопрстуфхцчшщьыъэюяАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЬЫЪЭЮЯabcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789")
        let allowedCharacterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789")
        
        
        if name == ""{
            HELPER.showToast(view: self.view, text: "Введите имя")
        } else if (name?.characters.count)! < 3{
            HELPER.showToast(view: self.view, text: "Имя должно быть не менее 3 букв")
        } else if name?.rangeOfCharacter(from: allowedNameCharacterset.inverted) != nil {
            HELPER.showToast(view: self.view, text: "Имя не должно содержать знаков")
        } else if email == "" {
            HELPER.showToast(view: self.view, text: "Введите Email")
        } else if password == "" {
            HELPER.showToast(view: self.view, text: "Введите пароль")
        } else if (password?.characters.count)! < 6{
            HELPER.showToast(view: self.view, text: "Пароль должен быть не менее 6 знаков")
        } else if (password?.characters.count)! > 12 {
            HELPER.showToast(view: self.view, text: "Пароль должен быть не более 12 знаков")
        } else if password?.rangeOfCharacter(from: allowedCharacterset.inverted) != nil {
            HELPER.showToast(view: self.view, text: "Можно использовать только латинские буквы и цифры")
            print("string contains special characters")
        } else if password != checkPass {
            HELPER.showToast(view: self.view, text: "Пароли не совпадают")
        } else {
            
            OperationQueue.main.addOperation {
                MBProgressHUD.showAdded(to: self.view, animated: true)
            }
            
            let url = "http://invietnam.website/vietnam/userreg.php?request=1&email=\(email!)&password=\(password!)&verkey=\(verkey!)&name=\(name!)&sex=\(self.sex)"
   
            Alamofire.request(url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
                .responseJSON { response in
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
                        OperationQueue.main.addOperation {
                            MBProgressHUD.hide(for: self.view, animated: true)
                        }
                        let jsonData = JSON(data: response.data!)
                        print(jsonData)
                        let responseArray = jsonData.object as! NSObject
                        print(responseArray)
                        self.result = responseArray.value(forKey: "result") as! String
                        
                        if self.result == "wrongkey" {
                            HELPER.showToast(view: self.view, text: "Введенный код неправильный")
                        } else if self.result == "success" {
                            let id = responseArray.value(forKey: "id") as! String
                            HELPER.saveUserAvatar(userId: id)
                            HELPER.saveUser(email: email!, vkid: "", telnum: "", name: name!, nickname: "", sex: self.sex, id: id, state: 1)
                            HELPER.showToast(view: self.view, text: "Благодарим за регистрацию")
                            HELPER.readyToGo(navCon: self.navigationController!)
                        }
                    }
                    
            }
              
            
        }
 
    }
    
    
    
    func giveMeURL(string : String) -> URL {
        let url = URL(string: string)
        return url!
    }
    
    
    @IBAction func dismiss(_ sender: Any) {
        self.navigationController?.navigationBar.isHidden = true
        _ = self.navigationController?.popViewController(animated: true)
    }

    
    
    func createActivityIndicator() -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2, y: self.view.frame.height / 2, width: 40, height: 40))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        indicator.center = self.view.center
        indicator.backgroundColor = UIColor.clear
        self.view.addSubview(indicator)
        return indicator
    }
 
    @IBAction func changeSex(_ sender: Any) {
        
        switch self.sexController.selectedSegmentIndex {
        case 0:
            self.sex = "Муж"
            break
        case 1:
            self.sex = "Жен"
        default:
            self.sex = "Муж"
            break
        }
        
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
