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

    @IBOutlet weak var textFieldChat: UITextField!
    @IBOutlet weak var tableViewChat: UITableView!
    @IBOutlet weak var buttonSend: UIButton!
    
    @IBOutlet weak var constraintBottomTableView: NSLayoutConstraint!
    
    var messengesArray = [String]()
    var keyboardHeight = CGFloat(0)
    var nameOfUser = ""
    
    var flagFromWhom = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = nameOfUser
        messengerInstance.registerObserver { (String, Message, messageStatus) in
            if let userID = String {
                if userID == self.nameOfUser {
                    self.flagFromWhom = 1
                    self.messengesArray = [(Message?.content.data)!] + self.messengesArray
                    DispatchQueue.main.async {
                        self.tableViewChat.beginUpdates()
                        self.tableViewChat.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .right)
                        self.tableViewChat.endUpdates()
                    }
                }
            } else {
                
            }
        }
        textFieldChat.delegate = self
        tableViewChat.delegate = self
        tableViewChat.dataSource = self
        self.tableViewChat.frame = CGRect(x: 0 , y: 118, width: 375, height: 549 - 200)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messengesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kChatCellReuseableID, for: indexPath) as! ChatTableViewCell
        switch flagFromWhom {
        case 0: cell.lableFromWhomMessenge.text = "To:"
        case 1: cell.lableFromWhomMessenge.text = "From:"
        default:
            break
        }
        cell.chatLable.text = messengesArray[indexPath.row]
        return cell
    }
    
    
    func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        textFieldChat.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    
    @IBAction func buttonSendPushed(_ sender: AnyObject) {
        let messageContentInstance = MessageContentObjC()
        messageContentInstance?.encrypted = false
        messageContentInstance?.type = Text
        messageContentInstance?.data = textFieldChat.text
        textFieldChat.text = ""
        let messengeSend = messengerInstance.sendMessage(toUser: nameOfUser, messageContent: messageContentInstance)
        flagFromWhom = 0
        messengesArray = [(messengeSend?.content.data)!] + messengesArray
        self.tableViewChat.beginUpdates()
        self.tableViewChat.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .left)
        self.tableViewChat.endUpdates()
        messengerInstance.sentMessageSeen(withId: messengeSend?.identifier, fromUser: nameOfUser)
        
        
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
