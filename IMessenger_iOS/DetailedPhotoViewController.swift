//
//  DetailedPhotoViewController.swift
//  IMessenger_iOS
//
//  Created by Ivan Pryadchenko on 13.12.16.
//  Copyright © 2016 Ivan Pryadchenko. All rights reserved.
//

import UIKit

class DetailedPhotoViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var imageViewForDetailedView: UIImageView!
    
    var messageRecieved = [(String,Message)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        scrollView.delegate = self
        scrollView.maximumZoomScale = 5.0
        scrollView.minimumZoomScale = 1.0
        scrollView.backgroundColor = UIColor.black
        
        let data = Data(base64Encoded: messageRecieved[0].1.content.data, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters);
        let someImage = UIImage(data: data!);
        
        let orientedImage = UIImage(cgImage: (someImage?.cgImage!)!, scale: 1, orientation: (someImage?.imageOrientation)!)
        imageViewForDetailedView.image = orientedImage
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageViewForDetailedView
    }
    
    @IBAction func barButtonPushed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        messageRecieved.removeAll()
    }
}
