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

public class FillSettings {
    
    public var color: CGColor
    
    public init(color: CGColor = CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)) {
        self.color = color
    }
    
    internal func apply(to context: CGContext) {
        context.setFillColor(self.color)
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
        context.addPath(self.lineSegment.cgPath)
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
        context.addPath(self.arc.cgPath)
        context.drawPath(using: .stroke)
        context.restoreGState()
    }
    
}

public class RectPrimitive: Primitive {
    
    public var rect: SMRect
    public var strokeSettings: StrokeSettings?
    public var fillSettings: FillSettings?
    
    public init(rect: SMRect, strokeSettings: StrokeSettings? = nil, fillSettings: FillSettings? = nil) {
        self.rect = rect
        self.strokeSettings = strokeSettings
        self.fillSettings = fillSettings
    }
    
    public func draw(on context: CGContext) {
        guard !(self.strokeSettings == nil && self.fillSettings == nil) else {
            return
        }
        context.saveGState()
        self.strokeSettings?.apply(to: context)
        self.fillSettings?.apply(to: context)
        context.addRect(self.rect.cgRect)
        if self.strokeSettings != nil && self.fillSettings != nil {
            context.drawPath(using: .fillStroke)
        } else if self.strokeSettings != nil {
            context.drawPath(using: .stroke)
        } else {
            context.drawPath(using: .fill)
        }
        context.restoreGState()
    }
    
}

public class PolygonPrimitive: Primitive {
    
    public var polygon: SMPolygon
    public var strokeSettings: StrokeSettings?
    public var fillSettings: FillSettings?
    
    public init(polygon: SMPolygon, strokeSettings: StrokeSettings? = nil, fillSettings: FillSettings? = nil) {
        self.polygon = polygon
        self.strokeSettings = strokeSettings
        self.fillSettings = fillSettings
    }
    
    public func draw(on context: CGContext) {
        guard !(self.strokeSettings == nil && self.fillSettings == nil) else {
            return
        }
        context.saveGState()
        self.strokeSettings?.apply(to: context)
        self.fillSettings?.apply(to: context)
        context.addPath(self.polygon.cgPath)
        if self.strokeSettings != nil && self.fillSettings != nil {
            context.drawPath(using: .fillStroke)
        } else if self.strokeSettings != nil {
            context.drawPath(using: .stroke)
        } else {
            context.drawPath(using: .fill)
        }
        context.restoreGState()
    }
    
}

public class PolylinePrimitive: Primitive {
    
    public var polyline: SMPolyline
    public var strokeSettings: StrokeSettings
    
    public init(polyline: SMPolyline, strokeSettings: StrokeSettings) {
        self.polyline = polyline
        self.strokeSettings = strokeSettings
    }
    
    public func draw(on context: CGContext) {
        context.saveGState()
        self.strokeSettings.apply(to: context)
        context.addPath(self.polyline.cgPath)
        context.drawPath(using: .stroke)
        context.restoreGState()
    }
    
}

public class CurvilinearPrimitive: Primitive {
    
    public var curvilinear: SMCurvilinearEdges
    public var strokeSettings: StrokeSettings?
    public var fillSettings: FillSettings?
    
    init(curvilinear: SMCurvilinearEdges, strokeSettings: StrokeSettings? = nil, fillSettings: FillSettings? = nil) {
        self.curvilinear = curvilinear
        self.strokeSettings = strokeSettings
        self.fillSettings = fillSettings
    }
    
    public func draw(on context: CGContext) {
        guard !(self.strokeSettings == nil && self.fillSettings == nil) else {
            return
        }
        context.saveGState()
        self.strokeSettings?.apply(to: context)
        self.fillSettings?.apply(to: context)
        context.addPath(self.curvilinear.cgPath)
        if self.strokeSettings != nil && self.fillSettings != nil {
            context.drawPath(using: .fillStroke)
        } else if self.strokeSettings != nil {
            context.drawPath(using: .stroke)
        } else {
            context.drawPath(using: .fill)
        }
        context.restoreGState()
    }
    
}

public class BezierCurvePrimitive: Primitive {
    
    public var bezierCurve: SMBezierCurve
    public var strokeSettings: StrokeSettings
    
    public init(bezierCurve: SMBezierCurve, strokeSettings: StrokeSettings) {
        self.bezierCurve = bezierCurve
        self.strokeSettings = strokeSettings
    }
    
    public func draw(on context: CGContext) {
        context.saveGState()
        self.strokeSettings.apply(to: context)
        context.addPath(self.bezierCurve.cgPath)
        context.drawPath(using: .stroke)
        context.restoreGState()
    }
    
}

public class QuadCurvePrimitive: Primitive {
    
    public var quadCurve: SMQuadCurve
    public var strokeSettings: StrokeSettings
    
    public init(quadCurve: SMQuadCurve, strokeSettings: StrokeSettings) {
        self.quadCurve = quadCurve
        self.strokeSettings = strokeSettings
    }
    
    public func draw(on context: CGContext) {
        context.saveGState()
        self.strokeSettings.apply(to: context)
        context.addPath(self.quadCurve.cgPath)
        context.drawPath(using: .stroke)
        context.restoreGState()
    }
    
}

public class EllipsePrimitive: Primitive {
    
    public var ellipse: SMEllipse
    public var strokeSettings: StrokeSettings?
    public var fillSettings: FillSettings?
    
    init(ellipse: SMEllipse, strokeSettings: StrokeSettings? = nil, fillSettings: FillSettings? = nil) {
        self.ellipse = ellipse
        self.strokeSettings = strokeSettings
        self.fillSettings = fillSettings
    }
    
    public func draw(on context: CGContext) {
        guard !(self.strokeSettings == nil && self.fillSettings == nil) else {
            return
        }
        context.saveGState()
        self.strokeSettings?.apply(to: context)
        self.fillSettings?.apply(to: context)
        context.addPath(self.ellipse.cgPath)
        if self.strokeSettings != nil && self.fillSettings != nil {
            context.drawPath(using: .fillStroke)
        } else if self.strokeSettings != nil {
            context.drawPath(using: .stroke)
        } else {
            context.drawPath(using: .fill)
        }
        context.restoreGState()
    }
    
}

public class HexagonPrimitive: Primitive {
    
    public var hexagon: SMHexagon
    public var strokeSettings: StrokeSettings?
    public var fillSettings: FillSettings?
    
    init(hexagon: SMHexagon, strokeSettings: StrokeSettings? = nil, fillSettings: FillSettings? = nil) {
        self.hexagon = hexagon
        self.strokeSettings = strokeSettings
        self.fillSettings = fillSettings
    }
    
    public func draw(on context: CGContext) {
        guard !(self.strokeSettings == nil && self.fillSettings == nil) else {
            return
        }
        context.saveGState()
        self.strokeSettings?.apply(to: context)
        self.fillSettings?.apply(to: context)
        context.addPath(self.hexagon.cgPath)
        if self.strokeSettings != nil && self.fillSettings != nil {
            context.drawPath(using: .fillStroke)
        } else if self.strokeSettings != nil {
            context.drawPath(using: .stroke)
        } else {
            context.drawPath(using: .fill)
        }
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
