//
//  EmojiGameViewController.swift
//  EmojiGame
//
//  Created by joanthan liu on 2018/8/30.
//  Copyright © 2018年 Butterfly Tech. All rights reserved.
//

import UIKit

class EmojiGameViewController: UIViewController {
    
    @IBOutlet weak var dropZone: UIView! {
        didSet { dropZone.addInteraction(UIDropInteraction(delegate: self)) }
    }

    var emojiGameView =  EmojiGameUIView()
    let manager = EmojiDataManager()
    
    
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.minimumZoomScale = 0.1
            scrollView.maximumZoomScale = 5.0
            scrollView.delegate = self
            scrollView.addSubview(emojiGameView)
        }
    }
    
    var emojiGameBackgroundImage: UIImage? {
        get {
            return emojiGameView.backgroundImage
        }
        
        set {
            scrollView?.zoomScale = 1.0
            emojiGameView.backgroundImage = newValue
            let size = newValue?.size ?? CGSize.zero
            emojiGameView.frame = CGRect(origin: CGPoint.zero, size: size)
            scrollView?.contentSize = size
            scrollViewWidth?.constant = size.width
            scrollViewHeight?.constant = size.height
            if let dropZone = self.dropZone, size.width > 0, size.height > 0 {
                scrollView?.zoomScale = max(dropZone.bounds.size.width / size.width, dropZone.bounds.size.height / size.height)
            }
        }
    }
    
    var imageFetcher: ImageFetcher!
    
    @IBOutlet weak var emojiCollectionView: UICollectionView! {
        didSet {
            emojiCollectionView.dataSource = self
            emojiCollectionView.delegate = self
            emojiCollectionView.dragDelegate = self
            emojiCollectionView.dropDelegate = self
        }
    }
    
    @IBOutlet weak var emojiBottomCollectionView: UICollectionView! {
        didSet {
            emojiBottomCollectionView.dataSource = self
            emojiBottomCollectionView.delegate = self
            emojiBottomCollectionView.dragDelegate = self
            emojiBottomCollectionView.dropDelegate = self
        }
    }
    
    private var font: UIFont {
        return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.preferredFont(forTextStyle: .body).withSize(64.0))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        EmojiDic.loadEmojiDataInKeyArray()
        initialize()
    }
}

extension EmojiGameViewController {
    func initialize() {
        manager.fetch()
    }
}

// Mark: Drop Interaction
extension EmojiGameViewController: UIDropInteractionDelegate {
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return //session.canLoadObjects(ofClass: NSURL.self) &&
            session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {

        session.loadObjects(ofClass: UIImage.self) { imageItems in
            let images = imageItems as! [UIImage]
            self.emojiGameBackgroundImage = images.first
        }
    }
}

// Mark: ScrollView
extension EmojiGameViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return emojiGameView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollViewWidth.constant = scrollView.contentSize.width
        scrollViewHeight.constant = scrollView.contentSize.height
    }
}

// Mark: CollectionView and drag
extension EmojiGameViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate, UICollectionViewDropDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollectionView {
            return EmojiDic.emojiKeyArray.count
        } else {
            return manager.numberOfItems()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiCVCell", for: indexPath)
            if let emojiCell = cell as? EmojiCollectionViewCell {
                let text = NSAttributedString(string: EmojiDic.emojiKeyArray[indexPath.item], attributes: [.font: font])
                emojiCell.emojiLabel.attributedText = text
            }
            return cell
        } else {
            let bottomCell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiBottomCVCell", for: indexPath)
            if let emojiBottomCell = bottomCell as? EmojiBottomCollectionViewCell {
                let item = manager.emojiBottom(at: indexPath)
                if let image = item.image {
                    emojiBottomCell.emojiBottomImage = UIImage(named: image)
                }
            }
            return bottomCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        if collectionView == emojiCollectionView {
            return dragItems(at: indexPath)
        } else {
            return dragBottomItems(at: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        if collectionView == emojiCollectionView {
            return dragItems(at: indexPath)
        } else {
            return dragBottomItems(at: indexPath)
        }
    }
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        if let attributedString = (emojiCollectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell)?.emojiLabel.attributedText {
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: attributedString))
            dragItem.localObject = attributedString
            return [dragItem]
        } else {
            return []
        }
    }
    
    private func dragBottomItems(at indexPath: IndexPath) -> [UIDragItem] {
        if let image = (emojiBottomCollectionView.cellForItem(at: indexPath) as? EmojiBottomCollectionViewCell)?.emojiBottomImageView.image {
            let dragBottomItem = UIDragItem(itemProvider: NSItemProvider(object: image))
            dragBottomItem.localObject = image
            return [dragBottomItem]
        } else {
            return []
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                if let attributedString = item.dragItem.localObject as? NSAttributedString {
                    collectionView.performBatchUpdates({
                        EmojiDic.emojiKeyArray.remove(at: sourceIndexPath.item)
                        EmojiDic.emojiKeyArray.insert(attributedString.string, at: destinationIndexPath.item)
                        collectionView.deleteItems(at: [sourceIndexPath])
                        collectionView.insertItems(at: [destinationIndexPath])
                    })
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                }
            } else {
                let placeHolderContext = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "dropPlaceHolderCell"))
                item.dragItem.itemProvider.loadObject(ofClass: NSAttributedString.self) { (provider, error) in
                    DispatchQueue.main.async {
                        if let attributedString = provider as? NSAttributedString {
                            placeHolderContext.commitInsertion(dataSourceUpdates: { insertionIndexPath in
                                EmojiDic.emojiKeyArray.insert(attributedString.string, at: insertionIndexPath.item)
                            })
                        } else {
                            placeHolderContext.deletePlaceholder()
                        }
                    }
                }
            }
        }
    }
}
