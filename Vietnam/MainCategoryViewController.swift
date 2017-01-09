//
//  MainCategoryViewController.swift
//  Vietnam
//
//  Created by Oleg Kuplin on 07.01.17.
//  Copyright © 2017 Oleg Kuplin. All rights reserved.
//

import UIKit

class MainCategoryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    private let reuseIdentifier = "homeCell"
    let categoryNames = ["Работа", "Жилье", "Услуги", "Мото", "Нужна помощь", "Обмен", "Привезти", "Бюро находок", "Обучение", "Электроника", "Животные", "Другие"]
    let imageNames = ["workicon.png", "houseicon.png", "service.png", "motoicon.png", "help.png", "exchange.png", "bread.png", "find.png", "study.png", "tech.png", "animals.png", "cancel.png"]
    var ads = Array<NSObject>()
    var refreshControl = UIRefreshControl()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView!.collectionViewLayout  = self.setCollectionViewLayout()
        self.collectionView.delegate = self

        
        
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControlEvents.valueChanged)
        collectionView.addSubview(refreshControl)

        // Do any additional setup after loading the view.
    }
    
    func refresh(sender: AnyObject) {
        HELPER.loadAds()
        refreshControl.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        
        return self.categoryNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MainCollectionViewCell
        
        cell.backgroundColor = UIColor.white
        
        if indexPath.row == 0 {
            cell.categoryLabel.text = "Работа/Подработка"
        } else if indexPath.row == 3 {
            cell.categoryLabel.text = "Мототовары/услуги"
        } else if indexPath.row == 6 {
            cell.categoryLabel.text = "Привезти/Передать"
        } else if indexPath.row == 9 {
            cell.categoryLabel.text = "Электроника/Бытовая"
        } else {
            cell.categoryLabel.text = self.categoryNames[indexPath.row]
        }
        
        cell.categoryImage.image = UIImage(named: self.imageNames[indexPath.row])

        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let resultsVC = self.storyboard?.instantiateViewController(withIdentifier: "resultsVC") as! ResultsViewController
        
        let choosedCategory = self.categoryNames[indexPath.row]
        var categoryAds = Array<NSObject>()
        self.ads = HELPER.getAds()
        for i in 0..<self.ads.count {
            let currentAd = self.ads[i]
            if (currentAd.value(forKey: "category") as! String == choosedCategory) {
                categoryAds.append(currentAd)
            }
            
        }
        
        resultsVC.currentCategory = choosedCategory
        resultsVC.categoryAds = categoryAds
        self.navigationController?.pushViewController(resultsVC, animated: true)
    }
    
    
    
    func setCollectionViewLayout() -> UICollectionViewFlowLayout {
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let height = self.collectionView.frame.width + (self.collectionView.frame.width / 6)
        layout.itemSize = CGSize(width: (self.collectionView.frame.width - 2) / 3, height: height / 3)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 1
        
        return layout
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
