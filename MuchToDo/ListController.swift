//
//  ListController.swift
//  ToDoParty
//
//  Created by Belle Beth Cooper on 18/2/18.
//  Copyright © 2018 Hello Code. All rights reserved.
//

import Foundation
import UIKit
import TableKit
import PinLayout


class ListController: UIViewController {
    lazy var lists: [Task] = {
        let personal = Task("Personal", dueDate: nil, parent: nil)
        let errands = Task("Errands", dueDate: nil, parent: nil)
        let work = Task("Work", dueDate: nil, parent: nil)
        let shopping = Task("Shopping", dueDate: nil, parent: nil)
        let goals = Task("Goals", dueDate: nil, parent: nil)
        let projects = Task("Project ideas", dueDate: nil, parent: nil)
        
        return [personal, errands, work, shopping, goals, projects]
    }()
    var tableView = UITableView()
    var tableDirector: TableDirector!
    var newTaskContainer = UIView()
    
    init() {
        print("ListController init")
        self.tableDirector = TableDirector(tableView: self.tableView)
        self.tableDirector.tableView?.allowsSelection = false
        super.init(nibName: nil, bundle: nil)
        self.view.addSubview(self.tableView)
        self.tableView.pin.all()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        print("ListController VDL")
        super.viewDidLoad()
        
        self.title = "Your lists"
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 28.0)]
        self.tableView.separatorStyle = .none
        self.tableView.register(ListCell.self, forCellReuseIdentifier: ListCell.reuseIdentifier)
        loadCells()
    }
    
    func loadCells() {
        print("ListController loadCells")
        
        let action = TableRowAction<ListCell>(.click) { (options) in
            let tasks: [Task] = {
                let blogList = Task("Blog posts to write", dueDate: nil, parent: nil)
                let bearTask = Task("How I use Bear", dueDate: nil, parent: blogList)
                let testingTask = Task("Some of the libraries I've tried for testing apps on iOS and which ones are my favourites", dueDate: Date().addingTimeInterval(60 * 60 * 24 * 4), parent: blogList)
                let favAppsTask = Task("My favourite apps", dueDate: Date().addingTimeInterval(60 * 60 * 24), parent: blogList)
                let fastlaneTask = Task("Using Fastlane", dueDate: nil, parent: blogList)
                let favSwiftTask = Task("My favourite things about using Swift 4 so far", dueDate: Date(), parent:blogList)
                return [bearTask, testingTask, favAppsTask, fastlaneTask, favSwiftTask]
            }()
            let taskController = TaskController(tasks: tasks)
            self.navigationController?.pushViewController(taskController, animated: true)
        }
        
        let rows = self.lists.map({ TableRow<ListCell>(item: $0, actions: [action]) })
        let section = TableSection(rows: rows)
        section.headerHeight = CGFloat.leastNormalMagnitude
        section.footerHeight = CGFloat.leastNormalMagnitude
        tableDirector.append(section: section)
        tableDirector.reload()
    }
}


class ListCell: UITableViewCell, ConfigurableCell {
    
    typealias T = Task
    static var estimatedHeight: CGFloat? {
        return 100
    }
    
    let name = UILabel()
    
    func configure(with task: Task) {
        separatorInset = .zero
        self.name.text = task.name
        self.name.font = UIFont.boldSystemFont(ofSize: 16.0)
        self.name.textColor = Styles.Colours.Pink.dark
        self.contentView.addSubview(self.name)
    }
    
    
    func layout() {
        self.name.sizeToFit()
        self.name.pin.vCenter()
        self.contentView.pin.wrapContent(.vertically, padding: 12)
    }
    
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        // 1) Set the contentView's width to the specified size parameter
        self.contentView.pin.width(size.width)
        // 2) Layout the contentView's controls
        layout()
        // 3) Returns a size that contains all controls
        return CGSize(width: self.contentView.frame.width, height: (self.name.frame.maxY) + 12)
    }
}


























