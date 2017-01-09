//
//  FavoritesViewController.swift
//  Vietnam
//
//  Created by Oleg Kuplin on 03.12.16.
//  Copyright © 2016 Oleg Kuplin. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {


    @IBOutlet weak var tableView: UITableView!
    
    var favoriteAds = Array<NSObject>()
    var refreshControl = UIRefreshControl()
    var state = 0
    var userId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isHidden = false
        self.tableView.delegate = self
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControlEvents.valueChanged)
        
        
        print("State: \(state)")
        if self.state == 1 {
            self.navigationItem.title = "Мои объявления"
            let rightBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.moveToAdd))
            self.navigationItem.rightBarButtonItem = rightBarButton
            
        }
                
    }
    
    
    override var hidesBottomBarWhenPushed: Bool {
        
        get { if self.state == 0{
            return false} else {
            return true
            }
        }
        set { super.hidesBottomBarWhenPushed = newValue }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.loadFavorites()
        
    }
    
    
    func moveToAdd() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let addAdsVC = storyboard.instantiateViewController(withIdentifier: "addAdsVC") as! AddAdsViewController
        self.navigationController?.pushViewController(addAdsVC, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh(sender: AnyObject) {
        self.loadFavorites()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.favoriteAds.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 2 // space b/w cells
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = UIColor(colorLiteralRed: 241/255, green: 241/255, blue: 247/255, alpha: 1.0)
        return header
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "favoritesCell", for: indexPath) as! FavoritesTableViewCell
        
        var subcategory = ""
        var currentInfo = ""

        if self.favoriteAds[indexPath.section].value(forKey: "subcategory") != nil {
            subcategory = self.favoriteAds[indexPath.section].value(forKey: "subcategory") as! String
        }
        if self.favoriteAds[indexPath.section].value(forKey: "info") != nil {
            currentInfo = self.favoriteAds[indexPath.section].value(forKey: "info") as! String
        }
        let currentDate = self.favoriteAds[indexPath.section].value(forKey: "date") as! String
        let category = self.favoriteAds[indexPath.section].value(forKey: "category") as! String
        let categoryDirectory = HELPER.switchCatLang(categoryRName: category)
        let currentId = self.favoriteAds[indexPath.section].value(forKey: "id") as! String
        let currentHeader = self.favoriteAds[indexPath.section].value(forKey: "header") as! String
        let currentCatSub = "\(category) \u{B7} \(subcategory)"

        
        cell.adHeader.text = currentHeader
        cell.adCatSub.text = currentCatSub
        cell.adDate.text   = currentDate
        cell.adInfo.text   = currentInfo
        cell.adImage.sd_setShowActivityIndicatorView(true)
        cell.adImage.sd_setImage(with: URL(string: "http://invietnam.website/vietnam/adpics/\(categoryDirectory)/\(currentId)_0.png"), placeholderImage: nil, options: [.retryFailed, .refreshCached])
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let addetailsVC = storyboard.instantiateViewController(withIdentifier: "addetailsVC") as! AdDetailsViewController
        addetailsVC.currentAd = self.favoriteAds[indexPath.section]
        if self.state == 1 {
            addetailsVC.state = 2
        } else {
            addetailsVC.fav = 1
        }
        self.navigationController?.pushViewController(addetailsVC, animated: true)
        
    }
    

    
    func loadFavorites() {
        
        self.favoriteAds.removeAll()
        
        if self.state == 0 {
            let managedContext = self.managedObjectContext()
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorites")
            
            do {
                let fetchedResult = try managedContext.fetch(fetchRequest)
                self.favoriteAds = fetchedResult as! [NSManagedObject]
                self.tableView.reloadData()
                refreshControl.endRefreshing()
            } catch {
                print("Error")
            }
        } else {
            
            let ads = HELPER.getAds()

            for ad in ads {
                let currentId = ad.value(forKey: "ownerid") as! String
                print("userId: \(self.userId), currentId: \(currentId)")
                if currentId == self.userId {
                    self.favoriteAds.append(ad)
                }
            }
            self.tableView.reloadData()
            refreshControl.endRefreshing()
        }
        
        self.favoriteAds = favoriteAds.sorted(by: {($0.value(forKey: "date") as! String) > ($1.value(forKey: "date") as! String)})

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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            if self.state == 1 {
                let alert = UIAlertController(title: "Внимание", message: "Вы действительно хотите удалить это объявление?", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Нет", style: UIAlertActionStyle.cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Да", style: UIAlertActionStyle.default, handler: { action in
                    let adForDelete = self.favoriteAds[indexPath.section]
                    let id = adForDelete.value(forKey: "id") as! String
                    let category = adForDelete.value(forKey: "category") as! String
                    let directory = HELPER.switchCatLang(categoryRName: category)
                    
                    let url = "http://invietnam.website/vietnam/ads.php?request=removead&id=\(id)&directory=\(directory)"
                    
                    Alamofire.request(url, method: .post)
                    self.favoriteAds.remove(at: indexPath.section)
                    self.tableView.reloadData()
                    HELPER.loadAds()
                    HELPER.showToast(view: self.view, text: "Объявление удалено")
                }))
                self.present(alert, animated: true, completion: nil)
            } else if self.state == 0 {
                HELPER.deleteFavorite(favorite: self.favoriteAds[indexPath.section] as! NSManagedObject)
                self.favoriteAds.remove(at: indexPath.section)
                self.tableView.reloadData()
            }
            
            
            
            
            //tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    @IBAction func changeVC(_ sender: Any) {
        if self.state == 0 {
            self.tabBarController?.selectedIndex = 0
        }
    }
    @IBAction func nextVC(_ sender: Any) {
        if self.state == 0 {
            self.tabBarController?.selectedIndex = 2
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
