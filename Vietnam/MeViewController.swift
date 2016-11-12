//
//  MeViewController.swift
//  Vietnam
//
//  Created by Oleg Kuplin on 12.11.16.
//  Copyright © 2016 Oleg Kuplin. All rights reserved.
//

import UIKit
import CoreData

class MeViewController: UIViewController, VKSdkUIDelegate, VKSdkDelegate{

    
    var personVC = PersonViewController()
    var unloggedVC = UnloggedViewController()
    let SCOPE = [VK_PER_NOTIFY, VK_PER_FRIENDS, VK_PER_OFFLINE, VK_PER_EMAIL]
    var isLog = false
    var activityIndicator = UIActivityIndicatorView()

    func managedObjectContext() -> NSManagedObjectContext{
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        if #available(iOS 10.0, *) {
            context = appDelegate.persistentContainer.viewContext
        } else {
            
        }
        
        return context
    }
    
    
    
    override func viewDidLoad() {

        
        super.viewDidLoad()
        print("in me now")
        
        self.activityIndicator = self.createActivityIndicator()
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        self.initVC()
        VKSdk.initialize(withAppId: "5721752").register(self)
        VKSdk.instance().register(self)
        VKSdk.instance().uiDelegate = self
        
        isLogged()
        //isLoggedVK()
    
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    
    func initVC(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.personVC = storyboard.instantiateViewController(withIdentifier: "personVC") as! PersonViewController
        self.unloggedVC = storyboard.instantiateViewController(withIdentifier: "unloggedVC") as! UnloggedViewController
    }
    
    
    override func addChildViewController(_ childController: UIViewController) {
        view.addSubview(childController.view)
        childController.view.frame = self.view.bounds
        childController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        childController.didMove(toParentViewController: self)
    }
    

    func isLogged(){
        
        let managedContext = self.managedObjectContext()
       
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Isregistered")
        
        do {
            let fetchedResult = try managedContext.fetch(fetchRequest)
            let model = fetchedResult as! [NSManagedObject]
            if model.count == 0 {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.addChildViewController(self.unloggedVC)
                print("I'ts empty array")
            } else {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.addChildViewController(self.personVC)

                print("Not empty")
            }
            
        } catch {
            print("Error while fetching occured")
        }
        
    }
    
    func isLoggedVK() {
        VKSdk.wakeUpSession(SCOPE, complete: {
            state, error in
            
            if state == VKAuthorizationState.authorized {
                self.isLog = true
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.addChildViewController(self.personVC)
                print("Me ready to go, adn it's true")
                print(self.isLog)
                
            } else {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.addChildViewController(self.unloggedVC)

                print("In me else now")
                
                
            }
        })
    }
    
    
    
       //MARK: - VK functions
    
    
    func vkSdkShouldPresent(_ controller: UIViewController!) {
        print("We are in should present")
        
        self.present(controller, animated: true, completion: nil)
        //self.navigationController?.topViewController?.present(controller, animated: true, completion: nil)
    }
    
    func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
        print("In need captcha enter")
        
        let captchaController = VKCaptchaViewController.captchaControllerWithError(captchaError)
        captchaController?.present(in: self.navigationController?.topViewController)
    }
    
    
    
    func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
        print("We are in vksdk access auth finished func")
        if ((result.token) != nil) {
            print("Token: \(result.token)")
            // Пользователь успешно авторизован
        } else if ((result.error) != nil) {
            print("Error: \(result.error)")
            // Пользователь отменил авторизацию или произошла ошибка
        }
        
    }
    
    
    func vkSdkUserAuthorizationFailed() {
        print("Authorization failed")
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func vkSdkTokenHasExpired(_ expiredToken: VKAccessToken!) {
        
        print("Token has expired")
    }

    func vkSdkAuthorizationStateUpdated(with result: VKAuthorizationResult!) {
        print("In auth state update")
        print(result)
    }
    
    func vkSdkAccessTokenUpdated(_ newToken: VKAccessToken!, oldToken: VKAccessToken!) {
        print("In acces token updated")
    }
    
    
    func createActivityIndicator() -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2, y: self.view.frame.height / 2, width: 40, height: 40))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        indicator.center = self.view.center
        indicator.backgroundColor = UIColor.clear
        self.view.addSubview(indicator)
        return indicator
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
