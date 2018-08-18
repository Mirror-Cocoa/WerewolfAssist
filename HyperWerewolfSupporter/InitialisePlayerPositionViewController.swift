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
        self.navigationItem.hidesBackButton = true
        
        
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
            
            // 値の受け取り
            let textFields:Array<UITextField>? = alert.textFields as Array<UITextField>?
            if (textFields != nil) {
                for textField:UITextField in textFields! {
                    // 初期人数
                    self.personNum = Int(textField.text!)!
                }
            }
            // TODO:この画面に遷移する
            // 大テーブルをセット
            self.squareTablePositionSet()
            
            

            
        })
        
        alert.addAction(defaultAction)
        
        // ステッパーの設置は一旦諦めて次に進もう。。
//        alert.view.addSubview(createStepper())
        
        alert.addTextField(configurationHandler: {(text:UITextField!) -> Void in
            text.placeholder = "人数を入力してください"
            text.text = "\(self.personNum)"

            let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            label.text = "人数"
            text.leftView = label
            text.leftViewMode = UITextFieldViewMode.always
        })
        
        
        
        present(alert, animated: true, completion: nil)
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
                                         height: self.view.frame.height / 2
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
        
        switch self.personNum {
        case 4:
            // 上下左右。下が自分。
            innerTableList = innerTablePisitioning(positionList: [15,7,2,10], outerRect: outerRect)
            break
        case 5:
            // 斜め全部と下。下が自分。
            innerTableList = innerTablePisitioning(positionList: [15,7,2,10], outerRect: outerRect)
            break
        default:
            break
        }
        
        var cnt = 0
        for innerTableRect in innerTableList {
            let innerTable = UIView.init(frame: innerTableRect)
            switch cnt{
            case 0:
                innerTable.backgroundColor = UIColor.blue
                break
            case 1:
                innerTable.backgroundColor = UIColor.red
                break
            case 2:
                innerTable.backgroundColor = UIColor.yellow
                break
            case 3:
                innerTable.backgroundColor = UIColor.green
                break
            default:
                break
            }
            self.view.addSubview(innerTable)
            
            cnt = cnt + 1
        }
        
    }
    
    /**
     * 内部テーブルのポジショニング指定
     */
    func innerTablePisitioning(positionList: [Int], outerRect: CGRect) -> [CGRect] {
        let innerTableSize = CGSize(width: outerRect.width / 7, height: outerRect.height / 6)
        var innerTableList: Array<CGRect> = Array(repeating: CGRect.zero, count: self.personNum)
        
        /*
            1  2  3  4  5  6  7
            8                12
            9                13
           10                14
           11                15
           16 17 18 19 20 21 22
         
        */
        
        var innerCount = 0
        for position in positionList {
            var xPosition = outerRect.minX
            var yPosition = outerRect.minY
            let minusCoefficient = CGFloat(position % 4)
            
            switch position {
            case (1...4):
                xPosition += innerTableSize.width * minusCoefficient
                break

            case (5...8):
                yPosition += innerTableSize.height * minusCoefficient
                break

            case (9...12):
                xPosition += outerRect.width - innerTableSize.width
                yPosition += innerTableSize.height * minusCoefficient
                break

            case (13...16):
                xPosition += innerTableSize.width * minusCoefficient
                yPosition += outerRect.height - innerTableSize.height

                break
                
            default:
                break
            }
            
            innerTableList[innerCount] = CGRect.init(
                    x: xPosition, y: yPosition, width: innerTableSize.width, height: innerTableSize.height
            )
            innerCount = innerCount + 1
        }
        
        return innerTableList
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


