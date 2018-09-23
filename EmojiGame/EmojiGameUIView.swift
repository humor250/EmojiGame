//
//  EmojiGameUIView.swift
//  EmojiGame
//
//  Created by joanthan liu on 2018/8/30.
//  Copyright © 2018年 Butterfly Tech. All rights reserved.
//

import UIKit
import AVFoundation

class EmojiGameUIView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init? (coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        addInteraction(UIDropInteraction(delegate: self))
    }
    
    var backgroundImage: UIImage? { didSet { setNeedsDisplay() }}
    
    override func draw(_ rect: CGRect) {
        backgroundImage?.draw(in: bounds) 
    }
    
    var emojiDataManager: EmojiDic?
    
}

extension EmojiGameUIView: UIDropInteractionDelegate {
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, item: UIDragItem, willAnimateDropWith animator: UIDragAnimating) {
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: NSAttributedString.self) { providers in
            for attributedString in providers as? [NSAttributedString] ?? [] {
                let dropPoint = session.location(in: self)
                let newLabel = self.addLabel(with: attributedString, centeredAt: dropPoint)
                newLabel.frame.size = CGSize(width: 320, height: 136)
                newLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
                newLabel.numberOfLines = 3
                UIView.animate(withDuration: 0.1, delay: 0, animations: { () -> Void in
                    newLabel.alpha = 0.0
                }) { (_) -> Void in
                    let font = UIFont.systemFont(ofSize: 56)
                    let shadow = NSShadow()
                    shadow.shadowColor = UIColor.red
                    shadow.shadowBlurRadius = 5
                    let attributes: [NSAttributedStringKey: Any] = [
                        .font: font,
                        .foregroundColor: UIColor.purple,
                        .shadow: shadow
                    ]
                    let emojiName = EmojiDic.emojiKeyValueDict[attributedString.string]
                    let emojiNameOnView = emojiName?.replacingOccurrences(of: "_", with: " ")
                    newLabel.attributedText = NSAttributedString(string: emojiNameOnView!, attributes: attributes)
                    UIView.animate(withDuration: 3, delay: 0, animations: { () -> Void in
                        newLabel.alpha = 1.0
                    }, completion: { (_) -> Void in
                        newLabel.attributedText = attributedString
                        EmojiSays.shared.say(sentence: attributedString)
                        
                    })
                }
            }
        }
    }
    
    func addLabel(with attributedString: NSAttributedString, centeredAt point: CGPoint) -> UILabel {
        let label = UILabel()
        label.backgroundColor = .clear
        label.attributedText = attributedString
        label.sizeToFit()
        label.frame.size = CGSize(width: 68, height: 68)
        label.center = point
        addEmojiGestureRecognizers(to: label)
        addSubview(label)
        return label
    }
}

extension EmojiGameUIView {
    
    ///
    /// Add gesture recognizers to the given view
    ///
    func addEmojiGestureRecognizers(to view: UIView) {
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectSubview(by:))))
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(selectAndMoveSubview(by:))))
    }
    
    ///
    /// The selected subview (if any), nil otherwise
    ///
    var selectedSubview: UIView? {
        get {
            // Selected views have a border with greater than 0
            return subviews.filter{ $0.layer.borderWidth > 0 }.first
        }
        set {
            // De-select all subviews first
            subviews.forEach{ $0.layer.borderWidth = 0 }
            
            // If there is a newValue set, "select it" (add border)
            newValue?.layer.borderWidth = newValue!.bounds.size.height / 20.0
            newValue?.layer.borderColor = UIColor.yellow.cgColor
            
            if newValue != nil {
                // Enable gesture-recognizers for the selected subview (i.e. we want to pan
                // on the selected subview and not in the content scrollview)
                enableRecognizers()
            }
            else {
                // Disable gesture-recognizers for the selected subview (so that others
                // i.e. scrollView pan/zoom work)
                disableRecognizers()
            }
        }
    }
    
    ///
    /// Select the the touched/tapped subview
    ///
    @objc private func selectSubview(by recognizer: UITapGestureRecognizer) {
        
        // Make sure the gesture is in valid state
        guard recognizer.state == .ended else {
            return
        }
        
        // Select it
        selectedSubview = recognizer.view
    }
    
    ///
    /// Pan gestures allow to move subview around
    ///
    @objc private func selectAndMoveSubview(by recognizer: UIPanGestureRecognizer) {
        
        switch recognizer.state {
        // If the view is not selected already, select it
        case .began:
            if selectedSubview != nil, recognizer.view != nil {
                selectedSubview = recognizer.view
                sendToFront(selectedSubview!)
            }
        // When panning, update view's position accordingly
        case .changed, .ended:
            if selectedSubview != nil {
                recognizer.view?.center = recognizer.view!.center.offset(by: recognizer.translation(in: self))
                recognizer.setTranslation(CGPoint.zero, in: self)
            }
        // Ignore other(s)
        default:
            break
        }
    }
    
    ///
    /// Move the given `view` to the front. For instance, dragging a subview will send it to the front to allow the
    /// user to re-arrange them as they wish.
    ///
    private func sendToFront(_ view: UIView) {
        if let indexOfSubview = subviews.index(of: view) {
            exchangeSubview(at: subviews.count-1, withSubviewAt: indexOfSubview)
        }
    }
    
    ///
    /// Enable emoji-gesture-recognizers.
    ///
    private func enableRecognizers() {
        // Disable any conflicting gesture-reconizers from parent scroll-view
        if let scrollView = superview as? UIScrollView {
            scrollView.panGestureRecognizer.isEnabled = false
            scrollView.pinchGestureRecognizer?.isEnabled = false
        }
        
        // Add gesture recognizers if needed
        if gestureRecognizers == nil || gestureRecognizers!.count == 0 {
            addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(deselectSubview)))
            addGestureRecognizer(
                UIPinchGestureRecognizer(target: self, action: #selector(resizeSelectedLabel(by:))))
        }
        else {
            gestureRecognizers?.forEach { $0.isEnabled = true }
        }
    }
    
    ///
    /// Disable emoji-gesture-recognizers.
    ///
    private func disableRecognizers() {
        // Enable gesture-reconizers from parent scroll-view
        if let scrollView = superview as? UIScrollView {
            scrollView.panGestureRecognizer.isEnabled = true
            scrollView.pinchGestureRecognizer?.isEnabled = true
        }
        
        gestureRecognizers?.forEach { $0.isEnabled = false }
    }
    
    ///
    /// Deselect any possibly selected subview
    ///
    @objc private func deselectSubview() {
        selectedSubview = nil
    }
    
    ///
    /// Pinching allows to resize the label
    ///
    @objc private func resizeSelectedLabel(by recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed, .ended:
            // Only UILabels should be resized
            if let label = selectedSubview as? UILabel {
                label.attributedText = label.attributedText?.withFontScaled(by: recognizer.scale)
                label.stretchToFit()
                label.layer.borderWidth = label.bounds.size.height/20.0
                recognizer.scale = 1.0
            }
        default:
            break
        }
    }
}
