//
//  Item.swift
//  Todoey
//
//  Created by ogya 1 on 07/03/19.
//  Copyright © 2019 ogya 1. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title : String = ""
    @objc dynamic var done : Bool = false
    let parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
