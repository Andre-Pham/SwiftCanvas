//
//  CanvasLayerManager.swift
//  SwiftCanvasDemo
//
//  Created by Andre Pham on 1/3/2024.
//

import Foundation
import SwiftMath
import UIKit

public class StrokeSettings {
    
    public var color: CGColor
    public var cap: CGLineCap
    public var width: Double
    public var dash: (phase: CGFloat, lengths: [CGFloat])?
    
    public init(
        color: CGColor = CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
        cap: CGLineCap = .butt,
        width: Double = 10.0,
        dash: (phase: CGFloat, lengths: [CGFloat])? = nil
    ) {
        self.color = color
        self.cap = cap
        self.width = width
        self.dash = dash
    }
    
    internal func apply(to context: CGContext) {
        context.setStrokeColor(self.color)
        context.setLineCap(self.cap)
        context.setLineWidth(self.width)
        if let dash {
            context.setLineDash(phase: dash.phase, lengths: dash.lengths)
        }
    }
    
}

public protocol Primitive {
    
    func draw(on context: CGContext)
    
}

public class LinePrimitive: Primitive {
    
    public var lineSegment: SMLineSegment
    public var strokeSettings: StrokeSettings
    
    public init(lineSegment: SMLineSegment, strokeSettings: StrokeSettings) {
        self.lineSegment = lineSegment
        self.strokeSettings = strokeSettings
    }
    
    public func draw(on context: CGContext) {
        context.saveGState()
        self.strokeSettings.apply(to: context)
        context.move(to: self.lineSegment.origin.cgPoint)
        context.addLine(to: self.lineSegment.end.cgPoint)
        context.drawPath(using: .stroke)
        context.restoreGState()
    }
    
}

public class ArcPrimitive: Primitive {
    
    public var arc: SMArc
    public var strokeSettings: StrokeSettings
    
    public init(arc: SMArc, strokeSettings: StrokeSettings) {
        self.arc = arc
        self.strokeSettings = strokeSettings
    }
    
    public func draw(on context: CGContext) {
        context.saveGState()
        self.strokeSettings.apply(to: context)
        context.addArc(
            center: self.arc.center.cgPoint,
            radius: self.arc.radius,
            startAngle: self.arc.startAngle.radians,
            endAngle: self.arc.endAngle.radians,
            clockwise: false
        )
        context.drawPath(using: .stroke)
        context.restoreGState()
    }
    
}

public class CanvasLayer {
    
    private(set) var id: String
    private var primitives = [Primitive]()
    
    public init(id: String = UUID().uuidString) {
        self.id = id
    }
    
    public func addPrimitive(_ primitive: Primitive) {
        self.primitives.append(primitive)
    }
    
    internal func draw(on context: CGContext) {
        for primitive in self.primitives {
            primitive.draw(on: context)
        }
    }
    
}

public class CanvasLayerManager {
    
    private var layers = [Int: CanvasLayer]()
    private var layerPositions = [String: Int]()
    private(set) var layerCount = 0
    
    internal func drawLayers(on context: CGContext) {
        for layerPosition in 0..<self.layerCount {
            let layer = self.layers[layerPosition]!
            layer.draw(on: context)
        }
    }
    
    public func addLayer(_ layer: CanvasLayer) {
        guard self.layerPositions[layer.id] == nil else {
            assertionFailure("Cannot add two layers with the same name (id)")
            return
        }
        self.layers[self.layerCount] = layer
        self.layerPositions[layer.id] = self.layerCount
        self.layerCount += 1
    }
    
    public func insertLayer(_ layer: CanvasLayer, at position: Int) {
        guard self.layerPositions[layer.id] == nil else {
            assertionFailure("Cannot add two layers with the same name (id)")
            return
        }
        guard position < self.layerCount else {
            self.addLayer(layer)
            return
        }
        for layerPosition in stride(from: self.layerCount, to: position, by: -1) {
            let layerToMoveUp = self.layers[layerPosition - 1]!
            self.layers[layerPosition] = layerToMoveUp
            self.layerPositions[layerToMoveUp.id] = layerPosition
        }
        self.layers[self.layerCount] = layer
        self.layerPositions[layer.id] = self.layerCount
        self.layerCount += 1
    }
    
    public func getLayer(at position: Int) -> CanvasLayer? {
        return self.layers[position]
    }
    
    public func getLayer(id: String) -> CanvasLayer? {
        if let position = self.layerPositions[id] {
            return self.getLayer(at: position)
        }
        return nil
    }
    
    @discardableResult
    public func removeLayer(at index: Int) -> CanvasLayer? {
        if let removedLayer = self.layers.removeValue(forKey: index) {
            self.layerPositions.removeValue(forKey: removedLayer.id)
            for layerPosition in index..<self.layerCount {
                self.layers[layerPosition] = self.layers[layerPosition + 1]
                self.layerPositions[self.layers[layerPosition]!.id] = layerPosition
            }
            if let last = self.layers.removeValue(forKey: self.layerCount - 1) {
                // This should never fail
                self.layerPositions.removeValue(forKey: last.id)
            } else {
                fatalError("Layer logic is wrong")
            }
            self.layerCount -= 1
            return removedLayer
        }
        return nil
    }
    
    @discardableResult
    public func removeLayer(id: String) -> CanvasLayer? {
        if let position = self.layerPositions[id] {
            return self.removeLayer(at: position)
        }
        return nil
    }
    
}
