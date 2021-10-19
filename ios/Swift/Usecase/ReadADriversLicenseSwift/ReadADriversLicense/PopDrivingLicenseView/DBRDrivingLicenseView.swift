//
//  PopDrivingLicenseView.swift
//  AwesomeBarcode
//
//  Created by Dynamsoft on 2021/09/18.
//  Copyright © 2021 Dynamsoft. All rights reserved.
//

import UIKit

class DBRDrivingLicenseView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var drivingLicenseInfTableView: UITableView!
    @IBOutlet weak var footTableView: UITableView!

    var barcodeResult:BarcodeData = BarcodeData()
    var drivingLicenseInfArr:[ScenarioDisplayInf] = [ScenarioDisplayInf]()
    var curIdx = 0
    var drivingLicenseTableViewfootHeight:CGFloat = 0
    
    init(frame: CGRect,barcodeResult:BarcodeData) {
        super.init(frame: frame)
        self.barcodeResult = barcodeResult
        initialFromXib(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialFromXib(frame: CGRect(x: 0, y: StatusH + NavigationH, width: FullScreenSize.width, height: FullScreenSize.height - (StatusH + NavigationH)))
    }
    
    func initialFromXib(frame: CGRect){
        self.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        self.frame = frame
        let nibName = String(describing: DBRDrivingLicenseView.self)
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName:nibName, bundle: bundle)
        self.contentView = nib.instantiate(withOwner: self, options: nil)[0] as? UIView
        self.contentView.frame = bounds
        self.addSubview(self.contentView)
        
        let footTableViewHeight = DBRDrivingLicenseView.CalculateTableviewHeight(barcodeCnt: self.barcodeResult.barcodeTexts.count, rowHeight:  kFootViewHeight, maxCnt: 3, disPlayCnt: 2.5)
        self.footTableView.separatorStyle = .none
        self.footTableView.showsVerticalScrollIndicator = true
        self.footTableView.frame = CGRect(x: 0, y: self.bounds.height - footTableViewHeight, width: self.contentView.bounds.width, height: footTableViewHeight)
        self.footTableView.dataSource = self
        self.footTableView.delegate = self
        self.footTableView.register(UINib(nibName:BrcdRsltListTableViewCell.identifier, bundle:nil),forCellReuseIdentifier:BrcdRsltListTableViewCell.identifier)
        
        self.drivingLicenseInfTableView.frame = CGRect(x: 0, y: 0, width: self.contentView.bounds.width, height: self.bounds.height - self.footTableView.bounds.height)
        self.drivingLicenseInfTableView.separatorStyle = .none
        self.drivingLicenseInfTableView.flashScrollIndicators()
        self.drivingLicenseInfTableView.dataSource = self
        self.drivingLicenseInfTableView.delegate = self
        self.drivingLicenseInfTableView.register(UINib(nibName:DrivingLicenseDetailTableViewCell.identifier, bundle:nil),forCellReuseIdentifier:DrivingLicenseDetailTableViewCell.identifier)
        let brcdText = self.barcodeResult.barcodeTexts[curIdx]
        self.drivingLicenseInfArr = DBRDrivingLicenseView.ExtractDriverLicenseInf(brcdText: brcdText)
        self.drivingLicenseInfTableView.scrollToRow(at: IndexPath(item: NSNotFound, section: 0), at: .top, animated: false)
    }
    
    public static func ExtractDriverLicenseInf(brcdText:String) ->[ScenarioDisplayInf]
    {
        var rltArray = [ScenarioDisplayInf]()
        let subStrArr = SplitDrivingLicenseText(brcdText:brcdText)
        if(subStrArr.count > 2)
        {
            FindDLAbbreviation(text: String(subStrArr[2]) + "\n", withLineFeed: false,rltArray:&rltArray)
        }
        FindDLAbbreviation(text: brcdText, withLineFeed: true,rltArray:&rltArray)
        return rltArray
    }
    
    static func SplitDrivingLicenseText(brcdText:String)-> [Substring]
    {
        var tText = brcdText.trimmingCharacters(in: .whitespaces)
        tText = tText.replacingOccurrences(of: "\r", with: "\n")
        var subStrArr = tText.split(separator: "\n")
        for i in  (0...(subStrArr.count - 1)).reversed()
        {
            if(subStrArr[i] == "")
            {
                subStrArr.remove(at: i)
            }
        }
        return subStrArr
    }
    
    public static func FindDLAbbreviation(text:String,withLineFeed:Bool,rltArray:inout [ScenarioDisplayInf])
    {
        let dicArray = NSArray(contentsOfFile: Bundle.main.path(forResource: "driverLicenseFields", ofType: "plist")!)!
        var rltArrayAll = [DBRDriverLicenseInfo]()
        for dict in dicArray
        {
            let setttingInf = DBRDriverLicenseInfo(dict: dict as! NSDictionary)
            rltArrayAll.append(setttingInf)
        }
        for item in rltArrayAll {
            let fieldValue = GetDriverLicenseField(brcdText:text, keyWord: item.abbreviation, withLineFeed: withLineFeed)
            if(fieldValue != nil)
            {
                rltArray.append(ScenarioDisplayInf(title: item.desc, value: fieldValue!))
            }
        }
    }
    
    static func CalculateTableviewHeight(barcodeCnt:Int, rowHeight:CGFloat, maxCnt:Int, disPlayCnt:CGFloat) -> CGFloat
    {
        var height:CGFloat
        if(barcodeCnt >= maxCnt)
        {
            height = rowHeight * disPlayCnt
        }
        else
        {
            height = rowHeight * CGFloat(barcodeCnt)
        }
        return height
    }
}

