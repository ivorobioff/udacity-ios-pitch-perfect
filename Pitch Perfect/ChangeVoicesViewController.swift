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
    
    private lazy var audioEngine: AVAudioEngine = {
        
        [unowned self] in
        
        var audioEngine = AVAudioEngine()
            
        audioEngine.attachNode(self.audioPlayer)
        audioEngine.attachNode(self.pitchNode)
        audioEngine.connect(self.audioPlayer, to: self.pitchNode, format: self.audioBuffer.format)
        audioEngine.connect(self.pitchNode, to: audioEngine.mainMixerNode, format: self.audioBuffer.format)
        
        return audioEngine
    }()
    
    
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
    
    private var audioPlayer: AVAudioPlayerNode = AVAudioPlayerNode()
    
    private var pitchNode = AVAudioUnitTimePitch()
    
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
    
    private func stopPlayingVoice(){
        refreshPlayerState()
        try! audioSession.setActive(false)
        stopButton.hidden = true
    }
    
    private func refreshPlayerState(){
        audioPlayer.stop()
        audioPlayer.reset()
        audioEngine.stop()
        audioEngine.reset()
    }
    
    private func playVoice(withPitch pitch: Float = 1.0, withRate rate: Float = 1.0){

        try! audioSession.setActive(true)
        
        refreshPlayerState()
        stopButton.hidden = false
        
        pitchNode.pitch = pitch
        pitchNode.rate = rate

        audioPlayer.scheduleBuffer(audioBuffer){
            [unowned self] in
            
            self.isPlaying = false
            
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                if (self.isPlaying == false){
                    self.stopButton.hidden = true
                }
            }
        }
        
        try! audioEngine.start()
        
        audioPlayer.play()
        isPlaying = true
    }
}
