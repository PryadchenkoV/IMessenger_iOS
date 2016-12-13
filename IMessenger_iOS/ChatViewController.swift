//
//  ChatViewController.swift
//  IMessenger_iOS
//
//  Created by Ivan Pryadchenko on 04.12.16.
//  Copyright © 2016 Ivan Pryadchenko. All rights reserved.
//

import UIKit
import AVKit
import MobileCoreServices

let kChatCellReuseableID = "chatTableViewCell"
let kImageCellReuseableID = "cellForImage"
let kVideoCellReuseableID = "cellWithVideo"
let kSegueFromChatToVideo = "fromChatToVideo"
let kSegueFromChatToDetailedPhoto = "fromChatToDetailedPhoto"
let kNumberOfMessagesSavedToHistory = 100


class ChatViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        // MARK: - Outlets
    
    @IBOutlet weak var barButtonClearHistory: UIBarButtonItem!
    @IBOutlet weak var buttonAddContent: UIButton!
    @IBOutlet weak var textFieldChat: UITextField!
    @IBOutlet weak var tableViewChat: UITableView!
    @IBOutlet weak var buttonSend: UIButton!
    @IBOutlet weak var constraintBottomTableView: NSLayoutConstraint!
    
    // MARK: - Var and let
    

    var loginUserID = ""
    
    var messageArray = [(String,Message,String)]()
    
    
    var keyboardHeight = CGFloat(0)
    var nameOfUser = ""
    var numberOfRow = 0
    
    let imageSentMail = UIImage(named: "send100")
    let imageReadMail = UIImage(named: "read100")
    let imageDeliveredMail = UIImage(named: "delivered100")
    let imageFailedMail = UIImage(named: "failed100")
    let imageSendingMail = UIImage(named: "sending100")
    
    
    // MARK: - Base Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = nameOfUser
        let userDefaultes = UserDefaults.standard
        if let bufLogin = userDefaultes.object(forKey: "Login") as? String {
            loginUserID = bufLogin
        }
        if let bufArrayOfSenders = userDefaultes.object(forKey: loginUserID + self.title! + "Senders") as? [String], let bufArrayOfData = userDefaultes.data(forKey: loginUserID + self.title! + "Messages"), let bufArrayOfStatuses = userDefaultes.object(forKey: loginUserID + self.title! + "Statuses") as? [String]{
            let bufArrayOfMessage = NSKeyedUnarchiver.unarchiveObject(with: bufArrayOfData) as! [Message]
            for index in (0 ..< bufArrayOfSenders.count) {
                messageArray += [(bufArrayOfSenders[index],bufArrayOfMessage[index],bufArrayOfStatuses[index])]
            }
        }
        
        let picker = UIImagePickerController()
        picker.delegate = self
        textFieldChat.delegate = self
        tableViewChat.delegate = self
        tableViewChat.dataSource = self
        tableViewChat.estimatedRowHeight = kCellForTableViewEstimateHeight
        tableViewChat.rowHeight = UITableViewAutomaticDimension
        let messengerInstance = MessengerObjC.sharedManager() as! MessengerObjC
        messengerInstance.registerObserver()
        NotificationCenter.default.addObserver(self, selector: #selector(self.onMessageReceived), name: NSNotification.Name(rawValue: kNSNotificationOnMessageReceived), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onStatusChanged),name: NSNotification.Name(rawValue: kNSkNSNotificationOnMessageStatusChanged), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        constraintBottomTableView.constant -= keyboardHeight
        var bufArrayOfSenders = [String]()
        var bufArrayOfMessages = [Message]()
        var bufArrayOfStatuses = [String]()
        var counterForHistory = 0
        for(user,message,status) in messageArray {
            counterForHistory += 1
            if(counterForHistory > kNumberOfMessagesSavedToHistory) {
                break
            }
            bufArrayOfSenders += [user]
            bufArrayOfMessages += [message]
            bufArrayOfStatuses += [status]
        }
        
        let userDefaultes = UserDefaults.standard
        userDefaultes.set(bufArrayOfSenders, forKey: loginUserID + self.title! + "Senders")
        let data = NSKeyedArchiver.archivedData(withRootObject: bufArrayOfMessages)
        userDefaultes.set(data, forKey: loginUserID + self.title! + "Messages")
        userDefaultes.set(bufArrayOfStatuses, forKey: loginUserID + self.title! + "Statuses")
    }
    
    
    // MARK: - Notification
    
    func onMessageReceived(notification: NSNotification) {
        let userInfo = notification.userInfo! as NSDictionary
        if userInfo["Sender"] as! String == self.nameOfUser {
            let message = userInfo["Message"] as! Message
            self.messageArray = [(self.nameOfUser,message,"None")] + self.messageArray
            DispatchQueue.main.async {
                self.tableViewChat.beginUpdates()
                self.tableViewChat.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .right)
                if self.messageArray.count > 1{
                    self.tableViewChat.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .bottom, animated: true)
                }
                self.tableViewChat.endUpdates()
            }


        }
    }
    
   func onStatusChanged(notification: NSNotification) {
        let userInfo = notification.userInfo! as NSDictionary
        let messageID = userInfo["MessageID"] as! String
        let statusOfMessage = userInfo["Status"] as! String
        //New
        for indexCountInArray in (0..<self.messageArray.count){
            if messageArray[indexCountInArray].1.identifier == messageID {
                messageArray[indexCountInArray].2 = statusOfMessage
                let indexOfMessage = indexCountInArray
                DispatchQueue.main.async {
                    self.tableViewChat.beginUpdates()
                    self.tableViewChat.reloadRows(at: [IndexPath.init(row: indexOfMessage, section: 0)], with: .none)
                    self.tableViewChat.endUpdates()
                }
                break
            }
        }
        
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
        let messengerInstance = MessengerObjC.sharedManager() as! MessengerObjC
        tableView.deselectRow(at: indexPath, animated: true)
        if messageArray[indexPath.row].0 == self.title! {
            DispatchQueue.main.async {
                messengerInstance.sentMessageSeen(withId: self.messageArray[indexPath.row].1.identifier, fromUser: self.title)
            }
        }
        if messageArray[indexPath.row].1.content.type == Video {
            numberOfRow = indexPath.row
            performSegue(withIdentifier: kSegueFromChatToVideo, sender: self)
        } else if messageArray[indexPath.row].1.content.type == Image {
            numberOfRow = indexPath.row
            performSegue(withIdentifier: kSegueFromChatToDetailedPhoto, sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if messageArray[indexPath.row].1.content.type == Text {
            let cell = tableView.dequeueReusableCell(withIdentifier: kChatCellReuseableID, for: indexPath) as! ChatTableViewCell
            if (messageArray[indexPath.row].0 == loginUserID){
                cell.lableFromWhomMessenge.text = "To:"
                cell.backgroundColor = UIColor.white
                cell.imageViewStatus.image = switchForStatus(statusString: messageArray[indexPath.row].2)
            } else if (messageArray[indexPath.row].0 == nameOfUser) {
                cell.lableFromWhomMessenge.text = "From:"
                cell.imageViewStatus.image = nil
                cell.backgroundColor = UIColor.init(red: 0.745, green: 0.929, blue: 1.0, alpha: 0.4)
            }
            cell.chatLable.text = messageArray[indexPath.row].1.content.data
            return cell
            
        } else if messageArray[indexPath.row].1.content.type == Image {
            let cell = tableView.dequeueReusableCell(withIdentifier: kImageCellReuseableID, for: indexPath) as! ImageTableViewCell
            if (messageArray[indexPath.row].0 == loginUserID){
                cell.lableFromWhomMessenge.text = "To:"
                cell.backgroundColor = UIColor.white
                cell.imageViewStatus.image = switchForStatus(statusString: messageArray[indexPath.row].2)
            } else if (messageArray[indexPath.row].0 == nameOfUser) {
                cell.lableFromWhomMessenge.text = "From:"
                cell.imageViewStatus.image = nil
                cell.backgroundColor = UIColor.init(red: 0.745, green: 0.929, blue: 1.0, alpha: 0.4)
            }
            let data = Data(base64Encoded: messageArray[indexPath.row].1.content.data, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters);
            let someImage = UIImage(data: data!);
            
            let orientedImage = UIImage(cgImage: (someImage?.cgImage!)!, scale: 1, orientation: (someImage?.imageOrientation)!)
            cell.imageViewTransferedPic.image = orientedImage
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: kVideoCellReuseableID, for: indexPath) as! VideoTableViewCell
            if (messageArray[indexPath.row].0 == loginUserID){
                cell.lableFromWhomMessenge.text = "To:"
                cell.backgroundColor = UIColor.white
                cell.imageViewStatus.image = switchForStatus(statusString: messageArray[indexPath.row].2)
            } else if (messageArray[indexPath.row].0 == nameOfUser) {
                cell.lableFromWhomMessenge.text = "From:"
                cell.imageViewStatus.image = nil
                cell.backgroundColor = UIColor.init(red: 0.745, green: 0.929, blue: 1.0, alpha: 0.4)
            }
            return cell
        }
    }
    
    
    // MARK: - IBActions
    
    @IBAction func buttonSendPushed(_ sender: AnyObject) {
        let messageContentInstance = MessageContentObjC()
        messageContentInstance?.encrypted = false
        messageContentInstance?.type = Text
        messageContentInstance?.data = textFieldChat.text
        textFieldChat.text = ""
        let messengerInstance = MessengerObjC.sharedManager() as! MessengerObjC
        let messengeSend = messengerInstance.sendMessage(toUser: self.nameOfUser, messageContent: messageContentInstance)
        self.messageArray = [(loginUserID, messengeSend!, "None")] + self.messageArray
        self.tableViewChat.beginUpdates()
        self.tableViewChat.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .left)
        if self.messageArray.count > 1{
            self.tableViewChat.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .bottom, animated: true)
        }
        self.tableViewChat.endUpdates()
    }
    
    @IBAction func buttonAddContentPushed(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: "What content do you want to add?", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Photo", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        alertController.addAction(cameraAction)
        let videoAction = UIAlertAction(title: "Video", style: .default) { (action) in
            if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .camera
                imagePicker.mediaTypes = [kUTTypeMovie as String]
                imagePicker.allowsEditing = false
                imagePicker.delegate = self
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        alertController.addAction(videoAction)
        let libraryAction = UIAlertAction(title: "Library", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            imagePicker.allowsEditing = false 
            self.present(imagePicker, animated: true, completion: nil)
            }
        }
        alertController.addAction(libraryAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive){ (action) in
        }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true) {
        }

    }
    
    
    @IBAction func barButtonPushed(_ sender: UIBarButtonItem) {
        if sender == barButtonClearHistory {
            
            let alertController = UIAlertController(title: nil, message: "Are you sure to clear the history?", preferredStyle: .actionSheet)
            
            let OKAction = UIAlertAction(title: "Yes", style: .default) { (action) in
                DispatchQueue.main.async {
                    self.messageArray.removeAll()
                    self.tableViewChat.reloadData()
                }
                
            }
            alertController.addAction(OKAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (action) in
            }
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true) {
            }
        }
    }
    
    // MARK: - Image Picker
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let dataToSave = UIImagePNGRepresentation(chosenImage)
            //let strBase64 = String(describing: dataToSave)
            let strBase64 = dataToSave?.base64EncodedString()
            let messageContentInstance = MessageContentObjC()
            messageContentInstance?.encrypted = false
            messageContentInstance?.type = Image
            messageContentInstance?.data = strBase64
            let messengerInstance = MessengerObjC.sharedManager() as! MessengerObjC
            let messengeSend = messengerInstance.sendMessage(toUser: self.nameOfUser, messageContent: messageContentInstance)
            self.messageArray = [(loginUserID, messengeSend!, "None")] + self.messageArray
            self.tableViewChat.beginUpdates()
            self.tableViewChat.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .left)
            if self.messageArray.count > 1{
                self.tableViewChat.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .bottom, animated: true)
            }
            self.tableViewChat.endUpdates()
            
        } else {
            if let pickedVideo = (info[UIImagePickerControllerMediaURL] as? URL) {
                let messageContentInstance = MessageContentObjC()
                let videoData = NSData(contentsOf: pickedVideo)
                //let strNew = String(videoData)
                let strBase64 = videoData?.base64EncodedData(options: NSData.Base64EncodingOptions.lineLength64Characters).base64EncodedString()
                messageContentInstance?.encrypted = false
                messageContentInstance?.type = Video
                messageContentInstance?.data = strBase64
                let messengerInstance = MessengerObjC.sharedManager() as! MessengerObjC
                let messengeSend = messengerInstance.sendMessage(toUser: self.nameOfUser, messageContent: messageContentInstance)
                self.messageArray = [(loginUserID, messengeSend!, "None")] + self.messageArray
                self.tableViewChat.beginUpdates()
                self.tableViewChat.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .left)
                if self.messageArray.count > 1{
                    self.tableViewChat.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .bottom, animated: true)
                }
                self.tableViewChat.endUpdates()
                self.tableViewChat.reloadData()
                
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Additional Func
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kSegueFromChatToVideo {
            if let destinantionController = segue.destination as? VideoFromMessageAVViewController {
                
                destinantionController.messageToPlay = [messageArray[numberOfRow].1]
            }
        }
        if segue.identifier == kSegueFromChatToDetailedPhoto {
            if let destinantionController = segue.destination as? DetailedPhotoViewController {
                
                destinantionController.messageRecieved = [(messageArray[numberOfRow].0,messageArray[numberOfRow].1)]
            }
        }
    }
    
    func switchForStatus(statusString: String) -> UIImage? {
        var bufImage: UIImage?
        switch(statusString) {
        case "Sending":
            bufImage = imageSendingMail
        case "Sent":
            bufImage = imageSentMail
        case "FailedToSend":
            bufImage = imageFailedMail
        case "Delivered":
            bufImage = imageDeliveredMail
        case "Seen":
            bufImage = imageReadMail
        case "None":
            bufImage = nil
        default:
            break
        }
        return bufImage
    }

}
