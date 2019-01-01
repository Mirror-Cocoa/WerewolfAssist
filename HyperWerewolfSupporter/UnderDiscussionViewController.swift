//
//  UnderDiscussionViewController.swift
//  HyperWerewolfSupporter
//
//  Created by Ichiro Miura on 2018/10/14.
//  Copyright © 2018年 mycompany. All rights reserved.
//

import UIKit

class UnderDiscussionViewController: UIViewController ,UIDragInteractionDelegate, UIDropInteractionDelegate, AlertPickerViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        return []
    }
    
    var personNum:Int?
    let userDefaults = UserDefaults.standard
    var personList: Array<[String:String]> = []
    var memberLabelList: [UILabel] = []
    var memberStatesViewList: [UIView] = []
    var memberArray: [String] = [];
    
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
    
    var isFirstTime: [Bool] = []
    
    var timer = Timer()
    var timerDisplay : Int = 0
    var timerGoing = false
    var startTime: TimeInterval = 0     // Startボタンを押した時刻
    var elapsedTime: Double = 0.0       // Stopボタンを押した時点で経過していた時間
    var time : Double = 0.0             // ラベルに表示する時間
    
    // pickerのviewをセット
    var pickerView: AlertPickerView!
    
    enum Mode {
        case fortune, hunter, sharer, madman, werewolf, spirit, none
    }
    
    enum Dead {
        case hang, killed, none
    }
    
    var currentMode: Mode = .none
    var currentDead: Dead = .none
    
    var hasMemberIcon: [Int] = []
    
    let fortuneArray = ["COのみ", "白判定", "黒判定", "溶かした"]
    let spiritArray = ["COのみ", "白判定", "黒判定"]
    let hunterArray = ["CO"]
    let sharerArray = ["CO"]
    let werewolfArray = ["疑惑", "CO", "LWCO"]
    let madmanArray = ["疑惑"]
    
    var isFirst = true
    
    
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
        
        // 15日目までのフラグを生成
        self.isFirstTime = [Bool](repeating: false, count: 15)
        self.isFirstTime[0] = true
        
        self.fortuneView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconTapped(sender:))))
        self.hunterView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconTapped(sender:))))
        self.sharerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconTapped(sender:))))
        self.madmanView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconTapped(sender:))))
        self.werewolfView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconTapped(sender:))))
        self.spiritView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconTapped(sender:))))
        
