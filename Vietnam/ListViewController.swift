//
//  ListViewController.swift
//  Vietnam
//
//  Created by Oleg Kuplin on 07.12.16.
//  Copyright © 2016 Oleg Kuplin. All rights reserved.
//

import UIKit
import XMPPFramework
//import CoreData


class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, XMPPStreamDelegate, XMPPRosterDelegate {

    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    var xmppStream = XMPPStream()
    let xmppRosterStorage = XMPPRosterCoreDataStorage()
    var xmppRoster: XMPPRoster?
    var user = NSObject()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.xmppStream = XMPPStream()
        self.xmppStream?.addDelegate(self, delegateQueue: DispatchQueue.main)
        self.xmppStream?.hostName = "188.166.219.161"
        self.xmppStream?.hostPort = 5222
        
        
        //self.navigationController?.navigationItem.titleView = self.createSegmentedController()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.isLogged()
    }
    
    
    func isLogged(){
        
        let managedContext = HELPER.managedObjectContext()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Isregistered")
        
        do {
            let fetchedResult = try managedContext.fetch(fetchRequest)
            let model = fetchedResult as! [NSManagedObject]
            print("I have \(model.count) users now oO")
            if model.count == 0 {
 
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
                
                let unloggedVC = storyboard.instantiateViewController(withIdentifier: "unloggedVC") as! UnloggedViewController
                self.navigationController?.pushViewController(unloggedVC, animated: false)
                print("I'ts empty array")
            } else {
                self.user = model[0]
                let id = self.user.value(forKey: "id") as! String
                print("User id: \(id)")
                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
                self.tableView.reloadData()
                self.navigationController?.navigationBar.isHidden = false
                self.connect()
                print("Not empty")
            }
            
        } catch {
            print("Error while fetching occured")
        }
        
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! ChatViewCell
        
   
        
        return cell
    }
    

    
    func connect() -> Bool {
        if !(xmppStream?.isConnected())! {
            
            let userID = self.user.value(forKey: "id") as! String
            
            let jabberID = "\(userID)@localhost"
            
            
            if !(xmppStream?.isDisconnected())! {
                return true
            }
            //            if jabberID == nil && myPassword == nil {
            //                return false
            //            }
            
            xmppStream?.myJID = XMPPJID(string: jabberID)
            
            do {
                try xmppStream?.connect(withTimeout: XMPPStreamTimeoutNone)
                print("Connection success")
                return true
            } catch {
                print("Something went wrong!")
                return false
            }
        } else {
            return true
        }
    }
    
    func xmppStreamDidConnect(_ sender: XMPPStream!) {
        print("Yahhooo")
        let userID = self.user.value(forKey: "id") as! String
        do {
            try sender.authenticate(withPassword: userID)
        } catch {
            print("error authenticating")
        }
    }
    
    func xmppStream(_ sender: XMPPStream!, didNotAuthenticate error: DDXMLElement!) {
        print(error)
        print("Error whyle authenticate")
    }
    
    func xmppStreamDidAuthenticate(_ sender: XMPPStream!) {
        print("Authanticated")
        
    }
    
    
    func disconnect() {
        //goOffline()
        xmppStream?.disconnect()
    }
    
    @IBAction func sendMessage(_ sender: Any) {
//        let body = DDXMLElement.element(withName: "body") as! DDXMLElement
//        let messageID = Xsender.generateUUID()
//        
//        body.stringValue = self.messageTextField.text
//        
//        
//        let completeMessage = DDXMLElement.element(withName: "message") as! DDXMLElement
//        
//        completeMessage.addAttribute(withName: "id", stringValue: messageID!)
//        completeMessage.addAttribute(withName: "type", stringValue: "chat")
//        completeMessage.addAttribute(withName: "to", stringValue: "admin@localhost")
//        completeMessage.addChild(body)
//        
//        let active = DDXMLElement.element(withName: "active", stringValue:
//            "http://jabber.org/protocol/chatstates") as! DDXMLElement
//        completeMessage.addChild(active)
//        
//        Xsender.send(completeMessage)
        
        let body = DDXMLElement.element(withName: "body") as! DDXMLElement
        
        body.stringValue = self.messageTextField.text
        
        
        let completeMessage = DDXMLElement.element(withName: "message") as! DDXMLElement
        
        completeMessage.addAttribute(withName: "type", stringValue: "chat")
        completeMessage.addAttribute(withName: "to", stringValue: "admin@localhost")
        completeMessage.addChild(body)
        
        let active = DDXMLElement.element(withName: "active", stringValue:
            "http://jabber.org/protocol/chatstates") as! DDXMLElement
        completeMessage.addChild(active)

        xmppStream?.send(completeMessage)
        
        print("Sent")
        self.resignFirstResponder()
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
