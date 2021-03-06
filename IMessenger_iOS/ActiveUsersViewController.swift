//
//  ActiveUsersViewController.swift
//  IMessenger_iOS
//
//  Created by Ivan Pryadchenko on 04.12.16.
//  Copyright © 2016 Ivan Pryadchenko. All rights reserved.
//

import UIKit
import AVFoundation


let kSystemSoundIDForNotifications: SystemSoundID = 1016
let kCellActiveUserReusedID = "cellActiveUser"
let kCellForTableViewEstimateHeight = CGFloat(44.0)

class ActiveUsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Var and let
    
    @IBOutlet weak var tableViewActiveUsers: UITableView!
    
    @IBOutlet weak var barButtonDisconnect: UIBarButtonItem!
    
    
    @IBOutlet weak var lableUserID: UILabel!
    @IBOutlet weak var barButtonRefresh: UIBarButtonItem!
    
    // MARK: - Var and let
    
    var userName = ""
    var arrayOfUsers = [String]()
    var messageArray = [(String,Message,String)]()
    var flagNewMessage = false
    var tmpDictionary = [String:Any]()
    
    var loginUserID = ""
    
    // MARK: - Basic Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userDefaultes = UserDefaults.standard
        if let bufLogin = userDefaultes.object(forKey: "Login") as? String {
            loginUserID = bufLogin
        }
        lableUserID.text = loginUserID
        tableViewActiveUsers.delegate = self
        tableViewActiveUsers.dataSource = self
        tableViewActiveUsers.estimatedRowHeight = kCellForTableViewEstimateHeight
        tableViewActiveUsers.rowHeight = UITableViewAutomaticDimension
        let messengerInstance = MessengerObjC.sharedManager() as! MessengerObjC
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
            case InternalError:
                DispatchQueue.main.async {
                    self.createAlertView(stringToPresent: "Internal Error")
                }
            case NetworkError:
                DispatchQueue.main.async {
                    self.createAlertView(stringToPresent: "Network Error")
                }
            default:
                break
            }
            
        }
        messengerInstance.registerObserver()
        NotificationCenter.default.addObserver(self, selector: #selector(self.onMessageReceived), name: NSNotification.Name(rawValue: kNSNotificationOnMessageReceived), object: nil)

        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - Notification
    
    func onMessageReceived(notification:Notification) {
        AudioServicesPlaySystemSound(kSystemSoundIDForNotifications)
        let userInfo = notification.userInfo! as NSDictionary
        let message = userInfo["Message"] as! Message
        let sender = userInfo["Sender"] as! String
        self.messageArray = [(sender,message,"None")] + self.messageArray
        var indexOfUser = 0
        for (number,user) in arrayOfUsers.enumerated() {
            if user == sender {
                indexOfUser = number
                break
            }
        }
        DispatchQueue.main.async {
            self.tableViewActiveUsers.beginUpdates()
            self.tableViewActiveUsers.reloadRows(at: [IndexPath.init(row: indexOfUser, section: 0)], with: .none)
            self.tableViewActiveUsers.endUpdates()
            if self.messageArray.count > 1{
                self.tableViewActiveUsers.scrollToRow(at: IndexPath.init(row: indexOfUser, section: 0), at: .top, animated: true)
            }
        }
    }
    
    
    
    // MARK: - TableView Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfUsers.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellActiveUsers = tableView.dequeueReusableCell(withIdentifier: kCellActiveUserReusedID) as! ActiveUserTableViewCell
        if messageArray.count > 0 && messageArray[0].0 == arrayOfUsers[indexPath.row] {
            var numberOfNotifications = 0
            for message in messageArray {
                if message.0 == arrayOfUsers[indexPath.row] {
                    numberOfNotifications += 1
                }
            }
            cellActiveUsers.lableNumberOfNotifications.isHidden = false
            cellActiveUsers.lableNumberOfNotifications.text = String(numberOfNotifications)
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
        var indexOfArray = 0
        for _ in (0..<messageArray.count) {
            if userName == messageArray[indexOfArray].0 {
                messageArray.remove(at: indexOfArray)
            } else {
                indexOfArray += 1
            }
        }
        DispatchQueue.main.async {
            self.tableViewActiveUsers.beginUpdates()
            self.tableViewActiveUsers.reloadRows(at: [indexPath], with: .none)
            self.tableViewActiveUsers.endUpdates()
        }
    }
    
    // MARK: - Addition Func

    @IBAction func barButtonPushed(_ sender: UIBarButtonItem) {
        let messengerInstance = MessengerObjC.sharedManager() as! MessengerObjC
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
                var bufTransportArray = [(String,Message,String)]()
                for index in (0..<messageArray.count) {
                    if messageArray[index].0 == userName {
                        bufTransportArray += [(messageArray[index].0,messageArray[index].1,messageArray[index].2)]
                    }
                }
                destinantionController.messageArray = bufTransportArray
                
            }
        }
    }
    
    func createAlertView(stringToPresent:String) {
        let messengerInstance = MessengerObjC.sharedManager() as! MessengerObjC
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

    override func viewWillAppear(_ animated: Bool) {
        var indexOfArray = 0
        for _ in (0..<messageArray.count) {
            if userName == messageArray[indexOfArray].0 {
                messageArray.remove(at: indexOfArray)
            } else {
                indexOfArray += 1
            }
        }
        tableViewActiveUsers.reloadData()
    }

}
