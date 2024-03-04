//
//  ViewController.swift
//  SwiftCanvasDemo
//
//  Created by Andre Pham on 29/2/2024.
//

import UIKit
import SwiftMath

class ViewController: UIViewController {
    
    private let button = LimeButton()
    private let button2 = LimeButton()
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
        let box = self.canvasController.canvasBox
        backgroundLayer.addPrimitive(RectPrimitive(rect: box, strokeSettings: StrokeSettings(), fillSettings: FillSettings()))
        
        let mainLayer = CanvasLayer(id: "main")
        self.canvasController.layerManager.addLayer(mainLayer)
        let arc = SMArc(center: SMPoint(x: 200, y: 200), radius: 50, startAngle: SMAngle(degrees: 0), endAngle: SMAngle(degrees: 90))
        let settings = StrokeSettings()
        mainLayer.addPrimitive(ArcPrimitive(arc: arc, strokeSettings: settings))
        
        let arc2 = SMArc(center: SMPoint(x: 200, y: 3000 - 200), radius: 50, startAngle: SMAngle(degrees: 0), endAngle: SMAngle(degrees: 90))
        let settings2 = StrokeSettings()
        mainLayer.addPrimitive(ArcPrimitive(arc: arc2, strokeSettings: settings2))
        
        let origin = SMEllipse(boundingBox: SMRect(center: self.canvasController.canvasOrigin, width: 50, height: 50))
        let originFillSettings = FillSettings(color: UIColor.blue.cgColor)
        mainLayer.addPrimitive(EllipsePrimitive(ellipse: origin, strokeSettings: StrokeSettings(), fillSettings: originFillSettings))
        
        LimeView(self.view).addSubview(self.button)
        self.button
            .setLabel(to: "Do Something")
            .constrainBottom()
            .constrainCenterHorizontal()
            .setOnTap({
                if self.colorState {
                    originFillSettings.color = UIColor.blue.cgColor
                } else {
                    originFillSettings.color = UIColor.systemPink.cgColor
                }
                self.colorState.toggle()
                self.canvasController.redraw()
            })
        
        self.view.addSubview(self.button2.view)
        self.button2
            .setLabel(to: "Test 1")
            .constrainToRightSide(of: self.button, padding: 50)
            .constrainBottom()
            .setOnTap({
                // Do nothing
            })
        
        let hitTarget = HitBox(id: "origin", box: origin.boundingBox)
        self.canvasController.layerManager.addHitTarget(hitTarget)
        
        self.canvasController.setOnHitTargetTapped({ id in
            print("\(id) tapped!")
            if self.colorState {
                originFillSettings.color = UIColor.blue.cgColor
            } else {
                originFillSettings.color = UIColor.systemPink.cgColor
            }
            self.colorState.toggle()
            self.canvasController.redraw()
        })
    }
    
    private var colorState = false


}

