//
//  ViewController.swift
//  Pitch Perfect
//
//  Created by Igor Vorobiov on 1/30/16.
//  Copyright © 2016 Igor Vorobiov. All rights reserved.
//

import UIKit
import AVFoundation

class RecordVoiceViewController: UIViewController, AVAudioRecorderDelegate {

    var recorder: AVAudioRecorder!
    
    @IBOutlet weak var recordingIndicator: UILabel!
    
    @IBOutlet weak var stopRecordingButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func recordVoice(sender: UIButton) {
        recordingIndicator.text = "Recording"
        recordingIndicator.hidden = false
        stopRecordingButton.hidden = false
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let fileName = "record.wav"
        
        let pathComponents = [dirPath, fileName]
        let recordPath = NSURL.fileURLWithPathComponents(pathComponents)!
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try! session.setActive(true)

        
        try! recorder = AVAudioRecorder(URL: recordPath, settings: [:])
        recorder.prepareToRecord()
        recorder.record()
        recorder.delegate = self
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        
        guard flag else {
            print("Unable to store the recording.")
            return
        }
        
        let model = RecordedAudio(title: recorder.url.lastPathComponent!, url: recorder.url)
        
        performSegueWithIdentifier("toPlayVoice", sender: model)
        recordingIndicator.hidden = true
    }
    
    @IBAction func stopRecording(sender: AnyObject) {
        recordingIndicator.text = "Processing"
        stopRecordingButton.hidden = true
        recorder.stop()
        try! AVAudioSession.sharedInstance().setActive(false)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        (segue.destinationViewController as! ChangeVoicesViewController).recordedAudio = sender as! RecordedAudio
    }
}

