//
//  ViewController.swift
//  iOS_final_project
//
//  Created by yochien on 2019/1/3.
//  Copyright © 2019年 yochien. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit


class LoginViewController: UIViewController {

    var userData: UserData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("send")
        
    }

    @IBAction func btnLoginWithFacebookClicked(_ sender: Any) {
        let fbLoginManager:FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) {(result, error) in
            if (error == nil){
                let fbLoginResult:FBSDKLoginManagerLoginResult = result!
                if fbLoginResult.grantedPermissions != nil {
                    if(fbLoginResult.grantedPermissions.contains("email")) {
                        self.getFBUserData()
                        self.turnToIndexSreen()
                        //fbLoginManager.logOut()
                    }
                    
                }
            }
        }
    }
    
    func turnToIndexSreen() {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "IndexScreen") {
            
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func loginButtonDidLogout(_ loginButton: FBSDKLoginButton!) {
        print("User Logout")
    }
    func getFBUserData() {
        
        if(FBSDKAccessToken.current() != nil) {
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: {(connection, result, error) -> Void in
                if (error == nil) {
                    print("success")
                    let facebookDic = result as! [String:AnyObject]
                    print(facebookDic)
                    
                    let name = facebookDic["name"] as! String
                    print(name)
                    
                    let email = facebookDic["email"] as! String
                    print(email)
                    
                    let facebookID = facebookDic["id"] as! String
                    print(facebookID)
                    
                    let picture = facebookDic["picture"] as! [String:AnyObject]
                    let pictureData = picture["data"] as! [String:AnyObject]
                    let pictureUrl = pictureData["url"] as! String
                    print(pictureUrl)
                    
                    UserData.save(userData: UserData(name: name, email: email, facebookID: facebookID, pictureUrl: pictureUrl))
                    
                    
                }
                else {
                    print("error")
                    print(error)
                }
            })
        }
    }
}

