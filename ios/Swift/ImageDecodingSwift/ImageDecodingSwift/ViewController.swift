//
//  ViewController.swift
//  ImageDecodingSwift
//
//  Created by dynamsoft's mac on 2022/12/27.
//

import UIKit
import Photos

class ViewController: UIViewController, UIImagePickerControllerDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate {

    var barcodeReader: DynamsoftBarcodeReader!
    
    lazy var photoLibraryButton: UIButton = {
        let button = UIButton.init(frame: CGRect(x: kScreenWidth - 70, y: 20 + kNaviBarAndStatusBarHeight, width: 50, height: 50))
        button.setImage(UIImage(named: "icon_select"), for: .normal)
        button.addTarget(self, action: #selector(selectPic(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var imageDecodingButton: UIButton = {
        let button = UIButton.init(frame: CGRect(x: (kScreenWidth - 100) / 2.0, y: kScreenHeight - 100, width: 100, height: 50))
        button.backgroundColor = UIColor(red: 59.003 / 255.0, green: 61.9991 / 255.0, blue: 69.0028 / 255.0, alpha: 1)
        button.layer.cornerRadius = 5.0
        button.setTitle("Decode", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(startDecoding(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var selectedImageV: UIImageView = {
        let topX = self.photoLibraryButton.frame.origin.y + self.photoLibraryButton.frame.size.height + 10
        let imageV = UIImageView.init(frame: CGRect(x: 0, y: topX, width: kScreenWidth, height: kScreenHeight - 2 * topX))
        imageV.layer.contentsGravity = .resizeAspect
        imageV.layer.contentsScale = UIScreen.main.scale
        return imageV
    }()
    
    lazy var loadingView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView.init(style: .whiteLarge)
        indicator.center = self.view.center
        return indicator
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 59.003 / 255.0, green: 61.9991 / 255.0, blue: 69.0028 / 255.0, alpha: 1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        self.title = "Image Decoding"
        
        configureDBR()
        setupUI()
    }

    private func configureDBR() -> Void {
        barcodeReader = DynamsoftBarcodeReader.init()
        barcodeReader.updateRuntimeSettings(EnumPresetTemplate.imageReadRateFirst)
        
        let settings = try? barcodeReader.getRuntimeSettings()
        settings!.barcodeFormatIds = EnumBarcodeFormat.ALL.rawValue
        settings!.barcodeFormatIds_2 = EnumBarcodeFormat2.DOTCODE.rawValue
        try? barcodeReader.updateRuntimeSettings(settings!)
    }
    
    private func setupUI() -> Void {
        self.view.addSubview(photoLibraryButton)
        self.view.addSubview(imageDecodingButton)
        self.view.addSubview(selectedImageV)
        self.view.addSubview(loadingView)
        
        self.updateSelectedImage(UIImage(named: "image-decoding")!)
    }
    
    func updateSelectedImage(_ image: UIImage) -> Void {
        self.selectedImageV.image = image
    }
    
    // MARK: - Photo selection.
    @objc private func selectPic(_ button: UIButton) -> Void {
        PHPhotoLibrary.requestAuthorization { status in
            if status != .authorized {
                self.requestAuthorization()
                return
            }
            self.presentPickerViewController()
        }
    }
    
    private func requestAuthorization() -> Void {
        DispatchQueue.main.async {
            let alertVC = UIAlertController.init(title: "Tips", message: "Settings-Privacy-Camera/Album-Authorization", preferredStyle: .alert)
            let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel) { action in
                
            }
            
            let confirmAction = UIAlertAction.init(title: "OK", style: .default) { action in
                let url = URL.init(string: UIApplication.openSettingsURLString)!
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
            
            alertVC.addAction(cancelAction)
            alertVC.addAction(confirmAction)
            self.present(alertVC, animated: true)
        }
    }
    
    private func presentPickerViewController() -> Void {
        DispatchQueue.main.async {
            let picker = UIImagePickerController()
            if #available(iOS 11.0, *) {
                UIScrollView.appearance().contentInsetAdjustmentBehavior = .always
            }
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    func loadingStart() -> Void {
        DispatchQueue.main.async {
            self.loadingView.startAnimating()
        }
    }
    
    func loadingFinished() -> Void {
        DispatchQueue.main.async {
            self.loadingView.stopAnimating()
        }
    }
    
    //MARK: UIImagePicker delegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        self.updateSelectedImage(image)
        picker.dismiss(animated: true)
    }
    
    // MARK: - Start Decoding
    @objc private func startDecoding(_ button: UIButton) -> Void {
        self.loadingStart()
        let image = self.selectedImageV.image!
        DispatchQueue.global().async {
            let results = try? self.barcodeReader.decodeImage(image)
            self.loadingFinished()
            self.handleImage(with: results)
        }
    }
    
    func handleImage(with results:[iTextResult]?) -> Void {
        if (results != nil){
            var msgText:String = ""
            let title:String = "Results"
            for item in results! {
                msgText = msgText + String(format:"\nFormat: %@\nText: %@\n", item.barcodeFormatString!,item.barcodeText ?? "noResuslt")
            }
            showResult(title, msgText, "OK") { self.loadingView.stopAnimating()
            }
        }else{
            showResult("No result", "", "OK") { self.loadingView.stopAnimating()
            }
        }
    }
    
    private func showResult(_ title: String, _ msg: String, _ acTitle: String, completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: acTitle, style: .default, handler: { _ in completion() }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    

}

