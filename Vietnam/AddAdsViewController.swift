//
//  AddAdsViewController.swift
//  Vietnam
//
//  Created by Oleg Kuplin on 19.11.16.
//  Copyright © 2016 Oleg Kuplin. All rights reserved.
//

import UIKit
import CoreData
import AssetsLibrary
import MobileCoreServices
import Alamofire




class AddAdsViewController: UIViewController, UIGestureRecognizerDelegate, TZImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, ChangeCategoryDelegate, UITextViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var adBody: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var cCategoryButton: UIButton!
    @IBOutlet weak var headerTF: UITextField!
    @IBOutlet weak var subCategoryButton: UIButton!
    @IBOutlet weak var cityButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoTF: UITextField!
    @IBOutlet weak var telnumTF: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var adTextLabel: UILabel!
    
    var user             = NSObject()
    var adForEdit        = NSObject()
    var category         = ""
    var subcategory      = ""
    var choosedPictures  = [UIImage]()
    var result           = ""
    var comeFrom         = 0
    let dropDownCategory = DropDown()
    let dropDownCity     = DropDown()
    let greenStyleColor  = UIColor(colorLiteralRed: 49/255, green: 102/255, blue: 49/255, alpha: 0.8)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        
        self.adTextLabel.text = "Текст объявления:"
        
        self.collectionView.delegate = self
        self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 1000, 0)
        print("Text view can contain \(self.adBody.text.characters.count) characters")
        
        self.isLogged()
        
        
        dropDownCategory.anchorView = self.subCategoryButton
        dropDownCategory.width = self.view.frame.width - 35
        dropDownCategory.textAligment = .center
        dropDownCategory.textFont = UIFont.systemFont(ofSize: 20)
        dropDownCategory.separatorColor = UIColor.lightGray
        dropDownCategory.separatorInsetRight = 20
        dropDownCategory.separatorInsetLeft = 20
        dropDownCategory.textColor = greenStyleColor
        
        dropDownCity.anchorView = self.cityButton
        dropDownCity.width = 100
        dropDownCity.cellHeight = 42
        dropDownCity.textFont = UIFont.systemFont(ofSize: 16)
        dropDownCity.bottomOffset = CGPoint(x: self.view.frame.width - 250, y:(dropDownCity.anchorView?.plainView.bounds.height)!)

        dropDownCity.dataSource = ["Все", "Вунгтау", "Далат", "Муйне","Нячанг", "Ханой", "Хошимин"]

        if self.comeFrom == 2 {
            self.navigationItem.title = "Редактировать объявление"
            let prevCategory = self.adForEdit.value(forKey: "category") as! String
            let prevHeader = self.adForEdit.value(forKey: "header") as! String
            let prevBody = self.adForEdit.value(forKey: "body") as! String
            let prevInfo = self.adForEdit.value(forKey: "info") as! String
            let prevTelnum = self.adForEdit.value(forKey: "telnum") as! String
            let prevCity = self.adForEdit.value(forKey: "city") as! String
            
            self.cityButton.setTitle(prevCity, for: .normal)
            self.telnumTF.text = prevTelnum
            self.infoTF.text = prevInfo
            self.adBody.text = prevBody
            self.headerTF.text = prevHeader
            self.category = prevCategory
            self.viewWillAppear(false)
            self.confirmButton.setTitle("Сохранить изменения", for: .normal)

            let pictures = Int(self.adForEdit.value(forKey: "pictures") as! String)
            
            let id = self.adForEdit.value(forKey: "id") as! String
            let categoryDirectory = HELPER.switchCatLang(categoryRName: prevCategory)
            
            
            for i in (0..<pictures!) {
                let prevImage = UIImageView()
                prevImage.sd_setImage(with: URL(string: "http://invietnam.website/vietnam/adpics/\(categoryDirectory)/\(id)_\(i).png"), placeholderImage: #imageLiteral(resourceName: "imagesPlaceholder"), options: [.retryFailed, .refreshCached])
                self.choosedPictures.append(prevImage.image!)
            }
            
        } else {
            let rightBarButton = UIBarButtonItem(title: "Сброс", style: .plain, target: self, action: #selector(self.resetInfo))
            self.navigationItem.rightBarButtonItem = rightBarButton
        }
        
        
        self.adBody.delegate = self
        
        
        
    }
    
    
    override var hidesBottomBarWhenPushed: Bool {
        
        get { if self.comeFrom == 0{
            return false} else {
            return true
            }
        }
        set { super.hidesBottomBarWhenPushed = newValue }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if self.category != "" {
            self.cCategoryButton.setAttributedTitle(self.getAttributedString(string: self.category), for: .normal)
            self.subCategoryButton.isEnabled =  true
            self.subCategoryButton.setTitleColor(greenStyleColor, for: .normal)
            self.infoLabel.isHidden = false
            self.infoTF.isHidden = false
            switch self.category {
            case "Работа":
                dropDownCategory.dataSource = ["Вакансия", "Резюме"]
                self.infoLabel.text = "З/П:"
                self.subCategoryButton.setTitle(self.dropDownCategory.dataSource[0], for: .normal)
                self.subcategory = dropDownCategory.dataSource[0]
                break
            case "Жилье":
                dropDownCategory.dataSource = ["Сдам", "Сниму"]
                self.infoLabel.text = "Цена:"
                self.subCategoryButton.setTitle(self.dropDownCategory.dataSource[0], for: .normal)
                self.subcategory = dropDownCategory.dataSource[0]
                break
            case "Услуги":
                dropDownCategory.dataSource = ["Предлагаю", "Ищу"]
                self.infoLabel.text = "Цена:"
                self.subCategoryButton.setTitle(self.dropDownCategory.dataSource[0], for: .normal)
                self.subcategory = dropDownCategory.dataSource[0]
                break
            case "Мото":
                dropDownCategory.dataSource = ["Сдам в аренду", "Сниму в аренду", "Куплю", "Продам"]
                self.infoLabel.text = "Цена:"
                self.subCategoryButton.setTitle(self.dropDownCategory.dataSource[0], for: .normal)
                self.subcategory = dropDownCategory.dataSource[0]
                break
            case "Привезти":
                dropDownCategory.dataSource = ["Привезти", "Передать"]
                self.subCategoryButton.setTitle(self.dropDownCategory.dataSource[0], for: .normal)
                self.subcategory = dropDownCategory.dataSource[0]
                break
            case "Бюро находок":
                dropDownCategory.dataSource = ["Найдено", "Потеряно"]
                self.subCategoryButton.setTitle(self.dropDownCategory.dataSource[0], for: .normal)
                self.subcategory = dropDownCategory.dataSource[0]
                break
            case "Обучение":
                dropDownCategory.dataSource = ["Обучу", "Научусь"]
                self.infoLabel.text = "Цена:"
                self.subCategoryButton.setTitle(self.dropDownCategory.dataSource[0], for: .normal)
                self.subcategory = dropDownCategory.dataSource[0]
                break
            case "Электроника":
                dropDownCategory.dataSource = ["Куплю", "Продам"]
                self.infoLabel.text = "Цена:"
                self.subCategoryButton.setTitle(self.dropDownCategory.dataSource[0], for: .normal)
                self.subcategory = dropDownCategory.dataSource[0]
                break
            default:
                self.subCategoryButton.isEnabled = false
                self.subCategoryButton.setTitleColor(UIColor.white, for: .normal)
                self.subCategoryButton.setTitle("Подкатегория", for: .normal)
                self.subcategory = ""
                self.infoLabel.isHidden = true
                self.infoTF.isHidden = true
                break
            }
        }
        
        isLogged()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        if self.comeFrom == 2 {
            let prevSubcategory = self.adForEdit.value(forKey: "subcategory") as! String
            self.subCategoryButton.setTitle(prevSubcategory, for: .normal)
            self.subcategory = prevSubcategory
            print("Subcategory: \(self.subcategory)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func resetInfo() {
        let alert = UIAlertController(title: "Внимание", message: "Вы действительно хотите очистить все поля?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Нет", style: UIAlertActionStyle.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Да", style: UIAlertActionStyle.default, handler: { action in
            self.category = ""
            self.cCategoryButton.setAttributedTitle(self.getAttributedString(string: "Выберите категорию"), for: .normal)
            self.subCategoryButton.setTitle("Подкатегория", for: .normal)
            self.headerTF.text = ""
            self.adBody.text = ""
            self.infoTF.text = ""
            self.choosedPictures.removeAll()
            self.collectionView.reloadData()
        }))
        
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        
        for i in 0..<photos.count {
            if self.choosedPictures.count == 5 {
                HELPER.showToast(view: self.view, text: "Максимум можно прикрепить 5 фотографий")
                break
            } else {
                self.choosedPictures.append(photos[i])
            }
        }
        self.collectionView.reloadData()
        
    }


    
    func changeCategory(string: String) {
        self.category = string
        self.subCategoryButton.setTitle("Подкатегория", for: .normal)
    }
    
    
    func isLogged(){
        
        let managedContext = self.managedObjectContext()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Isregistered")
        
        do {
            let fetchedResult = try managedContext.fetch(fetchRequest)
            let model = fetchedResult as! [NSManagedObject]
            print("I have \(model.count) users now oO")
            if model.count == 0 {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let unloggedVC = storyboard.instantiateViewController(withIdentifier: "unloggedVC") as! UnloggedViewController
                self.navigationController?.pushViewController(unloggedVC, animated: true)
                print("I'ts empty array")
            } else {
                self.user = HELPER.getUser()
                self.navigationController?.navigationBar.isHidden = false
                print("Not empty")
            }
            
        } catch {
            print("Error while fetching occured")
        }
        
    }
    
    

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.choosedPictures.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: "cpCell", for: indexPath) as! ChoosedPicturesViewCell
        cell.image.image = self.choosedPictures[indexPath.row]
        cell.cancelButton.layer.setValue(indexPath.row, forKey: "index")
        cell.cancelButton.addTarget(self, action: #selector(self.cancelPhoto(sender:)), for: UIControlEvents.touchUpInside)
        return cell
    }
    
    
    

    func cancelPhoto(sender:UIButton) {
        
        let i : Int = (sender.layer.value(forKey: "index")) as! Int
        self.choosedPictures.remove(at: i)
        self.collectionView.reloadData()
    }
    
    
    @IBAction func chooseCategory(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let searchVC = storyboard.instantiateViewController(withIdentifier: "ccVC") as! ChooseCategoryViewController
        searchVC.delegate = self
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    @IBAction func choosePictures(_ sender: Any) {
        let lr = TZImagePickerController(maxImagesCount: 5, delegate: self)
        self.present(lr!, animated: true, completion: nil)
    }
    
   
    @IBAction func publicAd(_ sender: Any) {
        let dateM = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatter.string(from: dateM)
        var name = ""
        var nickname = ""
        var id = ""
        //let subcategory = self.subCategoryButton.titleLabel?.text

        
        if self.user.value(forKey: "name") != nil {
            name = self.user.value(forKey: "name") as! String
        }
        
        if (self.user.value(forKey: "nickname") != nil) {
            nickname = self.user.value(forKey: "nickname") as! String
        }
        
        let header = HELPER.checkString(stringForCheck: self.headerTF.text!)
        let body = HELPER.checkString(stringForCheck: self.adBody.text!)
        let city = self.cityButton.titleLabel?.text
        let pictures = String(self.choosedPictures.count)
        let info = self.infoTF.text!
        let telnum = self.telnumTF.text!
        let ownerid = self.user.value(forKey: "id") as! String
        
        if self.category == "" {
            HELPER.showToast(view: self.view, text: "Выберите категорию")
        } else if city == "Город" {
            HELPER.showToast(view: self.view, text: "Укажите город")
        } else if telnum == "" {
            HELPER.showToast(view: self.view, text: "Укажите номер телефона")
        } else {
        
            OperationQueue.main.addOperation {
                MBProgressHUD.showAdded(to: self.view, animated: true)
            }
            var url = ""
            if self.comeFrom == 0 {
                url = "http://invietnam.website/vietnam/ads.php?request=addad&ownerid=\(ownerid)&name=\(name)&nickname=\(nickname)&header=\(header)&body=\(body)&info=\(info)&city=\(city!)&telnum=\(telnum)&date=\(date)&category=\(self.category)&subcategory=\(self.subcategory)&pictures=\(pictures)"
            } else if self.comeFrom == 2 {
                let directory = HELPER.switchCatLang(categoryRName: self.category)
                let id = self.adForEdit.value(forKey: "id") as! String
                url = "http://invietnam.website/vietnam/ads.php?request=editad&ownerid=\(ownerid)&name=\(name)&nickname=\(nickname)&header=\(header)&body=\(body)&info=\(info)&city=\(city!)&telnum=\(telnum)&date=\(date)&category=\(self.category)&subcategory=\(self.subcategory)&pictures=\(pictures)&directory=\(directory)&id=\(id)"
            }
            print(url)
            
            Alamofire.request(url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!).responseJSON { response in
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
                    print(result)
                    
                    let jsonData = JSON(data: response.data!)
                    print(jsonData)
                    let responseArray = jsonData.object as! NSObject
                    print(responseArray)
                    self.result = responseArray.value(forKey: "result") as! String
                    
                    if self.result == "error" {
                        OperationQueue.main.addOperation {
                            MBProgressHUD.hide(for: self.view, animated: true)
                        }
                        HELPER.showToast(view: self.view, text: "Ошибка, не удалось сохранить объявление")
                        
                    } else if self.result == "success" {
                        OperationQueue.main.addOperation {
                            MBProgressHUD.hide(for: self.view, animated: true)
                        }
                        
                        id = String(responseArray.value(forKey: "id") as! Int)
                        
                        if self.choosedPictures.count != 0 {
                            for i in 0..<self.choosedPictures.count {
                                do {
                                    try self.uploadImage(image: self.choosedPictures[i], id: "\(id)_\(i)")
                                } catch {
                                    print("Error")
                                }
                            }
                        }
                        
                        
                        if self.comeFrom == 0 {
                            HELPER.showToast(view: self.view, text: "Обявление успешно добавлено")
                            self.category = ""
                            self.cCategoryButton.setAttributedTitle(self.getAttributedString(string: "Выберите категорию"), for: .normal)
                            self.subCategoryButton.setTitle("Подкатегория", for: .normal)
                            self.headerTF.text = ""
                            self.adBody.text = ""
                            self.infoTF.text = ""
                            self.choosedPictures.removeAll()
                            self.collectionView.reloadData()
                        } else if self.comeFrom == 2 {
                            HELPER.showToast(view: self.view, text: "Обявление успешно обновлено")
                            
                            let delayTime = DispatchTime.now() + 1.5
                            DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
                                _ = self.navigationController?.popViewController(animated: true)
                            })
                            
                        }
                        
                        HELPER.loadAds()
                    }
                    
                }
                
            }
        
        
        }
        
        
        print("PRESSED")
  
        
        
        
        
        
    }
    
    
    
    
    func uploadImage(image : UIImage, id: String) throws -> Void {
        
        var parameters = [
            "task": "task",
            "variable1": "var"
        ]
        
        // add addtionial parameters
        parameters["userId"] = "27"
        parameters["body"] = "This is the body text."
        parameters["id"] = id
        parameters["category"] = HELPER.switchCatLang(categoryRName: self.category)
        
        // example image data
        
        
        
        let imageData = UIImageJPEGRepresentation(image, 0.25)
        
        // CREATE AND SEND REQUEST ----------
        
        let url = "http://invietnam.website/vietnam/uploadpic.php?"
        
        
        let urlRequest = try urlRequestWithComponents(urlString: url, parameters: parameters, imageData: imageData!)
        print(urlRequest)
        Alamofire.upload(urlRequest.1, with: urlRequest.0).uploadProgress { progress in
            print("Upload progress: \(progress)")
            }
            .responseJSON { response in
                
                print(response)
            }
    }
    
    
    func urlRequestWithComponents(urlString:String, parameters:Dictionary<String, String>, imageData:Data) throws -> (URLRequestConvertible, Data) {
        
        // create url request to send
        
        var mutableURLRequest = URLRequest(url: NSURL(string: urlString)! as URL)
        mutableURLRequest.httpMethod = Alamofire.HTTPMethod.post.rawValue
        let boundaryConstant = "myRandomBoundary12345";
        let contentType = "multipart/form-data;boundary="+boundaryConstant
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        // create upload data to send
        let uploadData = NSMutableData()
        
        // add image
        uploadData.append("\r\n--\(boundaryConstant)\r\n".data(using: String.Encoding.utf8)!)
        uploadData.append("Content-Disposition: form-data; name=\"file\"; filename=\"file.png\"\r\n".data(using: String.Encoding.utf8)!)
        uploadData.append("Content-Type: image/png\r\n\r\n".data(using: String.Encoding.utf8)!)
        uploadData.append(imageData as Data)
        
        // add parameters
        for (key, value) in parameters {
            uploadData.append("\r\n--\(boundaryConstant)\r\n".data(using: String.Encoding.utf8)!)
            uploadData.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".data(using: String.Encoding.utf8)!)
        }
        uploadData.append("\r\n--\(boundaryConstant)--\r\n".data(using: String.Encoding.utf8)!)
        
        return (try URLEncoding.default.encode(mutableURLRequest, with: nil), uploadData as Data)
        
    }
    
    
    
    @IBAction func showSubcategory(_ sender: Any) {
        
        dropDownCategory.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.subCategoryButton.setTitle(item, for: .normal)
            self.subcategory = item
        }
 
        dropDownCategory.show()
        
    }
    
    @IBAction func showCitys(_ sender: Any) {
        
        dropDownCity.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.cityButton.setTitle(item, for: .normal)
        }
        
        dropDownCity.show()
    }
    
    @IBAction func dismissKeyboard(_ sender: Any) {
        self.resignFirstResponder()
    }
    
    @IBAction func formatPhoneNumber(_ sender: Any) {
        
        self.telnumTF.text = "\((self.telnumTF.text!).toPhoneNumber())"
        self.resignFirstResponder()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if(text == "\n")
        {
            view.endEditing(true)
            return false
        }
        else
        {
            return true
        }
    }
    
    
    @IBAction func prevVC(_ sender: Any) {
        if self.comeFrom == 0 {
            self.tabBarController?.selectedIndex = 1
        }
    }
    
    @IBAction func nextVC(_ sender: Any) {
        if self.comeFrom == 0 {
            self.tabBarController?.selectedIndex = 3
        }
    }
    
    func getAttributedString(string: String) -> NSAttributedString {
        let attrs = [
            //NSForegroundColorAttributeName: UIColor(colorLiteralRed: 0/255, green: 122/255, blue: 255/255, alpha: 1.0),
            NSForegroundColorAttributeName: UIColor(colorLiteralRed: 49/255, green: 102/255, blue: 49/255, alpha: 0.7),

            NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue
            
            //NSFontAttributeName: UIFont(name: "BodoniOrnamentsITCTT", size: 18)!
        ] as [String : Any]
        
        
        let atstr = NSAttributedString(string: string, attributes: attrs)
        
        
        return atstr
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    func managedObjectContext() -> NSManagedObjectContext{
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        if #available(iOS 10.0, *) {
            context = appDelegate.persistentContainer.viewContext
        } else {
            
        }
        
        return context
    }
    
    
    
    
    

}
