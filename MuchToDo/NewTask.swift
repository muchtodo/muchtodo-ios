//
//  NewTask.swift
//  ToDoParty
//
//  Created by Belle Beth Cooper on 6/5/18.
//  Copyright © 2018 Hello Code. All rights reserved.
//

import Foundation
import UIKit
import PinLayout


class NewTask: UIViewController {
    
    private var taskEntry: NewTaskView?
    
    init(_ parent: Task?) {
        super.init(nibName: nil, bundle: nil)
        self.view.accessibilityIdentifier = "NewTaskController view"
        self.view.backgroundColor = UIColor.white
        self.taskEntry = NewTaskView(parent)
        self.view.addSubview(self.taskEntry!)
        self.taskEntry!.pin.height(60)
        self.view = self.taskEntry!
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.taskEntry?.taskEntry.becomeFirstResponder()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class NewTaskView: UIView {
    
    var parentTask: Task?
    let taskEntry = UITextField()
    
    init(_ parent: Task?) {
        self.parentTask = parent
        super.init(frame: CGRect.zero)
        self.backgroundColor = Styles.Colours.Pink.red
        self.clipsToBounds = true
        self.taskEntry.delegate = taskEntryDelegate()
        self.addSubview(self.taskEntry)
        self.taskEntry.placeholder = "Buy groceries tomorrow #errands"
        self.taskEntry.backgroundColor = Styles.Colours.Pink.red
        self.taskEntry.tintColor = Styles.Colours.Pink.light
        self.taskEntry.font = UIFont.boldSystemFont(ofSize: 18.0)
        self.taskEntry.textColor = Styles.Colours.Pink.light
    }
    
    
    override func layoutSubviews() {
        print("NewTask layoutSubviews")
        super.layoutSubviews()
        self.taskEntry.sizeToFit()
        self.taskEntry.pin.start(12).vCenter().maxWidth(75%)
        self.taskEntry.becomeFirstResponder()
        
        let plus = UIImage(named: "circle_tick")?.withRenderingMode(.alwaysTemplate)
        let add = UIButton()
        add.setBackgroundImage(plus, for: .normal)
        add.tintColor = Styles.Colours.Pink.light
        add.addTarget(self, action: #selector(self.addTask), for: .touchUpInside)
        self.addSubview(add)
        
        add.sizeToFit()
        add.pin.end(12).size(22).vCenter()
    }
    
    
    @objc func addTask() {
        print("NewTask addTask button pressed")
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class taskEntryDelegate: NSObject, UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("taskEntryDelegate textFieldDidBegin - text: \(String(describing: textField.text))")
    }
}
































