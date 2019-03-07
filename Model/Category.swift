//
//  Category.swift
//  Todoey
//
//  Created by ogya 1 on 07/03/19.
//  Copyright © 2019 ogya 1. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name : String = ""
    let items = List<Item>()
}
