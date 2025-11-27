/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit

class PickerPopupView: UIView, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var pickerOptions: [String] = [] {
        didSet {
            pickerView.reloadAllComponents()
        }
    }
    var initialSelectedIndex: Int = 0

    var onConfirm: ((Int) -> Void)?
    var onCancel: (() -> Void)?
    
    lazy var toolbar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .opaqueSeparator
        let cancel = UIButton(type: .system)
        cancel.setTitle("Cancel", for: .normal)
        cancel.titleLabel?.font = .systemFont(ofSize: 18)
        cancel.translatesAutoresizingMaskIntoConstraints = false
        cancel.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        
        let done = UIButton(type: .system)
        done.setTitle("OK", for: .normal)
        done.titleLabel?.font = .systemFont(ofSize: 18)
        done.translatesAutoresizingMaskIntoConstraints = false
        done.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        view.addSubview(cancel)
        view.addSubview(done)
        NSLayoutConstraint.activate([
            cancel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cancel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            done.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            done.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        return view
    }()
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let pickerView: UIPickerView = {
        let view = UIPickerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        addSubview(containerView)
        
        containerView.addSubview(toolbar)
        
        pickerView.dataSource = self
        pickerView.delegate = self
        containerView.addSubview(pickerView)
        
        NSLayoutConstraint.activate([
            toolbar.topAnchor.constraint(equalTo: containerView.topAnchor),
            toolbar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 44),
            
            pickerView.topAnchor.constraint(equalTo: toolbar.bottomAnchor, constant: 10),
            pickerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pickerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            pickerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
        ])
    }
    
    func updateConstraints(with parent: UIView) {
        let safeArea = parent.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 250)
        ])
    }
    
    // MARK: - doneTapped
    @objc private func doneTapped() {
        let selected = pickerView.selectedRow(inComponent: 0)
        onConfirm?(selected)
        dismiss()
    }
    
    @objc private func cancelTapped() {
        onCancel?()
        dismiss()
    }
    
    private func dismiss() {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
        }
    }
    
    // MARK: - UIPickerViewDataSource & Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let title = pickerOptions[row]
        return NSAttributedString(string: title, attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pickerView.selectRow(initialSelectedIndex, inComponent: 0, animated: false)
    }
}
