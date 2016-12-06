//
//  ViewController.swift
//  IMessenger_iOS
//
//  Created by Ivan Pryadchenko on 28.11.16.
//  Copyright © 2016 Ivan Pryadchenko. All rights reserved.
//

import UIKit

let kSegueFromLoginToActiveUsers = "fromLoginToActiveUsers"
let kSegueFromActiveUsersToChat = "fromActiveUsersToChat"
let messengerInstance = MessengerObjC()


class ViewController: UIViewController {

    @IBOutlet weak var lableLogin: UITextField!
    @IBOutlet weak var lablePassword: UITextField!
    @IBOutlet weak var buttonLogin: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func buttonLoginPushed(_ sender: UIButton) {
        messengerInstance.login(withUserId: lableLogin.text, password: lablePassword.text) { (result) in
            switch result {
            case Ok:
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: kSegueFromLoginToActiveUsers, sender:self)
                }
            case AuthError:
                DispatchQueue.main.async {
                    self.createAlertView(stringToPresent: "Authentification Error")
                }
                print("AuthError")
            case InternalError:
                DispatchQueue.main.async {
                    self.createAlertView(stringToPresent: "Internal Error")
                }
                print("InternalError")
            case NetworkError:
                DispatchQueue.main.async {
                    self.createAlertView(stringToPresent: "Network Error")
                }
                print("NetworkError")
            default:
                print("Default")
            }
        }
        
    }
    
    func createAlertView(stringToPresent:String) {
        let alertController = UIAlertController(title: "Something went wrong...", message: stringToPresent, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Ok", style: .default) { (action) in
        }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true) {
        }
    }
}

