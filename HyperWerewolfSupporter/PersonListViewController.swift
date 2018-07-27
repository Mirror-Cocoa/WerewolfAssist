//
//  PersonListViewController.swift
//  HyperWerewolfSupporter
//
//  Created by Ichiro Miura on 2018/06/30.
//  Copyright © 2018年 mycompany. All rights reserved.
//

import UIKit

class PersonListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // 編集
    enum Mode {
        case addMode, editMode
    }

    @IBOutlet var personTableView: UITableView!
    
    let userDefaults = UserDefaults.standard
    var personList: Array<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "人物登録"
        
        // ナビゲーションバーの右側に編集ボタンを追加.
        self.editButtonItem.title = "追加・削除"
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        if let loadData = userDefaults.object(forKey: "person") {
            personList = loadData as! Array<String>
        }
    }
    
    
    //MARK: - UITableView Delegate Method
    /*
     Cellが選択された際に呼び出される.
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 選択中のセルの番号、値、編集可能か？
        print("Num: \(indexPath.row)")
        print("Value: \(personList[indexPath.row])")
        print("Editing: \(tableView.isEditing)")
        
        // ダイアログを出して、名前を更新。
        // 編集モードで送信
        allocateMode(editType: .editMode, personName: personList[indexPath.row] , currentRow: indexPath.row)
        
        // TableViewを再読み込み
        personTableView.reloadData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "personCell", for: indexPath as IndexPath)
        // Cellに値を設定.
        cell.textLabel!.text = personList[indexPath.row] as? String
        return cell
    }
    
    /*
     編集ボタンが押された際に呼び出される
     */
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        // TableViewを編集可能にする
        personTableView.setEditing(editing, animated: true)

        // 編集中のときのみaddButtonをナビゲーションバーの左に表示する
        if editing {
            print("編集中")
            self.editButtonItem.title = "完了"
            let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(self.addCell(sender:)))
            self.navigationItem.setLeftBarButton(addButton, animated: true)
        } else {
            print("通常モード")
            self.editButtonItem.title = "追加・削除"
            self.navigationItem.setLeftBarButton(nil, animated: true)
        }
    }
    
    /*
     addButtonが押された際呼び出される
     */
    @objc func addCell(sender: AnyObject) {
        allocateMode(editType: .addMode, personName: "" , currentRow: -1)
    }

    /*
     Cellを挿入または削除しようとした際に呼び出される
     */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // 削除のとき.
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // 指定されたセルのオブジェクトをpersonListから削除する.
            personList.remove(at: indexPath.row)
            
            // UserDefaultに書き込み
            self.updateUserDefault(saveText: self.personList)
            
            // TableViewを再読み込み.
            personTableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: - Private Method
    func allocateMode(editType: Mode, personName: String, currentRow: Int) {
        let alertTitle:String = String(format: "人物の%@を行います。", (editType == .editMode) ? "編集" : "登録")
        let alertMsg:String = String(format: "%@したい人の名前を入力してください。", (editType == .editMode) ? "編集" : "登録")

        // アラートの初期設定
        let alert: UIAlertController = UIAlertController(title: alertTitle, message: alertMsg, preferredStyle:  UIAlertControllerStyle.alert)
        
        // OKボタンの処理
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            action in
            let textFields:Array<UITextField>? = alert.textFields as Array<UITextField>?
            
            if (textFields != nil) {
                for textField:UITextField in textFields! {
                    if (editType == .editMode) {
                        // テーブルの変更
                        self.personList[currentRow] = textField.text!;
                    } else if (editType == .addMode) {
                        // テーブルの追加
                        self.personList.append(textField.text!)
                    }
                    self.updateUserDefault(saveText: self.personList)
                }
            }
            
            // TableViewを再読み込み
            self.personTableView.reloadData()
        })
        
        // キャンセルボタン
        alert.addAction(UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel))
        alert.addAction(defaultAction)
        
        // テキストフィールドの設置
        alert.addTextField(configurationHandler: {(text:UITextField!) -> Void in
            text.placeholder = "入力してください"
            if (editType == .editMode) {
                text.text = self.personList[currentRow]
            }
            let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            label.text = "人物名"
            text.leftView = label
            text.leftViewMode = UITextFieldViewMode.always
        })
        
        present(alert, animated: true, completion: nil)
    }
    
    
    func updateUserDefault(saveText: Array<String>) {
        userDefaults.set(personList, forKey: "person")
        userDefaults.synchronize()
    }
   
}
