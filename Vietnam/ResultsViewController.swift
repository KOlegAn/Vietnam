//
//  ResultsViewController.swift
//  Vietnam
//
//  Created by Oleg Kuplin on 16.11.16.
//  Copyright © 2016 Oleg Kuplin. All rights reserved.
//

import UIKit
import CoreData
import SDWebImage

class ResultsViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UIGestureRecognizerDelegate {

    
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var currentCategory     = ""
    var currentSubcategorys = [String]()
    var choosedSubCategory  = 0
    var choosedCity         = ""
    
    var categoryAds    = Array<NSObject>()
    var currentAds     = Array<NSObject>()
    var filteredAds    = Array<NSObject>()
    
    var searchKey    = ""
    var dropDownCity = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(self.currentAds.count)
        print(self.searchKey)
        self.searchBar.delegate = self
        self.tableView.delegate = self
        self.tableView.allowsSelection = true
        
        currentSubcategorys = HELPER.getSubcategory(categoryName: currentCategory)
        
        var rightBarButton = UIBarButtonItem()
                
        rightBarButton = UIBarButtonItem(title: "Все города", style: .plain, target: self, action: #selector(self.barButtonTapped))
        
        dropDownCity.anchorView = rightBarButton
        dropDownCity.width = 100
        dropDownCity.cellHeight = 42
        dropDownCity.textFont = UIFont.systemFont(ofSize: 16)
        dropDownCity.dataSource = ["Все города", "Вунгтау", "Далат", "Муйне","Нячанг", "Ханой", "Хошимин"]
        
        
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        
        if currentSubcategorys.count == 0 {
            self.collectionView.isHidden = true
            let rect = CGRect(x: 0, y: self.tableView.frame.origin.y - 36, width: self.tableView.frame.width, height: self.tableView.frame.height)
            self.tableView.frame = rect
            self.currentAds = self.categoryAds
            self.currentAds = currentAds.sorted(by: {($0.value(forKey: "date") as! String) > ($1.value(forKey: "date") as! String)})
        } else {
            self.initSubcategory()
        }

        
    }

    func dismissKeyboard() {
        view.endEditing(true)
        print("Swiped")
        
        
    }
    
    
    func barButtonTapped() {
        
        dropDownCity.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            if item == "Все города" {
                self.choosedCity = ""
            } else {
                self.choosedCity = item
            }
            self.navigationItem.rightBarButtonItem?.title = item
            self.initSubcategory()
        }
        
