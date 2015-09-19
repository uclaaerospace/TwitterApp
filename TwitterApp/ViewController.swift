//
//  ViewController.swift
//  TwitterApp
//
//  Created by yoshihisa haruyama on 9/12/15.
//  Copyright (c) 2015 yoshihisa haruyama. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var detailImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailImage.sd_setImageWithURL(NSURL(string: "http://www.123freevectors.com/wp-content/small/new/signs-symbols/042-Olympic%20Logo%20Vector%20Art%20Free-l.png"))
        
    }




}

