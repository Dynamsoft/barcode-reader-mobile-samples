/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import Foundation
import UIKit
import DynamsoftCameraEnhancer
import DynamsoftBarcodeReader

class ResultViewController: UIViewController {
    
    var data:ImageData!
    var items:[BarcodeResultItem]!
    var editorView:ImageEditorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Results"
        setUpView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpDrawingItems()
    }
    
    func setUpDrawingItems() {
        let editorSize = editorView.frame.size
        let imageWidth:CGFloat = CGFloat(data.width)
        let imageHeight:CGFloat = CGFloat(data.height)
        var viewWidth:CGFloat
        var viewHeight:CGFloat
        if imageHeight/imageWidth >= editorSize.height/editorSize.width {
            viewHeight = editorSize.height
            viewWidth = editorSize.height/imageHeight*imageWidth
        } else {
            viewHeight = editorSize.width/imageWidth*imageHeight
            viewWidth = editorSize.width
        }
        var index = 1
        let layer = editorView.createDrawingLayer()
        layer.setDefaultStyle(DrawingStyleId.orangeStrokeFill.rawValue)
        var drawingItems:[DrawingItem] = []
        for item in items {
            let centrePoint = item.location.centrePoint
            let radius = 30.0
            let arcItem = ArcDrawingItem(centre: centrePoint, radius: radius)
            let string = String(index)
            let font = DrawingStyleManager.getDrawingStyle(arcItem.drawingStyleId)?.font ?? UIFont.systemFont(ofSize: 15)
            let size = (string as NSString).size(withAttributes: [NSAttributedString.Key.font: font])
            let width = ceil(size.width)
            let height = ceil(size.height)
            let point = CGPointMake(item.location.centrePoint.x/imageWidth*viewWidth, item.location.centrePoint.y/imageHeight*viewHeight)
            let textItem = TextDrawingItem(text: string, topLeftPoint: CGPoint(x: point.x - width/2, y: point.y - height/2), width: UInt(width), height: 0)
            textItem.coordinateBase = .view
            drawingItems.append(contentsOf: [arcItem, textItem])
            index += 1
        }
        layer.drawingItems = drawingItems
    }
    
    func setUpView() {
        let safeArea = view.safeAreaLayoutGuide
        var text:String = ""
        var index = 1
        for item in items {
            text += String(index) + ". " + item.formatString + ", " + item.text + "\n"
            index += 1
        }
        let textView = UITextView()
        textView.text = text
        textView.font = UIFont.systemFont(ofSize: 20)
        textView.textColor = UIColor.black
        textView.isEditable = false
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 0),
            textView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: 0),
            textView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: 0),
            textView.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.25)
        ])
        editorView = .init()
        view.insertSubview(editorView, at: 0)
        editorView.imageData = data
        editorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            editorView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 0),
            editorView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: 0),
            editorView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
            editorView.bottomAnchor.constraint(equalTo: textView.topAnchor, constant: -10)
        ])
    }

}
