//
//  ViewController.swift
//  SwiftCanvasDemo
//
//  Created by Andre Pham on 29/2/2024.
//

import UIKit
import SwiftMath

class ViewController: UIViewController {
    
    private let canvasController = CanvasController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Step 1: Add the Child View Controller to the Parent
        addChild(self.canvasController)
        
        // Step 2: Set Up the Child View Controller’s View
        view.addSubview(self.canvasController.view)
        self.canvasController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Step 3: Apply Auto Layout Constraints
        NSLayoutConstraint.activate([
            self.canvasController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            self.canvasController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            self.canvasController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 64),
            self.canvasController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -48)
        ])
        
        // Step 4: Notify the Child View Controller
        self.canvasController.didMove(toParent: self)
        
        self.canvasController.setCanvasBackgroundColor(to: .lightGray)
        
        let backgroundLayer = CanvasLayer(id: "background")
        self.canvasController.layerManager.addLayer(backgroundLayer)
        let line = SMLineSegment(origin: SMPoint(), end: SMPoint(x: 0, y: 3000))
        backgroundLayer.addPrimitive(LinePrimitive(lineSegment: line, strokeSettings: StrokeSettings()))
        
        let mainLayer = CanvasLayer(id: "main")
        self.canvasController.layerManager.addLayer(mainLayer)
        let arc = SMArc(center: SMPoint(x: 200, y: 200), radius: 50, startAngle: SMAngle(degrees: 0), endAngle: SMAngle(degrees: 90))
        let settings = StrokeSettings()
        mainLayer.addPrimitive(ArcPrimitive(arc: arc, strokeSettings: settings))
        
        let arc2 = SMArc(center: SMPoint(x: 200, y: 3000 - 200), radius: 50, startAngle: SMAngle(degrees: 0), endAngle: SMAngle(degrees: 90))
        let settings2 = StrokeSettings()
        mainLayer.addPrimitive(ArcPrimitive(arc: arc2, strokeSettings: settings2))
        
        let origin = SMArc(center: self.canvasController.canvasOrigin, radius: 10, startAngle: SMAngle(), endAngle: SMAngle(degrees: 359))
        mainLayer.addPrimitive(ArcPrimitive(arc: origin, strokeSettings: StrokeSettings()))
    }


}

