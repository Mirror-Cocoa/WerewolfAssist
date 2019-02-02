//
//  ViewController.swift
//  HyperWerewolfSupporter
//
//  Created by Ichiro Miura on 2019/01/29.
//  Copyright © 2019年 mycompany. All rights reserved.
//

import Foundation
import UIKit
import Gecco

class viewController: UIViewController, SpotlightViewControllerDelegate {
    
    private var spotlightViewController: SpotlightViewController!
    
    var stepIndex: Int = 0
    
    @IBOutlet var img: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.img.image = UIImage(named:"IMG_12.png")
        // 初期化
        self.spotlightViewController = SpotlightViewController()
        self.spotlightViewController?.delegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                navigationController?.setNavigationBarHidden(true, animated: false)
        
        
        present(self.spotlightViewController, animated: true) {
            let w = self.view.frame.width
            let h = self.view.frame.height
            
            self.spotlightViewController.spotlightView.appear(Spotlight.Oval(center: CGPoint(x: w / 2 + 105, y: h - 17.5), diameter: 50))
        }
    }
    
}
