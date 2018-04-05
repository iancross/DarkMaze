//
//  File.swift
//  Dark Maze
//
//  Created by crossibc on 4/5/18.
//  Copyright © 2018 crossibc. All rights reserved.
//

import UIKit

class FadeSegue: UIStoryboardSegue{
    override func perform(){
        // Get the view of the source
        let sourceViewControllerView = self.source.view
        // Get the view of the destination
        let destinationViewControllerView = self.destination.view
        destinationViewControllerView?.backgroundColor = UIColor.black
        sourceViewControllerView?.backgroundColor = UIColor.black

        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height

        // Make the destination view the size of the screen
        destinationViewControllerView?.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)

        // Insert destination below the source
        // Without this line the animation works but the transition is not smooth as it jumps from white to the new view controller
        destinationViewControllerView?.alpha = 0;
        sourceViewControllerView?.alpha = 1;
        sourceViewControllerView?.insertSubview(destinationViewControllerView!, belowSubview: sourceViewControllerView!)
        // Animate the fade, remove the destination view on completion and present the full view controller
        UIView.animate(withDuration: 2, animations: {
            sourceViewControllerView?.alpha = 0;
        }, completion: nil)
        
        UIView.animate(withDuration: 2, animations: {
            destinationViewControllerView?.alpha = 1;
        }, completion: { (finished) in
            destinationViewControllerView?.removeFromSuperview()
            self.source.present(self.destination, animated: false, completion: nil)
        })

    }
}

//import UIKit
//
//class FadeSegue: UIStoryboardSegue {
//
//    var placeholderView: UIViewController?
//
//    override func perform() {
//        let screenWidth = UIScreen.main.bounds.size.width
//        let screenHeight = UIScreen.main.bounds.size.height
//
//        if let placeholder = placeholderView {
//            placeholder.view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
//
//            placeholder.view.alpha = 0
//            source.view.addSubview(placeholder.view)
//
//            UIView.animate(withDuration: 5, animations: {
//                placeholder.view.alpha = 1
//            }, completion: { (finished) in
//                self.source.present(self.destination, animated: false, completion: {
//                    placeholder.view.removeFromSuperview()
//                })
//            })
//        } else {
//            self.destination.view.alpha = 0.0
//
//            self.source.present(self.destination, animated: false, completion: {
//                UIView.animate(withDuration: 5, animations: {
//                    self.destination.view.alpha = 1.0
//                })
//            })
//        }
//    }
//}

