/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit

protocol PopViewControllerDelegate: AnyObject {
    func didReceiveText(text: String?)
}

class ViewController: UIViewController, UITextFieldDelegate, PopViewControllerDelegate {

    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        textField.delegate = self
    }
    
    @IBAction func onStartSearching(_ sender: Any) {
        DispatchQueue.main.async {
            let vc = CameraViewController()
            vc.isStartSearching = true
            vc.text = self.textField.text
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func onButtonTouch(_ sender: Any) {
        DispatchQueue.main.async {
            let vc = CameraViewController()
            vc.isStartSearching = false
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func didReceiveText(text: String?) {
        self.textField.text = text
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

