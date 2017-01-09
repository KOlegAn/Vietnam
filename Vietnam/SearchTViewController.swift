//
//  SearchTViewController.swift
//  Vietnam
//
//  Created by Oleg Kuplin on 15.11.16.
//  Copyright © 2016 Oleg Kuplin. All rights reserved.
//

import UIKit
import CoreData

class SearchTViewController: UITableViewController, UISearchBarDelegate{

    var tries = [String]()
    var filteresTries = [String]()
    let searchController = UISearchController(searchResultsController: nil)
    var allAds = Array<NSObject>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true

        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        self.setSearchController()
        self.searchController.searchBar.delegate = self
 
        self.loadTries()

        self.tableView.tableHeaderView = self.searchController.searchBar

        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        print("In viewdidapper")
        self.searchController.isActive = true

    }
    
    
    override var hidesBottomBarWhenPushed: Bool {
        get { return true }
        set { super.hidesBottomBarWhenPushed = newValue }
    }
    

    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        
        self.filteresTries = self.tries.filter({ trie in
            return trie.lowercased().contains(searchText.lowercased())
        })
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchController.searchBar.resignFirstResponder()
        self.searchController.searchBar.showsCancelButton = false
        self.searchController.searchBar.text = ""
        self.searchController.searchBar.endEditing(true)
        
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        self.navigationController?.extendedLayoutIncludesOpaqueBars = true
        self.navigationController?.navigationBar.isTranslucent = true
        self.searchController.searchBar.showsCancelButton = true
        print("Editing")
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        self.saveTry(text: self.searchController.searchBar.text!)
        
        self.moveToSearchVC(searchKey: self.searchController.searchBar.text!)
        
    }
    
    
    func loadTries() {
        let managedContext = self.managedObjectContext()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Searches")
        
        do {
            let fetchedResult = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            
            for i in 0..<fetchedResult.count {
                let currentTry = fetchedResult[i].value(forKey: "tries") as? String
                self.tries.append(currentTry!)
            }
            self.tableView.reloadData()
            
        } catch {
            print("Error while fetching occured")
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if self.searchController.isActive && self.searchController.searchBar.text != "" {
            return self.filteresTries.count
        }
        
        print("\n\(self.tries.count)\n")
        return self.tries.count
    }
    
    

    

    func setSearchController() {
        
        let searchBarboundsY = (self.navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height
        
        self.searchController.searchBar.frame = CGRect(x: 0, y: searchBarboundsY, width: UIScreen.main.bounds.size.width - 30, height: 44)
        self.searchController.searchBar.searchBarStyle = UISearchBarStyle.minimal
        self.searchController.searchBar.tintColor = UIColor.darkGray
        self.searchController.searchBar.barTintColor = UIColor.white
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.placeholder = "Поиск"
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)

        if self.searchController.isActive && self.searchController.searchBar.text != "" {
            cell.textLabel?.text = self.filteresTries[indexPath.row]
        } else {
            cell.textLabel?.text = self.tries[indexPath.row]
        }
        return cell
    }
 

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if searchController.isActive && self.searchController.searchBar.text != "" {
            self.moveToSearchVC(searchKey: self.filteresTries[indexPath.row])
        } else {
            self.moveToSearchVC(searchKey: self.tries[indexPath.row])
        }
        
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

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
    
    
    func saveTry(text: String) {
        let managedContext = self.managedObjectContext()
        let newTry = NSEntityDescription.insertNewObject(forEntityName: "Searches", into: managedContext)
        newTry.setValue(text, forKey: "tries")
    }
    
    func moveToSearchVC(searchKey: String) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let resultsVC = storyboard.instantiateViewController(withIdentifier: "resultsVC") as! ResultsViewController
        resultsVC.categoryAds = HELPER.getAds()
        resultsVC.searchKey = searchKey
        self.navigationController?.pushViewController(resultsVC, animated: true)
    }

}



extension SearchTViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: self.searchController.searchBar.text!)
    }
}


