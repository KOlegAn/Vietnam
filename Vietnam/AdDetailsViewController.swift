//
//  AdDetailsViewController.swift
//  Vietnam
//
//  Created by Oleg Kuplin on 23.11.16.
//  Copyright © 2016 Oleg Kuplin. All rights reserved.
//

import UIKit
import CoreData

class AdDetailsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoLabelF: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var cityLabelF: UILabel!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var ownerLabelF: UILabel!
    @IBOutlet weak var telnumLabel: UIButton!
    @IBOutlet weak var telnumLabelF: UILabel!
    
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    
    var currentAd = NSObject()
    var isFullScreen = false
    var prevFrame = CGRect()
    var images = [UIImageView]()
    var fullView = UIImageView()
    var scrollImg: UIScrollView = UIScrollView()
    var state = 0
    var fav = 0
    var picRow = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        self.fitContent()
        self.view.isUserInteractionEnabled = true
        
        print("State now is: \(self.state) and subcategory is: \(self.self.currentAd.value(forKey: "subcategory") as! String)")
        if self.state == 2 {
            print("So state")
            let rightBarButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.editAd))
            self.navigationItem.rightBarButtonItem = rightBarButton
        } else {
            let rightBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "seaStar"), style: .plain, target: self, action: #selector(self.changeFavIcon))
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor(colorLiteralRed: 88/255, green: 177/255, blue: 86/255, alpha: 1.0)
            self.navigationItem.rightBarButtonItem = rightBarButton
        }

        self.isFavorite()
            // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func editAd() {
        let subcategory = self.currentAd.value(forKey: "subcategory") as! String
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let addAdsVC = storyboard.instantiateViewController(withIdentifier: "addAdsVC") as! AddAdsViewController
        addAdsVC.comeFrom = 2
        addAdsVC.adForEdit = self.currentAd
        addAdsVC.subcategory = subcategory
        self.navigationController?.pushViewController(addAdsVC, animated: true)
    }
    
    func changeFavIcon() {
        
        if self.state == 0 {
            self.navigationItem.rightBarButtonItem?.image = #imageLiteral(resourceName: "seaStar")
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor(colorLiteralRed: 88/255, green: 177/255, blue: 86/255, alpha: 1.0)
            var name = ""
            var nickname = ""
            if  self.currentAd.value(forKey: "name") != nil {
                name = self.currentAd.value(forKey: "name") as! String
            }
            if  self.currentAd.value(forKey: "nickname") != nil {
                nickname = self.currentAd.value(forKey: "nickname") as! String
            }

            
            
            let id = self.currentAd.value(forKey: "id") as! String
            let header = self.currentAd.value(forKey: "header") as! String
            let body = self.currentAd.value(forKey: "body") as! String
            let date = self.currentAd.value(forKey: "date") as! String
            let city = self.currentAd.value(forKey: "city") as! String
            let category = self.currentAd.value(forKey: "category") as! String
            let subcategory = self.currentAd.value(forKey: "subcategory") as! String
            let telnum = self.currentAd.value(forKey: "telnum") as! String
            let info = self.currentAd.value(forKey: "info") as! String
            let pictures = self.currentAd.value(forKey: "pictures") as! String
            
            
            HELPER.saveNewFavorite(id: id, name: name, nickname: nickname, date: date, body: body, header: header, city: city, category: category, subcategory: subcategory, telnum: telnum, info: info, pictures: pictures)
            self.state = 1
        } else {
            
            self.navigationItem.rightBarButtonItem?.image = #imageLiteral(resourceName: "seaFavorites")
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
            HELPER.deleteFavorite(favorite: self.deleteThisFavorite())
            self.state = 0
            if self.fav == 1 {
                self.navigationController?.popViewController(animated: true)
            }
        }
        
    }
    
    func isFavorite() {
        
        let id = self.currentAd.value(forKey: "id") as! String
        
        let managedContext = self.managedObjectContext()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorites")
        
        do {
            let fetchedResult = try managedContext.fetch(fetchRequest)
            let savedFavorites = fetchedResult as! [NSManagedObject]

            
            for favorite in savedFavorites {
                let idForCheck = favorite.value(forKey: "id") as! String
                
                if idForCheck == id {
                    self.navigationItem.rightBarButtonItem?.image = #imageLiteral(resourceName: "seaStar")
                    self.navigationItem.rightBarButtonItem?.tintColor = UIColor(colorLiteralRed: 88/255, green: 177/255, blue: 86/255, alpha: 1.0)
                    self.state = 1
                    break
                }
            }
            
        } catch {
            print("Error")
        }
        
    }
    
    override var hidesBottomBarWhenPushed: Bool {
        
        get { if self.state == 2{
            return false} else {
            return true
            }
        }
        set { super.hidesBottomBarWhenPushed = newValue }
    }
    
    func deleteThisFavorite() -> NSManagedObject {
        
        let id = self.currentAd.value(forKey: "id") as! String
        var forDelete : NSManagedObject?
        
        let managedContext = self.managedObjectContext()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorites")
        
        
        do {
            let fetchedResult = try managedContext.fetch(fetchRequest)
            let savedFavorites = fetchedResult as! [NSManagedObject]
            
            
            for favorite in savedFavorites {
                let idForCheck = favorite.value(forKey: "id") as! String
                
                if idForCheck == id {
                    self.navigationItem.rightBarButtonItem?.image = #imageLiteral(resourceName: "seaStar")
                    self.state = 1
                    forDelete = favorite
                    break
                }
            }
            
        } catch {
            print("Error")
        }
        
        return forDelete!
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        print("PICS HAVE \(self.images.count) ITEMS")
        if self.currentAd.value(forKey: "pictures") as! String == "0" {
            return 1
        } else {
            return Int(self.currentAd.value(forKey: "pictures") as! String)!
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: "addetailsCell", for: indexPath) as! AdDetailsViewCell
        
        
        
        
        let id = self.currentAd.value(forKey: "id") as! String
        let category = self.currentAd.value(forKey: "category") as! String
        let categoryDirectory = HELPER.switchCatLang(categoryRName: category)
        print(id)
        do {
            
            if self.currentAd.value(forKey: "pictures") as! String == "0" {
                cell.isUserInteractionEnabled = false
                
                var imageFrame = cell.image.frame
                imageFrame.size.width = self.collectionView.frame.width
                cell.image.frame = imageFrame
                cell.image.image = #imageLiteral(resourceName: "nopicplaceholder")
                cell.image.contentMode = .scaleAspectFit
                cell.backgroundColor = UIColor.white
                self.collectionView.backgroundColor = UIColor.white
            } else {
                cell.image.sd_setShowActivityIndicatorView(true)
                cell.image.sd_setIndicatorStyle(.gray)
                print("http://invietnam.website/vietnam/adpics/\(id)_\(indexPath.row).png")
                cell.image.sd_setImage(with: URL(string: "http://invietnam.website/vietnam/adpics/\(categoryDirectory)/\(id)_\(indexPath.row).png"), placeholderImage: #imageLiteral(resourceName: "imagesPlaceholder"), options: [.retryFailed, .refreshCached])
                
                self.images.append(cell.image)
            }
            
        } catch {
            print("No more pics")
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        self.navigationController?.navigationBar.isHidden = true
        
        self.picRow = indexPath.row
        
        print("Picrow now: \(self.picRow)")

        
        scrollImg.delegate = self
        scrollImg.backgroundColor = UIColor.black
        scrollImg.alwaysBounceVertical = false
        scrollImg.alwaysBounceHorizontal = false
        scrollImg.showsVerticalScrollIndicator = true
        scrollImg.flashScrollIndicators()
        
        scrollImg.minimumZoomScale = 1.0
        scrollImg.maximumZoomScale = 5.0

        fullView.contentMode = UIViewContentMode.scaleAspectFit
        fullView.backgroundColor = UIColor.black
        fullView.image = self.images[indexPath.row].image
        fullView.frame = self.view.bounds
        
        
        let tapGest = UITapGestureRecognizer(target: self, action: #selector(self.hideImage))
        tapGest.numberOfTapsRequired = 1
        tapGest.numberOfTouchesRequired = 1
        fullView.addGestureRecognizer(tapGest)
        
        let directions: [UISwipeGestureRecognizerDirection] = [.right, .left]
        for direction in directions {
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeImage(swipeGesture: )))
            gesture.direction = direction
            fullView.addGestureRecognizer(gesture)
        }
        
        
        scrollImg.isUserInteractionEnabled = true
        fullView.isUserInteractionEnabled = true
        
        
        scrollImg.addSubview(fullView)
        
        
        UIView.animate(withDuration: 0, animations: {
            
            self.view.addSubview(self.scrollImg)
            self.scrollImg.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)

        })
        
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        
    }
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.fullView
    }


    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if self.currentAd.value(forKey: "pictures") as! String == "0" {
            print("Returning")
            return CGSize(width: self.collectionView.frame.width, height: 200)
        } else {
            return CGSize(width: 200, height: 200)
        }
        
    }
    
    
    func hideImage(){
        scrollImg.removeFromSuperview()

        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true

    }
    
    
    func swipeImage(swipeGesture: UISwipeGestureRecognizer) {
        
        switch swipeGesture.direction {
        case UISwipeGestureRecognizerDirection.right:
            if self.picRow == 0 {
                self.picRow = self.images.count - 1
                fullView.image = self.images[self.images.count - 1].image
            } else {
                self.picRow = self.picRow - 1
                fullView.image = self.images[self.picRow].image
            }
        case UISwipeGestureRecognizerDirection.left:
            if self.picRow == self.images.count - 1{
                self.picRow = 0
                fullView.image = self.images[0].image
            } else {
                self.picRow = self.picRow + 1
                fullView.image = self.images[self.picRow].image
            }
        default:
            break
        }
        
    }
    
    
    func imgToFullScreen(recognizer : UITapGestureRecognizer, image: UIImageView) {
        
        if !self.isFullScreen {
            self.navigationController?.navigationBar.isHidden = true
            UIView.animate(withDuration: 3, delay: 0, options: .allowAnimatedContent, animations: {
                self.prevFrame = image.frame
                image.frame = UIScreen.main.bounds
            }, completion: { some in
                self.isFullScreen = true
            })
        } else {
            UIView.animate(withDuration: 5, delay: 0, options: .allowAnimatedContent, animations: {
                image.frame = self.prevFrame
            }, completion: { some in
                self.isFullScreen = false
                self.navigationController?.navigationBar.isHidden = false

            })
        }
        
        
    }
    
    
    func fitContent() {
        
        
        let header = self.currentAd.value(forKey: "header") as! String
        let body = self.currentAd.value(forKey: "body") as! String
        let date = self.currentAd.value(forKey: "date") as! String
        let city = self.currentAd.value(forKey: "city") as! String
        let owner = self.currentAd.value(forKey: "name") as! String
        let telnum = self.currentAd.value(forKey: "telnum") as! String
        let info = self.currentAd.value(forKey: "info") as! String
        
        
        self.headerLabel.text = header
        self.bodyLabel.text = HELPER.returnString(stringForReturn: body)
        self.dateLabel.text = "Время добавления: \(date)"
        self.ownerLabel.text = owner
        self.cityLabel.text = city
        self.telnumLabel.setTitle(telnum, for: .normal)
        if info != "" {
            
            let currentCategory = self.currentAd.value(forKey: "category") as! String
            self.infoLabel.text = info

            if currentCategory == "Работа" {
                self.infoLabelF.text = "З/П:"
            } else {
                self.infoLabelF.text = "Цена:"
            }
            
            
            
            self.bodyLabel.sizeToFit()
            
            
            let bodyFrame = self.bodyLabel.frame
            let bodyY = bodyFrame.origin.y + bodyFrame.size.height + 30
            var cityFrame = self.infoLabel.frame
            
            cityFrame.origin.y = bodyY
            self.infoLabel.frame = cityFrame
            cityFrame.origin.y = cityFrame.origin.y + 29
            self.cityLabel.frame = cityFrame
            cityFrame.origin.y = cityFrame.origin.y + 29
            self.ownerLabel.frame = cityFrame
            cityFrame.origin.y = cityFrame.origin.y + 29
            self.telnumLabel.frame = cityFrame
            cityFrame.origin.x = 16
            cityFrame.origin.y = bodyY
            self.infoLabelF.frame = cityFrame
            cityFrame.origin.y = cityFrame.origin.y + 29
            self.cityLabelF.frame = cityFrame
            cityFrame.origin.y = cityFrame.origin.y + 29
            self.ownerLabelF.frame = cityFrame
            cityFrame.origin.y = cityFrame.origin.y + 29
            self.telnumLabelF.frame = cityFrame
            
            
            self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, cityFrame.origin.y + 60, 0)
            
            
        } else {
            self.infoLabel.isHidden = true
            self.infoLabelF.isHidden = true
            
            self.bodyLabel.sizeToFit()
            
            
            let bodyFrame = self.bodyLabel.frame
            let bodyY = bodyFrame.origin.y + bodyFrame.size.height + 30
            var cityFrame = self.cityLabel.frame
            
            cityFrame.origin.y = bodyY
            self.cityLabel.frame = cityFrame
            cityFrame.origin.y = cityFrame.origin.y + 29
            self.ownerLabel.frame = cityFrame
            cityFrame.origin.y = cityFrame.origin.y + 29
            self.telnumLabel.frame = cityFrame
            cityFrame.origin.x = 16
            cityFrame.origin.y = bodyY
            self.cityLabelF.frame = cityFrame
            cityFrame.origin.y = cityFrame.origin.y + 29
            self.ownerLabelF.frame = cityFrame
            cityFrame.origin.y = cityFrame.origin.y + 29
            self.telnumLabelF.frame = cityFrame
            
            
            self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, cityFrame.origin.y + 60, 0)
            
        }
        
        
        

        
    }
    
    @IBAction func makeCall(_ sender: Any) {
        
        
        let telString = (self.telnumLabel.titleLabel?.text)! as String
        
        print("Telnum: \(telString.digitsOnly())")

        let alert = UIAlertController(title: "Внимание", message: "Вы действительно хотите позвонить?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Нет", style: UIAlertActionStyle.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Да", style: UIAlertActionStyle.default, handler: { action in
            
            UIApplication.shared.openURL(URL(string: "tel://\(telString.digitsOnly())")!)

        }))
        
        
        self.present(alert, animated: true, completion: nil)
        
        
        
        
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
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
