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
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        stopPlayingVoice()
    }
    
    @IBAction func stopPlaying(sender: UIButton) {
        stopPlayingVoice()
    }
    
    @IBAction func fastVoice(sender: UIButton) {
        playVoice(withRate: 2.0)
    }
    
    @IBAction func funnyVoice(sender: UIButton) {
        playVoice(withPitch: 1000)
    }
    
    @IBAction func slowVoice(sender: UIButton) {
        playVoice(withRate: 0.5)
    }
    
    @IBAction func scaryVoice(sender: UIButton){
        playVoice(withPitch: -1000)
    }
    
    
    @IBAction func reverbVoice(sender: UIButton) {
        playVoiceWithReverb()
    }
    
    private func stopPlayingVoice(){
        refreshPlayerState()
        try! audioSession.setActive(false)
        stopButton.hidden = true
    }
    
    private func refreshPlayerState(){
        audioPlayer?.stop()
        audioPlayer?.reset()
        audioEngine?.stop()
        audioEngine?.reset()
    }
    
    private func playVoiceWithReverb(){
        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        let reverbNode = AVAudioUnitReverb()
        reverbNode.loadFactoryPreset(.LargeHall)
        reverbNode.wetDryMix = 50.0
        
        engine.attachNode(player)
        engine.attachNode(reverbNode)
        
        engine.connect(player, to: reverbNode, format: audioBuffer.format)
        engine.connect(reverbNode, to: engine.mainMixerNode, format: audioBuffer.format)
        
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
        stopButton.hidden = false
        
        
        audioPlayer!.scheduleBuffer(audioBuffer){
            [unowned self] in
            
            self.isPlaying = false
            
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                if (self.isPlaying == false){
                    self.stopButton.hidden = true
                }
            }
        }
        
        try! audioEngine!.start()
        
        audioPlayer!.play()
        isPlaying = true
    }
}
