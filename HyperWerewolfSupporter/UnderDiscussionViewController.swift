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
    
    @IBOutlet weak var timeStartButton: UIButton!
    @IBOutlet weak var timeStopButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var timerStepper: UIStepper!
    
    var timer = Timer()
    var timerDisplay : Int = 0
    var timerGoing = false
    var startTime: TimeInterval = 0     // Startボタンを押した時刻
    var elapsedTime: Double = 0.0       // Stopボタンを押した時点で経過していた時間
    var time : Double = 0.0             // ラベルに表示する時間
    
    @IBOutlet weak var calendar: UIImageView!
    @IBOutlet weak var calendarStepper: UIStepper!
    
    @IBOutlet weak var resultTable: UIScrollView!
    
    @IBOutlet weak var resultContentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.personNum)
        print(self.personList)
        self.squareTablePositionSet()
        
        // 暫定用に何か時間を
        self.timerInitSetting()
        self.createResultTable()
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
     * タイマーの初期設定
     */
    func timerInitSetting() {
        // 暫定04:00にする。(0埋めはしておこう。)
        // 後で人数に合わせよう。
        timerStepper.value = 240
        self.timeDisplay()
    }
    
    
    /**
     * タイマーの表示
     */
    func timeDisplay() {
        timerLabel.text = NSString(format: "%02d:%02d",
                                   Int(self.timerStepper.value)/60,
                                   Int(self.timerStepper.value)%60) as String
    }
    
    /**
     * スタートボタン or 一時停止ボタンが押された時
     */
    @IBAction func tapStart(_ sender: Any) {
        // 0秒なら返す
        if(self.timerStepper.value == 0) { return }
//         状態切り替え
        self.timerGoing = !self.timerGoing
        let timerButton = (sender as! UIButton)
        
        if self.timerGoing {
            // 画像切り替え
            timerButton.setImage(UIImage(named: "time_pause"), for: .normal)
            startTime = Date().timeIntervalSince1970
            // 1秒おきに関数「update」を呼び出す
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        } else {
            timerButton.setImage(UIImage(named: "time_start"), for: .normal)
            timer.invalidate()
        }
        
    }
    // 1秒ごとに呼び出される処理
    @objc func update() {
        self.timerStepper.value -= 1
        // 「ss:mm」形式でラベルに表示する
        self.timeDisplay()
        
        // ステッパーの管理条件はまた今度。。。
//        if(Int(self.timerStepper.value) % 30 == 0) {
//            self.timerStepper.stepValue += Double(Int(self.timerStepper.value) % 30);
//        } else {
//            self.timerStepper.stepValue = 30
//        }
        // 0秒になったら全て止める。
        if(self.timerStepper.value == 0) {
            self.timerStop()
        }
    }
    
    
    
    @IBAction func tapStop(_ sender: Any) {
        self.timerStop()
        self.timeDisplay()
    }
    
    @IBAction func onStepperChange(_ sender: Any) {
        if self.timerStepper.stepValue == 0 {
            self.timerStop()
        }
        self.timeDisplay()
//        self.timerStepper.stepValue = 30
    }
    
    func timerStop () {
        if self.timerGoing {
            self.timeStartButton.setImage(UIImage(named: "time_start"), for: .normal)
        }
        self.timerGoing = false
        timer.invalidate()
        self.timerStepper.value = 0
    }
    
    @IBAction func calendarChange(_ sender: Any) {
        self.calendar.image = UIImage(named: "days_" + String(Int(self.calendarStepper.value)))
    }
    
    func createResultTable() {
        let fLength = 29
        let fLength2 = fLength * 2
        
        for row in 0..<3 {
            let titleTableFrame = UIView.init(frame: CGRect.init(x: 0, y: 0, width: fLength, height: fLength))
            self.resultTable.addSubview(createBorder(v: titleTableFrame))
            // 制約を制定
            constraintsInit(v: titleTableFrame)
            titleTableFrame.leadingAnchor.constraint(equalTo: self.resultTable.leadingAnchor, constant: 0).isActive = true
            titleTableFrame.topAnchor.constraint(equalTo: self.resultTable.topAnchor, constant: CGFloat(row * fLength)).isActive = true
            
            var labelText = ""
            switch row {
            case 1:
                labelText = "吊"
                break;
            case 2:
                labelText = "噛"
                break;
            default:
                break;
            }
            // 結果テーブルにラベルの追加
            titleTableFrame.addSubview(createLabel(txt: labelText, v: titleTableFrame))
            
            for column in 0..<15 {
                let longTableFrame = UIView.init(frame: CGRect.init(x: 0, y: 0, width: fLength2, height: fLength))
                self.resultTable.addSubview(createBorder(v: longTableFrame))
                
                // 制約を制定
                constraintsInit(v: longTableFrame)
                longTableFrame.leadingAnchor.constraint(equalTo: self.resultTable.leadingAnchor, constant: CGFloat(column * fLength2 + fLength)).isActive = true
                longTableFrame.topAnchor.constraint(equalTo: self.resultTable.topAnchor, constant: CGFloat(row * fLength)).isActive = true
                
                // ヘッダーラベルの制定
                if (row == 0) {
                    longTableFrame.addSubview(createLabel(txt: String(column + 1) + "日目", v: longTableFrame))
                }
            }
        }
        
        createFortuneResult(row: 3, fLength: fLength, name: "占", target: "対象", result: "結果")
        
    }
    
    func createFortuneResult(row: Int, fLength: Int, name: String, target: String, result: String) {
        for column in 0..<31 {
            let tableFrame = UIView.init(frame: CGRect.init(x: 0, y: 0, width: fLength, height: fLength))
            self.resultTable.addSubview(createBorder(v: tableFrame))
            
            // 制約を制定
            constraintsInit(v: tableFrame)
            tableFrame.leadingAnchor.constraint(equalTo: self.resultTable.leadingAnchor, constant: CGFloat(column * fLength)).isActive = true
            tableFrame.topAnchor.constraint(equalTo: self.resultTable.topAnchor, constant: CGFloat(row * fLength)).isActive = true
            
            // ラベルの追加
            tableFrame.addSubview(createLabel(txt: (column == 0) ? "占" : (column % 2 != 0) ? target : result, v: tableFrame))
        }
    }
    
    
    
    func createBorder(v: UIView) -> UIView {
        //上下左のCALayerを作成
        let rectArray = [
//            CGRect(x: 0, y: 0, width: v.frame.width, height: 1.0),
            CGRect(x: 0, y: 0, width: 1.0, height:v.frame.height),
            CGRect(x: 0, y: v.frame.height, width: v.frame.width, height:-1.0),
//            CGRect(x: v.frame.width, y: 0, width: -1.0, height:v.frame.height)
        ]
        
        for idx in 0..<rectArray.count {
            let border = CALayer()
            border.frame = rectArray[idx]
            border.backgroundColor = UIColor.black.cgColor
            v.layer.addSublayer(border)
        }
        return v
    }
    
    func constraintsInit(v: UIView) {
        v.translatesAutoresizingMaskIntoConstraints = false
        v.widthAnchor.constraint(equalTo: self.resultTable.widthAnchor, constant: v.frame.size.width).isActive = true
        v.heightAnchor.constraint(equalTo: self.resultTable.heightAnchor, constant: v.frame.size.height).isActive = true
    }
    
    func createLabel(txt: String, v:UIView) -> UILabel {
        let resultLabel = UILabel(frame:CGRect(x:0,y:0,width:v.frame.size.width,height:v.frame.size.height))
        resultLabel.text = txt
        resultLabel.textColor = UIColor.black
        resultLabel.textAlignment = NSTextAlignment.center
        resultLabel.adjustsFontSizeToFitWidth = true
        resultLabel.isUserInteractionEnabled = false
        return resultLabel
    }
    
    
}
