//
//  UnderDiscussionViewController.swift
//  HyperWerewolfSupporter
//
//  Created by Ichiro Miura on 2018/10/14.
//  Copyright © 2018年 mycompany. All rights reserved.
//

import UIKit

class UnderDiscussionViewController: UIViewController ,UIDragInteractionDelegate, UIDropInteractionDelegate {
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        return []
    }
    
    var personNum:Int?
    let userDefaults = UserDefaults.standard
    var personList: Array<[String:String]> = []
    var memberLabelList: [UILabel] = []
    
    var innerTableList: [UIView] = []
    var innerTableRectList: [CGRect] = []
    
    var dragIdx = 0
    var dropIdx = 0
    
    @IBOutlet weak var outerTable: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.personNum)
        print(self.personList)
        self.squareTablePositionSet()
        
    }
    
    /**
     * 机を描画する
     */
    func squareTablePositionSet() {
        var targetPerson = 0
        
        for _ in 0..<personList.count {
            if (self.personList[targetPerson]["yourself"] != nil) {
                break
            }
            targetPerson += 1
        }
        
        self.personList.insert(self.personList[targetPerson], at:0)
        self.personList.remove(at: targetPerson + 1)
        
        var cnt = 0
        
        for innerTableRect in innerTableRectList {
            let innerTable = UIView.init(frame: innerTableRect)
            innerTable.backgroundColor = UIColor.init(red: 230/255, green: 255/255, blue: 230/255, alpha: 90/100)
            
            //上下左右のCALayerを作成
            let rectArray = [
                CGRect(x: 0, y: 0, width: innerTable.frame.width, height: 1.0),
                CGRect(x: 0, y: 0, width: 1.0, height:innerTable.frame.height),
                CGRect(x: 0, y: innerTable.frame.height, width: innerTable.frame.width, height:-1.0),
                CGRect(x: innerTable.frame.width, y: 0, width: -1.0, height:innerTable.frame.height)
            ]
            
            for idx in 0..<rectArray.count {
                let border = CALayer()
                border.frame = rectArray[idx]
                border.backgroundColor = UIColor.black.cgColor
                innerTable.layer.addSublayer(border)
            }
            
            // 小テーブルの追加
            self.view.addSubview(innerTable)
            
            let dragDelegate: UIDragInteractionDelegate = self
            let dragInteraction = UIDragInteraction(delegate: dragDelegate)
            dragInteraction.isEnabled = true    // iPhoneの場合はデフォルトがfalseになっている
            innerTable.addInteraction(dragInteraction)
            self.innerTableList.append(innerTable)
            
            let dropDelegate: UIDropInteractionDelegate = self
            let dropInteraction = UIDropInteraction(delegate: dropDelegate)
            innerTable.addInteraction(dropInteraction)
            
            innerTable.addSubview(self.memberLabelList[cnt])
            
            cnt += 1
        }
        
    }
    
    
    
    
    
}
