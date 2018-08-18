//
//  TaskController.swift
//  MuchToDo
//
//  Created by Belle Beth Cooper on 18/2/18.
//  Copyright © 2018 Hello Code. All rights reserved.
//

import UIKit
import TableKit
import SnapKit
import PinLayout
import RealmSwift


class TaskController: UIViewController {
    let tasks: Results<Task>
    var tableView = UITableView()
    var tableDirector: TableDirector!
    var newTaskContainer = UIView()
    
    init(tasks: Results<Task>, title: String) {
        print("MainController init")
        self.tasks = tasks
        self.tableDirector = TableDirector(tableView: self.tableView)
        self.tableDirector.tableView?.allowsSelection = false
        super.init(nibName: nil, bundle: nil)
        self.title = title
        
        self.view.addSubview(self.newTaskContainer)
        let newTask = NewTask(nil)
        self.addChildViewController(newTask)
        self.newTaskContainer.addSubview(newTask.view)
        newTask.didMove(toParentViewController: self)
        self.newTaskContainer.pin.height(60).horizontally().top()
        self.newTaskContainer.layoutIfNeeded()
        newTask.view.pin.horizontally().top()

        self.view.addSubview(self.tableView)
        self.tableView.pin.horizontally().bottom().below(of: self.newTaskContainer).marginTop(20)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        print("MainController VDL")
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(sender:)), name: .UIKeyboardDidShow, object: nil)
        self.view.backgroundColor = UIColor.white
        self.tableView.separatorStyle = .none
        self.tableView.register(TaskCell.self, forCellReuseIdentifier: TaskCell.reuseIdentifier)
        loadCells()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.navigationBar.barTintColor = Styles.Colours.Pink.red
//        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 28.0, weight: UIFont.Weight.heavy), NSAttributedStringKey.kern: 1.2]
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    func loadCells() {
        print("MainController loadCells")
        
        let incomplete = self.tasks.filter { (task) -> Bool in
            task.complete == false
        }
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            print("ListCont loadCells - deleting: \(incomplete[indexPath.row].name) from \(String(describing: incomplete[indexPath.row].parent))")
            if let realm = realm {
                do {
                    try realm.write {
                        realm.delete(incomplete[indexPath.row])
                    }
                } catch {
                    print("ListCont loadCells - caught error deleting object in realm: \(error)")
                }
            }
        }
        delete.backgroundColor = Styles.Colours.Theme.iconTint
        
        let rows: [TableRow<TaskCell>] = incomplete.map({ TableRow<TaskCell>(item: $0, editingActions: [delete]) })
        let section = TableSection(rows: rows)
        section.headerHeight = CGFloat.leastNormalMagnitude
        section.footerHeight = CGFloat.leastNormalMagnitude
        tableDirector.append(section: section)
        tableDirector.reload()
    }
    
    
    @objc func openNewTask() {
        print("MainController openNewTask")
    }
    
    
    @objc func keyboardDidShow(sender: Notification) {
        guard let userInfo = sender.userInfo else { return }
        guard let frame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
//        self.tableView.pin.horizontally().bottom(self.view.frame.height - frame.height).below(of: self.newTaskContainer).marginTop(20)
    }
}


class TaskCell: UITableViewCell, ConfigurableCell {
    
    typealias T = Task
    var taskCellView: TaskCellView?
    
    static var estimatedHeight: CGFloat? {
        return 100
    }
    
    func configure(with task: Task) {
        self.taskCellView = TaskCellView(withTask: task, inContentView: self.contentView)
        separatorInset = .zero
    }
    
    
    func layout() {
        self.taskCellView?.sizeToFit()
        self.taskCellView?.layoutIfNeeded()
    }
    
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        // 1) Set the contentView's width to the specified size parameter
        self.contentView.pin.width(size.width)
        // 2) Layout the contentView's controls
        layout()
        // 3) Returns a size that contains all controls
        return CGSize(width: self.contentView.frame.width, height: (self.taskCellView?.frame.maxY ?? 20) + 12)
    }
}


class TaskCellView: UIView {
    
    var task: Task?
    
