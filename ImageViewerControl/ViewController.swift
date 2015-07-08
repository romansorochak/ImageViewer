//
//  ViewController.swift
//  ImageViewerControl
//
//  Created by RomanSorochak on 08.07.15.
//  Copyright (c) 2015 SorikProduction. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    struct Constants {
        static let SegueId = "segueId"
    }
    
    let pageImages = [UIImage(named: "1")!,
        UIImage(named: "2")!,
        UIImage(named: "3")!,
        UIImage(named: "4")!,
        UIImage(named: "5")!,
        UIImage(named: "6")!,
        UIImage(named: "7")!,
        UIImage(named: "8")!
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

    @IBAction func showImage(sender: AnyObject) {
        
        performSegueWithIdentifier(Constants.SegueId, sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == Constants.SegueId {
            if let vc = segue.destinationViewController as? ImageViewerViewController {
                
                vc.pageImages = pageImages
                vc.currentImage = 0
            }
        }
    }
}

