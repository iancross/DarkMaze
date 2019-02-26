//
//  AudioController.swift
//  DarkMaze
//
//  Created by crossibc on 2/25/19.
//  Copyright © 2019 crossibc. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import Foundation
import CoreData

class AudioController{
    static let shared = AudioController()
    
    var backgroundAudioPlayer: AVAudioPlayer?
    
    //MARK Music
    
    init(){
    }
    
    public func playBackgroundMusic(){
        do {
            print ("things should be playing now!!!!!!!!!!!!!!!!!!!!")
            let url = Bundle.main.url(forResource: "background", withExtension: "mp3")!
            backgroundAudioPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundAudioPlayer!.prepareToPlay()
            backgroundAudioPlayer!.numberOfLoops = -1
            backgroundAudioPlayer!.play()
            
        } catch  {
            print ("error")
        }
    }
    
    public func backgroundToggledOnOff(){
        if let player = backgroundAudioPlayer{
            if isBackgroundMusicEnabled(){
                player.stop()
                flipSettingInCoreData(key: "backgroundMusicEnabled", newValue: false)
            }
            else{
                playBackgroundMusic()
                flipSettingInCoreData(key: "backgroundMusicEnabled", newValue: true)
            }
        }
    }

    
    public func initAudioSettings(){
        print ("this is being called")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("something bad app delegate ------------------------------------")
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let settingsEntity = NSEntityDescription.entity(forEntityName: "Settings",in: managedContext)!
        let settings = Settings(entity: settingsEntity, insertInto: managedContext)
        settings.backgroundMusicEnabled = true
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        playBackgroundMusic()
    }
    

    
    private func flipSettingInCoreData(key: String, newValue: Bool){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Settings")
        do {
            if let s = try managedContext.fetch(fetchRequest) as? [NSManagedObject]{
                if s.count > 0{
                    s[0].setValue(newValue, forKey: "backgroundMusicEnabled")
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    private func isBackgroundMusicEnabled() -> Bool{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return false
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Settings")
        do {
            if let s = try managedContext.fetch(fetchRequest) as? [NSManagedObject]{
                print ("the managed object is size of \(s.count)")
                if s.count > 0{
                    if let enabled = s[0].value(forKey: "backgroundMusicEnabled") as? Bool {
                        print ("we have the setting")
                        print ("the enabled bool in isBackgroundMusicEnabled is \(enabled)")
                        return enabled
                    }
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return false
    }
}

