//
//  VideoFromMessageAVViewController.swift
//  IMessenger_iOS
//
//  Created by Ivan Pryadchenko on 10.12.16.
//  Copyright © 2016 Ivan Pryadchenko. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class VideoFromMessageAVViewController: AVPlayerViewController {

    var messageToPlay = [Message]()
    var urlToVideo:URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mess = messageToPlay[0].content.data
        let data = Data(base64Encoded: messageToPlay[0].content.data, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters);
        let url = URL(string: mess!)
        //let url = URL(dataRepresentation: messageToPlay[0].content.data, relativeTo: nil)
        let player = AVPlayer(url: url!)
        let playerController = AVPlayerViewController()
        
        playerController.player = player
        self.addChildViewController(playerController)
        self.view.addSubview(playerController.view)
        playerController.view.frame = self.view.frame
        
        player.play()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
