//
//  alertable.swift
//  DarkMaze
//
//  Created by crossibc on 3/4/19.
//  Copyright © 2019 crossibc. All rights reserved.
//

import SpriteKit

protocol Alertable { }
extension Alertable where Self: SKScene {
    
    func showAlert(withTitle title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel) { _ in }
        alertController.addAction(okAction)
        
        view?.window?.rootViewController?.present(alertController, animated: true)
    }
    
    func showAlertWithSettings(withTitle title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel) { _ in }
        alertController.addAction(okAction)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        alertController.addAction(settingsAction)
        
        view?.window?.rootViewController?.present(alertController, animated: true)
    }
    
//    func showAlertWithOptions(withTitle title: String, message: String) -> Bool{
//        var continueWithReset = false
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        
//        let okAction = UIAlertAction(title: "OK", style: .default) {
//            _ in
//            reset
//        }
//        alertController.addAction(okAction)
//        let cancelAction = UIAlertAction(title: "Cancel", style: .default) {
//            _ in
//            continueWithReset = false
//        }
//        alertController.addAction(cancelAction)
//        
//        view?.window?.rootViewController?.present(alertController, animated: true)
//        return continueWithReset
//    }
}
