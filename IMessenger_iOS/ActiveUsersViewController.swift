//
//  ActiveUsersViewController.swift
//  IMessenger_iOS
//
//  Created by Ivan Pryadchenko on 04.12.16.
//  Copyright © 2016 Ivan Pryadchenko. All rights reserved.
//

import UIKit

let kCellActiveUserReusedID = "cellActiveUser"

class ActiveUsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableViewActiveUsers: UITableView!
    
    @IBOutlet weak var barButtonDisconnect: UIBarButtonItem!
    
    @IBOutlet weak var lableUserID: UILabel!
    @IBOutlet weak var barButtonRefresh: UIBarButtonItem!
    var userName = ""
    var arrayOfUsers = [String]()
    var messageArray = [(String,Message)]()
    var flagNewMessage = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lableUserID.text = loginUserID
        tableViewActiveUsers.delegate = self
        tableViewActiveUsers.dataSource = self
        tableViewActiveUsers.estimatedRowHeight = 44.0
        tableViewActiveUsers.rowHeight = UITableViewAutomaticDimension
        messengerInstance.requestActiveUsers { (operationResult, arrayOfUsers) in
            switch operationResult {
            case Ok:
                for user in arrayOfUsers! {
                    let userObj = user as! UserObjC
                    self.arrayOfUsers.append(userObj.userId)
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
    
    override func viewWillAppear(_ animated: Bool) {
        
        messengerInstance.registerObserver { (String, message, messageStatus) in
            if let user = String {
                self.messageArray = [(user, message!)] + self.messageArray
                var indexForUpdate = 0
                for (number,index) in self.arrayOfUsers.enumerated(){
                    if index == user {
                        indexForUpdate = number
                        break
                    }
                }
                //self.messengesArray = [message!] + self.messengesArray
                DispatchQueue.main.async {
                    self.tableViewActiveUsers.beginUpdates()
                    self.tableViewActiveUsers.deleteRows(at: [IndexPath.init(row: indexForUpdate, section: 0)], with: .none)
                    self.tableViewActiveUsers.insertRows(at: [IndexPath.init(row: indexForUpdate, section: 0)], with: .none)
                    self.tableViewActiveUsers.scrollToRow(at: IndexPath.init(row: indexForUpdate, section: 0), at: .bottom, animated: true)
                    self.tableViewActiveUsers.endUpdates()
                }
                
            }
        }
        
        messageArray.removeAll()
        DispatchQueue.main.async {
            self.tableViewActiveUsers.reloadData()
        }

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfUsers.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellActiveUsers = tableView.dequeueReusableCell(withIdentifier: kCellActiveUserReusedID) as! ActiveUserTableViewCell
        if messageArray.count > 0 && messageArray[messageArray.count - 1].0 == arrayOfUsers[indexPath.row] {
            cellActiveUsers.lableNumberOfNotifications.isHidden = false
            cellActiveUsers.lableNumberOfNotifications.text = String(Int(cellActiveUsers.lableNumberOfNotifications.text!)! + 1)
        } else {
            cellActiveUsers.lableNumberOfNotifications.isHidden = true
        }
        cellActiveUsers.lableNameOfUser.text = arrayOfUsers[indexPath.row]
        return cellActiveUsers
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        userName = arrayOfUsers[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: kSegueFromActiveUsersToChat, sender: self)
    }

    @IBAction func barButtonPushed(_ sender: UIBarButtonItem) {
        switch sender{
        case barButtonDisconnect:
            messengerInstance.disconnectFromServer()
        case barButtonRefresh:
            arrayOfUsers.removeAll()
            messengerInstance.requestActiveUsers { (operationResult, NSMutableArray) in
                switch operationResult {
                case Ok:
                    for user in NSMutableArray! {
                        let userObj = user as! UserObjC
                        self.arrayOfUsers.append(userObj.userId)
                    }
                    DispatchQueue.main.async {
                        self.tableViewActiveUsers.reloadData()
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
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kSegueFromActiveUsersToChat {
            if let destinantionController = segue.destination as? ChatViewController {
                destinantionController.nameOfUser = userName
                destinantionController.messageFullArray = messageArray
            }
        }
    }
    
    func createAlertView(stringToPresent:String) {
        let alertController = UIAlertController(title: "Try again", message: stringToPresent, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        let refreshAction = UIAlertAction(title: "Refresh", style: .default, handler: { (action) in
            messengerInstance.requestActiveUsers { (operationResult, NSMutableArray) in
                switch operationResult {
                case Ok:
                    for user in NSMutableArray! {
                        let userObj = user as! UserObjC
                        self.arrayOfUsers.append(userObj.userId)
                    }
                    DispatchQueue.main.async {
                        self.tableViewActiveUsers.reloadData()
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
        })
        alertController.addAction(cancelAction)
        alertController.addAction(refreshAction)
        self.present(alertController, animated: true) {
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        messengerInstance.unregisterObserver()
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