        dropDownCity.show()
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if self.searchKey != "" {
            self.filterContentForSearchText(searchText: self.searchKey)
        } else {
            self.tableView.reloadData()
        }
        
    }
    
    
    override var hidesBottomBarWhenPushed: Bool {
        get { return true }
        set { super.hidesBottomBarWhenPushed = newValue }
    }

    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchKey = self.searchBar.text!
        if self.searchKey != "" {
            self.filterContentForSearchText(searchText: self.searchKey)
        } else {
            self.tableView.reloadData()

        }
    }
    
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        
        self.filteredAds = self.currentAds.filter({ ad in
            return (ad.value(forKey: "header") as! String).lowercased().contains(searchText.lowercased())
        })
        self.tableView.reloadData()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if self.searchKey != "" {
            return self.filteredAds.count
        } else {
            return self.currentAds.count
        }
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "resultsCell", for: indexPath) as! ResultsViewCell

        if indexPath.row % 2 != 0 {
            cell.backgroundColor = UIColor(colorLiteralRed: 241/255, green: 241/255, blue: 247/255, alpha: 1.0)
        }
        
        
        var currentHeader     = ""
        var currentDate       = ""
        var categoryDirectory = ""
        var currentId         = ""
        var subcategory       = ""
        var currentInfo       = ""
        
        if self.searchKey != "" {
            currentHeader = self.filteredAds[indexPath.row].value(forKey: "header") as! String
            if self.filteredAds[indexPath.row].value(forKey: "subcategory") != nil {
                subcategory = self.filteredAds[indexPath.row].value(forKey: "subcategory") as! String
            }
            if self.filteredAds[indexPath.row].value(forKey: "info") != nil {
                currentInfo = self.filteredAds[indexPath.row].value(forKey: "info") as! String
            }
            currentDate = self.filteredAds[indexPath.row].value(forKey: "date") as! String
            let category = self.filteredAds[indexPath.row].value(forKey: "category") as! String
            categoryDirectory = HELPER.switchCatLang(categoryRName: category)
            currentId = self.filteredAds[indexPath.row].value(forKey: "id") as! String
        } else {
            currentHeader = self.currentAds[indexPath.row].value(forKey: "header") as! String
            if self.currentAds[indexPath.row].value(forKey: "subcategory") != nil {
                subcategory = self.currentAds[indexPath.row].value(forKey: "subcategory") as! String
            }
            if self.currentAds[indexPath.row].value(forKey: "info") != nil {
                currentInfo = self.currentAds[indexPath.row].value(forKey: "info") as! String
            }
            currentDate = self.currentAds[indexPath.row].value(forKey: "date") as! String
            let category = self.currentAds[indexPath.row].value(forKey: "category") as! String
            categoryDirectory = HELPER.switchCatLang(categoryRName: category)
            currentId = self.currentAds[indexPath.row].value(forKey: "id") as! String
        }
        cell.adHeader.text = currentHeader
        if self.currentCategory == "Работа" {
            cell.adInfo.text = "З/П: \(currentInfo)"
        } else if currentInfo == "" {
            cell.adInfo.text = currentInfo
        } else {
            cell.adInfo.text = "Цена: \(currentInfo)"
        }
        
        
        cell.adCatSub.text = subcategory
        cell.adDate.text = currentDate
        
        cell.adIMage.sd_setShowActivityIndicatorView(true)
        cell.adIMage.sd_setImage(with: URL(string: "http://invietnam.website/vietnam/adpics/\(categoryDirectory)/\(currentId)_0.png"), placeholderImage: #imageLiteral(resourceName: "nopicplaceholder"), options: [.retryFailed, .refreshCached])
        
        cell.isUserInteractionEnabled = true
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let addetailsVC = storyboard.instantiateViewController(withIdentifier: "addetailsVC") as! AdDetailsViewController
        if self.searchKey != "" {
            addetailsVC.currentAd = self.filteredAds[indexPath.row]
        } else {
            addetailsVC.currentAd = self.currentAds[indexPath.row]
            print(currentAds[indexPath.row].value(forKey: "header")!)
        }
        self.navigationController?.pushViewController(addetailsVC, animated: true)
        
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.currentSubcategorys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "subcategoryCell", for: indexPath) as! ResultsSubViewCell
        
        cell.subcategoryTF.isEnabled = false
        if indexPath.row == choosedSubCategory {
            cell.subcategoryTF.backgroundColor = HELPER.uicolorFromHex(rgbValue: 0x037517)

            //cell.subcategoryTF.backgroundColor = UIColor(colorLiteralRed: 97/255, green: 178/255, blue: 86/255, alpha: 0.75)
        } else {
            cell.subcategoryTF.backgroundColor = UIColor(colorLiteralRed: 97/255, green: 178/255, blue: 86/255, alpha: 0.75)

            //cell.subcategoryTF.backgroundColor = UIColor(colorLiteralRed: 146/255, green: 226/255, blue: 250/255, alpha: 0.75)
        }
        cell.subcategoryTF.textColor = UIColor.white
        cell.subcategoryTF.text = self.currentSubcategorys[indexPath.row]
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.chooseSubcategor(sender:)))
        cell.addGestureRecognizer(tap)
        
        return cell
    }
    
    
    func chooseSubcategor(sender : UITapGestureRecognizer) {
        
        let tapLocation = sender.location(in: self.collectionView)
        let indexPath: NSIndexPath = self.collectionView.indexPathForItem(at: tapLocation)! as NSIndexPath

        self.choosedSubCategory = indexPath.row
        self.collectionView.reloadData()
        
        self.currentAds.removeAll()
        let choosedSubcategory = self.currentSubcategorys[indexPath.row]
        for ad in categoryAds {
            
            if self.choosedCity == "" {
                let currentSubcategory = ad.value(forKey: "subcategory") as! String
                if choosedSubcategory == currentSubcategory {
                    self.currentAds.append(ad)
                }
            } else {
                let currentCity = ad.value(forKey: "city") as! String
                
                if currentCity == self.choosedCity {
                    let currentSubcategory = ad.value(forKey: "subcategory") as! String
                    if choosedSubcategory == currentSubcategory {
                        self.currentAds.append(ad)
                    }
                }
            }
            
        }
        self.currentAds = currentAds.sorted(by: {($0.value(forKey: "date") as! String) > ($1.value(forKey: "date") as! String)})
        self.tableView.reloadData()
        
        print("Cell \(indexPath.row) tapped")
    }
    
    
    func initSubcategory() {
        
        self.currentAds.removeAll()

        if self.currentSubcategorys.count == 0 {
            
            if self.choosedCity == "" {
                self.currentAds = self.categoryAds
            } else {
                for ad in categoryAds {
                    let currentCity = ad.value(forKey: "city") as! String
                    if currentCity == self.choosedCity {
                        self.currentAds.append(ad)
                    }
                }
            }
            
            

        } else {
            let choosedSubcategory = self.currentSubcategorys[choosedSubCategory]
            
            for ad in categoryAds {
                if self.choosedCity == "" {
                    let currentSubcategory = ad.value(forKey: "subcategory") as! String
                    if choosedSubcategory == currentSubcategory {
                        self.currentAds.append(ad)
                    }
                } else {
                    let currentCity = ad.value(forKey: "city") as! String
                    
                    if currentCity == self.choosedCity {
                        let currentSubcategory = ad.value(forKey: "subcategory") as! String
                        if choosedSubcategory == currentSubcategory {
                            self.currentAds.append(ad)
                        }
                    }
                }
                
            }
        }
        
        
        self.currentAds = currentAds.sorted(by: {($0.value(forKey: "date") as! String) > ($1.value(forKey: "date") as! String)})
        self.tableView.reloadData()
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    


    @IBAction func goBack(_ sender: Any) {
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

}
