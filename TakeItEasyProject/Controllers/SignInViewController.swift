//
//  SignInViewController.swift
//  TakeItEasy
//
//  Created by Zachary Saffron on 6/8/22.
//  Design by Jacob Digby
//

import UIKit
import CoreData

class SignInViewController: UIViewController {

    //design class
    var topColor = UIColor(red: 0.17, green: 1.00, blue: 0.58, alpha: 1.0)
    var bottomColor = UIColor(red: 0.17, green: 0.52, blue: 1.00, alpha: 1.0)
    var accent = UIColor(red: 1.00, green: 0.44, blue: 0.07, alpha: 1.00)
    
    var front: Design?
    
    // All connections used for SignInViewController

    @IBOutlet weak var enterEmailTextField: UITextField!
    @IBOutlet weak var enterPasswordTextField: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var remSwitch: UISwitch!
    
    // Various variables for usage
    
    let userDef = UserDefaults.standard
    let switchStatus = UserDefaults.standard
    
    // This function checks if rememberMe switch is on
    // Saves the data and calls it to the email and password text fields
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //front end design elements
        front = Design()
        view.layer.insertSublayer((front?.gradient(boundary: view))!, at: 0)
        
//        if(switchStatus.bool(forKey: "switch")){
//            remSwitch.setOn(true, animated: true)
//            let req : [String : Any] = [kSecClass as String : kSecClassGenericPassword, kSecAttrAccount as String : userDef.value(forKey: "UN") as! String, kSecReturnAttributes as String : true, kSecReturnData as String : true]
//            var res : CFTypeRef?
//            if(SecItemCopyMatching(req as CFDictionary, &res) == noErr){
//                let data = res as? [String : Any]
//                let uID = data![kSecAttrAccount as String] as? String
//                let passData = (data![kSecValueData as String] as? Data)!
//                let pass = String(data : passData, encoding: .utf8)
//                enterEmailTextField.text = uID
//                enterPasswordTextField.text = pass
//
//            }else{
//                print("error calling remember me data")
//            }
//
//        }else{
//            remSwitch.setOn(false, animated: true)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
            if(switchStatus.bool(forKey: "switch")){
                   remSwitch.setOn(true, animated: true)
                let req : [String : Any] = [kSecClass as String : kSecClassGenericPassword, kSecAttrAccount as String : userDef.value(forKey: "UN") as! String, kSecReturnAttributes as String : true, kSecReturnData as String : true]
                var res : CFTypeRef?
                if(SecItemCopyMatching(req as CFDictionary, &res) == noErr){
                    let data = res as? [String : Any]
                    let uID = data![kSecAttrAccount as String] as? String
                    let passData = (data![kSecValueData as String] as? Data)!
                    let pass = String(data : passData, encoding: .utf8)
                        enterEmailTextField.text = uID
                        enterPasswordTextField.text = pass
        
                }else{
                    print("error calling remember me data")
                }
        
        }else{
            remSwitch.setOn(false, animated: true)
        }
    }
    
    
    // Action function used for keychain with the rememberMe switch
    // This checks if the switch is on to save the credentials or not for the user
    
    @IBAction func rememberMe(_ sender: Any) {
        if(remSwitch.isOn ==  true){
            switchStatus.set(true, forKey: "switch")
                
                userDef.set(enterEmailTextField.text, forKey: "UN")
                  let attribute : [String : Any] = [kSecClass as String : kSecClassGenericPassword, kSecAttrAccount as String : enterEmailTextField.text!, kSecValueData as String : enterPasswordTextField.text!.data(using: .utf8)]
                  if(SecItemAdd(attribute as CFDictionary, nil ) == noErr){
                      print("remember me is saved")
                  }else{
                      print("remember me not saved")
                  }
              }else{
                  switchStatus.set(false, forKey: "switch")
                  let req : [String: Any] = [kSecClass as String : kSecClassGenericPassword, kSecAttrAccount as String : enterEmailTextField.text!]
                  if(SecItemDelete(req as CFDictionary) == noErr){
                      print("delete remember")
                  }else{
                      print("error with deleting remember")
                  }
              }
    }
    
    
    // This action function checks if the username and password	are correct
    // If correct, segue to TakeItEasy interface :)
    
    @IBAction func buttonSignIn(_ sender: Any) {
        //1. validate username and password inputs
        let emailTextField = enterEmailTextField.text!
        let passwordTextField = enterPasswordTextField.text!
        
        func checkInput(text : String) -> Bool {
            var isValid = false
            if !text.isEmpty && text != "" && text != nil {
                isValid = true
            }
            return isValid
        }
        
        if checkInput(text: emailTextField) && checkInput(text: passwordTextField) {
            //check if user is registered
            if !DBHelperUser.dbHelperUser.isUserRegistered(username: emailTextField) {
                errorMessage.text = "Please sign in first"
            }
            //check if password is correct
            //let correctPassword = DBHelperUser.dbHelperUser.getOne(username: emailTextField).password
            let user = DBHelperUser.dbHelperUser.getOne(username: emailTextField)
            let correctPassword = user.password
            if passwordTextField == correctPassword {
                //present the tab bar controller in full screen
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginNextScreen = storyboard.instantiateViewController(withIdentifier: "TabBar")
                //show the tab controller as an instantiated vc
                loginNextScreen.modalPresentationStyle = .fullScreen
                self.present(loginNextScreen, animated: true, completion: nil)
                //save password to keychain if remember me is on
                //savePassword()
            } else {
                errorMessage.text = "Please check username/password."
            }
        } else {
            errorMessage.text = "Please input username/password."
        }
    }
}
