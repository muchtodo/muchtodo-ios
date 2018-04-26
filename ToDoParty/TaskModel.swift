//
//  TaskModel.swift
//  ToDoParty
//
//  Created by Belle Beth Cooper on 18/2/18.
//  Copyright © 2018 Hello Code. All rights reserved.
//

import Foundation

class Task {
    let id: Int
    var name: String
    var parent: Task?
    var completable: Bool = true
    var complete: Bool = false
    var subtasks: [Task]? = nil
//    var startDate: Date?
    var dueDate: Date?
//    var repeats: Bool = false
    
    init(_ name: String, dueDate: Date?, parent: Task?) {
        self.name = name
        self.id = 1
        self.dueDate = dueDate ?? nil
        self.parent = parent ?? nil
        if self.parent == nil {
            self.completable = false
        }
    }
    
    
    private func createID() -> Int {
        // TODO: write method
        return 1
    }
}


func testTasks() -> [Task] {
    
    let personalList = Task("Personal", dueDate: nil, parent: nil)
    let newsletterTask = Task("Send newsletter", dueDate: Date(), parent: personalList)
    let monthlyReviewTask = Task("Write monthly review", dueDate: nil, parent: personalList)
    let binsTask = Task("Put out the bins", dueDate: Date().addingTimeInterval(60 * 60 * 24 * 3), parent: personalList)
    let vacuumTask = Task("Vacuum", dueDate:nil, parent: personalList)
    
    let blogList = Task("Blog posts to write", dueDate: nil, parent: nil)
    let bearTask = Task("How I use Bear", dueDate: nil, parent: blogList)
    let favAppsTask = Task("My favourite apps", dueDate: Date().addingTimeInterval(60 * 60 * 24), parent: blogList)
    let fastlaneTask = Task("Using Fastlane", dueDate: nil, parent: blogList)
    let favSwiftTask = Task("My favourite things about using Swift 4 so far", dueDate: Date(), parent:blogList)
    
    return [personalList, newsletterTask, monthlyReviewTask, binsTask, vacuumTask, blogList, bearTask, favAppsTask, fastlaneTask, favSwiftTask]
}


















