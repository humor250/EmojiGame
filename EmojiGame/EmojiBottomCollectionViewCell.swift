//
//  EmojiBottomCollectionViewCell.swift
//  EmojiGame
//
//  Created by joanthan liu on 2018/9/2.
//  Copyright © 2018年 Butterfly Tech. All rights reserved.
//

import UIKit

class EmojiBottomCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var emojiBottomImageView: UIImageView!
    var emojiBottomImage: UIImage! {
        didSet {
            self.emojiBottomImageView.image = emojiBottomImage
            self.setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
