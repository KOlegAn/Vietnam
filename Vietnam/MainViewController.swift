//
//  MainViewController.swift
//  Vietnam
//
//  Created by Oleg Kuplin on 11.11.16.
//  Copyright © 2016 Oleg Kuplin. All rights reserved.
//

import UIKit
import Alamofire

class MainViewController: UIViewController, UISearchBarDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var categoryContainer: UIView!
    @IBOutlet weak var tableContainer: UIView!
    @IBOutlet weak var titleSegmentedController: UISegmentedControl!
    
    private let reuseIdentifier = "homeCell"
    let categoryNames = ["Работа", "Жилье", "Услуги", "Мото", "Нужна помощь", "Обмен", "Привезти", "Бюро находок", "Обучение", "Электроника", "Животные", "Другие"]
    let imageNames = ["workicon.png", "houseicon.png", "service.png", "motoicon.png", "help.png", "exchange.png", "bread.png", "find.png", "study.png", "tech.png", "animals.png", "cancel.png"]
    var headers = [String]()
    var bodys = [String]()
    var refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true

        self.navigationController?.navigationBar.isHidden = false
        self.searchBar.delegate = self
        
        self.navigationItem.hidesBackButton = true

        HELPER.loadAds()
        
        

        self.checkSegmentedController()
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.

    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("Editing")
        
        //self.showProhressHUD(text: "You are right")
        self.searchBar.resignFirstResponder()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let searchVC = storyboard.instantiateViewController(withIdentifier: "searchVC") as! SearchTViewController
        searchVC.allAds = HELPER.getAds()
        
        self.navigationController?.pushViewController(searchVC, animated: false)
    }

    @IBAction func indexChanged(_ sender: Any) {
        self.checkSegmentedController()
    }
    
    
    func checkSegmentedController() {
        
        switch self.titleSegmentedController.selectedSegmentIndex {
            
        case 0:
            self.categoryContainer.isHidden = true
            self.tableContainer.isHidden = false
            break
        case 1:
            self.categoryContainer.isHidden = false
            self.tableContainer.isHidden = true
            break
        default:
            break
        }
    }
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        OperationQueue.main.addOperation {
            self.searchBar.endEditing(true)
            self.searchBar.text = ""
        }
    }
    
    
    
    
    func separate(responseArray : Array<NSObject>) {
        
        for i in 0..<responseArray.count {
            let currentAd = responseArray[i]
            self.headers.append(currentAd.value(forKey: "header") as! String)
            self.bodys.append(currentAd.value(forKey: "body") as! String)
        }
        
        
    }
    
    @IBAction func changeVC(_ sender: Any) {
        self.tabBarController?.selectedIndex = 1
    }
    @IBAction func prevVC(_ sender: Any) {
        self.tabBarController?.selectedIndex = 4
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
