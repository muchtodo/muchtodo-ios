//
//  ViewController.swift
//  ToDoParty
//
//  Created by Belle Beth Cooper on 18/2/18.
//  Copyright © 2018 Hello Code. All rights reserved.
//

import UIKit
import TableKit
import SnapKit


class MainController: UIViewController {
    let tasks = testTasks()
    var tableView = UITableView()
    var tableDirector: TableDirector!
    
    init() {
        
        self.tableDirector = TableDirector(tableView: self.tableView)
        self.tableDirector.tableView?.separatorStyle = .none
        super.init(nibName: nil, bundle: nil)
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Your tasks"
        
        self.tableView.separatorStyle = .none
        self.tableView.register(TaskCell.self, forCellReuseIdentifier: TaskCell.reuseIdentifier)
        
        loadCells()
    }
    
    func loadCells() {
        let rows = tasks.map({ TableRow<TaskCell>(item: $0) })
        tableDirector += rows
        tableDirector.reload()
    }
}


class TaskCell: UITableViewCell, ConfigurableCell {
    
    typealias T = Task
    var taskCellView: TaskCellView?
    
    static var estimatedHeight: CGFloat? {
        return 100
    }
    
    func configure(with task: Task) {
        self.taskCellView = TaskCellView(withTask: task)
        contentView.addSubview(self.taskCellView!)
        separatorInset = .zero
    }
}


class TaskCellView: UIView {
    
    var task: Task?
    
    let box = UIButton()
    let taskName = UILabel()
    let dateLabel = UILabel()
    
    init(withTask task: Task) {
        self.task = task
        super.init(frame: CGRect.zero)
        
        let hStack = UIStackView(frame: CGRect.zero)
        hStack.axis = .horizontal
        
        if task.completable {
            box.setImage(UIImage(named: "taskbox")?.withRenderingMode(.alwaysTemplate), for: .normal)
            box.tintColor = UIColor(red:0.32, green:0.40, blue:0.56, alpha:1.0)
            box.addTarget(self, action: #selector(TaskCellView.buttonPressed), for: .touchUpInside)
            hStack.addArrangedSubview(box)
        }
        
        
        taskName.font = UIFont(name: "FiraSans-Regular", size: 16.0)
        taskName.text = task.name
        taskName.textColor = UIColor(red:0.32, green:0.40, blue:0.56, alpha:1.0)
        if task.parent == nil {
            taskName.font = UIFont(name: "FiraSans-Bold", size: 19.0)
        }
        hStack.addArrangedSubview(taskName)
        self.addSubview(hStack)
        
        if let due = task.dueDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            let dateString = dateFormatter.string(from: due)
            dateLabel.text = dateString
            dateLabel.textColor = UIColor(red:0.20, green:0.23, blue:0.34, alpha:1.0)
            dateLabel.font = UIFont(name: "FiraSans-Regular", size: 12.0)
            
            let vStack = UIStackView(arrangedSubviews: [hStack, dateLabel])
            vStack.axis = .vertical
            hStack.removeFromSuperview()
            self.addSubview(vStack)
        }
    }
    
    
    @objc func buttonPressed() {
        print("button pressed")
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

























