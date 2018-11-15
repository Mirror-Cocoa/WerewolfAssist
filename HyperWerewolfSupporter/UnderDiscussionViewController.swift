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
    @IBOutlet weak var adjustView: UIView!
    
    @IBOutlet weak var iconView: UIView!
    
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
    
    enum Mode {
        case fortune, hunter, sharer, madman, werewolf, spirit, none
    }
    var currentMode: Mode  = .none
    
    var hasMemberIcon: [Int] = []
    
    let fortuneArray = ["COのみ", "白判定", "黒判定", "溶かした", "CO撤回"]
    let spiritArray = ["COのみ", "白判定", "黒判定", "CO撤回"]
    let hunterArray = ["CO", "CO撤回"]
    let sharerArray = ["CO", "CO撤回"]
    let werewolfArray = ["疑惑", "CO", "CO撤回", "LWCO"]
    let madmanArray = ["疑惑"]
    
    
    @IBOutlet weak var calendar: UIImageView!
    @IBOutlet weak var calendarStepper: UIStepper!
    
    @IBOutlet weak var resultTable: UIScrollView!
    
    @IBOutlet weak var resultContentView: UIView!
    
    @IBOutlet weak var fortuneView: UIView!
    @IBOutlet weak var hunterView: UIView!
    @IBOutlet weak var sharerView: UIView!
    @IBOutlet weak var madmanView: UIView!
    @IBOutlet weak var werewolfView: UIView!
    @IBOutlet weak var spiritView: UIView!
    
    @IBOutlet weak var currentView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.personNum)
        print(self.personList)
        self.squareTablePositionSet()
        
        // 暫定用に何か時間を
        self.timerInitSetting()
        self.createResultTable()
        
        self.fortuneView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconTapped(sender:))))
        self.hunterView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconTapped(sender:))))
        self.sharerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconTapped(sender:))))
        self.madmanView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconTapped(sender:))))
        self.werewolfView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconTapped(sender:))))
        self.spiritView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconTapped(sender:))))
        
