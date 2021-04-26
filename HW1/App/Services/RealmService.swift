//
//  RealmService.swift
//  HW1
//
//  Created by Ilya Doroshkevitch on 05.04.2021.
//
import Foundation
import RealmSwift
import UIKit

protocol RealmServiceDelegate: class {
    func goToMainViewController()
    func registerSuccess()
    func passwordChanged()
    func noSuchLoginExists()
    func passwordIsIncorrect()
}

class RealmService {

    let realm = try! Realm()
    let coordinates = CoordinatesToStore()
    weak var delegate: RealmServiceDelegate?

    // MARK: - Login methods
    func registerUser(login: String, password: String) {
        guard let user = realm.object(ofType: User.self, forPrimaryKey: login) else {
            try! realm.write {
                let user = User()
                user.login = login
                user.password = password
                realm.add(user)
                print("Register success")
                delegate?.registerSuccess()
            }
            return
        }
        try! realm.write {
            // Change password if user already registered
            user.password = password
            print("Password changed")
            delegate?.passwordChanged()
        }
    }

    func checkLogin(login: String, password: String) {
        guard let user = realm.object(ofType: User.self, forPrimaryKey: login) else {
            print("No such login exists");
            delegate?.noSuchLoginExists();
            return }

        if ((user.password.isEqual(password))) {
            print("Login OK, go to MainViewController")
            delegate?.goToMainViewController()
        } else {
            print("Password is incorrect")
            delegate?.passwordIsIncorrect()
        }
    }


    // MARK: - Map methods
    func lastTrack() -> Results<CoordinatesToStore> {
        realm.objects(CoordinatesToStore.self)
    }

    func savePath(coordinates: String) {
        try! realm.write {
            self.coordinates.toStore = coordinates
            realm.add(self.coordinates)
        }
    }
 }


