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
    
    var player: AVAudioPlayer!
    
    @IBOutlet weak var stopButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        player = try! AVAudioPlayer(contentsOfURL: recordedAudio.url)
        player.delegate = self
        player.enableRate = true
        player.volume = 1.0
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        stopButton.hidden = true
    }
    
    @IBAction func stopPlaying(sender: UIButton) {
        stopPlayingVoice()
    }
    
    @IBAction func fastVoice(sender: UIButton) {
       playVoice(2.0)
    }
    
    @IBAction func slowVoice(sender: UIButton) {
        playVoice(0.5)
    }
    
    private func stopPlayingVoice(){
        player.stop();
        player.currentTime = 0
        stopButton.hidden = true
    }
    
    private func playVoice(rate: Float = 1.0){
        player.stop()
        player.rate = rate
        player.play()
        stopButton.hidden = false
    }
}
