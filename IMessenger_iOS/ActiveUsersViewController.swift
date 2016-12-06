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
    
    var arrayOfUsers = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewActiveUsers.delegate = self
        tableViewActiveUsers.dataSource = self
        messengerInstance.requestActiveUsers { (operationResult, NSMutableArray) in
            switch operationResult {
            case Ok:
                for user in NSMutableArray! {
                    let userObj = user as! UserObjC
                    self.arrayOfUsers.append(userObj.userId)
                }
            case AuthError:
                print("AuthError")
            case InternalError:
                print("InternalError")
            case NetworkError:
                print("NetworkError")
            default:
                print("Default")
            }

        }
        
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfUsers.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellActiveUsers = tableView.dequeueReusableCell(withIdentifier: kCellActiveUserReusedID) as! ActiveUserTableViewCell
        cellActiveUsers.lableNameOfUser.text = arrayOfUsers[indexPath.row]
        return cellActiveUsers
    }

    @IBAction func barButtonPushed(_ sender: UIBarButtonItem) {
        switch sender{
        case barButtonDisconnect:
            messengerInstance.disconnectFromServer()
        default:
            break
        }
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
