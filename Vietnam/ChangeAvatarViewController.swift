//
//  ChangeAvatarViewController.swift
//  Vietnam
//
//  Created by Oleg Kuplin on 28.11.16.
//  Copyright © 2016 Oleg Kuplin. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class ChangeAvatarViewController: UIViewController, TZImagePickerControllerDelegate {

    @IBOutlet weak var avatarImage: UIImageView!
    var userID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.avatarImage.image = HELPER.getUserAvatar()
        self.avatarImage.layer.cornerRadius = 20
        self.avatarImage.clipsToBounds = true
        
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        
        
        let picWidth = photos[0].size.width
        let picHeight = photos[0].size.height
        
        
        let yRect = (picHeight / 2) - (picWidth / 2)
        let xRect = (picWidth / 2) - (picHeight / 2)
        
        let imageRect: CGRect
        
        if picWidth <= picHeight {
            imageRect = CGRect(x: CGFloat(0), y: CGFloat(yRect), width: picWidth, height: picWidth)
        } else {
            imageRect = CGRect(x: xRect, y: CGFloat(0), width: picHeight, height: picHeight)
        }
                
        self.avatarImage.image = photos[0].crop(rect: imageRect)
        
    }
    
    
    
    @IBAction func choosePhoto(_ sender: Any) {
        let lr = TZImagePickerController(maxImagesCount: 1, delegate: self)
        self.present(lr!, animated: true, completion: nil)
    }
    
    
    
    @IBAction func saveNewPhoto(_ sender: Any) {
        
        
        do {
            try self.uploadImage()
        } catch {
            print("Error")
        }
        
        let view = self.avatarImage.image
        let avatar = NSData(data: UIImagePNGRepresentation(view!)!)
        HELPER.changeUserAvatar().setValue(avatar, forKey: "avatar")
        
        HELPER.showToast(view: self.view, text: "Изменения успешно внесены")
        let delayTime = DispatchTime.now() + 1.5
        DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
            _ = self.navigationController?.popViewController(animated: true)
        })
    }
    
    
    func uploadImage() throws -> Void {
        
        var parameters = [
            "task": "task",
            "variable1": "var"
        ]
        
        // add addtionial parameters
        parameters["userId"] = "27"
        parameters["body"] = "This is the body text."
        parameters["id"] = self.userID
        
        // example image data
        
        
        
        
        let imageData = UIImageJPEGRepresentation(self.avatarImage.image!, 0.25)
        
        
        
        // CREATE AND SEND REQUEST ----------
        
        let url = "http://invietnam.website/vietnam/userEdit.php?request=newava&id=\(self.userID)"
        
        
        let urlRequest = try urlRequestWithComponents(urlString: url, parameters: parameters, imageData: imageData!)
        print(urlRequest)
        Alamofire.upload(urlRequest.1, with: urlRequest.0).uploadProgress { progress in
            print("Upload progress: \(progress)")
            }
            .responseJSON { response in
                
                print(response)
        }
        
        
        
    }
    
    
    func urlRequestWithComponents(urlString:String, parameters:Dictionary<String, String>, imageData:Data) throws -> (URLRequestConvertible, Data) {
        
        // create url request to send
        
        var mutableURLRequest = URLRequest(url: NSURL(string: urlString)! as URL)
        mutableURLRequest.httpMethod = Alamofire.HTTPMethod.post.rawValue
        let boundaryConstant = "myRandomBoundary12345";
        let contentType = "multipart/form-data;boundary="+boundaryConstant
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        
        
        // create upload data to send
        let uploadData = NSMutableData()
        
        // add image
        uploadData.append("\r\n--\(boundaryConstant)\r\n".data(using: String.Encoding.utf8)!)
        uploadData.append("Content-Disposition: form-data; name=\"file\"; filename=\"file.png\"\r\n".data(using: String.Encoding.utf8)!)
        uploadData.append("Content-Type: image/png\r\n\r\n".data(using: String.Encoding.utf8)!)
        uploadData.append(imageData as Data)
        
        // add parameters
        for (key, value) in parameters {
            uploadData.append("\r\n--\(boundaryConstant)\r\n".data(using: String.Encoding.utf8)!)
            uploadData.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".data(using: String.Encoding.utf8)!)
        }
        uploadData.append("\r\n--\(boundaryConstant)--\r\n".data(using: String.Encoding.utf8)!)
        
        return (try URLEncoding.default.encode(mutableURLRequest, with: nil), uploadData as Data)
        
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



extension UIImage {
    func crop(rect: CGRect) -> UIImage {
        
        var rect = rect
        rect.origin.x*=self.scale
        rect.origin.y*=self.scale
        rect.size.width*=self.scale
        rect.size.height*=self.scale
        
        let imageRef = self.cgImage!.cropping(to: rect)
        let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return image
    }
}
