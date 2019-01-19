//
//  UnderDiscussionViewController.swift
//  HyperWerewolfSupporter
//
//  Created by Ichiro Miura on 2018/10/14.
//  Copyright © 2018年 mycompany. All rights reserved.
//

import UIKit

class UnderDiscussionViewController: UIViewController ,UIDragInteractionDelegate, UIDropInteractionDelegate, AlertPickerViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
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
    
    enum Select {
        case co, white, black, melt, lw, none
    }
    
    var currentMode: Mode = .none
    var currentDead: Dead = .none
    var currentSelect: Select = .none
    
    var hasMemberIcon: [Int] = []
    
    let fortuneArray = ["CO", "白", "黒", "溶"]
    let spiritArray = ["CO", "白", "黒"]
    let hunterArray = ["CO"]
    let sharerArray = ["CO"]
    let werewolfArray = ["疑惑", "CO", "LWCO"]
    let madmanArray = ["疑惑"]
    
    // 占いCOした人、霊能COした人
    var fortunePersonArray: [String] = []
    var spiritPersonArray: [String] = []
    
    // 占われた人、霊能力使われた人 配列は日付[占い元:[占い先:結果]]
    var fortunePersonList: Array<[String:[String:String]]> = []
    var spiritPersonList: Array<[String:[String:String]]> = []
    
    var hangArray: [String] = []
    var tempHang : String = "";
    
    var isFirst = true
    var isPickerDone = false
    
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
    var descSubLabelArray: [UILabel] = []
    
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
        
        self.fortunePersonList = Array<[String:[String:String]]>(repeating: ["":["":""]], count: 15)
        self.spiritPersonList = Array<[String:[String:String]]>(repeating: ["":["":""]], count: 15)
        
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
            
            self.memberLabelList[cnt].isUserInteractionEnabled = false
            
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
     * ピッカーがキャンセル、若しくは何も選択されていなかった場合
     */
    func calendarReset () {
        self.isFirstTime[Int(self.calendarStepper.value) - 1] = false
        self.calendarStepper.value -= 1
        self.calendar.image = UIImage(named: "days_" + String(Int(self.calendarStepper.value)))
        self.tempHang = "";
    }
    
    /*
     * ピッカーの作成
     * 処刑の場合は1つ、噛みの場合は2つ作成する
     */
    func createPicker() {
        self.pickerView = AlertPickerView()
        self.view.addSubview(pickerView)
        
        self.pickerView.items = self.memberArray
                // モーダルをいつか作ろうね
        //            self.accessibilityViewIsModal = false
        
        // 吊り/噛みによって文言を変更
        if (currentDead == .hang) {
            self.pickerView.items.insert("【吊られた人を選択】", at: 0)
        } else if (currentDead == .killed) {
            self.pickerView.items.insert("【噛まれた人を選択】", at: 0)
            self.pickerView.items.insert("GJ", at: 1)
            self.pickerView.items.remove(value: self.tempHang)
        }
        
        self.pickerView.delegate = self
        self.pickerView.dataSource = self as? AlertPickerViewDataSource
        
        self.pickerView.showPicker()
    
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
    // pickerViewがタップされた時の処理
    func pickerView(pickerView: UIPickerView, didSelect numbers: [Int]) {
        self.isPickerDone = true
        // 未選択の場合return
        let num = numbers[0]
        if (num == 0) {
            calendarReset()
            return
        }
        
        if (self.currentDead == .hang) {
            // 吊られた場合の処理
            self.tempHang = self.pickerView.items[num];
            self.currentDead = .killed
            self.createPicker()
        } else if (self.currentDead == .killed) {
            // 噛まれた場合の処理
            deadImage(name: self.tempHang, isHang: true)
            createResult(row: 1, column: Int(self.calendarStepper.value) - 2, name: self.tempHang)
            self.hangArray.append(self.tempHang)
            self.memberArray.remove(value: self.tempHang)
            
            
            if (num != 1) {
                createResult(row: 2, column: Int(self.calendarStepper.value) - 2, name: self.pickerView.items[num])
                self.memberArray.remove(value: self.pickerView.items[num])
                deadImage(name: self.pickerView.items[num], isHang: false)
            } else {
                // GJの場合は消さない
                createResult(row: 2, column: Int(self.calendarStepper.value) - 2, name: "-")
            }
        }
    }
    
    func pickerViewDidHide(pickerView: UIPickerView) {
        if (!self.isPickerDone) {
            calendarReset()
        }
        self.isPickerDone = false
    }
    
    func deadImage (name: String, isHang: Bool) {
        // UIImageView 初期化
        let imageView = (isHang) ? UIImageView(image:UIImage(named:"ghost")!) : UIImageView(image:UIImage(named:"knife")!)

        // 死亡者のテーブルの大きさを取得
        for idx in 0..<self.memberLabelList.count {
            if (self.memberLabelList[idx].text == name) {
                // その人のテーブルビューを取得する
                // 画像の中心を内部テーブルの中心に設定
                imageView.frame = self.innerTableList[idx].frame
                break
            }
        }
        
        imageView.alpha = 0.7
        self.view.addSubview(imageView)
    }
    
    
    
    func createResultTable() {
        let fLength = 29
        let fLength2 = fLength * 2
        
        for row in 0..<3 {
            let titleTableFrame = UIView.init(frame: CGRect.init(x: 0, y: 0, width: fLength, height: fLength))
            self.resultTable.addSubview(createBorder(v: titleTableFrame))
            // 制約を制定
            constraintsInit(v: titleTableFrame)
            titleTableFrame.leadingAnchor.constraint(equalTo: self.resultTable.leadingAnchor).isActive = true
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
        
        createFortuneResultTable()
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
    
    func createFortuneResultTable() {
        for row in 3..<11 {
            for column in 0..<31 {
                if (row == 3) {
                    createFortuneResult(row: row, column: column, fLength: 29, name: "占", target: "対象", result: "結果", isInit: true)
                } else if (row == 7) {
                    createFortuneResult(row: row, column: column, fLength: 29, name: "霊", target: "対象", result: "結果", isInit: true)
                } else if (row >= 8 && (column == 1 || column == 2)) {
                    createFortuneResult(row: row, column: column, fLength: 29, name: "", target: "-", result: "-", isInit: true)
                } else {
                    createFortuneResult(row: row, column: column, fLength: 29, name: "", target: "", result: "", isInit: true)
                }
            }
        }
    }
    
    func createFortuneResult(row: Int, column: Int, fLength: Int, name: String, target: String, result: String, isInit: Bool) {
        let tableFrame = UIView.init(frame: CGRect.init(x: 0, y: 0, width: fLength, height: fLength))
        if (isInit) {
            self.resultTable.addSubview(createBorder(v: tableFrame))
        } else {
            self.resultTable.addSubview(tableFrame)
        }
        
        // 制約を制定
        constraintsInit(v: tableFrame)
        tableFrame.leadingAnchor.constraint(equalTo: self.resultTable.leadingAnchor, constant: CGFloat(column * fLength)).isActive = true
        tableFrame.topAnchor.constraint(equalTo: self.resultTable.topAnchor, constant: CGFloat(row * fLength)).isActive = true
        self.resultContentView.frame.size.height += CGFloat(row * fLength + fLength)
        
        // ラベルの追加
        if (isInit) {
            tableFrame.addSubview(createLabel(txt: (column == 0) ? name : (column % 2 != 0) ? target : result, v: tableFrame))
        } else {
            tableFrame.addSubview(createLabel(txt: target, v: tableFrame))
            
            // 結果分の作成
            let resultTableFrame = UIView.init(frame: CGRect.init(x: 0, y: 0, width: fLength, height: fLength))
            self.resultTable.addSubview(resultTableFrame)
            constraintsInit(v: resultTableFrame)
            resultTableFrame.leadingAnchor.constraint(equalTo: self.resultTable.leadingAnchor, constant: CGFloat(column * fLength + fLength)).isActive = true
            resultTableFrame.topAnchor.constraint(equalTo: self.resultTable.topAnchor, constant: CGFloat(row * fLength)).isActive = true
            self.resultContentView.frame.size.height += CGFloat(row * fLength + fLength)
            resultTableFrame.addSubview(createLabel(txt: result, v: tableFrame))
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
            
            // 元々のsubviewは消す
            self.view.subviews.forEach {
                if $0.tag == 10{
                    $0.removeFromSuperview()
                }
            }
        
            // ラベルの設定
            if currentV.frame.minY == self.iconView.frame.minY {
                self.currentMode = .fortune
                self.currentSelect = .co
                descriptionDisplay(labels: self.fortuneArray)
                
            }
            
            if currentV.frame.maxY == self.iconView.frame.maxY {
                let viewWidth = CGFloat(39)
                let calcWidth = CGFloat(currentV.frame.origin.x / viewWidth)
                switch calcWidth {
                case 0:
                    self.currentMode = .spirit
                    self.currentSelect = .co
                    descriptionDisplay(labels: self.spiritArray)
                    break
                case 1:
                    self.currentMode = .hunter
                    self.currentSelect = .co
                    descriptionDisplay(labels: self.hunterArray)
                    break
                case 2:
                    self.currentMode = .sharer
                    self.currentSelect = .co
                    descriptionDisplay(labels: self.sharerArray)
                    break
                case 3:
                    self.currentMode = .madman
                    self.currentSelect = .co
                    descriptionDisplay(labels: self.madmanArray)
                    break
                case 4:
                    self.currentMode = .werewolf
                    self.currentSelect = .co
                    descriptionDisplay(labels: self.werewolfArray)
                    break
                default:
                    self.currentMode = .none
                    break
                }
            }
            self.descriptionLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(descTapped(sender:))))
        }
    }
    
    func descriptionDisplay (labels: [String]) {
        self.descriptionLabel.text = labels[0]
        self.descriptionLabel.backgroundColor = UIColor.cyan
        self.descriptionLabel.textAlignment = NSTextAlignment.center
        self.descriptionLabel.sizeToFit()
        var prevLabel = self.descriptionLabel
        
        for idx in 0..<labels.count - 1 {
            self.descSubLabelArray.append(UILabel.init(frame: .zero))
            
            if (self.currentMode == .fortune && self.fortunePersonArray.count == 0 ||
                self.currentMode == .spirit && self.spiritPersonArray.count == 0) {
                self.descSubLabelArray[idx].backgroundColor = UIColor.gray
            } else {
                self.descSubLabelArray[idx].backgroundColor = UIColor.white
            }
            
            self.descSubLabelArray[idx].text = labels[idx + 1]
            self.descSubLabelArray[idx].tag = 10
            self.descSubLabelArray[idx].sizeToFit()
            self.descSubLabelArray[idx].textAlignment = NSTextAlignment.center
            self.view.addSubview(self.descSubLabelArray[idx])

            // ラベルの制約を制定
            self.descSubLabelArray[idx].translatesAutoresizingMaskIntoConstraints = false
            self.descSubLabelArray[idx].leadingAnchor.constraint(equalTo: (prevLabel?.trailingAnchor)!, constant: CGFloat(30)).isActive = true
            self.descSubLabelArray[idx].topAnchor.constraint(equalTo: (prevLabel?.topAnchor)!).isActive = true
            
            self.descSubLabelArray[idx].widthAnchor.constraint(equalTo: (prevLabel?.widthAnchor)!).isActive = true
            self.descSubLabelArray[idx].heightAnchor.constraint(equalTo: (prevLabel?.heightAnchor)!).isActive = true
            
            if (self.currentMode == .fortune && self.fortunePersonArray.count != 0 ||
                self.currentMode == .spirit && self.spiritPersonArray.count != 0) {
                self.descSubLabelArray[idx].isUserInteractionEnabled = true
            }
            
            self.descSubLabelArray[idx].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(descTapped(sender:))))
            prevLabel = self.descSubLabelArray[idx]
        }
    }
    

    
    /*
     * 説明ラベルが押されたら
     */
    @objc func descTapped(sender: UITapGestureRecognizer) {
        print(self.currentMode)
        if let label = sender.view as? UILabel {
            
            // 背景色を修正
            self.descriptionLabel.backgroundColor = (self.descriptionLabel.text != label.text) ? UIColor.white : UIColor.cyan
            for idx in 0..<self.descSubLabelArray.count {
                if (self.currentMode == .fortune && self.fortunePersonArray.count != 0 ||
                    self.currentMode == .spirit && self.spiritPersonArray.count != 0) {
                    self.descSubLabelArray[idx].backgroundColor = (self.descSubLabelArray[idx].text != label.text) ? UIColor.white : UIColor.cyan
                }
            }
            
            switch label.text {
                case "CO" :
                    self.currentSelect = .co
                    break
                case "白" :
                    self.currentSelect = .white
                    break
                case "黒" :
                    self.currentSelect = .black
                    break
                case "溶" :
                    self.currentSelect = .melt
                    break
                case "疑惑" : break
                case "LWCO" : break
                case .none: break
                default: break
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
            
            // 占い・霊能COの時、既存なら何もしない(将来的には同じ人は撤回を実装)
            switch self.currentMode {
            case .fortune:
                if (self.currentSelect == .co && fortunePersonArray.count < 3) {
                    if (!self.fortunePersonArray.contains(target.text!)) {
                        self.fortunePersonArray.append(target.text!)
                        self.memberLabelList[self.memberLabelList.index(of: target)!].isUserInteractionEnabled = true
                        for idx in 0..<self.descSubLabelArray.count {
                            if (self.fortunePersonArray.count != 0) {
                                self.descSubLabelArray[idx].backgroundColor = UIColor.white
                                self.descSubLabelArray[idx].isUserInteractionEnabled = true
                            }
                            
                        }
                        createFortuneResult(row: fortunePersonArray.count + 3, column: 0, fLength: 29, name: target.text!, target: "", result: "", isInit: true)
                    } else {
                        return
                    }
                } else {
                    return
                }
                break
            case .hunter:
                break
            case .sharer:
                break
            case .madman:
                break
            case .werewolf:
                break
            case .spirit:
                if (self.currentSelect == .co && spiritPersonArray.count < 3) {
                    if (!self.spiritPersonArray.contains(target.text!)) {
                        self.spiritPersonArray.append(target.text!)
                        for idx in 0..<self.descSubLabelArray.count {
                            if (self.spiritPersonArray.count != 0) {
                                self.descSubLabelArray[idx].backgroundColor = UIColor.white
                                self.descSubLabelArray[idx].isUserInteractionEnabled = true
                            }
                        }
                        createFortuneResult(row: spiritPersonArray.count + 7, column: 0, fLength: 29, name: target.text!, target: "", result: "", isInit: true)
                    } else {
                        return
                    }
                } else if(self.currentSelect == .black || self.currentSelect == .white) {
                    // 霊能結果の反映
                    if (Int(self.calendarStepper.value) == 0 || self.hangArray.count == 0 || !self.spiritPersonArray.contains(target.text!)) { return }
                    var spiritResultStr = ""
                    // ステータスビューの反映用(前日吊られた人のを反映する)
                    var spiritStatusView = UIView()
                    for idx in 0..<self.memberLabelList.count {
                        if (self.memberLabelList[idx].text == self.hangArray[Int(self.calendarStepper.value) - 2]) {
                            // その人のステータスビューを取得する
                            spiritStatusView = self.memberStatesViewList[idx]
                            break
                        }
                    }
                    switch self.currentSelect {
                    case .black :
                        spiritResultStr = "黒";
                        spiritStatusView.backgroundColor = UIColor.black
                        break
                    case .white :
                        spiritResultStr = "白";
                        spiritStatusView.backgroundColor = UIColor.white
                        break
                    default : break
                    }
                    
                    self.createFortuneResult(row: self.spiritPersonArray.index(of: target.text!)! + 8,
                                             column: (Int(self.calendarStepper.value) * 2) - 1,
                                             fLength: 29,
                                             name: "",
                                             target: self.hangArray[Int(self.calendarStepper.value) - 2],
                                             result: spiritResultStr,
                                             isInit: false
                    )
                    return
                }
                break
            case .none:
                break
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
            
            
            
        }
        
    }
    
    
    
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        
        if (self.currentMode == .fortune &&
            self.currentSelect == .black || self.currentSelect == .white) {
        
            for idx in 0..<self.innerTableList.count {
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
        }

        // ドラッグ位置にラベルがなければドラッグ可能ではありません。
        return []
    }

    func dropInteraction(_ interaction: UIDropInteraction,
                         sessionDidUpdate session: UIDropSession) -> UIDropProposal {

        // 現在の位置を取得
        let currentPoint = session.location(in: self.view)

        // ドロップ先のinnerTableを取得
        for idx in 0..<self.innerTableList.count {
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
                            // 占い結果の反映
                            if (self.currentMode == .fortune) {
                                
                                var fortuneResultStr = ""
                                // ステータスビューの反映用
                                var targetStatusView = UIView()
                                for idx in 0..<self.memberLabelList.count {
                                    if (self.memberLabelList[idx].text == self.memberLabelList[self.dropIdx].text!) {
                                        // その人のステータスビューを取得する
                                        targetStatusView = self.memberStatesViewList[idx]
                                        break
                                    }
                                }
                                
                                let fromPerson = string as String
                                let toPerson = self.memberLabelList[self.dropIdx].text!
                                var startStr = String(fromPerson[fromPerson.startIndex])
                                
                                switch self.currentSelect {
                                case .black :
                                    fortuneResultStr = "黒";
                                    startStr += "●"
                                    break
                                case .white :
                                    fortuneResultStr = "白";
                                    startStr += "○"
                                    break
                                case .melt :
                                    fortuneResultStr = "溶";
                                    startStr += "溶"
                                    break
                                default : break
                                }
                                
                                let resultLabel = self.createLabel(txt: startStr, v: targetStatusView)
                                let dispSize = CGSize(width: targetStatusView.frame.size.width, height: targetStatusView.frame.size.height)
                                let addDict = [fromPerson: [toPerson : fortuneResultStr]]
                                
                                // 占われた人、 [日付] => [占い元:[占い先:結果]]
                                if (self.fortunePersonList.canAccess(index: Int(self.calendarStepper.value))) {
                                    // いる場合、更新。同一条件なら何もしない
                                    let prevDict = self.fortunePersonList[Int(self.calendarStepper.value)]
                                    if (prevDict == addDict) { return }
                                    self.fortunePersonList[Int(self.calendarStepper.value)] = addDict
                                    
                                    // 修正前のバックグラウンドを修正(prevDictのtoが、占い先、霊媒先、占いCO、霊媒COでないことを確認してからgrayにする)
                                    
                                    
                                    
                                } else {
                                    // いない場合、新規追加
                                    self.fortunePersonList.insert([fromPerson: [toPerson : fortuneResultStr]], at: Int(self.calendarStepper.value))
                                }
                                
                                targetStatusView.backgroundColor = UIColor.white
                                
                                resultLabel.frame = CGRect(x:0, y:dispSize.height / 2, width:dispSize.width / 2, height:dispSize.height / 2)
                                resultLabel.tag = 20
                                
                                targetStatusView.addSubview(resultLabel)
                                
                                self.createFortuneResult(row: self.fortunePersonArray.index(of: string as String)! + 4,
                                                         column: (Int(self.calendarStepper.value) * 2) - 1,
                                                         fLength: 29,
                                                         name: "",
                                                         target: self.memberLabelList[self.dropIdx].text!,
                                                         result: fortuneResultStr,
                                                         isInit: false
                                )
                            }
                        }
                    }
                }
            }
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

extension Array {
    func canAccess(index: Int) -> Bool {
        return self.count-1 >= index
    }
}
