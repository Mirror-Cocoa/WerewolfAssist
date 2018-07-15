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
    var myItems: NSMutableArray = ["TEST1", "TEST2", "TEST3", "+"]

    @IBOutlet var personTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "人物登録"
        
        // ナビゲーションバーの右側に編集ボタンを追加.
        self.editButtonItem.title = "削除"
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    

        
    }
    
    
    //MARK: - UITableView Delegate Method
    /*
     Cellが選択された際に呼び出される.
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 選択中のセルの番号、値、編集可能か？
        print("Num: \(indexPath.row)")
        print("Value: \(myItems[indexPath.row])")
        print("Editing: \(tableView.isEditing)")
        
        // ダイアログを出して、名前を更新。一番下なら追加。
        if indexPath.row != myItems.count - 1 {
            // 編集モード
            allocateMode(editType: .editMode, personName: myItems[indexPath.row] as! String, currentRow: indexPath.row)
        } else {
            // 追加モード
            allocateMode(editType: .addMode, personName: myItems[indexPath.row] as! String, currentRow: indexPath.row)
        }
        
        // TableViewを再読み込み
        personTableView.reloadData()
    }
    
    /*
     Cellの総数を返す
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myItems.count
    }
    
    /*
     Cellに値を設定する
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "personCell", for: indexPath as IndexPath)
        // Cellに値を設定.
        cell.textLabel!.text = myItems[indexPath.row] as? String
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
            self.editButtonItem.title = "削除"
            self.navigationItem.setLeftBarButton(nil, animated: true)
        }
    }
    
    /*
     addButtonが押された際呼び出される
     */
    @objc func addCell(sender: AnyObject) {
        // myItemsに追加.
        myItems.add("add Cell")
    }

    /*
     Cellを挿入または削除しようとした際に呼び出される
     */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
//        let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "削除") { (action, index) -> Void in
//            self.myItems.remove(indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//
//            self.personTableView.reloadData()
//        }
        // 削除のとき.
        if editingStyle == UITableViewCellEditingStyle.delete {
            print("削除")
            // 指定されたセルのオブジェクトをmyItemsから削除する.
            myItems.removeObject(at: indexPath.row)
            
            // TableViewを再読み込み.
            personTableView.reloadData()
        }
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK: - Private Method
    func allocateMode(editType: Mode, personName: String, currentRow: Int) {
        var alertTitle:String = ""
        var alertMsg:String = ""
        
        // 追加or編集？
        switch editType {
        case .editMode:
            alertTitle = "人物の編集を行います。"
            alertMsg = "編集したい人の名前を編集してください。"
            break
        case .addMode:
            alertTitle = "人物の登録を行います。"
            alertMsg = "登録したい人の名前を入力してください。"
            break
        }
        
        // アラートの初期設定
        let alert: UIAlertController = UIAlertController(title: alertTitle, message: alertMsg, preferredStyle:  UIAlertControllerStyle.alert)
        
        // OKボタンの処理
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            action in
            let textFields:Array<UITextField>? = alert.textFields as Array<UITextField>?
            
            if textFields != nil {
                for textField:UITextField in textFields! {
                    switch editType {
                    case .editMode:
                        // テーブルの変更
                        self.myItems[currentRow] = textField.text!;
                        break
                    case .addMode:
                        // テーブルの追加
                        self.myItems.insert(textField.text!, at: self.myItems.count - 1)
                        break
                    }
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
                text.text = self.myItems[currentRow] as? String
            }
            let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            label.text = "人物名"
            text.leftView = label
            text.leftViewMode = UITextFieldViewMode.always
        })
        
        present(alert, animated: true, completion: nil)
    }
}


