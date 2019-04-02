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
    let BACKGROUND_VOLUME:Float = 0.3
    let LEVELOPENCLOSE_VOLUME: Float = 0.4
    let FOOTSTEP_VOLUME: Float = 0.5
    
    var gameSoundsEnabled: Bool = true
    var backgroundAudioPlayer: AVAudioPlayer?
    var levelOpenCloseAudioPlayer: AVAudioPlayer?
    var buttonClickAudioplayer: AVAudioPlayer?
    var footstepAudioPlayer: AVAudioPlayer?
    var crackingAudioPlayer: AVAudioPlayer?
    var successAudioPlayer: AVAudioPlayer?
    var footstepCounter = 0
    
    
    //MARK Music
    
    init(){
        setupAudioPlayers()
        playBackgroundMusic()
    }
    
    public func reInitPlayersAndSounds(){
        print("in reInitPlayersAndSounds")
        playBackgroundMusic()
        gameSoundsEnabled = isSettingEnabled(settingName: "gameSounds")
    }
    
    public func decreaseBackgroundVolume(){
        setBackgroundVolume(v: 0.08)
    }
    
    public func increaseBackgroundVolume(){
        setBackgroundVolume(v: 0.3)
    }
    
    private func setBackgroundVolume(v: Float){
        if let player = backgroundAudioPlayer{
            if player.isPlaying {
                player.volume = v
            }
        }
    }
    
    private func setupAudioPlayers(){
        do {
            ////i might need to change how i actually play it. probably don't need to keep loading the contents
            if let url = Bundle.main.url(forResource: "levelOpenClose", withExtension: "wav"){
                levelOpenCloseAudioPlayer = try AVAudioPlayer(contentsOf: url)
            }
            if let url = Bundle.main.url(forResource: "caveAmbience", withExtension: "mp3"){
                backgroundAudioPlayer = try AVAudioPlayer(contentsOf: url)
                playBackgroundMusic()
            }
            if let url = Bundle.main.url(forResource: "buttonClick", withExtension: "wav"){
                buttonClickAudioplayer = try AVAudioPlayer(contentsOf: url)
            }
            if let url = Bundle.main.url(forResource: "combinedChoir", withExtension: "wav"){
                successAudioPlayer = try AVAudioPlayer(contentsOf: url)
            }
            
            
        } catch  {
            print ("error")
        }
    }
    
    
    
    public func levelOpenClose(){
        if gameSoundsEnabled{
            if let player = levelOpenCloseAudioPlayer{
                player.prepareToPlay()
                player.volume = LEVELOPENCLOSE_VOLUME
                player.play()
            }
        }
    }
    
    public func playButtonClick(){
        if gameSoundsEnabled{
            if let player = buttonClickAudioplayer{
                player.volume = LEVELOPENCLOSE_VOLUME
                player.prepareToPlay()
                player.play()
            }
        }
    }
    
    public func playSuccessSound(){
        if gameSoundsEnabled{
            if let player = successAudioPlayer {
                player.volume = LEVELOPENCLOSE_VOLUME
                player.prepareToPlay()
                player.play()
            }
        }
    }
    
    public func playFootstep(){
        do  {
            if let url = Bundle.main.url(forResource: String(footstepCounter + 1), withExtension: "wav"){
                footstepAudioPlayer = try AVAudioPlayer(contentsOf: url)
                footstepAudioPlayer!.volume = FOOTSTEP_VOLUME
                footstepAudioPlayer!.prepareToPlay()
                footstepAudioPlayer!.play()
                footstepCounter = (footstepCounter + 1) % 9
            }

        }
        catch{
            print ("sound error")
        }
    }
    
    public func playCracking(){
        do  {
            if let url = Bundle.main.url(forResource: "crackingSound", withExtension: "wav"){
                crackingAudioPlayer = try AVAudioPlayer(contentsOf: url)
                crackingAudioPlayer!.prepareToPlay()
                crackingAudioPlayer!.play()
            }
            
        }
        catch{
            print ("sound error")
        }
    }
    
    public func playBackgroundMusic(){
        if let player = backgroundAudioPlayer{
            if isSettingEnabled(settingName: "ambientSounds"){ //&& !backgroundAudioPlayer!.isPlaying{
                player.numberOfLoops = -1
                player.volume = BACKGROUND_VOLUME
                player.prepareToPlay()
                player.play()
            }
            else{
                print (backgroundAudioPlayer?.isPlaying)
                player.stop()
            }
        }
        else{
            setupAudioPlayers()
            print ("this should only be called once gaaaaaaaaa ---------------------------------------------------------------------------------------------------")
        }
    }

    
    public func initAudioSettings(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("something bad app delegate ------------------------------------")
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let settingsEntity = NSEntityDescription.entity(forEntityName: "Settings",in: managedContext)!
        let settings = Settings(entity: settingsEntity, insertInto: managedContext)
        settings.ambientSounds = true
        settings.gameSounds = true
        settings.showAlertWhenGoingBack = true
        settings.askedForFeedback1 = false
        settings.askedForFeedback2 = false
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        playBackgroundMusic()
    }
    

    
    public func flipSettingInCoreData(key: String, newValue: Bool){
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
            if key == "gameSounds"{
                gameSoundsEnabled = newValue
            }
            if key == "ambientSounds"{
                playBackgroundMusic()
            }
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

