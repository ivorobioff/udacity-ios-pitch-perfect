//
//  ViewController.swift
//  Pitch Perfect
//
//  Created by Igor Vorobiov on 1/30/16.
//  Copyright © 2016 Igor Vorobiov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var recordingIndicator: UILabel!
    
    @IBOutlet weak var stopRecordingButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func recordVoice(sender: UIButton) {
        recordingIndicator.hidden = false
    
    }
    
    @IBAction func stopRecording(sender: AnyObject) {
        recordingIndicator.hidden = true
    }
}

