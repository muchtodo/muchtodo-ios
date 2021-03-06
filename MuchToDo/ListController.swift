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


class MainController: UIViewController {
    
    let smartLists = SmartListController()
    let userLists = ListController()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addChildViewController(self.smartLists)
        self.view.addSubview(self.smartLists.view)
        self.smartLists.didMove(toParentViewController: self)
        
        self.addChildViewController(self.userLists)
        self.view.addSubview(self.userLists.view)
        self.userLists.didMove(toParentViewController: self)
        
        self.smartLists.view.pin.top().horizontally()
        
//        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 28.0)]
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "add"),
                                                                 style: .done,
                                                                 target: self,
                                                                 action: #selector(self.addTask))
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 28.0, weight: UIFont.Weight.heavy), NSAttributedStringKey.kern: 1.2]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.title = "Your lists"
        if let navController = self.navigationController {
            navController.navigationBar.isTranslucent = false
            let gradient = CAGradientLayer()
            gradient.frame = self.view.bounds
            gradient.colors = [Styles.Colours.Theme.navBarDarkest.cgColor, Styles.Colours.Theme.navBarLightest.cgColor]
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 1, y: 1)
            var img: UIImage? = nil
            UIGraphicsBeginImageContext(gradient.frame.size)
            if let context = UIGraphicsGetCurrentContext() {
                gradient.render(in: context)
                img = UIGraphicsGetImageFromCurrentImageContext()
            }
            UIGraphicsEndImageContext()
            if let img = img {
                navController.navigationBar.barTintColor = UIColor(patternImage: img)
                navController.navigationBar.setNeedsLayout()
            }
        }
        
        self.smartLists.view.layoutIfNeeded()
        let height = self.smartLists.tableView.contentSize.height
        self.smartLists.view.pin.height(height)
        self.smartLists.tableView.pin.height(height)
        self.userLists.view.pin.below(of: smartLists.view).horizontally().bottom()
    }
    
    
    // MARK: - add task
    @objc func addTask() {
        let bg = UIView(frame: self.view.frame)
        bg.backgroundColor = UIColor.black
        bg.layer.opacity = 0.3
        self.view.addSubview(bg)
        self.view.bringSubview(toFront: bg)
        bg.pin.all()
        
        let newTask = NewTask(nil)
        newTask.onFinished = { newTask in
            newTask.view.removeFromSuperview()
            newTask.willMove(toParentViewController: nil)
            newTask.removeFromParentViewController()
            bg.removeFromSuperview()
        }
        self.addChildViewController(newTask)
        self.view.addSubview(newTask.view)
        newTask.didMove(toParentViewController: self)
        newTask.view.pin.width(90%).hCenter().top(20)
        newTask.view.layer.cornerRadius = 14.0
        self.view.layoutIfNeeded()
    }
}


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
        self.tableView.separatorStyle = .none
        self.tableView.register(ListCell.self, forCellReuseIdentifier: ListCell.reuseIdentifier)
        
        getRealmResults()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.navigationBar.barTintColor = Styles.Colours.Pink.red
