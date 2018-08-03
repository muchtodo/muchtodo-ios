//
//  TaskModel.swift
//  ToDoParty
//
//  Created by Belle Beth Cooper on 18/2/18.
//  Copyright © 2018 Hello Code. All rights reserved.
//

import Foundation
import RealmSwift


class Task: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var parent: Task? = nil {
        didSet {
            self.completable = true
            self.iconName = nil
        }
    }
    @objc dynamic var completable: Bool = false
    @objc dynamic var complete: Bool = false
    @objc dynamic var dueDate: Date?
    @objc dynamic var count: Int = 0
    @objc dynamic var iconName: String? = "list"
    
    
    override static func indexedProperties() -> [String] {
        return ["name, dueDate, complete"]
    }
    
    
    override static func ignoredProperties() -> [String] {
        return ["count"]
    }
    
    
    override static func primaryKey() -> String? {
        return "name"
    }
    
    // TODO: add primary key of id once I figure out how to create random id for each new task
}


















