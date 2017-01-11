//
//  MeViewController.swift
//  Vietnam
//
//  Created by Oleg Kuplin on 12.11.16.
//  Copyright © 2016 Oleg Kuplin. All rights reserved.
//

import UIKit
import CoreData

class MeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

    //, UIGestureRecognizerDelegate
    
    @IBOutlet weak var tableView: UITableView!
    
    var isLog = false
    var activityIndicator = UIActivityIndicatorView()
    let adCells = ["Мои объявления", "Добавить объявление"]
    var userInfo: NSObject?
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self

        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.navigationBar.isHidden = false
        self.activityIndicator = self.createActivityIndicator()
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false

//        refreshControl.attributedTitle = NSAttributedString(string: "")
//        refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControlEvents.valueChanged)
//        tableView.addSubview(refreshControl)
    }
    
    
    
    func refresh(sender: AnyObject) {
        
        self.isLogged()
        

    }
    
    override var hidesBottomBarWhenPushed: Bool {
        get { return false }
        set { super.hidesBottomBarWhenPushed = newValue }
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.tableView.delegate = self
        self.tableView.reloadData()
        self.isLogged()

        var rect = self.tableView.frame
        rect.origin.y = 47
        //self.tableView.frame = rect
        
        print("View appeared")
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    

    

    func isLogged(){
        
        let managedContext = HELPER.managedObjectContext()
       
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Isregistered")
        
        do {
            let fetchedResult = try managedContext.fetch(fetchRequest)
            let model = fetchedResult as! [NSManagedObject]
            print("I have \(model.count) users now oO")
            if model.count == 0 {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

                
                let unloggedVC = storyboard.instantiateViewController(withIdentifier: "unloggedVC") as! UnloggedViewController
                self.navigationController?.pushViewController(unloggedVC, animated: false)
                print("I'ts empty array")
            } else {
                self.userInfo = model[0]
                let id = self.userInfo?.value(forKey: "id") as! String
                print("User id: \(id)")
                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.tableView.reloadData()
                self.navigationController?.navigationBar.isHidden = false
                self.refreshControl.endRefreshing()
                
                
                print("Not empty")
            }
            
        } catch {
            print("Error while fetching occured")
        }
        
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        switch section {
        case 1:
            return 2
        default:
            return 1
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        
        if self.userInfo != nil {
            
            if indexPath.section == 0 {
                let cell1 = self.tableView.dequeueReusableCell(withIdentifier: "mainInfoCell", for: indexPath) as! MainInfoCell
                cell.selectionStyle = .blue
                
                var name = ""
                var nickname = ""
                if self.userInfo?.value(forKey: "name") != nil {
                    name = self.userInfo?.value(forKey: "name") as! String
                }
                
                if self.userInfo?.value(forKey: "nickname") != nil {
                    nickname = self.userInfo?.value(forKey: "nickname") as! String
                }
                
                
                cell1.avatarImage.image = HELPER.getUserAvatar()
                cell1.avatarImage.layer.cornerRadius = 5
                cell1.avatarImage.backgroundColor = UIColor.clear
                
                cell1.nameLabel.text = name
                cell1.nicknameLabel.text = nickname
                return cell1
                
            } else if indexPath.section == 1 {
                let cell1 = self.tableView.dequeueReusableCell(withIdentifier: "adsInfoCell", for: indexPath) as! AdsInfoCell
                cell1.label.text = self.adCells[indexPath.row]
                
                if indexPath.row == 0 {
                    cell1.setImage.image = #imageLiteral(resourceName: "myads")
                } else if indexPath.row == 1 {
                    cell1.setImage.image = #imageLiteral(resourceName: "adad")
                }
                
                cell1.rightArrowImage.image = #imageLiteral(resourceName: "right_arrow")
                return cell1
            } else if indexPath.section == 2 {
                let cell1 = self.tableView.dequeueReusableCell(withIdentifier: "adsInfoCell", for: indexPath) as! AdsInfoCell
                cell1.label.text = "Настройки"
                cell1.setImage.image = #imageLiteral(resourceName: "gear")
                cell1.rightArrowImage.image = #imageLiteral(resourceName: "right_arrow")
                return cell1
                
            } else if indexPath.section == 3 {
                if indexPath.row == 0 {
                    let cell1 = self.tableView.dequeueReusableCell(withIdentifier: "adsInfoCell", for: indexPath) as! AdsInfoCell
                    cell1.label.text = "Выйти"
                    cell1.label.textAlignment = .center
                    return cell1
                } else {
                    
                }
            }
            
        } else {
            print("It's nill")
        }
        
        return cell
    }

    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = UIColor.clear
        return v
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 100
        default:
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 3 {
            return 60
        } else {
            return 17
        }
        
    }
    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
         
        
        switch indexPath.section {
        case 0:
            let personSetVC = storyboard.instantiateViewController(withIdentifier: "personSetVC") as! PersonSettingsViewController
            personSetVC.userInfo = (self.userInfo)!
            self.navigationController?.pushViewController(personSetVC, animated: true)
            break
        case 1:
            
            switch indexPath.row {
            case 0:
                let favoritesVC = storyboard.instantiateViewController(withIdentifier: "favoritesVC") as! FavoritesViewController
                let userId = self.userInfo?.value(forKey: "id") as! String
                favoritesVC.userId = userId
                favoritesVC.state = 1
                self.navigationController?.pushViewController(favoritesVC, animated: true)
                print("Мои объявы")
                break
            case 1:
                let addAdsVC = storyboard.instantiateViewController(withIdentifier: "addAdsVC") as! AddAdsViewController
                addAdsVC.comeFrom = 1
                self.navigationController?.pushViewController(addAdsVC, animated: true)
            default:
                break
            }
        case 2:
            
            
            let settingsVC = storyboard.instantiateViewController(withIdentifier: "settingsVC") as! SettingsViewController
            self.navigationController?.pushViewController(settingsVC, animated: true)
            print("Настройки")
            break
        case 3:
            
            if indexPath.row == 0 {
                let alert = UIAlertController(title: "Внимание", message: "Вы действительно хотите выйти из аккаунта?", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Нет", style: UIAlertActionStyle.cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Да", style: UIAlertActionStyle.default, handler: { action in
                    HELPER.deleteUser()
                    HELPER.clearFavorites()
                    
                    let delayTime = DispatchTime.now() + 1.5
                    DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
                        self.isLogged()
                    })
                }))
                
                
                self.present(alert, animated: true, completion: nil)
                
                
                print("Выйти")
                break
            } else {
                
            }
            
            
        default:
            break
        }
        
        
        
    }
    
    func deleteUser(){
        let managedContext = HELPER.managedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Isregistered")
        let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            _ = try managedContext.execute(request)
        } catch {
            print("Error")
        }
        print("Deleted")
    }

    
    func createActivityIndicator() -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2, y: self.view.frame.height / 2, width: 40, height: 40))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        indicator.center = self.view.center
        indicator.backgroundColor = UIColor.clear
        self.view.addSubview(indicator)
        return indicator
    }
    

   
    @IBAction func prevVC(_ sender: Any) {
        self.tabBarController?.selectedIndex = 3
    }
    
    @IBAction func nextVC(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
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