//        self.navigationController?.navigationBar.tintColor = UIColor.white
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
            let taskController = TaskController(tasks: tasks, title: options.item.name)
            self.navigationController?.pushViewController(taskController, animated: true)
        }
        
        var l = Array(lists)
        if let realm = realm {
            for t in l {
                if t.name == "Inbox" {
                    l.remove(at: l.index(of: t)!)
                }
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
        
        let inbox = Task()
        inbox.name = "Inbox"
        
        let personal = Task()
        personal.name = "Personal"
        let newsletter = Task()
        newsletter.name = "Send newsletter"
        newsletter.parent = personal
        newsletter.dueDate = Date()
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
    let countView = UIView()
    var icon: UIImageView?
    
    
    func configure(with task: Task) {
        let backgroundView = UIView()
        backgroundView.backgroundColor = Styles.Colours.Theme.cellSelect
        self.selectedBackgroundView = backgroundView
        
        separatorInset = .zero
        self.name.text = task.name
        self.name.font = UIFont.boldSystemFont(ofSize: 18.0)
        self.name.textColor = Styles.Colours.Grey.darkest
        self.contentView.addSubview(self.name)
        
        if let imgName = task.iconName {
            self.icon = UIImageView()
            self.icon!.image = UIImage(named: imgName)?.withRenderingMode(.alwaysTemplate)
            self.icon?.contentMode = .scaleAspectFit
            self.icon?.tintColor = Styles.Colours.Theme.iconTint
            self.contentView.addSubview(self.icon!)
        }
        
        if task.count > 0 {
            self.countLabel.text = String(task.count)
            self.countLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
            self.countLabel.textColor = UIColor.white
            self.countView.addSubview(self.countLabel)
            self.countView.backgroundColor = Styles.Colours.Theme.counterBackground
            self.countView.layer.cornerRadius = 11.0
            self.contentView.addSubview(self.countView)
        }
        
    }
    
    
    func layout() {
        if let icon = self.icon {
            icon.pin.start(18).vCenter().width(22).sizeToFit(.width)
//            icon.sizeToFit()
            self.name.sizeToFit()
            self.name.pin.after(of: icon, aligned: .center).marginStart(12)
        } else {
            self.name.sizeToFit()
            self.name.pin.vCenter().start(22)
        }
        self.countLabel.sizeToFit()
        self.countLabel.pin.center()
        self.countView.pin.wrapContent(padding: PEdgeInsets(top: 3, left: 12, bottom: 3, right: 12)).vCenter().end(16)
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


// MARK: - smart lists

class SmartListController: UIViewController {
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
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        print("SmartListController VDL")
        super.viewDidLoad()
        self.tableView.separatorStyle = .none
        self.tableView.register(SmartListCell.self, forCellReuseIdentifier: ListCell.reuseIdentifier)
        let lists = setUpSmartLists()
        getRealmResults(lists: lists)
    }
    
    
    func setUpSmartLists() -> [SmartList] {
        let inbox = SmartList(name: "Inbox", iconName: "inbox", count: 0, type: .Inbox)
        let today = SmartList(name: "Today", iconName: "pin", count: 0, type: .Today)
        let week = SmartList(name: "This week", iconName: "calendar", count: 0, type: .ThisWeek)
        let all = SmartList(name: "All tasks", iconName: "files", count: 0, type: .All)
        return [inbox, today, week, all]
    }
    
    
    func getRealmResults(lists: [SmartList]) {
        guard let realm = realm else {
            print("ListController loadCells - can't access realm")
            return
        }
        let cal = Calendar.autoupdatingCurrent
        let todayStart = cal.startOfDay(for: Date())
        let todayEnd: Date? = {
            let components = DateComponents(day: 1, second: -1)
            return cal.date(byAdding: components, to: todayStart)
        }()
        let weekEnd: Date? = {
            let comps = DateComponents(hour: 11, minute: 59, second: 59, weekday: 1)
            return cal.nextDate(after: Date(), matching: comps, matchingPolicy: .strict)
        }()
        var newLists = [SmartList]()
        for l in lists {
            switch l.type {
            case .Inbox:
                var count = 0
                let inboxQ = realm.objects(Task.self).filter("name == %@", "Inbox AND complete == false")
                if inboxQ.count > 0 {
                    count = inboxQ.count
                }
                newLists.append(SmartList(name: l.name, iconName: "inbox", count: count , type: .Inbox))
            case .All:
                newLists.append(SmartList(name: l.name, iconName: "files", count: realm.objects(Task.self).filter("parent != nil AND complete == false").count, type: .All))
            case .Today:
                newLists.append(SmartList(name: l.name, iconName: "pin", count: realm.objects(Task.self).filter("dueDate BETWEEN %@ AND complete == false", [todayStart, todayEnd]).count, type: .Today))
            case .ThisWeek:
                newLists.append(SmartList(name: l.name, iconName: "calendar", count: realm.objects(Task.self).filter("dueDate BETWEEN %@ AND complete == false", [todayStart, weekEnd]).count, type: .ThisWeek))
            }
        }
        self.tableDirector.clear()
        loadCells(with: newLists)
    }
    
    
    func loadCells(with lists: [SmartList]) {
        print("ListController loadCells")
        
        let action = TableRowAction<SmartListCell>(.click) { (options) in
            print("ListCont loadCells action - \(options.item.name)")
            guard let realm = realm else {
                print("ListController loadCells action - can't get realm")
                return
            }
            let cal = Calendar.autoupdatingCurrent
            let todayStart = cal.startOfDay(for: Date())
            let todayEnd: Date? = {
                let components = DateComponents(day: 1, second: -1)
                return cal.date(byAdding: components, to: todayStart)
            }()
            let weekEnd: Date? = {
                let comps = DateComponents(hour: 11, minute: 59, second: 59, weekday: 1)
                return cal.nextDate(after: Date(), matching: comps, matchingPolicy: .strict)
            }()
            
            var tasks: Results<Task>
            var title = ""
            switch options.item.type {
            case .Inbox:
                let inboxQ = realm.objects(Task.self).filter("name == %@", "Inbox AND complete == false")
                guard inboxQ.count > 0 else { return }
                tasks = realm.objects(Task.self).filter("parent == %@ AND complete == false", inboxQ[0])
                title = "Inbox"
            case .All:
                tasks = realm.objects(Task.self).filter("parent != nil AND complete == false")
                title = "All tasks"
            case .Today:
                tasks = realm.objects(Task.self).filter("dueDate BETWEEN %@ AND complete == false", [todayStart, todayEnd])
                print("ListCont loadCells - today tasks: \(tasks)")
                title = "Today"
            case .ThisWeek:
                tasks = realm.objects(Task.self).filter("dueDate BETWEEN %@ AND complete == false", [todayStart, weekEnd])
                title = "This week"
            }
            let taskController = TaskController(tasks: tasks, title: title)
            self.navigationController?.pushViewController(taskController, animated: true)
        }
        
        let l = Array(lists)
        let rows: [TableRow<SmartListCell>] = l.map({ TableRow<SmartListCell>(item: $0, actions: [action]) })
        let section = TableSection(rows: rows)
        section.headerHeight = CGFloat.leastNormalMagnitude
        section.footerHeight = CGFloat.leastNormalMagnitude
        tableDirector.append(section: section)
        tableDirector.reload()
    }
}


enum SmartListType {
    case Inbox
    case Today
    case ThisWeek
    case All
}


struct SmartList {
    let name: String
    var iconName: String
    var count: Int = 0
    let type: SmartListType
}


class SmartListCell: UITableViewCell, ConfigurableCell {
    
    typealias T = SmartList
    static var estimatedHeight: CGFloat? {
        return 100
    }
    
    let name = UILabel()
    var countLabel: UILabel?
    var countView: UIView?
    var icon = UIImageView()
    
    
    func configure(with list: SmartList) {
        let backgroundView = UIView()
        backgroundView.backgroundColor = Styles.Colours.Theme.cellSelect
        self.selectedBackgroundView = backgroundView
        
        separatorInset = .zero
        self.name.text = list.name
        self.name.font = UIFont.boldSystemFont(ofSize: 18.0)
        self.name.textColor = Styles.Colours.Grey.darkest
        self.contentView.addSubview(self.name)
        
        icon.image = UIImage(named: list.iconName)?.withRenderingMode(.alwaysTemplate)
        icon.tintColor = Styles.Colours.Theme.iconTint
        self.contentView.addSubview(self.icon)
        
        if list.count > 0 {
            self.countLabel = UILabel()
            self.countLabel!.text = String(list.count)
            self.countLabel!.font = UIFont.boldSystemFont(ofSize: 14.0)
            self.countLabel!.textColor = UIColor.white
            self.countView = UIView()
            self.countView!.addSubview(self.countLabel!)
            self.countView!.backgroundColor = Styles.Colours.Theme.counterBackground
            self.countView!.layer.cornerRadius = 11.0
            self.contentView.addSubview(self.countView!)
        }
    }
    
    
    func layout() {
        self.icon.pin.size(18).start(22).vCenter()
        self.icon.sizeToFit()
        self.name.sizeToFit()
        self.name.pin.after(of: self.icon, aligned: .center).marginStart(12)
        
        if let countLabel = self.countLabel {
            countLabel.sizeToFit()
            countLabel.pin.center()
        }
        if let countView = self.countView {
            countView.pin.wrapContent(padding: PEdgeInsets(top: 3, left: 12, bottom: 3, right: 12)).vCenter().end(16)
            contentView.pin.wrapContent(.vertically, padding: 12)
        }
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






























