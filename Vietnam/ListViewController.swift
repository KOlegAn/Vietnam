//
//  ListViewController.swift
//  Vietnam
//
//  Created by Oleg Kuplin on 07.12.16.
//  Copyright © 2016 Oleg Kuplin. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, StreamDelegate {

    let input = InputStream()
    let outputStream = OutputStream()

    //let segment = UISegmentedControl()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
       // let myNavigationBar = UINavigationBar()
        
        
        
        //self.navigationController?.navigationItem.titleView = self.createSegmentedController()
        // Do any additional setup after loading the view.
    }
    
    
    
    func initNetworkCommunication() {
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func prevVC(_ sender: Any) {
        self.tabBarController?.selectedIndex = 2
    }

    @IBAction func nextVC(_ sender: Any) {
        self.tabBarController?.selectedIndex = 4
    }
    
    func createSegmentedController() -> UISegmentedControl {
        
        let segment: UISegmentedControl = UISegmentedControl(items: ["First", "Second"])
        
        segment.sizeToFit()
        segment.tintColor = UIColor(red:0.99, green:0.00, blue:0.25, alpha:1.00)
        segment.selectedSegmentIndex = 0;
        segment.frame = CGRect(x: 10, y: 3, width: Int((self.navigationController?.navigationBar.frame.size.width)! - 20), height: (Int((self.navigationController?.navigationBar.frame.size.height)! - 5)))
        segment.setTitleTextAttributes([NSFontAttributeName: UIFont(name:"ProximaNova-Light", size: 11)!],
                                       for: UIControlState.normal)
        
        return segment
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