class DBRDriverLicenseInfo: NSObject {

    var abbreviation:String!
    var desc:String!
    
    init(dict:NSDictionary)
    {
        super.init()
        self.abbreviation = dict["abbreviation"] as? String
        self.desc = dict["description"] as? String
    }
}

class ScenarioDisplayInf:NSObject{
    
    var title:String!
    var value: String!
    var id:Int?
    
    init(title:String,value:String,id:Int = 0) {
        super.init()
        self.title = title
        self.value = value
        self.id = id
    }
}

class BarcodeData:NSObject{
    
    var barcodeTypes: [String]
    var barcodeTypesDes:[String]
    var barcodeTexts: [String]
    var decodeTime:String
    
    override init() {
        self.barcodeTypes = [String]()
        self.barcodeTypesDes = [String]()
        self.barcodeTexts = [String]()
        self.decodeTime = ""
    }
    
    required init(original: BarcodeData) {
        self.barcodeTypes = original.barcodeTypes
        self.barcodeTypesDes = original.barcodeTypesDes
        self.barcodeTexts = original.barcodeTexts
        self.decodeTime = original.decodeTime
    }
    
    init(type: [String],typeDes: [String], text: [String], time:String) {
        self.barcodeTypes = type
        self.barcodeTypesDes = typeDes
        self.barcodeTexts = text
        self.decodeTime = time
    }
}

extension DBRDrivingLicenseView{
    
    static func GetDriverLicenseField(brcdText:String, keyWord:String,withLineFeed:Bool) -> String?
    {
        let key = withLineFeed ? "\n" + keyWord : keyWord
        let range = brcdText.range(of: key)
        if(range == nil || range!.isEmpty)
        {
            return nil
        }
        let subStr = brcdText[range!.upperBound ..< brcdText.endIndex]
        let keyWordRange = subStr.range(of: "\n")
        if(keyWordRange == nil || range!.isEmpty)
        {
            return nil
        }
        let rltStr = subStr[subStr.startIndex ..< keyWordRange!.lowerBound]
        return String(rltStr).trimmingCharacters(in:NSCharacterSet.whitespaces)
    }
    
    func GetDBRDriverLicenseInfo(plistName:String) -> [DBRDriverLicenseInfo]
    {
        let dicArray = NSArray(contentsOfFile: Bundle.main.path(forResource: plistName, ofType: "plist")!)!
        var rltArray = [DBRDriverLicenseInfo]()
        for dict in dicArray
        {
            let setttingInf = DBRDriverLicenseInfo(dict: dict as! NSDictionary)
            rltArray.append(setttingInf)
        }
        return rltArray
    }
}

