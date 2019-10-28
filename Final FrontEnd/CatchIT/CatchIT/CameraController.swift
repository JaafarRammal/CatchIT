//
//  ViewController.swift
//  CatchIT
//
//  Created by Jaafar Rammal on 10/26/19.
//  Copyright © 2019 Jaafar Rammal. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

class CameraController: UIViewController, AVCapturePhotoCaptureDelegate {
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var userScore: UILabel!
    @IBOutlet weak var previewView: UIView!
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var post = false
    
    @IBOutlet var dimView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = .lightContent
        NotificationCenter.default.addObserver(self, selector: #selector(CameraController.ChangeText), name: NSNotification.Name(rawValue: "refresh"), object: nil)
    }
    
    @IBOutlet weak var confirmTrash: UIButton!
    @IBOutlet weak var confirmTrashView: UIView!
    @IBAction func confirmTrash(_ sender: Any) {
       //POST API
        if(post){
            print("Try post")
            let url = URL(string: "http://34.76.123.9:5002/transaction")!
            var request = URLRequest(url: url)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            let timeInterval = NSDate().timeIntervalSince1970
            let parameters: [String: Any] = [
                "user_id": 1,
                "points": 10,
                "label": "can",
                "datetime":1572169610,
                "location":"London"
                
            ]
            request.httpBody = parameters.percentEscaped().data(using: .utf8)

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data,
                    let response = response as? HTTPURLResponse,
                    error == nil else {                                              // check for fundamental networking error
                    print("error", error ?? "Unknown error")
                    return
                }

                guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                    print("statusCode should be 2xx, but is \(response.statusCode)")
                    print("response = \(response)")
                    return
                }

                let responseString = String(data: data, encoding: .utf8)
                print("responseString = \(responseString ?? "0")")
            }

            task.resume()
        }
        
        confirmTrashView.removeFromSuperview()
        dimView.removeFromSuperview()
    }
    @IBOutlet weak var collectedTrash: UILabel!
    @IBOutlet weak var wonPoint: UILabel!
    override func viewDidAppear(_ animated: Bool) {
//         defaults.set(0, forKey: "UserScore")
        super.viewDidAppear(animated)
        navigationController?.navigationBar.barTintColor = .white

        updateUserScore(change: 0)
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium
        guard let backCamera = AVCaptureDevice.default(for: .video)
            else {
                print("Unable to access back camera!")
                return
        }
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            stillImageOutput = AVCapturePhotoOutput()

            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
               captureSession.addInput(input)
               captureSession.addOutput(stillImageOutput)
               setupLivePreview()
            }
        }
        catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
        
        videoPreviewLayer?.videoGravity = .resizeAspectFill
        videoPreviewLayer!.frame = previewView.bounds
        
    }
    
    @IBAction func didTakePhoto(_ sender: Any) {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func setupLivePreview() {
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        videoPreviewLayer.videoGravity = .resizeAspect
        videoPreviewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(videoPreviewLayer)
        DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
            self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.previewView.bounds
            }
        }
    }
    

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
                guard let imageData = photo.fileDataRepresentation()
            else { return }
        
        let image = UIImage(data: imageData)
        let labeler = Vision.vision().cloudImageLabeler()
        labeler.process(VisionImage(image: image!)) {
            labels, error in
            guard error == nil, let labels = labels else { print(error);return }
            print("\n")
            // Task succeeded.
            
            self.view.addSubview(self.dimView)
            self.dimView.frame = CGRect(x: 0,y: 0,width: self.view.frame.width, height: self.view.frame.height)
            
            var wdc = [0,0,0]
            for label in labels {
                switch label.text {
                case "Water", "Bottled water", "Drinking water", "Water bottle", "Fluid", "Drinkware", "Bottle", "Mineral water", "Two-liter bottle, Plastic bottle":
                    wdc[0] += 1
                case "Drink", "Beverage can", "Energy drink", "Red Bull":
                    wdc[1] += 1
                case "Chocolate", "Snack", "Junk food", "Paper", "Plastic":
                    wdc[2] += 1
                default:
                    0
                }
            }
                  
            if(wdc[0]-2 > wdc[1] && wdc[0]-2 > wdc[2]){
                self.showTrash(result: "Plastic Bottle")
                self.wonPoint.text = "3 points"
                self.updateUserScore(change: 3)
            }else if (wdc[1] > wdc[0] && wdc[1] > wdc[2]){
                self.showTrash(result: "Metal Can")
                self.wonPoint.text = "7 point"
                self.updateUserScore(change: 7)

            }else if (wdc[2] > wdc[0] && wdc[2] > wdc[1]){
                self.showTrash(result: "Wrapping")
                self.wonPoint.text = "4 points"
                self.updateUserScore(change: 4)
            }else{
                self.showTrash(result: "Scan Again")
                self.wonPoint.text = "Scan Again"
            }
            
            
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    func showTrash(result: String){
        collectedTrash.text = result
        self.view.addSubview(self.confirmTrashView)
        post = result == "Scan Again" ? false : true
        self.confirmTrash.layer.cornerRadius = 20
        print("\n")
        self.confirmTrashView.center = self.view.center
        self.confirmTrashView.layer.cornerRadius = 25
    }
    
    func updateUserScore(change: Int = 0){
    
        defaults.set(Int(defaults.string(forKey: "UserScore")!)! + change, forKey: "UserScore")
        
        userScore.text = "\(defaults.string(forKey: "UserScore")!) points"
    }
    
    @objc func ChangeText(){
     DispatchQueue.main.async {
        self.updateUserScore(change: 0)
     }
    }
    
    
    
}

extension Dictionary {
    func percentEscaped() -> String {
        return map { (key, value) in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}



