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
    
    /**
     * 内部テーブルのポジショニング指定
     */
    func innerTablePisitioning(positionCount: Int, outerRect: CGRect) -> [CGRect] {
        let innerTableSize = CGSize(width: outerRect.width / 7, height: outerRect.height / 6)
        var innerTableList: Array<CGRect> = Array(repeating: CGRect.zero, count: self.personNum!)
        
        let wholeDistance = outerRect.width * 2 + outerRect.height * 2 - innerTableSize.width * 2 - innerTableSize.height * 2
        let moveDistance = (wholeDistance / (CGFloat(positionCount)))
        
        let rightX = outerRect.maxX - innerTableSize.width
        let underY = outerRect.maxY - innerTableSize.height + (self.navigationController?.navigationBar.frame.size.height)!
        
        let initXPosition = outerRect.maxX - ((outerRect.width + innerTableSize.width) / 2)
        let initYPosition = underY
        
        var xPosition = initXPosition
        var yPosition = initYPosition
        
        for pos in 0..<positionCount {
            if (pos == 0) {
                innerTableList[pos] = CGRect.init(
                    x: xPosition, y: yPosition, width: innerTableSize.width, height: innerTableSize.height
                )
                continue
            }
            
            // Y軸が下にいたら
            if (yPosition == underY) {
                // xPositionが最低限を超えていたら
                if (xPosition - moveDistance < outerRect.minX) {
                    yPosition -= abs(moveDistance - xPosition)+(self.navigationController?.navigationBar.frame.size.height)!
                    xPosition = outerRect.minX
                } else {
                    xPosition -= moveDistance
                }
                
            }
                // X軸が左にいたら
            else if (xPosition == outerRect.minX) {
                // yPositionが最低限を超えていたら
                if (yPosition - moveDistance - (self.navigationController?.navigationBar.frame.size.height)! < outerRect.minY) {
                    xPosition += abs(moveDistance - yPosition)-(self.navigationController?.navigationBar.frame.size.height)!
                    yPosition = outerRect.minY + (self.navigationController?.navigationBar.frame.size.height)!
                } else {
                    yPosition -= moveDistance
                }
            }
                
                // Y軸が上にいたら
            else if (yPosition - (self.navigationController?.navigationBar.frame.size.height)! == outerRect.minY) {
                // xPositionが最上限を超えていたら
                if (xPosition + moveDistance > rightX) {
                    yPosition += moveDistance - (rightX - xPosition)
                    xPosition = rightX
                } else {
                    xPosition += moveDistance
                }
            }
                
                // X軸が右にいたら
            else if (xPosition == rightX) {
                // yPositionが最上限を超えていたら
                if (yPosition + moveDistance > underY) {
                    xPosition -= moveDistance - (underY - yPosition)
                    yPosition = underY
                } else {
                    yPosition += moveDistance
                }
            }
            
            innerTableList[pos] = CGRect.init(
                x: xPosition, y: yPosition, width: innerTableSize.width, height: innerTableSize.height
            )
        }
        
        return innerTableList
    }
    
    
}
