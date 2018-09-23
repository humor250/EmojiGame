//
//  EmojiBottomItem.swift
//  EmojiGame
//
//  Created by joanthan liu on 2018/9/6.
//  Copyright © 2018年 Butterfly Tech. All rights reserved.
//

import Foundation

struct EmojiBottomItem {
    var name:String?
    var image:String?
}

extension EmojiBottomItem {
    init(dict:[String : AnyObject]) {
        self.name  = dict["name"] as? String
        self.image = dict["image"] as? String
    }
}
