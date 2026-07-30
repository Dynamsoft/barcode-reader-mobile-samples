/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit

class ResultViewController: UIViewController {
    
    var text:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Results"
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func setup() {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 32),
            label.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -32)
        ])
    }
}
