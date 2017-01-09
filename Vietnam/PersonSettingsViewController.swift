//
//  PersonSettingsViewController.swift
//  Vietnam
//
//  Created by Oleg Kuplin on 28.11.16.
//  Copyright © 2016 Oleg Kuplin. All rights reserved.
//

import UIKit

class PersonSettingsViewController: UITableViewController {
    
    
    var userInfo = NSObject()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let name = self.userInfo.value(forKey: "name") as! String
        print(name)
        
        
        self.navigationItem.title = "Мой Профиль"

    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        self.userInfo = HELPER.getUser()
        print("\(self.userInfo.value(forKey: "name") as! String)")
        self.tableView.reloadData()
        print("ViewWillappear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(true)
//        super.viewWillAppear(false)
//        self.userInfo = HELPER.getUser()
//        print("\(self.userInfo.value(forKey: "name") as! String)")
//        self.tableView.reloadData()
//        print("ViewWillappear")

    }
    
    
    override var hidesBottomBarWhenPushed: Bool {
        get { return true }
        set { super.hidesBottomBarWhenPushed = newValue }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1:
            return 3
        case 2:
            return 2
        default:
            return 1
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "personSetCell", for: indexPath) as! PersonSetCell

        
        
            
            if indexPath.section == 0 {
                
                cell.cellItem.text = "Фото профиля"
                cell.cellValue.text = ""
                cell.cellImage.image = HELPER.getUserAvatar()
                cell.cellImage.layer.cornerRadius = 5
                cell.cellImage.clipsToBounds = true
                
            } else if indexPath.section == 1 {
                switch indexPath.row {
                case 0:
                    cell.cellItem.text = "Имя"
                    cell.cellValue.text = self.userInfo.value(forKey: "name") as? String
                    break
                case 1:
                    cell.cellItem.text = "Ник"
                    cell.cellValue.text = self.userInfo.value(forKey: "nickname") as? String
                    break
                case 2:
                    cell.cellItem.text = "Пол"
                    cell.cellValue.text = self.userInfo.value(forKey: "sex") as? String
                    break
                default:
                    break
                }
            } else if indexPath.section == 2 {
                cell.selectionStyle = .none
                switch indexPath.row {
                case 0:
                    cell.cellItem.text = "Email"
                    cell.cellValue.text = self.userInfo.value(forKey: "email") as? String
                    break
                case 1:
                    cell.cellItem.text = "Тел. Номер"
                    cell.cellValue.text = self.userInfo.value(forKey: "telnum") as? String
                    break
                default:
                    break
                }
                
            }
        
        
        
        
        return cell
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = self.tableView.cellForRow(at: indexPath) as! PersonSetCell
        
        
        
        if indexPath.section == 0 {

            let changeAvatarVC = ChangeAvatarViewController(nibName: "ChangeAvatarViewController", bundle: nil)
            changeAvatarVC.userID = self.userInfo.value(forKey: "id") as! String
            self.navigationController?.pushViewController(changeAvatarVC, animated: true)
        } else if indexPath.section == 2{
            if indexPath.row == 1 {
                let changeItemVC = ChangeItemViewController(nibName: "ChangeItemViewController", bundle: nil)
                
                if cell.cellValue.text != nil {
                    changeItemVC.value = cell.cellValue.text!
                    
                } else {
                    changeItemVC.value = ""
                }
                
                changeItemVC.name = cell.cellItem.text!
                changeItemVC.userInfo = self.userInfo
                self.navigationController?.pushViewController(changeItemVC, animated: true)
            }
        }else {
            let changeItemVC = ChangeItemViewController(nibName: "ChangeItemViewController", bundle: nil)
            
            if cell.cellValue.text != nil {
                changeItemVC.value = cell.cellValue.text!

            } else {
                changeItemVC.value = ""
            }
            
            changeItemVC.name = cell.cellItem.text!
            changeItemVC.userInfo = self.userInfo
            self.navigationController?.pushViewController(changeItemVC, animated: true)
        }
        
        
    }
    
    
    
    
    
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
            switch indexPath.section {
            case 0:
                return 80
            default:
                return 40
            }
            
        
    }

    
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 17
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
    
}
