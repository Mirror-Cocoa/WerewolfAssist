//
//  AlertPickerView.swift
//  HyperWerewolfSupporter
//
//  Created by Ichiro Miura on 2018/12/25.
//  Copyright © 2018年 mycompany. All rights reserved.
//

import UIKit


class AlertPickerView: UIView {
    var pickerView: UIPickerView!
    var pickerToolbar: UIToolbar!
    var toolbarItems: [UIBarItem]!
    var items:Array<String>!
    let heightOfPickerView:CGFloat = 216
    let heightOfToolbar:CGFloat = 44
    var backgroundColorOfPickerView  = UIColor.white
    var backgroundColorOfToolbar = UIColor.white
    var textColorOfToolbar = UIColor.black
    
    var delegate: AlertPickerViewDelegate? {
        didSet {
            pickerView.delegate = delegate
        }
    }
    var dataSource: AlertPickerViewDataSource? {
        didSet {
            pickerView.dataSource = dataSource
        }
    }
    private var selectedRows: [Int]?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initFunc()
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        initFunc()
//        println("initfunc")
    }
    
    private func initFunc() {
        let screenSize = UIScreen.main.bounds.size
        self.backgroundColor = UIColor.black
        
        pickerToolbar = UIToolbar()
        pickerView = UIPickerView()
        toolbarItems = []
        
        pickerToolbar.isTranslucent = false
        pickerView.showsSelectionIndicator = true
        pickerView.backgroundColor = self.backgroundColorOfPickerView
        
        
        self.frame = CGRect(x:0, y:screenSize.height, width:screenSize.width, height:self.heightOfPickerView + self.heightOfToolbar)
        
        //pickerToolbar
        pickerToolbar.frame = CGRect(x:0, y:0, width:screenSize.width, height:self.heightOfToolbar)
        pickerToolbar.barTintColor = self.backgroundColorOfPickerView
        
        //pickerView
        pickerView.frame = CGRect(x:0,y:self.heightOfToolbar, width:screenSize.width, height:self.heightOfPickerView)
        pickerView.backgroundColor = self.backgroundColorOfPickerView
        
        
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        space.width = 12
        
        let cancelItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(cancelPicker(sender:)))
        let flexSpaceItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        
        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(endPicker(sender:)))
        
        toolbarItems! += [space, cancelItem, flexSpaceItem, doneButtonItem, space]
        pickerToolbar.setItems(toolbarItems as? [UIBarButtonItem], animated: false)
        pickerToolbar.tintColor = self.textColorOfToolbar
        pickerToolbar.barTintColor = self.backgroundColorOfToolbar
        
        
        self.addSubview(pickerToolbar)
        self.addSubview(pickerView)
    }
    func showPicker() {
        if selectedRows == nil {
            selectedRows = getSelectedRows()
        }
        delegate?.pickerViewWillShow?(pickerView: pickerView)
        dataSource?.pickerViewWillShow?(pickerView: pickerView)
        let screenSize = UIScreen.main.bounds.size
        
        UIView.animate(withDuration: 0.2 ,animations: { () -> Void in
            
            self.frame = CGRect(x:0, y:screenSize.height - (self.heightOfToolbar + self.heightOfPickerView), width:screenSize.width, height:self.heightOfPickerView + self.heightOfToolbar)
            
        }) { (completed:Bool) -> Void in
            self.delegate?.pickerViewDidSHow?(pickerView: self.pickerView)
            self.dataSource?.pickerViewDidSHow?(pickerView: self.pickerView)
        }
    }
    
    
    
    @objc func cancelPicker(sender: AnyObject) {
        hidePicker()
        restoreSelectedRows()
        selectedRows = nil
    }
    @objc func endPicker(sender: AnyObject) {
        hidePicker()
        delegate?.pickerView?(pickerView: pickerView, didSelect: getSelectedRows())
        selectedRows = nil
    }
    private func hidePicker() {
        let screenSize = UIScreen.main.bounds.size
        delegate?.pickerViewWillHide?(pickerView: pickerView)
        UIView.animate(withDuration: 0.2 ,animations: { () -> Void in
            
            self.frame = CGRect(x:0, y:screenSize.height, width:screenSize.width, height:self.heightOfToolbar + self.heightOfPickerView)
            
        }) { (completed:Bool) -> Void in
            self.delegate?.pickerViewDidHide?(pickerView: self.pickerView)
        }
    }
    private func getSelectedRows() -> [Int] {
        var selectedRows = [Int]()
        for i in 0 ... pickerView.numberOfComponents - 1 {
            selectedRows.append(pickerView.selectedRow(inComponent: i))
        }
        return selectedRows
    }
    private func restoreSelectedRows() {
        for i in 0..<selectedRows!.count {
            pickerView.selectRow(selectedRows![i], inComponent: i, animated: true)
        }
    }
}

@objc
protocol AlertPickerViewDelegate: UIPickerViewDelegate {
    @objc optional func pickerView(pickerView: UIPickerView, didSelect numbers: [Int])
    @objc optional func pickerViewDidSHow(pickerView: UIPickerView)
    @objc optional func pickerViewDidHide(pickerView: UIPickerView)
    @objc optional func pickerViewWillHide(pickerView: UIPickerView)
    @objc optional func pickerViewWillShow(pickerView: UIPickerView)
    @objc optional func pickerViewDidShow(pickerView: UIPickerView)
    
}

@objc
protocol AlertPickerViewDataSource: UIPickerViewDataSource {
    @objc optional func pickerView(pickerView: UIPickerView, didSelect numbers: [Int])
    @objc optional func pickerViewDidSHow(pickerView: UIPickerView)
    @objc optional func pickerViewDidHide(pickerView: UIPickerView)
    @objc optional func pickerViewWillHide(pickerView: UIPickerView)
    @objc optional func pickerViewWillShow(pickerView: UIPickerView)
    @objc optional func pickerViewDidShow(pickerView: UIPickerView)
    
}
