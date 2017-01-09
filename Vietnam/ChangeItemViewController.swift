//
//  ChangeItemViewController.swift
//  Vietnam
//
//  Created by Oleg Kuplin on 28.11.16.
//  Copyright © 2016 Oleg Kuplin. All rights reserved.
//

import UIKit
import Alamofire


class ChangeItemViewController: UIViewController {

    
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemValue: UITextField!
    @IBOutlet weak var sexValue: UISegmentedControl!
    
    var userInfo = NSObject()
    var name = ""
    var value = ""
    var result = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        if name == "Тел. Номер" {
            self.itemValue.keyboardType = .phonePad
            print("Yes")
        }
        self.itemName.text = name
        self.itemValue.text = value
        if self.name == "Пол" {
            self.itemValue.isHidden = true
            
            switch self.userInfo.value(forKey: "sex") as! String {
            case "Муж":
                self.value = "Муж"
                self.sexValue.selectedSegmentIndex = 0
            default:
                self.value = "Жен"
                self.sexValue.selectedSegmentIndex = 1
            }
            
        } else {
            self.sexValue.isHidden = true
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveNewItem(_ sender: Any) {
        
        let id = self.userInfo.value(forKey: "id") as! String
        let name = self.userInfo.value(forKey: "name") as! String
        let nickname = self.userInfo.value(forKey: "nickname") as! String
        let email = self.userInfo.value(forKey: "email") as! String
        let telNum = self.userInfo.value(forKey: "telnum") as! String
        let sex = self.userInfo.value(forKey: "sex") as! String
        let state = self.userInfo.value(forKey: "state") as! Int
        let vkid = self.userInfo.value(forKey: "vkid") as! String
        
        
        
        OperationQueue.main.addOperation {
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        var url = ""
        if self.name == "Пол" {
            url = "http://invietnam.website/vietnam/userEdit.php?request=\(HELPER.switchItemName(itemName: self.name))&id=\(id)&value=\(self.value)"
        } else {
            url = "http://invietnam.website/vietnam/userEdit.php?request=\(HELPER.switchItemName(itemName: self.name))&id=\(id)&value=\(self.itemValue.text!)"
        }
        print(url)
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
                    
                    if self.result == "success" {
                        HELPER.showToast(view: self.view, text: "Изменения успешно внесены")
                        if self.name == "Имя" {
                            HELPER.getUser().setValue(self.itemValue.text!, forKey: "name")
                        } else if self.name == "Ник" {
                            HELPER.getUser().setValue(self.itemValue.text!, forKey: "nickname")
                        } else if self.name == "Тел. Номер" {
                            HELPER.getUser().setValue(self.itemValue.text!, forKey: "telnum")
                        } else if self.name == "Пол" {
                            HELPER.getUser().setValue(self.value, forKey: "sex")
                        }
                        
                        let delayTime = DispatchTime.now() + 1.5
                        DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
                            _ = self.navigationController?.popViewController(animated: true)
                        })
                    } else {
                        
                    }
                }
                
        }
        
        
    

    }

    
    
    
    @IBAction func changeSexValue(_ sender: Any) {
        switch self.sexValue.selectedSegmentIndex {
        case 0:
            self.value = "Муж"
        default:
            self.value = "Жен"
            print(self.sexValue.selectedSegmentIndex.description)
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


