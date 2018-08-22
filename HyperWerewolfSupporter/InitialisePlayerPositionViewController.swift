//
//  InitialisePlayerPositionViewController.swift
//  HyperWerewolfSupporter
//
//  Created by Ichiro Miura on 2018/06/30.
//  Copyright © 2018年 mycompany. All rights reserved.
//

import UIKit

class InitialisePlayerPositionViewController: UIViewController {
    
    var personNum = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 戻るを消す
//        self.navigationItem.hidesBackButton = true
        // アラートをセット
        initSetAlert()
    }
    
    
    /**
      * アラートの設定
      */
    func initSetAlert () {
        // アラートの初期設定
        let alert: UIAlertController = UIAlertController(title: "人数を入力してください", message: "", preferredStyle:  UIAlertControllerStyle.alert)

        // キャンセルボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler:{
            action in
            self.navigationController!.popViewController(animated: true)
        })
        
        alert.addAction(cancelAction)

        // OKボタンの処理
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            action in
            
            var success = false
            // 値の受け取り
            let textFields:Array<UITextField>? = alert.textFields as Array<UITextField>?
            if (textFields != nil) {
                for textField:UITextField in textFields! {
                    if (self.isOnlyNumber(textField.text!)) {
                        if (4 <= Int(textField.text!)! && Int(textField.text!)! <= 20) {
                            // 初期人数
                            self.personNum = Int(textField.text!)!
                            success = true
                        } else {
                            // 注意文言アラート
                            let warningAlert: UIAlertController = UIAlertController(title: "", message: "人数は4人〜20人の間で入力してください", preferredStyle:  UIAlertControllerStyle.alert)
                            // キャンセルボタン
                            let warningCancelAction: UIAlertAction = UIAlertAction(title: "はい", style: UIAlertActionStyle.default, handler:{
                                action in
                                self.navigationController!.popViewController(animated: true)
                            })
                            warningAlert.addAction(warningCancelAction)
                            self.present(warningAlert, animated: true, completion: nil)
                        }
                    } else {
                        // 注意文言アラート
                        let warningAlert: UIAlertController = UIAlertController(title: "", message: "人数は数値で入力してください", preferredStyle:  UIAlertControllerStyle.alert)
                        // キャンセルボタン
                        let warningCancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.default, handler:{
                            action in
                            self.navigationController!.popViewController(animated: true)
                        })
                        
                        warningAlert.addAction(warningCancelAction)
                        self.present(warningAlert, animated: true, completion: nil)
                        
                    }
                }
            }
            if (success){
                // 大テーブルをセット
                self.squareTablePositionSet()
            }
        })
        
        alert.addAction(defaultAction)
        
        // ステッパーの設置は一旦諦めて次に進もう。。
//        alert.view.addSubview(createStepper())
        
        alert.addTextField(configurationHandler: {(text:UITextField!) -> Void in
            text.text = "\(self.personNum)"
            text.keyboardType = UIKeyboardType.numberPad

            let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            label.text = "人数"
            text.leftView = label
            text.leftViewMode = UITextFieldViewMode.always
            
        })

        present(alert, animated: true, completion: nil)
    }
    
    // 数字のみかを調べる。
    func isOnlyNumber(_ str:String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES '\\\\d+'")
        return predicate.evaluate(with: str)
    }

    /**
      * ステッパーの設置
      */
//    func createStepper() -> UIStepper {
//        let alertStepper = UIStepper()
//        alertStepper.wraps = false
//        alertStepper.maximumValue = 20
//        alertStepper.minimumValue = 1
//        alertStepper.value = Double(personNum)
//
//        // 値が変わった時の処理を指定
//        alertStepper.addTarget(self, action: #selector(stepperChanged), for: UIControlEvents.valueChanged)
//
//        return alertStepper
//    }
//
//    @objc func stepperChanged(sender: UIStepper) {
//        personNum = Int(sender.value)
////        alert.view.addSubview(createStepper())
////        createStepper().value = Double(personNum)
//    }
    
    /**
     * 机を描画する
     */
    func squareTablePositionSet() {
        let outerTableRect = CGRect.init(x: CGFloat(10.0),
                                         y: (self.navigationController?.navigationBar.frame.size.height)! + 10,
                                         width: self.view.frame.width / 2 - 10,
                                         height: self.view.frame.width / 2 - 10
        )
        let outerTable = UIView.init(frame: outerTableRect)
        outerTable.backgroundColor = UIColor.gray
        self.view.addSubview(outerTable)
        
        innerTableSetting(outerRect: outerTableRect)
        
        
    }
    
    /**
     * 内部テーブルの設置
     */
    func innerTableSetting(outerRect: CGRect) {
        
        
        var innerTableList: Array<CGRect> = Array(repeating: CGRect.zero, count: self.personNum)
        
        innerTableList = innerTablePisitioning(positionCount: self.personNum, outerRect: outerRect)
        
        var cnt = 0
        for innerTableRect in innerTableList {
            let innerTable = UIView.init(frame: innerTableRect)
            innerTable.backgroundColor = UIColor.init(red: 230/255, green: 255/255, blue: 230/255, alpha: 90/100)
            
//            switch cnt{
//            case 0:
//                innerTable.backgroundColor = UIColor.blue
//                break
//            case 1:
//                innerTable.backgroundColor = UIColor.red
//                break
//            case 2:
//                innerTable.backgroundColor = UIColor.yellow
//                break
//            case 3:
//                innerTable.backgroundColor = UIColor.green
//                break
//            default:
//                break
//            }
            self.view.addSubview(innerTable)
            
            let label: UILabel = UILabel(frame:CGRect(x:0,y:0,width:innerTableRect.width,height:innerTableRect.height))
            label.text = String(cnt)
            label.textColor = UIColor.black
            label.textAlignment = NSTextAlignment.center
            
            innerTable.addSubview(label)
            
            cnt = cnt + 1
        }
        
    }
    
    /**
     * 内部テーブルのポジショニング指定
     */
    func innerTablePisitioning(positionCount: Int, outerRect: CGRect) -> [CGRect] {
        let innerTableSize = CGSize(width: outerRect.width / 7, height: outerRect.height / 6)
        var innerTableList: Array<CGRect> = Array(repeating: CGRect.zero, count: self.personNum)
        
        let wholeDistance = outerRect.width * 2 + outerRect.height * 2 - innerTableSize.width * 2 - innerTableSize.height * 2
        let moveDistance = (wholeDistance / CGFloat(positionCount))
        
        let rightX = outerRect.maxX - innerTableSize.width
        let underY = outerRect.maxY - innerTableSize.height
        
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
                    yPosition -= abs(moveDistance - xPosition)
                    xPosition = outerRect.minX
                } else {
                    xPosition -= moveDistance
                }
            
            }
            // X軸が左にいたら
            else if (xPosition == outerRect.minX) {
                // yPositionが最低限を超えていたら
                if (yPosition - moveDistance < outerRect.minY) {
                    xPosition += abs(moveDistance - yPosition)
                    yPosition = outerRect.minY
                } else {
                    yPosition -= moveDistance
                }
            }
            
            // Y軸が上にいたら
            else if (yPosition == outerRect.minY) {
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