//        self.descriptionLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(descTapped(sender:))))
        descriptionLabel.adjustsFontSizeToFitWidth = true
        
        // メンバーの配列を用意
        for val in self.memberLabelList { self.memberArray.append(val.text!) }
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 一度だけ実行したい処理
        _ = self.initViewLayout
    }
    
    private lazy var initViewLayout : Void = {
        self.view.layoutIfNeeded()
        for innerTableRect in self.innerTableRectList {
            self.statusViewSet(tableV: UIView.init(frame: innerTableRect))
        }
    }()
    
    func statusViewSet(tableV: UIView) {
        
        var rect:CGRect = CGRect.zero
        if (tableV.frame.maxY - (self.navigationController?.navigationBar.frame.size.height)! == outerTable.frame.maxY) {
            rect = CGRect(
                x:tableV.frame.minX, y: tableV.frame.maxY, width:tableV.frame.width, height:tableV.frame.height
            )
        } else if (tableV.frame.minX == outerTable.frame.minX) {
            rect = CGRect(
                x:tableV.frame.minX - tableV.frame.size.width, y: tableV.frame.minY, width:tableV.frame.width, height:tableV.frame.height
            )
        } else if (tableV.frame.minY - (self.navigationController?.navigationBar.frame.size.height)! == outerTable.frame.minY) {
            rect = CGRect(
                x:tableV.frame.minX, y: tableV.frame.minY - tableV.frame.size.height, width:tableV.frame.width, height:tableV.frame.height
            )
        } else if (tableV.frame.maxX == outerTable.frame.maxX) {
            rect = CGRect(
                x:tableV.frame.maxX, y: tableV.frame.minY, width:tableV.frame.width, height:tableV.frame.height
            )
        }
        
        let statusView = UIView.init(frame: CGRect(
            x:rect.origin.x, y: rect.origin.y, width:tableV.frame.width, height:tableV.frame.height
        ))
        
//        statusView.layer.shouldRasterize = true;
        statusView.backgroundColor = UIColor.gray
//            .withAlphaComponent(1.0)
//        statusView.alpha = 1.0
//        statusView.layer.opacity = 1.0
        
        let rectArray = [
            CGRect(x: 0, y: 0, width: statusView.frame.width, height: 1.0),
            CGRect(x: 0, y: 0, width: 1.0, height:statusView.frame.height),
            CGRect(x: 0, y: statusView.frame.height, width: statusView.frame.width, height:-1.0),
            CGRect(x: statusView.frame.width, y: 0, width: -1.0, height:statusView.frame.height)
        ]
        
        for idx in 0..<rectArray.count {
            let border = CALayer()
            border.frame = rectArray[idx]
            border.backgroundColor = UIColor.black.cgColor
            statusView.layer.addSublayer(border)
        }
        
        if (rect != CGRect.zero) {
            self.memberStatesViewList.append(statusView)
            self.view.addSubview(statusView)
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
    
    
    /*
     * カレンダーの時間が変わったら
     */
    @IBAction func calendarChange(_ sender: Any) {
        self.calendar.image = UIImage(named: "days_" + String(Int(self.calendarStepper.value)))
        if (!(self.isFirstTime[Int(self.calendarStepper.value) - 1])) {
            self.currentDead = .hang
            self.createPicker()
            self.isFirstTime[Int(self.calendarStepper.value) - 1] = true
            
        }
    }
    
    /*
     * ピッカーの作成
     * 処刑の場合は1つ、噛みの場合は2つ作成する
     */
    func createPicker() {
        
//        if (currentDead == .hang) {
        
            self.pickerView = AlertPickerView()
            self.view.addSubview(pickerView)
            // モーダルをいつか作ろうね
//            self.accessibilityViewIsModal = false
            
        
            self.pickerView.items = self.memberArray
            
            self.pickerView.delegate = self
            self.pickerView.dataSource = self as? AlertPickerViewDataSource
            
            self.pickerView.showPicker()
//        } else if (currentDead == .killed) {
//
//            self.pickerView = AlertPickerView()
//            self.view.addSubview(pickerView)
//
//            var memberArray: [String] = [];
//            for val in self.memberLabelList { memberArray.append(val.text!) }
//            self.pickerView.items = memberArray
//
//            self.pickerView.delegate = self
//            self.pickerView.dataSource = self as? AlertPickerViewDataSource
//
//            self.pickerView.showPicker()
//        }
        
    }
    
    
    
    
    /*
     * ピッカーのデリゲートメソッド
     */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ namePickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerView.items.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerView.items[row]
    }
    func pickerView(pickerView: UIPickerView, didSelect numbers: [Int]) {
        print("selected \(numbers)")
        let num = numbers[0]
        self.memberArray.remove(value: self.memberArray[num])
        
        if (self.currentDead == .hang) {
            createResult(row: 1, column: Int(self.calendarStepper.value) - 2, name: self.pickerView.items[num])
            self.currentDead = .killed
            self.createPicker()
        } else if (self.currentDead == .killed) {
            createResult(row: 2, column: Int(self.calendarStepper.value) - 2, name: self.pickerView.items[num])
        }
        
    }
    
    
    
    func pickerViewDidHide(pickerView: UIPickerView) {
        print("hided pickerview")
//        self.currentDead = .hang
//        self.accessibilityViewIsModal = false
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
        
        createFortuneResultTable(row: 3, fLength: fLength, name: "占", target: "対象", result: "結果")
        createFortuneResultTable(row: 4, fLength: fLength, name: "", target: "", result: "")
        createFortuneResultTable(row: 5, fLength: fLength, name: "", target: "", result: "")
        createFortuneResultTable(row: 6, fLength: fLength, name: "", target: "", result: "")
        createFortuneResultTable(row: 7, fLength: fLength, name: "霊", target: "対象", result: "結果")
        createFortuneResultTable(row: 8, fLength: fLength, name: "", target: "", result: "")
        createFortuneResultTable(row: 9, fLength: fLength, name: "", target: "", result: "")
        createFortuneResultTable(row: 10, fLength: fLength, name: "", target: "", result: "")
    }
    
    func createResult(row: Int, column: Int, name: String) {
        let fLength = 29
        let fLength2 = fLength * 2
        
        let longTableFrame = UIView.init(frame: CGRect.init(x: 0, y: 0, width: fLength2, height: fLength))
        self.resultTable.addSubview(createBorder(v: longTableFrame))
        
        // 制約を制定
        constraintsInit(v: longTableFrame)
        longTableFrame.leadingAnchor.constraint(equalTo: self.resultTable.leadingAnchor, constant: CGFloat(column * fLength2 + fLength)).isActive = true
        longTableFrame.topAnchor.constraint(equalTo: self.resultTable.topAnchor, constant: CGFloat(row * fLength)).isActive = true
        
        // ヘッダーラベルの制定
        longTableFrame.addSubview(createLabel(txt: name, v: longTableFrame))
    }
    
    func createFortuneResultTable(row: Int, fLength: Int, name: String, target: String, result: String) {
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
        if currentMode == .none {
            return
        }
        if let tableV = sender.view {
            
            // 人名を取得
            var target = UILabel();
            for childView in tableV.subviews {
                if type(of: (childView as NSObject)).isEqual(UILabel.self) {
                    target = childView as! UILabel;
                    break
                }
            }
            
            for idx in 0..<self.personList.count {
                if (self.personList[idx]["name"]! == target.text) {
                    // その人のアイコンを登録/削除する
                    iconChoice(idx: idx)
                    break
                }
            }
            
            // 同じ人のステータスビューを取得
            var targetStatusView = UIView()
            for idx in 0..<self.memberLabelList.count {
                if (self.memberLabelList[idx].text == target.text!) {
                    // その人のステータスビューを取得する
                    targetStatusView = self.memberStatesViewList[idx]
                    break
                }
            }
            
            targetStatusView.backgroundColor = UIColor.white
            
            
            

            // 画像のコピー
            // ビットマップ画像のcontextを作成.
            UIGraphicsBeginImageContextWithOptions(CGSize(width: self.currentView.bounds.size.width, height: self.currentView.bounds.size.height), false, 0.0)
            // 対象のview内の描画をcontextに複写する.
            self.currentView.layer.render(in: UIGraphicsGetCurrentContext()!)
            
            
            let dispSize = CGSize(width: targetStatusView.frame.size.width, height: targetStatusView.frame.size.height)
            
            // 現在のcontextのビットマップをUIImageとして取得.
            let imageView = UIImageView(image:UIGraphicsGetImageFromCurrentImageContext()!)
            
            // TODO:2つの役職まで追加/削除を行う
//            for idx in 0..<self.memberLabelList.count {
//                for idx2 in 0..<self.personList.count {
//                    if (self.memberLabelList[idx].text == self.personList[idx2]["name"]!) {
//                        if (isIcon(str: self.personList[idx2]["icon1"]!)) {
//                            imageView.frame = CGRect(x:0, y: 0, width:dispSize.width / 2, height:dispSize.height / 2)
//                        }
//                        if (isIcon(str: self.personList[idx2]["icon2"]!)) {
//                            imageView.frame = CGRect(x:dispSize.width / 2, y: dispSize.height / 2, width:dispSize.width / 2, height:dispSize.height / 2)
//                        }
//                    }
//                }
//            }
            
            
            imageView.frame = CGRect(x:0, y: 0, width:dispSize.width / 2, height:dispSize.height / 2)
            
            
            
            // TODO: 重なる時、どうにかして下層部の色の影響を受けずにできないだろうか？
//            imageView.alpha = 1.0
//            imageView.layer.shouldRasterize = true;
//            imageView.layer.opacity = 1.0
            
            targetStatusView.addSubview(imageView)
            // contextを閉じる.
            UIGraphicsEndImageContext()
            // 縦横比率を保ちつつ画像をUIImageViewの大きさに合わせる.
            targetStatusView.contentMode = UIViewContentMode.scaleAspectFit
            
            // 占い・霊能COの時、既存なら何もしない(将来的には消しますか？を実装)
            // 既存なしなら追加を行う。
            
            
            
            
            
            
            
        }
        
    }
    
    func iconChoice(idx: Int) {
        switch self.currentMode {
        case .fortune:
            iconAddDel(idx: idx, icon: "F")
            break
        case .hunter:
            iconAddDel(idx: idx, icon: "H")
            break
        case .sharer:
            iconAddDel(idx: idx, icon: "SH")
            break
        case .madman:
            iconAddDel(idx: idx, icon: "M")
            break
        case .werewolf:
            iconAddDel(idx: idx, icon: "W")
            break
        case .spirit:
            iconAddDel(idx: idx, icon: "SP")
            break
        case .none: break
        }
    }
    
    func iconAddDel(idx: Int, icon: String) {
        if (self.personList[idx]["icon1"] == icon) {
            // icon1が同一の場合、icon1を消す
            self.personList[idx]["icon1"] = ""
            // icon2がある場合、icon1に移動し、icon2は消す
            if (self.personList[idx]["icon2"] != nil) {
                self.personList[idx]["icon1"] = self.personList[idx]["icon2"]
                self.personList[idx]["icon2"] = ""
            }
        } else if (self.personList[idx]["icon1"] == "" || self.personList[idx]["icon1"] == nil) {
            // icon1がない場合、icon1をiconにする
            self.personList[idx]["icon1"] = icon
        } else {
            // icon1がその他の場合
            // icon2が同一の場合、icon2を消す
            if (self.personList[idx]["icon2"] == icon) {
                self.personList[idx]["icon2"] = ""
            } else if (self.personList[idx]["icon1"] == "" || self.personList[idx]["icon1"] == nil) {
                // icon2がない場合、icon2をiconにする
                self.personList[idx]["icon2"] = icon
            } else {
                // icon2がその他の場合、何もしない
            }
        }
    }
    
    func isIcon(str: String) -> Bool {
        switch self.currentMode {
        case .fortune: return (str == "F")
        case .hunter: return (str == "H")
        case .sharer: return (str == "SH")
        case .madman: return (str == "M")
        case .werewolf: return (str == "W")
        case .spirit: return (str == "SP")
        case .none: break
        }
        return false
    }
 
}

extension Array where Element: Equatable {
    mutating func remove(value: Element) {
        if let i = self.index(of: value) {
            self.remove(at: i)
        }
    }
}
