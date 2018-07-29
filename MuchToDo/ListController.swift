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
import RealmSwift


class ListController: UIViewController {
    var tableView = UITableView()
    var tableDirector: TableDirector!
    var newTaskContainer = UIView()
    var notificationToken: NotificationToken? = nil // used to observe realm changes
    
    
    init() {
        print("ListController init")
        self.tableDirector = TableDirector(tableView: self.tableView)
        super.init(nibName: nil, bundle: nil)
        self.view.addSubview(self.tableView)
        self.tableView.pin.all()
        
        setUpTasks()
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
        getRealmResults()
    }
    
    
    func getRealmResults() {
        guard let realm = realm else {
            print("ListController loadCells - can't access realm")
            return
        }
        let lists = realm.objects(Task.self).filter("parent == nil")
        self.notificationToken = lists.observe { [weak self] (changes) in
            self?.tableDirector.clear()
            self?.loadCells(with: lists)
        }
    }
    
    
    func loadCells(with lists: Results<Task>) {
        print("ListController loadCells")
        
        let action = TableRowAction<ListCell>(.click) { (options) in
            guard let realm = realm else {
                print("ListController loadCells action - can't get realm")
                return
            }
            let tasks = realm.objects(Task.self).filter("parent == %@", options.item)
            let taskController = TaskController(tasks: tasks, parent: options.item)
            self.navigationController?.pushViewController(taskController, animated: true)
        }
        
        let l = Array(lists)
        if let realm = realm {
            for t in l {
                let subs = realm.objects(Task.self).filter("parent == %@", t)
                t.count = subs.count
            }
        }
        let rows: [TableRow<ListCell>] = l.map({ TableRow<ListCell>(item: $0, actions: [action]) })
        let section = TableSection(rows: rows)
        section.headerHeight = CGFloat.leastNormalMagnitude
        section.footerHeight = CGFloat.leastNormalMagnitude
        tableDirector.append(section: section)
        tableDirector.reload()
    }
    
    
    func setUpTasks() {
        
        let personal = Task()
        personal.name = "Personal"
        let newsletter = Task()
        newsletter.name = "Send newsletter"
        newsletter.parent = personal
        let monthlyReview = Task()
        monthlyReview.name = "Write monthly review"
        monthlyReview.parent = personal
        monthlyReview.dueDate = Date().addingTimeInterval(60 * 60 * 24)
        
        let blog = Task()
        blog.name = "Blog posts to write"
        let bear = Task()
        bear.name = "How I use Bear and what notes I keep pinned"
        bear.parent = blog
        bear.dueDate = Date().addingTimeInterval(60 * 60 * 24 * 3)
        let testing = Task()
        testing.name = "Some of the libraries I've tried for testing apps on iOS and which ones are my favourites"
        testing.parent = blog
        testing.dueDate = Date().addingTimeInterval(60 * 60 * 24)
        
        let tasks = [personal, newsletter, monthlyReview, blog, bear, testing]
        
        if let realm = realm {
            do {
                try realm.write {
                    // set update:true so that if any of these already exist they'll be updated
                    // rather than causing an error because they're not unique
                    realm.add(tasks, update: true)
                }
            } catch {
                print("ListController setUpTasks - caught error writing to realm: \(error)")
            }
        }
    }
}


class ListCell: UITableViewCell, ConfigurableCell {
    
    typealias T = Task
    static var estimatedHeight: CGFloat? {
        return 100
    }
    
    let name = UILabel()
    let countLabel = UILabel()
    
    
    func configure(with task: Task) {
        separatorInset = .zero
        self.name.text = task.name
        self.name.font = UIFont.boldSystemFont(ofSize: 18.0)
        self.name.textColor = Styles.Colours.Grey.darkest
        self.contentView.addSubview(self.name)
        
        if task.count > 0 {
            self.countLabel.text = String(task.count)
        }
        self.countLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        self.countLabel.textColor = Styles.Colours.Pink.red
        self.contentView.addSubview(self.countLabel)
    }
    
    
    func layout() {
        self.name.sizeToFit()
        self.name.pin.vCenter().start(16)
        self.countLabel.sizeToFit()
        self.countLabel.pin.vCenter().end(16)
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


























