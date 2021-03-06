//
//  InitialisePlayerPositionViewController.swift
//  HyperWerewolfSupporter
//
//  Created by Ichiro Miura on 2018/06/30.
//  Copyright © 2018年 mycompany. All rights reserved.
//

import UIKit

class InitialisePlayerPositionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIDragInteractionDelegate, UIDropInteractionDelegate {
    
    var personNum = 10
    let userDefaults = UserDefaults.standard
    var personList: Array<[String:String]> = []
    @IBOutlet weak var outerTable: UIView!
    @IBOutlet weak var memberList: UITableView!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    var memberLabelList: [UILabel] = []
    var checkMarks: [Bool] = []
    var checkTrueList: [Int] = []
    
    var innerTableList: [UIView] = []
    var innerTableRectList: [CGRect] = []
    
    var dragIdx = 0
    var dropIdx = 0
    
    var hasYourSelf = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ユーザ情報を取得
        if let loadData = userDefaults.object(forKey: "person") {
            personList = loadData as! Array<[String:String]>
            personList.sort(by: {$0["name"]! < $1["name"]!})
        }
        
        // ユーザがいなければ、トップ画面に戻す
        if (personList.count == 0) {
            // 注意文言アラート
            let warningAlert: UIAlertController = UIAlertController(title: "人物が未登録です", message: "まずは人物リストから人物を1人以上登録してください", preferredStyle:  UIAlertController.Style.alert)
            
            // キャンセルボタン
            let warningCancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.default, handler:{
                action in
                self.navigationController!.popViewController(animated: true)
                
            })
            warningAlert.addAction(warningCancelAction)
            self.present(warningAlert, animated: true, completion: nil)
        } else {
            for idx in 0..<personList.count {
                if (self.personList[idx]["yourself"] != nil) {
                    self.hasYourSelf = true
                    break
                }
            }
            if (!self.hasYourSelf) {
                // 注意文言アラート
                let warningAlert: UIAlertController = UIAlertController(title: "「あなた」が未登録です", message: "自分の名前を長押しし、本人登録を行ってください", preferredStyle:  UIAlertController.Style.alert)
                
                // キャンセルボタン
                let warningCancelAction: UIAlertAction = UIAlertAction(title: "確認", style: UIAlertAction.Style.default, handler:{
                    action in
                    self.navigationController!.popViewController(animated: true)
                    
                })
                warningAlert.addAction(warningCancelAction)
                self.present(warningAlert, animated: true, completion: nil)
                
            } else {
                
                self.checkMarks = [Bool](repeating: false, count: personList.count)
                self.checkMarks[0] = true
                self.checkTrueList.append(0)
                
                memberList.dataSource = self
                memberList.delegate = self
                
                // アラートをセット
                initSetAlert()
            }
        }
    }
    
    
    
    /**
      * アラートの設定
      */
    func initSetAlert () {
        // アラートの初期設定
        let alert: UIAlertController = UIAlertController(title: "人数を入力してください", message: "4〜16までの数値", preferredStyle:  UIAlertController.Style.alert)

        // キャンセルボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
            action in
            self.navigationController!.popViewController(animated: true)
        })
        
        alert.addAction(cancelAction)

        // OKボタンの処理
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            action in
            
            var success = false
            // 値の受け取り
            let textFields:Array<UITextField>? = alert.textFields as Array<UITextField>?
            if (textFields != nil) {
                for textField:UITextField in textFields! {
                    if (self.isOnlyNumber(textField.text!)) {
                        if (4 <= Int(textField.text!)! && Int(textField.text!)! <= 16) {
                            // 初期人数
                            self.personNum = Int(textField.text!)!
                            success = true
                        } else {
                            // 注意文言アラート
                            let warningAlert: UIAlertController = UIAlertController(title: "", message: "人数は4人〜16人の間で入力してください", preferredStyle:  UIAlertController.Style.alert)
                            // キャンセルボタン
                            let warningCancelAction: UIAlertAction = UIAlertAction(title: "はい", style: UIAlertAction.Style.default, handler:{
                                action in
                                self.navigationController!.popViewController(animated: true)
                            })
                            warningAlert.addAction(warningCancelAction)
                            self.present(warningAlert, animated: true, completion: nil)
                        }
                    } else {
                        // 注意文言アラート
                        let warningAlert: UIAlertController = UIAlertController(title: "", message: "人数は数値で入力してください", preferredStyle:  UIAlertController.Style.alert)
                        // キャンセルボタン
                        let warningCancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.default, handler:{
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
                self.memberList.reloadData()
                self.squareTablePositionSet()
            }
        })
        
        alert.addAction(defaultAction)
        
        // ステッパーの設置は一旦諦めて次に進もう。。
//        alert.view.addSubview(createStepper())
        
        alert.addTextField(configurationHandler: {(text:UITextField!) -> Void in
//            text.placeholder = "\(self.personNum)"
            text.keyboardType = UIKeyboardType.numberPad

            let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            label.text = "人数"
            text.leftView = label
            text.leftViewMode = UITextField.ViewMode.always
            
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
        
        self.innerTableRectList = innerTablePisitioning(positionCount: self.personNum, outerRect: outerTable.frame)
        
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
        
        self.memberLabelList = [UILabel](repeating: UILabel(frame:.zero), count: personNum)
        
        
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
            
            // 小テーブルにラベルの追加
            self.memberLabelList[cnt] = UILabel(frame:CGRect(x:0,y:0,width:innerTableRect.width,height:innerTableRect.height))
            
            let dragDelegate: UIDragInteractionDelegate = self
            let dragInteraction = UIDragInteraction(delegate: dragDelegate)
            dragInteraction.isEnabled = true    // iPhoneの場合はデフォルトがfalseになっている
            innerTable.addInteraction(dragInteraction)
            self.innerTableList.append(innerTable)
            
            let dropDelegate: UIDropInteractionDelegate = self
            let dropInteraction = UIDropInteraction(delegate: dropDelegate)
            innerTable.addInteraction(dropInteraction)
            
            self.memberLabelList[cnt].text = (cnt == 0) ? personList[cnt]["name"] : ""
            self.memberLabelList[cnt].textColor = UIColor.black
            self.memberLabelList[cnt].textAlignment = NSTextAlignment.center
            self.memberLabelList[cnt].adjustsFontSizeToFitWidth = true
            self.memberLabelList[cnt].isUserInteractionEnabled = (cnt != 0)
            
            innerTable.addSubview(self.memberLabelList[cnt])
            
            cnt += 1
        }
        
    }
    
    /**
     * 内部テーブルのポジショニング指定
     */
    func innerTablePisitioning(positionCount: Int, outerRect: CGRect) -> [CGRect] {
        let innerTableSize = CGSize(width: outerRect.width / 7, height: outerRect.height / 6)
        var innerTableList: Array<CGRect> = Array(repeating: CGRect.zero, count: self.personNum)

        // iOS11以降かどうかで分岐する
        let insets: UIEdgeInsets
        if #available(iOS 11, *) {
            insets = view.safeAreaInsets
        } else {
            insets = .zero
        }
        
        let leftX = outerRect.minX + insets.left
        let rightX = outerRect.maxX - innerTableSize.width + insets.left
        
        let overY = outerRect.minY + insets.top
        let underY = outerRect.maxY - innerTableSize.height + insets.top
        

        
        let margin3x = outerRect.width / 3
        let x3_1 = leftX + margin3x - innerTableSize.width / 2
        let x3_2 = x3_1 + margin3x
        
        let margin3y = outerRect.height / 3
        let y3_1 = underY - margin3y + innerTableSize.height / 2
        let y3_2 = y3_1 - margin3y
        
        let margin5y = innerTableSize.height * 1.25
        let y5_1 = underY - margin5y
        let y5_2 = y5_1 - margin5y
        let y5_3 = y5_2 - margin5y
        
        let margin6x = innerTableSize.width * 1.2
        let x6_1 = outerRect.minX + margin6x + insets.left
        let x6_2 = x6_1 + margin6x
        let x6_3 = x6_2 + margin6x
        let x6_4 = x6_3 + margin6x
        
        let centerX = (outerRect.maxX + outerRect.minX - innerTableSize.width) / 2 + insets.left
        let centerY = (outerRect.height) / 2 - (innerTableSize.height / 2) + overY
        
        let initXPosition = outerRect.maxX - ((outerRect.width + innerTableSize.width) / 2) + insets.left
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
            
            switch positionCount {
            case 4:
                switch pos {
                case 1: xPosition = leftX;          yPosition = centerY; break
                case 2: xPosition = centerX;        yPosition = overY; break
                case 3: xPosition = rightX;         yPosition = centerY; break
                default:break
                }
                break
                
            case 5:
                switch pos {
                case 1: xPosition = leftX;          yPosition = centerY; break
                case 2: xPosition = leftX;          yPosition = overY; break
                case 3: xPosition = rightX;         yPosition = overY; break
                case 4: xPosition = rightX;         yPosition = centerY; break
                default:break
                }
                break
            case 6:
                switch pos {
                case 1: xPosition = leftX;          yPosition = underY; break
                case 2: xPosition = leftX;          yPosition = overY; break
                case 3: xPosition = centerX;        yPosition = overY; break
                case 4: xPosition = rightX;         yPosition = overY; break
                case 5: xPosition = rightX;         yPosition = underY; break
                default:break
                }
                break
            case 7:
                switch pos {
                case 1: xPosition = leftX;          yPosition = y3_1; break
                case 2: xPosition = leftX;          yPosition = y3_2; break
                case 3: xPosition = x3_1;           yPosition = overY; break
                case 4: xPosition = x3_2;           yPosition = overY; break
                case 5: xPosition = rightX;         yPosition = y3_2; break
                case 6: xPosition = rightX;         yPosition = y3_1; break
                default:break
                }
                break
            case 8:
                switch pos {
                case 1: xPosition = leftX;          yPosition = underY; break
                case 2: xPosition = leftX;          yPosition = centerY; break
                case 3: xPosition = leftX;          yPosition = overY; break
                case 4: xPosition = centerX;        yPosition = overY; break
                case 5: xPosition = rightX;         yPosition = overY; break
                case 6: xPosition = rightX;         yPosition = centerY; break
                case 7: xPosition = rightX;         yPosition = underY; break
                default:break
                }
                break
            case 9:
                switch pos {
                case 1: xPosition = x3_1;           yPosition = underY; break
                case 2: xPosition = leftX;          yPosition = y3_1; break
                case 3: xPosition = leftX;          yPosition = y3_2; break
                case 4: xPosition = x3_1;           yPosition = overY; break
                case 5: xPosition = x3_2;           yPosition = overY; break
                case 6: xPosition = rightX;         yPosition = y3_2; break
                case 7: xPosition = rightX;         yPosition = y3_1; break
                case 8: xPosition = x3_2;           yPosition = underY; break
                default:break
                }
                break
            case 10:
                switch pos {
                case 1: xPosition = x3_1;           yPosition = underY; break
                case 2: xPosition = leftX;          yPosition = y3_1; break
                case 3: xPosition = leftX;          yPosition = y3_2; break
                case 4: xPosition = x3_1;           yPosition = overY; break
                case 5: xPosition = centerX;        yPosition = overY; break
                case 6: xPosition = x3_2;           yPosition = overY; break
                case 7: xPosition = rightX;         yPosition = y3_2; break
                case 8: xPosition = rightX;         yPosition = y3_1; break
                case 9: xPosition = x3_2;           yPosition = underY; break
                default:break
                }
                break
            case 11:
                switch pos {
                case 1: xPosition = x3_1;           yPosition = underY; break
                case 2: xPosition = leftX;          yPosition = underY; break
                case 3: xPosition = leftX;          yPosition = centerY; break
                case 4: xPosition = leftX;          yPosition = overY; break
                case 5: xPosition = x3_1;           yPosition = overY; break
                case 6: xPosition = x3_2;           yPosition = overY; break
                case 7: xPosition = rightX;         yPosition = overY; break
                case 8: xPosition = rightX;         yPosition = centerY; break
                case 9: xPosition = rightX;         yPosition = underY; break
                case 10: xPosition = x3_2;          yPosition = underY; break
                default:break
                }
                break
            case 12:
                switch pos {
                case 1: xPosition = x3_1;           yPosition = underY; break
                case 2: xPosition = leftX;          yPosition = underY; break
                case 3: xPosition = leftX;          yPosition = centerY; break
                case 4: xPosition = leftX;          yPosition = overY; break
                case 5: xPosition = x3_1;           yPosition = overY; break
                case 6: xPosition = centerX;        yPosition = overY; break
                case 7: xPosition = x3_2;           yPosition = overY; break
                case 8: xPosition = rightX;         yPosition = overY; break
                case 9: xPosition = rightX;         yPosition = centerY; break
                case 10: xPosition = rightX;        yPosition = underY; break
                case 11: xPosition = x3_2;          yPosition = underY; break
                default:break
                }
                break
            case 13:
                switch pos {
                case 1: xPosition = x3_1;           yPosition = underY; break
                case 2: xPosition = leftX;          yPosition = underY; break
                case 3: xPosition = leftX;          yPosition = y3_1; break
                case 4: xPosition = leftX;          yPosition = y3_2; break
                case 5: xPosition = leftX;          yPosition = overY; break
                case 6: xPosition = x3_1;           yPosition = overY; break
                case 7: xPosition = x3_2;           yPosition = overY; break
                case 8: xPosition = rightX;         yPosition = overY; break
                case 9: xPosition = rightX;         yPosition = y3_2; break
                case 10: xPosition = rightX;        yPosition = y3_1; break
                case 11: xPosition = rightX;        yPosition = underY; break
                case 12: xPosition = x3_2;          yPosition = underY; break
                default:break
                }
                break
            case 14:
                switch pos {
                case 1: xPosition = x3_1;           yPosition = underY; break
                case 2: xPosition = leftX;          yPosition = underY; break
                case 3: xPosition = leftX;          yPosition = y3_1; break
                case 4: xPosition = leftX;          yPosition = y3_2; break
                case 5: xPosition = leftX;          yPosition = overY; break
                case 6: xPosition = x3_1;           yPosition = overY; break
                case 7: xPosition = centerX;        yPosition = overY; break
                case 8: xPosition = x3_2;           yPosition = overY; break
                case 9: xPosition = rightX;         yPosition = overY; break
                case 10: xPosition = rightX;        yPosition = y3_2; break
                case 11: xPosition = rightX;        yPosition = y3_1; break
                case 12: xPosition = rightX;        yPosition = underY; break
                case 13: xPosition = x3_2;          yPosition = underY; break
                default:break
                }
                break
            case 15:
                switch pos {
                case 1: xPosition = x3_1;           yPosition = underY; break
                case 2: xPosition = leftX;          yPosition = underY; break
                case 3: xPosition = leftX;          yPosition = y3_1; break
                case 4: xPosition = leftX;          yPosition = y3_2; break
                case 5: xPosition = leftX;          yPosition = overY; break
                case 6: xPosition = x6_1;           yPosition = overY; break
                case 7: xPosition = x6_2;           yPosition = overY; break
                case 8: xPosition = x6_3;           yPosition = overY; break
                case 9: xPosition = x6_4;           yPosition = overY; break
                case 10: xPosition = rightX;        yPosition = overY; break
                case 11: xPosition = rightX;        yPosition = y3_2; break
                case 12: xPosition = rightX;        yPosition = y3_1; break
                case 13: xPosition = rightX;        yPosition = underY; break
                case 14: xPosition = x3_2;          yPosition = underY; break
                default:break
                }
                break
            case 16:
                switch pos {
                case 1: xPosition = x3_1;           yPosition = underY; break
                case 2: xPosition = leftX;          yPosition = underY; break
                case 3: xPosition = leftX;          yPosition = y5_1; break
                case 4: xPosition = leftX;          yPosition = centerY; break
                case 5: xPosition = leftX;          yPosition = y5_3; break
                case 6: xPosition = leftX;          yPosition = overY; break
                case 7: xPosition = x3_1;           yPosition = overY; break
                case 8: xPosition = centerX;        yPosition = overY; break
                case 9: xPosition = x3_2;           yPosition = overY; break
                case 10: xPosition = rightX;        yPosition = overY; break
                case 11: xPosition = rightX;        yPosition = y5_3; break
                case 12: xPosition = rightX;        yPosition = centerY; break
                case 13: xPosition = rightX;        yPosition = y5_1; break
                case 14: xPosition = rightX;        yPosition = underY; break
                case 15: xPosition = x3_2;          yPosition = underY; break
                default:break
                }
                break
            case 17:
                break
            case 18:
                break
            case 19:
                break
            case 20:
                break
                
                
            default:break
                
                
            }
            
            
            
            innerTableList[pos] = CGRect.init(
                x: xPosition, y: yPosition, width: innerTableSize.width, height: innerTableSize.height
            )
        }
        
        
        
        return innerTableList
    }
    
    
    
    
    
    /*
     Cellの総数を返す
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return personList.count
    }
    
    /*
     Cellに値を設定する
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "memberCell", for: indexPath as IndexPath)
        if (self.hasYourSelf) {
            // Cellに値を設定.
            var targetPerson = 0
            
            for _ in 0..<personList.count {
                if (self.personList[targetPerson]["yourself"] != nil) {
                    break
                }
                targetPerson += 1
            }
            self.personList.insert(self.personList[targetPerson], at:0)
            self.personList.remove(at: targetPerson + 1)
            cell.textLabel!.text = (indexPath.row < personList.count) ? personList[indexPath.row]["name"] : "モブ"
            cell.accessoryType = (self.checkMarks[indexPath.row]) ? .checkmark :.none
        }
        return cell
    }
    
    /*
     Cellがタップされた時
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
            let isAdd = !self.checkMarks[indexPath.row]
            // チェックをつける際
            if (self.personList[indexPath.row]["yourself"] == nil) {

                if (isAdd) {
                    // 人数オーバーしていたら何もしない
                    if (self.checkTrueList.count >= personNum) {
                        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
                        return
                    } else {
                        cell.accessoryType = .checkmark
                        self.checkTrueList.append(indexPath.row)
                    }
                } else {
                    cell.accessoryType = .none
                    var findList = 0
                    for list in 0..<self.checkTrueList.count {
                        if (self.checkTrueList[list] == indexPath.row) {
                            findList = list
                            break
                        }
                    }
                    self.checkTrueList.remove(at: findList)
                }
                
                self.checkMarks[indexPath.row] = !self.checkMarks[indexPath.row]
                
                for person in 0..<personNum {
                    self.memberLabelList[person].text = (person < self.checkTrueList.count) ?  self.personList[self.checkTrueList[person]]["name"] : ""
                }
            }
        }
        // チェックが揃っていれば次へボタンの有効化
        self.nextButton.isEnabled = self.checkTrueList.count == self.personNum
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    
    @IBAction func memberAdd(_ sender: Any) {
        let alertTitle:String = "人物の登録を行います。"
        let alertMsg:String = "登録したい人の名前を入力してください。"
        
        // アラートの初期設定
        let alert: UIAlertController = UIAlertController(title: alertTitle, message: alertMsg, preferredStyle:  UIAlertController.Style.alert)
        
        // OKボタンの処理
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            action in
            let textFields:Array<UITextField>? = alert.textFields as Array<UITextField>?
            
            if (textFields != nil) {
                for textField:UITextField in textFields! {
                    // テーブルの追加
                    var personDict = [String:String]()
                    personDict["name"] = textField.text!
                    self.personList.append(personDict)
                }
                // userDefaultsに追加
                self.userDefaults.set(self.personList, forKey: "person")
                self.userDefaults.synchronize()
            }
            self.checkMarks.append(false)
            // TableViewを再読み込み
            self.memberList.reloadData()
        })
        alert.addAction(UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel))
        alert.addAction(defaultAction)
            
        // テキストフィールドの設置
        alert.addTextField(configurationHandler: {(text:UITextField!) -> Void in
            text.placeholder = "入力してください"
            let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            label.text = "人物名"
            text.leftView = label
            text.leftViewMode = UITextField.ViewMode.always
        })
            
        present(alert, animated: true, completion: nil)
        
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        
        for idx in 1..<self.innerTableList.count {
            // ドラッグされた位置を取得します
            let points = session.location(in: self.innerTableList[idx])
            // ドラッグされた位置にラベルがあれば、そのラベルの文字列をドラッグします。
            // Note: UILabelをhitTestで見つけるためには、ラベルのuserInteractionEnabledを
            // trueにしておく必要があります。
            if let hitView = self.innerTableList[idx].hitTest(points, with: nil) {
                if let label = hitView as? UILabel {
                    let text = (label.text ?? "") as NSString
                    let dragItem = UIDragItem(itemProvider: NSItemProvider(object: text))
                    dragItem.localObject = label  // ドラッグ対象を紐付けておく
                    self.dragIdx = idx
                    return [dragItem]
                }
            }
        }

        // ドラッグ位置にラベルがなければドラッグ可能ではありません。
        return []
    }
    
    func dropInteraction(_ interaction: UIDropInteraction,
                         sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        // 自分以外は .forbidden を返します。
        guard self.innerTableList[0] != self.innerTableList[0].hitTest(
            session.location(in: self.innerTableList[0]), with: nil) else {
            return UIDropProposal(operation: .forbidden)
        }
        
        // 現在の位置を取得
        let currentPoint = session.location(in: self.view)
        
        // ドロップ先のinnerTableを取得
        for idx in 1..<self.innerTableList.count {
            if (self.innerTableList[idx].frame.minX <= currentPoint.x && currentPoint.x <= self.innerTableList[idx].frame.maxX &&
                self.innerTableList[idx].frame.minY <= currentPoint.y && currentPoint.y <= self.innerTableList[idx].frame.maxY) {
                self.dropIdx = idx
                // 同一人物ならforbidden
                if (self.dragIdx == self.dropIdx) { return UIDropProposal(operation: .forbidden) }
                break
            }
        }
        
        // ドラッグ中のアイテムが文字列を含んでいる場合はドロップできます。
        return (session.canLoadObjects(ofClass: NSString.self)) ? UIDropProposal(operation: .copy) :  UIDropProposal(operation: .cancel)
    }
    
    /*
     * ドロップできないものをさっさと弾く
     */
    func dropInteraction(_ interaction: UIDropInteraction,
                         canHandle session: UIDropSession) -> Bool {
        // 文字列を取り出せるものしかドロップできない
        return session.canLoadObjects(ofClass: NSString.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction,
                         performDrop session: UIDropSession) {
        for item in session.items {
            // 文字列をロードできないアイテムはスキップします
            if item.itemProvider.canLoadObject(ofClass: NSString.self) {
                item.itemProvider.loadObject(ofClass: NSString.self) { (object, error) in
                    // アイテムのロードは非同期に行われます
                    // ロードが終わるとここにやってきます
                    if let string = object as? NSString {
                        // UIへの反映はメインスレッドで行います
                        DispatchQueue.main.async {
                            // ラベルの入れ替え
                            let tmp = self.memberLabelList[self.dropIdx].text
                            self.memberLabelList[self.dropIdx].text = string as String
                            self.memberLabelList[self.dragIdx].text = tmp
                        }
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     次へボタンが押された際に呼び出される(Segueへ)
     */
    @IBAction func onClickNextButton(_ sender: Any) {
        performSegue(withIdentifier: "underDiscussion",sender: nil)
    }
    
    /*
     segue 準備
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "underDiscussion") {
            let under: UnderDiscussionViewController = (segue.destination as? UnderDiscussionViewController)!
            // 次のビューに値渡し
            under.personNum = self.personNum
            under.personList = self.personList
            under.outerTable = self.outerTable
            under.memberLabelList = self.memberLabelList
            under.innerTableRectList =  self.innerTableRectList
        }
    }
    
    
}
