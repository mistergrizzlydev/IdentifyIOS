//
//  UserDefaults.swift
//  Kimlik
//
//  Created by MacBookPro on 5.02.2021.
//

import Foundation

class UserDefaultService {
    
    static let shared = UserDefaultService()
    let userDefaults = UserDefaults.standard

    private init () {}
    
    func setValue(key: String, value: String) {
        userDefaults.setValue(value, forKey: key)
    }
    
    func setBool(key: String, value: Bool) {
        userDefaults.setValue(value, forKey: key)
    }
    
    func getValue(key: String) -> String {
        return userDefaults.string(forKey: key) ?? ""
    }
    
    func getBool(key: String) -> Bool {
        return userDefaults.bool(forKey: key)
    }
}

