//
//  ChangeVoicesViewController.swift
//  Pitch Perfect
//
//  Created by Igor Vorobiov on 1/31/16.
//  Copyright © 2016 Igor Vorobiov. All rights reserved.
//

import UIKit
import AVFoundation

class ChangeVoicesViewController: UIViewController, AVAudioPlayerDelegate {

    var recordedAudio: RecordedAudio!
    
    var isPlaying = false
    
    private var audioEngine: AVAudioEngine?
    private var audioPlayer: AVAudioPlayerNode?
    private var voiceActivator: UIButton?
    
    private lazy var audioSession: AVAudioSession = {
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayback)
        
        return session
    }()
    
    private lazy var audioBuffer: AVAudioPCMBuffer = {
        
        [unowned self] in
        
        let file = try! AVAudioFile(forReading: self.recordedAudio.url)
        
        let buffer = AVAudioPCMBuffer(PCMFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length))
        try! file.readIntoBuffer(buffer)
        
        return buffer
    }()
    
    @IBOutlet weak var stopButton: UIButton!
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        stopPlayingVoice()
    }
    
    @IBAction func stopPlaying(sender: UIButton) {
        stopPlayingVoice()
    }
    
    @IBAction func fastVoice(sender: UIButton) {
        replaceVoiceActivator(sender)
        playVoice(withRate: 2.0)
    }
    
    @IBAction func funnyVoice(sender: UIButton) {
        replaceVoiceActivator(sender)
        playVoice(withPitch: 1000)
    }
    
    @IBAction func slowVoice(sender: UIButton) {
        replaceVoiceActivator(sender)
        playVoice(withRate: 0.5)
    }
    
    @IBAction func scaryVoice(sender: UIButton){
        replaceVoiceActivator(sender)
        playVoice(withPitch: -1000)
    }
    
    @IBAction func reverbVoice(sender: UIButton) {
        replaceVoiceActivator(sender)
        playVoiceWithReverb()
    }
    
    @IBAction func dirtyVoice(sender: UIButton) {
        replaceVoiceActivator(sender)
        playVoiceWithDistortion()
    }
    
    private func replaceVoiceActivator(button: UIButton){
        voiceActivator?.enabled = true
        voiceActivator = button
        button.enabled = false
    }
    
    private func stopPlayingVoice(){
       
        audioPlayer?.stop()
        audioPlayer?.reset()
        audioEngine?.stop()
        audioEngine?.reset()
        
        try! audioSession.setActive(false)
        stopButton.hidden = true
        voiceActivator?.enabled = true
    }
    
    private func playVoiceWithDistortion(){
        let distortionNode = AVAudioUnitDistortion()
        distortionNode.loadFactoryPreset(.SpeechCosmicInterference)
        distortionNode.wetDryMix = 80.0
        playVoice(withNode: distortionNode)
    }
    
    private func playVoiceWithReverb(){
        let reverbNode = AVAudioUnitReverb()
        reverbNode.loadFactoryPreset(.Cathedral)
        reverbNode.wetDryMix = 50.0
        playVoice(withNode: reverbNode)
    }
    
    private func playVoice(withPitch pitch: Float){
        
        let pitchNode = AVAudioUnitTimePitch()
        pitchNode.pitch = pitch
        
        playVoice(withNode: pitchNode)
    }
    
    private func playVoice(withRate rate: Float){
        
        let pitchNode = AVAudioUnitTimePitch()
        pitchNode.rate = rate
        
        playVoice(withNode: pitchNode)
    }
    
    private func playVoice(withNode node: AVAudioNode){
        
        try! audioSession.setActive(true)
        
        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        
        audioEngine = engine
        audioPlayer = player
        
        engine.attachNode(player)
        engine.attachNode(node)
        
        engine.connect(player, to: node, format: audioBuffer.format)
        engine.connect(node, to: engine.mainMixerNode, format: audioBuffer.format)
        
        if (UIScreen.mainScreen().bounds.size.height > 480){
            stopButton.hidden = false
        }
        
        audioPlayer!.scheduleBuffer(audioBuffer){
            [unowned self] in
            
            self.isPlaying = false
            
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                if (self.isPlaying == false){
                    self.stopButton.hidden = true
                    self.voiceActivator?.enabled = true
                }
            }
        }
        
        try! audioEngine!.start()
        
        audioPlayer!.play()
        isPlaying = true
    }
 }
