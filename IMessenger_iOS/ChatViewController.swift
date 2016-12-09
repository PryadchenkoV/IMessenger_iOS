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
    

    var messageFullArray = [(String,Message)]()
    var messageArray = [(String,Message,messageStatus)]()
    
    
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
        let userDefaultes = UserDefaults.standard
        if let bufArrayOfSenders = userDefaultes.object(forKey: self.title! + "Senders") as? [String], let bufArrayOfData = userDefaultes.data(forKey: self.title! + "Messages") {
            let bufArrayOfMessage = NSKeyedUnarchiver.unarchiveObject(with: bufArrayOfData) as! [Message]
            for index in (0 ..< bufArrayOfSenders.count) {
                messageFullArray += [(bufArrayOfSenders[index],bufArrayOfMessage[index])]
            }
        }
        //var tmpArrayOfSenders = [String]()
        //var tmpArryaOfMessage = [Message]()
        
        messengerInstance.registerObserver { (string, message, messageStatus) in
            if let userID = string {
                if userID == self.nameOfUser {
                    self.flagFromWhom = 1
                    self.messageFullArray = [(self.title!, message!)] + self.messageFullArray
                    //self.messengesArray = [message!] + self.messengesArray
                    DispatchQueue.main.async {
                        self.tableViewChat.beginUpdates()
                        self.tableViewChat.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .right)
                        if self.messageFullArray.count > 1{
                            self.tableViewChat.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .bottom, animated: true)
                        }
                        self.tableViewChat.endUpdates()
                    }
                }
            } else {
                var indexCount = -1
                for (_,messageInArray) in self.messageFullArray {
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
                            let tmpFlag = self.flagFromWhom
                            self.flagFromWhom = 0
                            self.tableViewChat.deleteRows(at: [IndexPath.init(row: indexOfMessage, section: 0)], with: .none)
                            self.tableViewChat.insertRows(at: [IndexPath.init(row: indexOfMessage, section: 0)], with: .none)
                            self.tableViewChat.endUpdates()
                            self.flagFromWhom = tmpFlag
                        }
                    }
                }
            }
        }
        textFieldChat.delegate = self
        tableViewChat.delegate = self
        tableViewChat.dataSource = self
        tableViewChat.estimatedRowHeight = 44.0
        tableViewChat.rowHeight = UITableViewAutomaticDimension
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
        if messageFullArray[indexPath.row].0 == self.title! {
            DispatchQueue.main.async {
                
                messengerInstance.sentMessageSeen(withId: self.messageFullArray[indexPath.row].1.identifier, fromUser: self.title)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageFullArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kChatCellReuseableID, for: indexPath) as! ChatTableViewCell

        if (messageFullArray[indexPath.row].0 == loginUserID){
            cell.lableFromWhomMessenge.text = "To:"
            cell.backgroundColor = UIColor.white
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
        } else if (messageFullArray[indexPath.row].0 == nameOfUser) {
            cell.lableFromWhomMessenge.text = "From:"
            cell.imageViewStatus.image = nil
            cell.backgroundColor = UIColor.init(red: 0.745, green: 0.929, blue: 1.0, alpha: 0.4)
        }
        cell.chatLable.text = messageFullArray[indexPath.row].1.content.data
        //cell.chatLable.text = messengesArray[indexPath.row].content.data
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
        messageFullArray = [(loginUserID, messengeSend!)] + messageFullArray
        //messengesArray = [(messengeSend)!] + messengesArray
        //tableViewChat.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .bottom, animated: true)
        self.tableViewChat.beginUpdates()
        self.tableViewChat.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .left)
        if messageFullArray.count > 1{
            tableViewChat.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .bottom, animated: true)
        }
        self.tableViewChat.endUpdates()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        constraintBottomTableView.constant -= keyboardHeight
        
        var bufArrayOfSenders = [String]()
        var bufArrayOfMessages = [Message]()
        
        for (user,message) in messageFullArray {
            bufArrayOfSenders += [user]
            bufArrayOfMessages += [message]
        }
        let userDefaultes = UserDefaults.standard
        userDefaultes.set(bufArrayOfSenders, forKey: self.title! + "Senders")
        let data = NSKeyedArchiver.archivedData(withRootObject: bufArrayOfMessages)
        userDefaultes.set(data, forKey: self.title! + "Messages")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
    }

}