//        self.descriptionLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(descTapped(sender:))))
        descriptionLabel.adjustsFontSizeToFitWidth = true
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
            
            innerTable.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tableTapped(sender:))))
            
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
        createFortuneResult(row: 4, fLength: fLength, name: "霊", target: "対象", result: "結果")
        
    }
    
    func createFortuneResult(row: Int, fLength: Int, name: String, target: String, result: String) {
        for column in 0..<31 {
            let tableFrame = UIView.init(frame: CGRect.init(x: 0, y: 0, width: fLength, height: fLength))
            self.resultTable.addSubview(createBorder(v: tableFrame))
            
            // 制約を制定
            constraintsInit(v: tableFrame)
            tableFrame.leadingAnchor.constraint(equalTo: self.resultTable.leadingAnchor, constant: CGFloat(column * fLength)).isActive = true
            tableFrame.topAnchor.constraint(equalTo: self.resultTable.topAnchor, constant: CGFloat(row * fLength)).isActive = true
//            self.resultContentView.heightAnchor.constraint(equalToConstant: CGFloat(row * fLength + fLength))
            self.resultContentView.frame.size.height += CGFloat(row * fLength + fLength)
            
            // ラベルの追加
            tableFrame.addSubview(createLabel(txt: (column == 0) ? name : (column % 2 != 0) ? target : result, v: tableFrame))
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
    
    /*
     * アイコンが押されたら
     */
    @objc func iconTapped(sender: UITapGestureRecognizer) {
        print(sender.view!)
        if let currentV = sender.view {
            // 画像のコピー
            // ビットマップ画像のcontextを作成.
            UIGraphicsBeginImageContextWithOptions(currentV.bounds.size, false, 0.0)
            // 対象のview内の描画をcontextに複写する.
            currentV.layer.render(in: UIGraphicsGetCurrentContext()!)
            // 現在のcontextのビットマップをUIImageとして取得.
            self.currentView.image = UIGraphicsGetImageFromCurrentImageContext()!
            // contextを閉じる.
            UIGraphicsEndImageContext()
            // 縦横比率を保ちつつ画像をUIImageViewの大きさに合わせる.
            self.currentView.contentMode = UIViewContentMode.scaleAspectFit
            
            // ラベルの設定
            if currentV.frame.minY == self.iconView.frame.minY {
                self.currentMode = .fortune
                self.descriptionLabel.text = self.fortuneArray[0]
            }
            
            if currentV.frame.maxY == self.iconView.frame.maxY {
                let viewWidth = CGFloat(39)
                let calcWidth = CGFloat(currentV.frame.origin.x / viewWidth)
                switch calcWidth {
                case 0:
                    self.currentMode = .spirit
                    self.descriptionLabel.text = self.spiritArray[0]
                    break
                case 1:
                    self.currentMode = .hunter
                    self.descriptionLabel.text = self.hunterArray[0]
                    break
                case 2:
                    self.currentMode = .sharer
                    self.descriptionLabel.text = self.sharerArray[0]
                    break
                case 3:
                    self.currentMode = .madman
                    self.descriptionLabel.text = self.madmanArray[0]
                    break
                case 4:
                    self.currentMode = .werewolf
                    self.descriptionLabel.text = self.werewolfArray[0]
                    break
                default:
                    self.currentMode = .none
                    break
                }
            }
            self.currentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(descTapped(sender:))))
            self.descriptionLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(descTapped(sender:))))
        }
    }
    
    /*
     * 説明ラベルが押されたら
     */
    @objc func descTapped(sender: UITapGestureRecognizer) {
        print(self.currentMode)
        var descModeArray: [String] = []
        
        switch self.currentMode {
            case .fortune:
                descModeArray = self.fortuneArray
                break
            case .hunter:
                descModeArray = self.hunterArray
                break
            case .sharer:
                descModeArray = self.sharerArray
                break
            case .madman:
                descModeArray = self.madmanArray
                break
            case .werewolf:
                descModeArray = self.werewolfArray
                break
            case .spirit:
                descModeArray = self.spiritArray
                break
            case .none: break
        }
        
        for idx in 0..<descModeArray.count {
            if (self.descriptionLabel.text == descModeArray[idx]) {
                self.descriptionLabel.text = descModeArray[(idx + 1 != descModeArray.count) ? idx + 1 : 0]
                break
            }
        }
    }
    
    /*
     * テーブルの人間がタップされたら
     */
    @objc func tableTapped(sender: UITapGestureRecognizer) {
        if let tableV = sender.view {
            
            var target = UILabel();
            for childView in tableV.subviews {
                if type(of: (childView as NSObject)).isEqual(UILabel.self) {
                    target = childView as! UILabel;
                }
            }
            
            for idx in 0..<self.personList.count {
                if (self.personList[idx]["name"]! == target.text) {
                    self.personList[idx]["icon1"] = "あああ"
                    self.personList[idx]["icon2"] = "いいい"
                }
            }
            
            // 画像のコピー
            // ビットマップ画像のcontextを作成.
            UIGraphicsBeginImageContextWithOptions(CGSize(width: self.currentView.bounds.size.width, height: self.currentView.bounds.size.height), false, 0.0)
            // 対象のview内の描画をcontextに複写する.
            self.currentView.layer.render(in: UIGraphicsGetCurrentContext()!)
            
            let dispSize = CGSize(width: innerTableRectList[0].size.width, height: innerTableRectList[0].size.height)
            
            // 現在のcontextのビットマップをUIImageとして取得.
            let imageView = UIImageView(image:UIGraphicsGetImageFromCurrentImageContext()!)
            
            var rect:CGRect = CGRect.zero
            if (tableV.frame.maxY - (self.navigationController?.navigationBar.frame.size.height)! == outerTable.frame.maxY) {
                rect = CGRect(
                    x:tableV.frame.minX, y: tableV.frame.maxY, width:dispSize.width / 2, height:dispSize.height / 2
                )
            } else if (tableV.frame.minX == outerTable.frame.minX) {
                rect = CGRect(
                    x:tableV.frame.minX - tableV.frame.size.width, y: tableV.frame.minY, width:dispSize.width / 2, height:dispSize.height / 2
                )
            } else if (tableV.frame.minY - (self.navigationController?.navigationBar.frame.size.height)! == outerTable.frame.minY) {
                rect = CGRect(
                    x:tableV.frame.minX, y: tableV.frame.minY - tableV.frame.size.height, width:dispSize.width / 2, height:dispSize.height / 2
                )
            } else if (tableV.frame.maxX == outerTable.frame.maxX) {
                rect = CGRect(
                    x:tableV.frame.maxX, y: tableV.frame.minY, width:dispSize.width / 2, height:dispSize.height / 2
                )
            }
            
            let newCanvas = UIView.init(frame: CGRect(
                x:rect.origin.x, y: rect.origin.y, width:dispSize.width, height:dispSize.height
            ))
            newCanvas.backgroundColor = UIColor.white
            self.view.addSubview(newCanvas)
            
            imageView.frame = rect;
            self.view.addSubview(imageView)
            // contextを閉じる.
            UIGraphicsEndImageContext()
            // 縦横比率を保ちつつ画像をUIImageViewの大きさに合わせる.
            imageView.contentMode = UIViewContentMode.scaleAspectFit
        }
        
    }
}
