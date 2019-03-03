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
    let BACKGROUND_VOLUME:Float = 0.7
    var backgroundAudioPlayer: AVAudioPlayer?
    var soundEffectsAudioPlayer: AVAudioPlayer?
    
    
    //MARK Music
    
    init(){
    }
    
    public func levelOpenClose(){
        //if isSettingEnabled(settingName: "Game Sounds"){
        do {
            if let url = Bundle.main.url(forResource: "levelOpenClose", withExtension: "wav"){
                soundEffectsAudioPlayer = try AVAudioPlayer(contentsOf: url)
                soundEffectsAudioPlayer!.prepareToPlay()
                soundEffectsAudioPlayer!.numberOfLoops = 0
                soundEffectsAudioPlayer!.play()
            }
        } catch  {
            print ("error")
        }
    }
    
    public func playBackgroundMusic(){
        do {
            if let url = Bundle.main.url(forResource: "background", withExtension: "mp3"){
                backgroundAudioPlayer = try AVAudioPlayer(contentsOf: url)
                backgroundAudioPlayer!.prepareToPlay()
                backgroundAudioPlayer!.numberOfLoops = -1
                backgroundAudioPlayer!.volume = BACKGROUND_VOLUME
                
                if isSettingEnabled(settingName: "ambientSounds"){
                    print ("things should be playing now!!!!!!!!!!!!!!!!!!!!")
                    backgroundAudioPlayer!.play()
                }
            }
        } catch  {
            print ("error")
        }
    }
    
    public func backgroundToggledOnOff(){
        print ("backgroundToggleOnOff")
        if let player = backgroundAudioPlayer{
            if isSettingEnabled(settingName: "ambientSounds"){
                player.stop()
                flipSettingInCoreData(key: "ambientSounds", newValue: false)
            }
            else{
                flipSettingInCoreData(key: "ambientSounds", newValue: true)
                playBackgroundMusic()
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
        settings.ambientSounds = true
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
                    s[0].setValue(newValue, forKey: key)
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
    
    public func isSettingEnabled(settingName: String) -> Bool{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return false
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Settings")
        do {
            if let s = try managedContext.fetch(fetchRequest) as? [NSManagedObject]{
                if s.count > 0{
                    if let enabled = s[0].value(forKey: settingName) as? Bool {
                        print ("we have the setting")
                        print ("the enabled bool in \(settingName) is \(enabled)")
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

