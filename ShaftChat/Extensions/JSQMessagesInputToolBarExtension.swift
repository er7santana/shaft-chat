//
//  JSQMessagesInputToolBarExtension.swift
//  ShaftChat
//
//  Created by Eliezer Rodrigo on 04/09/19.
//  Copyright © 2019 Shaft Corporation. All rights reserved.
//

import Foundation
import JSQMessagesViewController

//extension JSQMessagesInputToolbar {
//
//    override open func didMoveToWindow() {
//        super.didMoveToWindow()
//        guard let window = window else { return }
//        if #available(iOS 11.0, *) {
//            guard let constraint = (superview?.constraints.first { $0.secondAnchor == bottomAnchor }) else { return }
//            let anchor = window.safeAreaLayoutGuide.bottomAnchor
//            NSLayoutConstraint.deactivate([constraint])
//            bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: anchor, multiplier: 1.5).isActive = true
//        }
//    }
//    
//}
