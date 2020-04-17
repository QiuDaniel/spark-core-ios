//
//  ViewController.swift
//  SPTokenCore
//
//  Created by SPARK-Daniel on 2020/4/13.
//  Copyright © 2020 SPARK-Daniel. All rights reserved.
//

import UIKit
import MBProgressHUD

class ViewController: UIViewController {
    
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var outPutTextView: UITextView!
    
    var running = false
    var startTime: TimeInterval = 0
    var output = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func testAction(_ sender: UIButton) {
        self.outPutTextView.text = ""
        if running {
            return
        }
        
        running = true
        startBtn.isEnabled = false
        startTime = CFAbsoluteTimeGetCurrent()
        
        doWorkBackground("Genrating...") {
            self.start()
        }
    }
    
    func start() {
        log("Create Keystore")
        let keystore = try! EthereumKeystore(password: "testpassword", privateKey: "c4446f6131340025012fa10f8d9401177cd4243e8de8443953701c3f629f9807")
        log("Keystore String:" + keystore.export())
        log("Decyrpting keystore")
        let decrypted = keystore.decryptPrivateKey(password:"testpassword")
        log("PrivateKey:" + decrypted)
        log("Finished")
        
    }
    
    
    func doWorkBackground(_ workTip: String, hardWork:@escaping () -> Void) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = workTip
        DispatchQueue.global().async {
            hardWork()
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.stop()
            }
        }
    }
    
    func stop() {
        running = false
        startBtn.isEnabled = true
    }
    
    func log(_ message: String) {
        let timestamp = String(format: "%.4f", CFAbsoluteTimeGetCurrent() - startTime)
        output += "\(timestamp)s: \(message)\n"
        DispatchQueue.main.async {
            self.outPutTextView.text = self.output
        }
    }
    
    func prettyPrintJSON(_ obj: JSONObject) -> String  {
        // fail fast in demo
        let encoded = try! JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
        return String(data: encoded, encoding: .utf8)!
    }
    
}

