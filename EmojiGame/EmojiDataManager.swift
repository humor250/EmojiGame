//
//  EmojiDataManager.swift
//  EmojiGame
//
//  Created by joanthan liu on 2018/9/6.
//  Copyright © 2018年 Butterfly Tech. All rights reserved.
//

import Foundation

class EmojiDataManager: DataManager {
    fileprivate var items:[EmojiBottomItem] = []
    
    func fetch() {
        for data in load(file: "EmojiData") {
            items.append(EmojiBottomItem(dict: data))
        }
    }
    
    func numberOfItems() -> Int {
        return items.count
    }
    
    func emojiBottom(at index:IndexPath) -> EmojiBottomItem {
        return items[index.item]
    }
}
