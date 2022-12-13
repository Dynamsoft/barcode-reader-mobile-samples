//
//  PullListView.swift
//  GeneralSettingsSwift
//
//  Created by dynamsoft's mac on 2022/12/6.
//

import UIKit

typealias SelectCompletion = (_ selectedDic: [String: Any]) -> Void

class PullListView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {

    private var pullListArray: [[String: Any]]  = []
    
    private var title: String = ""
    
    private var selectedDicInfo: [String :Any] = [:]
    
    private var selectCompletion: SelectCompletion?
    
    let pullListHeight: CGFloat = kIs_iPhoneXAndLater ? (270 + 34) : 270
    
    private lazy var backgroundMaskView: UIView = {
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: self.width, height: self.height))
        view.backgroundColor = .black.withAlphaComponent(0.2)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var pullListBackgroundView: UIView = {
        let view = UIView.init(frame: CGRect(x: 0, y: self.height - pullListHeight, width: self.width, height: pullListHeight))
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var headerView: UIView = {
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: self.width, height: 40))
        view.backgroundColor = .black.withAlphaComponent(0.05)
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel.init(frame: CGRect(x: (kScreenWidth - 100) / 2.0, y: 0, width: 100, height: self.headerView.height))
        label.text = self.title
        label.textColor = .gray
        label.font = kFont_Regular(13)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton.init(frame: CGRect(x: 0, y: 0, width: 60, height: self.headerView.height))
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.titleLabel?.font = kFont_Regular(12)
        button.addTarget(self, action: #selector(cancelAction(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton.init(frame: CGRect(x: kScreenWidth - 60, y: 0, width: 60, height: self.headerView.height))
        button.setTitle("OK", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.titleLabel?.font = kFont_Regular(12)
        button.addTarget(self, action: #selector(confirimAction(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var pickerView: UIPickerView = {
        let pickerViewHeight: CGFloat = kIs_iPhoneXAndLater ? (pullListHeight - self.headerView.height - 34) : (pullListHeight - self.headerView.height)
        let picker = UIPickerView.init(frame: CGRect(x: 0, y: self.headerView.bottom, width: kScreenWidth, height: pickerViewHeight))
        picker.backgroundColor = .white
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()
    
    static func showPullList(with pullListArray:[[String: Any]],
                             title: String,
                             selectedDicInfo:[String: Any],
                             completion: @escaping SelectCompletion) -> Void {
        let pullListView = PullListView(frame: UIScreen.main.bounds, pullListArray: pullListArray, title: title, selectedDicInfo: selectedDicInfo, completion: completion)
        pullListView.show()
    }

    init(frame: CGRect,
         pullListArray:[[String: Any]],
         title: String,
         selectedDicInfo:[String: Any],
         completion: @escaping SelectCompletion) {
        super.init(frame: frame)
        self.pullListArray.append(contentsOf: pullListArray)
        self.title = title
        self.selectedDicInfo = selectedDicInfo
        self.selectCompletion = completion
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() -> Void {
        self.addSubview(backgroundMaskView)
        self.backgroundMaskView.addSubview(pullListBackgroundView)
        self.pullListBackgroundView.addSubview(headerView)
        self.headerView.addSubview(titleLabel)
        self.headerView.addSubview(cancelButton)
        self.headerView.addSubview(confirmButton)
        self.pullListBackgroundView.addSubview(pickerView)
        
        // Jump to seleted row.
        let selectedName = selectedDicInfo["showName"] as! String
        var selectedRow = 0
        var currentLoopIndex = 0
        for singleInfoDic in pullListArray {
            let singleName = singleInfoDic["showName"] as! String
            if singleName == selectedName {
                selectedRow = currentLoopIndex
                break
            }
            currentLoopIndex = currentLoopIndex + 1
        }
        
        self.pickerView.selectRow(selectedRow, inComponent: 0, animated: true)
    }
    
    private func show() -> Void {
        self.pullListBackgroundView.top = kScreenHeight
        UIView.animate(withDuration: 0.2) {
            self.pullListBackgroundView.top = kScreenHeight - self.pullListBackgroundView.height
        } completion: { finished in
            
        }

        let window = UIApplication.shared.delegate?.window
        window??.addSubview(self)
    }
    
    private func dismiss() -> Void {
        UIView.animate(withDuration: 0.2) {
            self.pullListBackgroundView.top = kScreenHeight
        } completion: { finished in
            self.removeFromSuperview()
        }
    }
    
    @objc private func cancelAction(_ button: UIButton) -> Void {
        self.dismiss()
    }
    
    @objc private func confirimAction(_ button: UIButton) -> Void {
        self.selectCompletion?(self.selectedDicInfo)
        self.dismiss()
    }
    
    //MARK: - UIPickerViewDelegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pullListArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return kScreenWidth
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let infoDic = pullListArray[row];
        let showName = infoDic["showName"] as! String
        let contentLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 35))
        contentLabel.text = showName
        contentLabel.textAlignment = .center
        contentLabel.font = kFont_Regular(16)
        return contentLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedDicInfo = pullListArray[row]
    }
    
    
}