extension DBRDrivingLicenseView: UITableViewDataSource, UITableViewDelegate{
    
    // MARK: - tableViewFunctions
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == self.footTableView)
        {
            return self.barcodeResult.barcodeTexts.count
        }
        else
        {
            return drivingLicenseInfArr.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(tableView == self.footTableView)
        {
            return 0
        }
        else
        {
            return 70
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(tableView == self.footTableView)
        {
            return nil
        }
        else
        {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 70))
            view.backgroundColor = UIColor.white
            let label = UILabel(frame: CGRect(x: 25, y: 35, width: 200, height: 22))
            label.font = UIFont.systemFont(ofSize: 20)
            label.text = "Driver License info"
            label.textColor = UIColor.black
            view.addSubview(label)
            return view
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if(tableView == self.footTableView)
        {
            return 0
        }
        else
        {
            let brcdText = self.barcodeResult.barcodeTexts[curIdx]
            let brcdType = self.barcodeResult.barcodeTypesDes[curIdx]
            let text = "Format: \n\(brcdType)\n\nText:\n\(brcdText)\n"
            let height = LabelHeightTextAdaptation(str: text, font: UIFont.systemFont(ofSize: 14), width: tableView.bounds.width)
            drivingLicenseTableViewfootHeight = height
            return height
        }
    }
    
    func LabelHeightTextAdaptation(str: String, font: UIFont, width: CGFloat) -> CGFloat
    {
        let statusLabelText:NSString = str as NSString
        let size = CGSize(width: width, height: CGFloat(MAXFLOAT))
        let strSize = statusLabelText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil).size
        return strSize.height
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if(tableView == self.footTableView)
        {
            return nil
        }
        else
        {
            let brcdText = self.barcodeResult.barcodeTexts[curIdx]
            let brcdType = self.barcodeResult.barcodeTypesDes[curIdx]
            return DBRDrivingLicenseView.GetScenarioFootView(brcdText: brcdText,brcdType:brcdType, width: tableView.bounds.width,height:drivingLicenseTableViewfootHeight)
        }
    }
    
    static func GetScenarioFootView(brcdText: String, brcdType:String, width:CGFloat, height:CGFloat) -> UIView
    {
        let text = "Format: \n\(brcdType)\n\nText:\n\(brcdText)\n"
        let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        view.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1)
        let label = UILabel(frame: CGRect(x: 25, y: 0, width: view.frame.width - 50, height: height))
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = text
        label.textColor = UIColor(red: 96/255.0, green:96/255.0, blue:96/255.0, alpha:1.0)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(tableView == self.footTableView)
        {
            return kFootViewHeight
        }
        else
        {
            return 55
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView == self.footTableView)
        {
            let identifer = BrcdRsltListTableViewCell.identifier
            let cell = tableView.dequeueReusableCell(withIdentifier: identifer, for: indexPath) as! BrcdRsltListTableViewCell
            let formatStr = self.barcodeResult.barcodeTypesDes[indexPath.row]
            cell.cellNum.text = indexPath.row + 1 < 10 ? "0\(indexPath.row + 1)": String(indexPath.row)
            cell.setFormatLabel(text: "Format:" + formatStr)
            return cell
        }
        else
        {
            let identifer = DrivingLicenseDetailTableViewCell.identifier
            let cell = tableView.dequeueReusableCell(withIdentifier: identifer, for: indexPath) as! DrivingLicenseDetailTableViewCell
            cell.abbreviationLb.text = self.drivingLicenseInfArr[indexPath.row].title
            cell.descriptionLb.text = self.drivingLicenseInfArr[indexPath.row].value
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if(tableView == self.footTableView)
        {
            curIdx = indexPath.row;
            let brcdText = self.barcodeResult.barcodeTexts[curIdx]
            self.drivingLicenseInfArr =  DBRDrivingLicenseView.ExtractDriverLicenseInf(brcdText: brcdText)
            self.drivingLicenseInfTableView.reloadData()
        }
    }
}
