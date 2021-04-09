//
//  User.swift
//  HW1
//
//  Created by Ilya Doroshkevitch on 05.04.2021.
//

import Foundation
import RealmSwift

class User: Object {

    @objc dynamic var login = ""
    @objc dynamic var password = ""

    override static func primaryKey() -> String? {
       return "login"
     }


}