    var box: TaskButton?
    let taskName = UILabel()
    var dateLabel: UILabel?
    
    init(withTask task: Task, inContentView contentView: UIView) {
        self.task = task
        super.init(frame: CGRect.zero)
        if task.completable {
            
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: 16, height: 16))
            let img = renderer.image { ctx in
                ctx.cgContext.setFillColor(UIColor.clear.cgColor)
                ctx.cgContext.setStrokeColor(Styles.Colours.Grey.dark.cgColor)
                ctx.cgContext.setLineWidth(2)
                
                let rectangle = CGRect(x: 0, y: 0, width: 16, height: 16)
                let path = UIBezierPath(roundedRect: rectangle, cornerRadius: 5.0)
                ctx.cgContext.addPath(path.cgPath)
                ctx.cgContext.drawPath(using: .fillStroke)
            }
            
            self.box = TaskButton(task: task)
            self.box!.setImage(img, for: .normal)
            self.box!.tintColor = Styles.Colours.Grey.dark
            self.box!.addTarget(self, action: #selector(TaskCellView.buttonPressed(sender:)), for: .touchUpInside)
            self.addSubview(self.box!)
        }
        
        taskName.font = UIFont.systemFont(ofSize: 16.0)
        self.taskName.numberOfLines = 0
        self.taskName.lineBreakMode = .byWordWrapping
        taskName.text = task.name
        taskName.textColor = Styles.Colours.Grey.darkest
        if task.parent == nil {
            taskName.font = UIFont.boldSystemFont(ofSize: 18.0)
        }
        self.addSubview(self.taskName)
        
        if let due = task.dueDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            let dateString = dateFormatter.string(from: due)
            self.dateLabel = UILabel()
            self.dateLabel!.text = dateString
            self.dateLabel!.textColor = Styles.Colours.Grey.darkest
            self.dateLabel!.font = UIFont.systemFont(ofSize: 12.0)
            self.addSubview(self.dateLabel!)
        }
        
        contentView.addSubview(self)
    }
    
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        self.pin.width(size.width)
        layout()
        return CGSize(width: self.frame.size.width, height: self.taskName.frame.maxY + 12)
    }
    
    
    func layout() {
//        print("MainController self: \(self.frame), box: \(self.box?.frame) name: \(self.taskName.frame) date: \(self.dateLabel?.frame)")
        self.layoutIfNeeded()
//        print("MainController self: \(self.frame), box: \(self.box?.frame) name: \(self.taskName.frame) date: \(self.dateLabel?.frame)")
        self.pin.wrapContent(.vertically, padding: 12).horizontally()
//        print("MainController self: \(self.frame), box: \(self.box?.frame) name: \(self.taskName.frame) date: \(self.dateLabel?.frame)")
        if let box = self.box {
            box.pin.size(16).start(12).before(of: self.taskName, aligned: .center).marginEnd(12)
            self.taskName.pin.top().width(60%).sizeToFit(.width).after(of: box).marginStart(12)
        } else {
            self.taskName.pin.start(8).top().width(60%).sizeToFit(.width)
        }
        //        print("MainController self: \(self.frame), box: \(self.box?.frame) name: \(self.taskName.frame) date: \(self.dateLabel?.frame)")
        //        self.taskName.sizeToFit()
//        print("MainController self: \(self.frame), box: \(self.box?.frame) name: \(self.taskName.frame) date: \(self.dateLabel?.frame)")
        if let date = self.dateLabel {
            date.sizeToFit()
            date.pin.end(12).top()
        }
//        print("MainController self: \(self.frame), box: \(self.box?.frame) name: \(self.taskName.frame) date: \(self.dateLabel?.frame)")
    }
    
    
    @objc func buttonPressed(sender: TaskButton) {
        print("TaskCell buttonPressed - for task: \(sender.task.name)")
        if let realm = realm {
            do {
                try realm.write {
                    sender.task.complete = true
                }
            } catch {
                print("TaskCell buttonPressed - error updating completed for task: \(sender.task.name)")
            }
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class TaskButton: UIButton {
    
    let task: Task
    
    init(task: Task) {
        self.task = task
        super.init(frame: .zero)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

























