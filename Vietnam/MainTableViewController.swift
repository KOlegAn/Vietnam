//
//  MainTableViewController.swift
//  Vietnam
//
//  Created by Oleg Kuplin on 08.01.17.
//  Copyright © 2017 Oleg Kuplin. All rights reserved.
//

import UIKit

class MainTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var cityButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var ads              = Array<NSObject>()
    var cityAds          = Array<NSObject>()
    var refreshControl   = UIRefreshControl()
    let dropDownCity     = DropDown()
    var currentCity      = "Все города"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.ads = HELPER.getAds()
        
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)

        self.cityAds = self.ads
        
        dropDownCity.anchorView = self.cityButton
        dropDownCity.width = self.cityButton.frame.size.width + 122
        dropDownCity.cellHeight = 42
        dropDownCity.textFont = UIFont.systemFont(ofSize: 16)
        dropDownCity.textAligment = .center
        dropDownCity.separatorColor = UIColor.gray
        dropDownCity.separatorInsetRight = 15
        dropDownCity.bottomOffset = CGPoint(x: self.view.frame.width - 250, y:(dropDownCity.anchorView?.plainView.bounds.height)!)
        
        dropDownCity.dataSource = ["Все", "Вунгтау", "Далат", "Муйне","Нячанг", "Ханой", "Хошимин"]
    }

    func refresh(sender: AnyObject) {
        HELPER.loadAds()
        self.ads = HELPER.getAds()
        self.changeCity()
        refreshControl.endRefreshing()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return self.cityAds.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "MainTableCell", for: indexPath) as! MainTableViewCell
        
        if indexPath.row % 2 != 0 {
            cell.backgroundColor = UIColor(colorLiteralRed: 241/255, green: 241/255, blue: 247/255, alpha: 1.0)
        } else {
            cell.backgroundColor = UIColor.white
        }
        
        
        var currentHeader     = ""
        var currentDate       = ""
        var categoryDirectory = ""
        var currentId         = ""
        var subcategory       = ""
        var currentInfo       = ""
        
        currentHeader = self.cityAds[indexPath.row].value(forKey: "header") as! String
        if self.cityAds[indexPath.row].value(forKey: "subcategory") != nil {
            subcategory = self.cityAds[indexPath.row].value(forKey: "subcategory") as! String
        }
        if self.cityAds[indexPath.row].value(forKey: "info") != nil {
            currentInfo = self.cityAds[indexPath.row].value(forKey: "info") as! String
        }
        currentDate = self.cityAds[indexPath.row].value(forKey: "date") as! String
        let category = self.cityAds[indexPath.row].value(forKey: "category") as! String
        categoryDirectory = HELPER.switchCatLang(categoryRName: category)
        currentId = self.cityAds[indexPath.row].value(forKey: "id") as! String
        
        
        cell.adHeader.text = currentHeader
        if category == "Работа" {
            cell.adInfo.text = "З/П: \(currentInfo)"
        } else if currentInfo == "" {
            cell.adInfo.text = currentInfo
        } else {
            cell.adInfo.text = "Цена: \(currentInfo)"
        }
        
        if subcategory == "" {
            cell.adCatSub.text = category
        } else {
            cell.adCatSub.text = "\(category)/\(subcategory)"
        }
        
        cell.adDate.text = currentDate
        
        cell.adIMage.sd_setShowActivityIndicatorView(true)
        cell.adIMage.sd_setImage(with: URL(string: "http://invietnam.website/vietnam/adpics/\(categoryDirectory)/\(currentId)_0.png"), placeholderImage: #imageLiteral(resourceName: "nopicplaceholder"), options: [.retryFailed, .refreshCached])
        
        cell.isUserInteractionEnabled = true
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
   
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let addetailsVC = storyboard.instantiateViewController(withIdentifier: "addetailsVC") as! AdDetailsViewController
        
        addetailsVC.currentAd = self.cityAds[indexPath.row]
        print(cityAds[indexPath.row].value(forKey: "header")!)
        
        self.navigationController?.pushViewController(addetailsVC, animated: true)

    }

    @IBAction func showCities(_ sender: Any) {
        dropDownCity.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            if index == 0 {
                self.cityButton.setTitle("Все города", for: .normal)
                self.currentCity = "Все города"
            } else {
                self.cityButton.setTitle(item, for: .normal)
                self.currentCity = item
            }
            
            self.changeCity()
            self.tableView.reloadData()
        }
        
        dropDownCity.show()
    }
    
    
    func changeCity() {
        self.cityAds.removeAll()
        
        if self.currentCity == "Все города" {
            self.cityAds = self.ads
        } else {
            for ad in self.ads {
                let currentCity = ad.value(forKey: "city") as! String
                if currentCity == self.currentCity {
                    self.cityAds.append(ad)
                }
            }
        }
        self.tableView.reloadData()
    }

    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
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
