//
//  ChatViewController.swift
//  IMessenger_iOS
//
//  Created by Ivan Pryadchenko on 04.12.16.
//  Copyright © 2016 Ivan Pryadchenko. All rights reserved.
//

import UIKit

let kChatCellReuseableID = "chatTableViewCell"

class ChatViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    // MARK: - Outlets
    
    @IBOutlet weak var textFieldChat: UITextField!
    @IBOutlet weak var tableViewChat: UITableView!
    @IBOutlet weak var buttonSend: UIButton!
    
    @IBOutlet weak var constraintBottomTableView: NSLayoutConstraint!
    
    // MARK: - Var and let
    
    var messengesArray = [Message]()
    var keyboardHeight = CGFloat(0)
    var nameOfUser = ""
    
    let imageSentMail = UIImage(named: "send100")
    let imageReadMail = UIImage(named: "read100")
    let imageDeliveredMail = UIImage(named: "delivered100")
    let imageFailedMail = UIImage(named: "failed100")
    let imageSendingMail = UIImage(named: "sending100")
    
    
    var flagFromWhom = -1
    var flagStatus = -1
    
    // MARK: - Base Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = nameOfUser
        messengerInstance.registerObserver { (string, message, messageStatus) in
            if let userID = string {
                if userID == self.nameOfUser {
                    self.flagFromWhom = 1
                    self.messengesArray = [message!] + self.messengesArray
                    DispatchQueue.main.async {
                        self.tableViewChat.beginUpdates()
                        self.tableViewChat.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .right)
                        self.tableViewChat.endUpdates()
                    }
                }
            } else {
                var indexCount = -1
                for messageInArray in self.messengesArray {
                    indexCount += 1
                    if messageInArray.identifier == message!.identifier {
                        let indexOfMessage = indexCount
                        DispatchQueue.main.async {
                            switch(messageStatus) {
                            case Sending:
                                self.flagStatus = 1
                            case Sent:
                                self.flagStatus = 2
                            case FailedToSend:
                                self.flagStatus = 3
                            case Delivered:
                                self.flagStatus = 4
                            case Seen:
                                self.flagStatus = 5
                            default:
                                break
                            }
                            self.tableViewChat.beginUpdates()
                            self.tableViewChat.deleteRows(at: [IndexPath.init(row: indexOfMessage, section: 0)], with: .none)
                            self.tableViewChat.insertRows(at: [IndexPath.init(row: indexOfMessage, section: 0)], with: .none)
                            self.tableViewChat.endUpdates()
                        }
                    }
                }
            }
        }
        textFieldChat.delegate = self
        tableViewChat.delegate = self
        tableViewChat.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func keyboardWillShow(notification: NSNotification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        keyboardHeight = keyboardRectangle.height
        constraintBottomTableView.constant += keyboardHeight
    }
    
    func keyboardWillHide(notification: NSNotification) {
        constraintBottomTableView.constant -= keyboardHeight
    }
    
    // MARK: - TableView Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        DispatchQueue.main.async {
            messengerInstance.sentMessageSeen(withId: self.messengesArray[indexPath.row].identifier, fromUser: self.title)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messengesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kChatCellReuseableID, for: indexPath) as! ChatTableViewCell
        switch flagFromWhom {
        case 0: cell.lableFromWhomMessenge.text = "To:"
        switch(flagStatus) {
        case 1:
            cell.imageViewStatus.image = imageSendingMail
        case 2:
            cell.imageViewStatus.image = imageSentMail
        case 3:
            cell.imageViewStatus.image = imageFailedMail
        case 4:
            cell.imageViewStatus.image = imageDeliveredMail
        case 5:
            cell.imageViewStatus.image = imageReadMail
        default:
            break
            }
        case 1: cell.lableFromWhomMessenge.text = "From:"
        default:
            break
        }
        cell.chatLable.text = messengesArray[indexPath.row].content.data
        return cell
    }
    
    // MARK: - IBActions
    
    @IBAction func buttonSendPushed(_ sender: AnyObject) {
        let messageContentInstance = MessageContentObjC()
        messageContentInstance?.encrypted = false
        messageContentInstance?.type = Text
        messageContentInstance?.data = textFieldChat.text
        textFieldChat.text = ""
        let messengeSend = messengerInstance.sendMessage(toUser: nameOfUser, messageContent: messageContentInstance)
        flagFromWhom = 0
        messengesArray = [(messengeSend)!] + messengesArray
        self.tableViewChat.beginUpdates()
        self.tableViewChat.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .left)
        self.tableViewChat.endUpdates()
        
        
    }
    

}
