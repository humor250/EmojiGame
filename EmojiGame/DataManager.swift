//
//  DataManager.swift
//  EmojiGame
//
//  Created by joanthan liu on 2018/9/6.
//  Copyright © 2018年 Butterfly Tech. All rights reserved.
//

import Foundation

protocol DataManager {
    func load(file name:String) -> [[String : AnyObject]]
}

extension DataManager {
    func load(file name: String) -> [[String : AnyObject]] {
        guard let path = Bundle.main.path(forResource: name, ofType: "plist"),
            let items = NSArray(contentsOfFile: path) else { return [[:]] }
        
        return items as! [[String : AnyObject]]
    }
}
