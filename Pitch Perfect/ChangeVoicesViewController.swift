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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        stopPlayingVoice()
    }
    
    @IBAction func stopPlaying(sender: UIButton) {
        stopPlayingVoice()
    }
    
    @IBAction func fastVoice(sender: UIButton) {
        replaceVoiceActivator(with: sender)
        playVoice(withRate: 2.0)
    }
    
    @IBAction func funnyVoice(sender: UIButton) {
        replaceVoiceActivator(with: sender)
        playVoice(withPitch: 1000)
    }
    
    @IBAction func slowVoice(sender: UIButton) {
        replaceVoiceActivator(with: sender)
        playVoice(withRate: 0.5)
    }
    
    @IBAction func scaryVoice(sender: UIButton){
        replaceVoiceActivator(with: sender)
        playVoice(withPitch: -1000)
    }
    
    @IBAction func reverbVoice(sender: UIButton) {
        replaceVoiceActivator(with: sender)
        playVoiceWithReverb()
    }
    
    @IBAction func dirtyVoice(sender: UIButton) {
        replaceVoiceActivator(with: sender)
        playVoiceWithDistortion()
    }
    
    private func replaceVoiceActivator(with button: UIButton){
        voiceActivator?.enabled = true
        voiceActivator = button
        button.enabled = false
    }
    
    private func stopPlayingVoice(){
        refreshPlayerState()
        try! audioSession.setActive(false)
        stopButton.hidden = true
        voiceActivator?.enabled = true
    }
    
    private func refreshPlayerState(){
        audioPlayer?.stop()
        audioPlayer?.reset()
        audioEngine?.stop()
        audioEngine?.reset()
    }
    
    private func playVoiceWithDistortion(){
        let distortionNode = AVAudioUnitDistortion()
        distortionNode.loadFactoryPreset(.SpeechCosmicInterference)
        distortionNode.wetDryMix = 80.0
        playVoice(withEffect: distortionNode)
    }
    
    private func playVoiceWithReverb(){
        let reverbNode = AVAudioUnitReverb()
        reverbNode.loadFactoryPreset(.Cathedral)
        reverbNode.wetDryMix = 50.0
        playVoice(withEffect: reverbNode)
    }
    
    private func playVoice(withEffect effect: AVAudioUnitEffect){
        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        
        engine.attachNode(player)
        engine.attachNode(effect)
        
        engine.connect(player, to: effect, format: audioBuffer.format)
        engine.connect(effect, to: engine.mainMixerNode, format: audioBuffer.format)
        
        playVoice(withEngine: engine, withPlayer: player)

    }
    
    private func playVoice(withPitch pitch: Float){
        
        let pitchNode = AVAudioUnitTimePitch()
        pitchNode.pitch = pitch
        
        playVoice(withPitchNode: pitchNode)
    }
    
    private func playVoice(withRate rate: Float){
        
        let pitchNode = AVAudioUnitTimePitch()
        pitchNode.rate = rate
        
        playVoice(withPitchNode: pitchNode)
    }
    
    private func playVoice(withPitchNode pitchNode: AVAudioUnitTimePitch){
        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        
        engine.attachNode(player)
        engine.attachNode(pitchNode)
        
        engine.connect(player, to: pitchNode, format: audioBuffer.format)
        engine.connect(pitchNode, to: engine.mainMixerNode, format: audioBuffer.format)
        
        playVoice(withEngine: engine, withPlayer: player)
    }
    
    private func playVoice(withEngine engine: AVAudioEngine, withPlayer player: AVAudioPlayerNode){

        try! audioSession.setActive(true)
        
        audioEngine = engine
        audioPlayer = player
        
        refreshPlayerState()
        
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
