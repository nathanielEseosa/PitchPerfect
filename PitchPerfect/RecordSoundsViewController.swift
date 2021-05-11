//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Nathaniel Idahosa on 06.05.21.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    // MARK: Outlets
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordingLabel: UILabel!
    
    var audioRecorder: AVAudioRecorder!
    var pulseLayers = [CAShapeLayer]()
    var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createPulse()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            let playSoundsVC = segue.destination as? PlaySoundsViewController
            let recordedAudioURL = sender as? URL
            playSoundsVC?.recordedAudioURL = recordedAudioURL
        }
    }

    // MARK: Actions
    
    @IBAction func recordButtonPressed(_ sender: Any) {
        isRecording = !isRecording
        setupUI()
        if isRecording {
            startRecording()
        } else {
            stopRecording()
        }
    }
    
    func startRecording() {
        setupUI()
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
        
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    func stopRecording() {
        setupUI()
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    
    func setupUI() {
        if isRecording {
            recordingLabel.text = "Recording in Progress"
            recordButton.setImage(#imageLiteral(resourceName: "Stop"), for: .normal)
            startPulesAnimation()
        } else {
            recordingLabel.text = "Tap to Record"
            recordButton.isEnabled = true
            recordButton.setImage(#imageLiteral(resourceName: "Record"), for: .normal)
            stopPulseAnimation()
        }
    }
    
    // MARK: Pulse Animation Methods
    
    func createPulse() {
            let circleInterval: CGFloat = 15
            let micRadius = (recordButton.frame.size.width) - circleInterval
            for circleNumber in 1 ... 3 {
                let circleRadius: CGFloat = (micRadius / 2) + (circleInterval * CGFloat(circleNumber))
                let circularPath = UIBezierPath(arcCenter: .zero, radius: circleRadius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
                let pulseLayer = CAShapeLayer()
                pulseLayer.path = circularPath.cgPath
                pulseLayer.lineWidth = 3.0
                pulseLayer.fillColor = UIColor.clear.cgColor
                pulseLayer.strokeColor = UIColor(red: 0.4, green: 1.0, blue: 0.2, alpha: 0.5).cgColor
                pulseLayer.lineCap = .round
                pulseLayer.position = CGPoint(x: recordButton.frame.size.width/2, y: recordButton.frame.size.height/2)
                pulseLayers.append(pulseLayer)
            }
        }
    
    func animatePulse(index: Int) {
            let opacityAnim = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
            opacityAnim.duration = 1.5
            opacityAnim.fromValue = 0.9
            opacityAnim.toValue = 0.0
            opacityAnim.timingFunction = CAMediaTimingFunction(name: .easeOut)
            opacityAnim.repeatCount = .greatestFiniteMagnitude
            pulseLayers[index].add(opacityAnim, forKey: "opacity")
            self.recordButton.layer.addSublayer(pulseLayers[index])
        }
    
    func startPulesAnimation() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.animatePulse(index: 2)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.animatePulse(index: 1)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        self.animatePulse(index: 0)
                    }
                }
            }
        }
    
    func stopPulseAnimation() {
            for (index, _) in self.pulseLayers.enumerated() {
                pulseLayers[index].removeAllAnimations()
                pulseLayers[index].removeFromSuperlayer()
            }
        }
    
    // MARK: Delegate Actions
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        } else {
            print("recording was not souccessful")
        }
    }
    
}

