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


class ViewController: UIViewController {
    
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)

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
        let refreshBarButton: UIBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        self.navigationItem.rightBarButtonItem = refreshBarButton
        self.activityIndicator.startAnimating()
        let messengerInstance = MessengerObjC.sharedManager() as! MessengerObjC
        messengerInstance.login(withUserId: lableLogin.text, password: lablePassword.text) { (result) in
            self.activityIndicator.stopAnimating()
            switch result {
            case Ok:
                let userDefaultes = UserDefaults.standard
                userDefaultes.set(self.lableLogin.text!, forKey: "Login")
                userDefaultes.set(self.lablePassword.text!, forKey: "Password")
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: kSegueFromLoginToActiveUsers, sender:self)
                }
            case AuthError:
                DispatchQueue.main.async {
                    self.createAlertView(stringToPresent: "Authentification Error")
                }
                self.activityIndicator.stopAnimating()
            case InternalError:
                DispatchQueue.main.async {
                    self.createAlertView(stringToPresent: "Internal Error")
                }
                self.activityIndicator.stopAnimating()
            case NetworkError:
                DispatchQueue.main.async {
                    self.createAlertView(stringToPresent: "Network Error")
                }
                self.activityIndicator.stopAnimating()
            default: break
            }
        }
        
    }
    
    func createAlertView(stringToPresent:String) {
        let alertController = UIAlertController(title: "Something went wrong...", message: stringToPresent, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Ok", style: .default) { (_) in
        }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true) {
        }
    }
}

