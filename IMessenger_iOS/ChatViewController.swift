//
//  ChatViewController.swift
//  IMessenger_iOS
//
//  Created by Ivan Pryadchenko on 04.12.16.
//  Copyright © 2016 Ivan Pryadchenko. All rights reserved.
//

import UIKit

let kChatCellReuseableID = "chatTableViewCell"

class ChatViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var textFieldChat: UITextField!
    @IBOutlet weak var tableViewChat: UITableView!
    @IBOutlet weak var buttonSend: UIButton!
    
    var messengesArrayToUser = ["Ahoy!"]
    var messengesArrayFromUser = ["Hi"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewChat.delegate = self
        tableViewChat.dataSource = self
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messengesArrayToUser.count + messengesArrayFromUser.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kChatCellReuseableID, for: indexPath) as! ChatTableViewCell
        cell.chatLable.text = messengesArrayToUser[indexPath.row]
        cell.chatLable.textAlignment = NSTextAlignment.right
        cell.chatLable.text = messengesArrayFromUser[indexPath.row]
        return cell
    }
    
    
    
    @IBAction func buttonSendPushed(_ sender: UIButton) {
        messengesArrayToUser.append(textFieldChat.text!)
        textFieldChat.text = ""
        let IndexPathOfLastRow = IndexPath(row: self.messengesArrayToUser.count - 1, section: 0)
        tableViewChat.insertRows(at: [IndexPathOfLastRow], with: .left)
        tableViewChat.reloadData()
        print(messengesArrayToUser)
        
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
