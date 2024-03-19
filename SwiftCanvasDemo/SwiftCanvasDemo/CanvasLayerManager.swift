//
//  CanvasLayerManager.swift
//  SwiftCanvasDemo
//
//  Created by Andre Pham on 1/3/2024.
//

import Foundation
import SwiftMath
import UIKit

// TODO: Add text primitive and ShadowSettings
// ALSO fix the bug where if you leave the app and come back the scrollview has gone off the canvas

public class StrokeSettings: CanvasClonable {
    
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
    
    public required init(_ original: StrokeSettings) {
        self.color = original.color
        self.cap = original.cap
        self.width = original.width
        if let dash = original.dash {
            self.dash = (phase: dash.phase, lengths: Array(dash.lengths))
        } else {
            self.dash = nil
        }
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

public class FillSettings: CanvasClonable {
    
    public var color: CGColor
    
    public init(color: CGColor = CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)) {
        self.color = color
    }
    
    public required init(_ original: FillSettings) {
        self.color = original.color
    }
    
    internal func apply(to context: CGContext) {
        context.setFillColor(self.color)
    }
    
}

public protocol Primitive {
    
    var boundingBox: CGRect? { get }
    
    func draw(on context: CGContext)
    
}

public class LinePrimitive: Primitive {
    
    private(set) var path: CGPath
    private(set) public var boundingBox: CGRect?
    private(set) public var strokeSettings: StrokeSettings
    
    public init(lineSegment: SMLineSegment, strokeSettings: StrokeSettings) {
        self.strokeSettings = strokeSettings.clone()
        self.path = lineSegment.cgPath
        self.boundingBox = self.path.boundingBox.insetBy(dx: -self.strokeSettings.width, dy: -self.strokeSettings.width)
    }
    
    public func draw(on context: CGContext) {
        context.saveGState()
        self.strokeSettings.apply(to: context)
        context.addPath(self.path)
        context.drawPath(using: .stroke)
        context.restoreGState()
    }
    
    public func setLine(to lineSegment: SMLineSegment) {
        self.path = lineSegment.cgPath
        self.boundingBox = self.path.boundingBox.insetBy(dx: -self.strokeSettings.width, dy: -self.strokeSettings.width)
    }
    
    public func setStrokeSettings(to strokeSettings: StrokeSettings) {
        self.strokeSettings = strokeSettings.clone()
        self.boundingBox = self.path.boundingBox.insetBy(dx: -self.strokeSettings.width, dy: -self.strokeSettings.width)
    }
    
}

public class ArcPrimitive: Primitive {
    
    private(set) var path: CGPath
    private(set) public var boundingBox: CGRect?
    private(set) public var strokeSettings: StrokeSettings
    
    public init(arc: SMArc, strokeSettings: StrokeSettings) {
        self.strokeSettings = strokeSettings.clone()
        self.path = arc.cgPath
        self.boundingBox = self.path.boundingBox.insetBy(dx: -self.strokeSettings.width, dy: -self.strokeSettings.width)
    }
    
    public func draw(on context: CGContext) {
        context.saveGState()
        self.strokeSettings.apply(to: context)
        context.addPath(self.path)
        context.drawPath(using: .stroke)
        context.restoreGState()
    }
    
    public func setArc(to arc: SMArc) {
        self.path = arc.cgPath
        self.boundingBox = self.path.boundingBox.insetBy(dx: -self.strokeSettings.width, dy: -self.strokeSettings.width)
    }
    
    public func setStrokeSettings(to strokeSettings: StrokeSettings) {
        self.strokeSettings = strokeSettings.clone()
        self.boundingBox = self.path.boundingBox.insetBy(dx: -self.strokeSettings.width, dy: -self.strokeSettings.width)
    }
    
}

public class RectPrimitive: Primitive {
    
    private(set) var path: CGRect
    private(set) public var boundingBox: CGRect?
    private(set) public var strokeSettings: StrokeSettings?
    private(set) public var fillSettings: FillSettings?
    
    public init(rect: SMRect, strokeSettings: StrokeSettings? = nil, fillSettings: FillSettings? = nil) {
        self.strokeSettings = strokeSettings?.clone()
        self.fillSettings = fillSettings?.clone()
        self.path = rect.cgRect
        self.boundingBox = self.path.insetBy(dx: -(self.strokeSettings?.width ?? 0.0), dy: -(self.strokeSettings?.width ?? 0.0))
    }
    
    public func draw(on context: CGContext) {
        guard !(self.strokeSettings == nil && self.fillSettings == nil) else {
            return
        }
        context.saveGState()
        self.strokeSettings?.apply(to: context)
        self.fillSettings?.apply(to: context)
        context.addRect(self.path)
        if self.strokeSettings != nil && self.fillSettings != nil {
            context.drawPath(using: .fillStroke)
        } else if self.strokeSettings != nil {
            context.drawPath(using: .stroke)
        } else {
            context.drawPath(using: .fill)
        }
        context.restoreGState()
    }
    
    public func setRect(to rect: SMRect) {
        self.path = rect.cgRect
        self.boundingBox = self.path.insetBy(dx: -(self.strokeSettings?.width ?? 0.0), dy: -(self.strokeSettings?.width ?? 0.0))
    }
    
    public func setFillSettings(to fillSettings: FillSettings) {
        self.fillSettings = fillSettings.clone()
    }
    
    public func setStrokeSettings(to strokeSettings: StrokeSettings) {
        self.strokeSettings = strokeSettings.clone()
        self.boundingBox = self.path.insetBy(dx: -(self.strokeSettings?.width ?? 0.0), dy: -(self.strokeSettings?.width ?? 0.0))
    }
    
}

public class PolygonPrimitive: Primitive {
    
    private(set) var path: CGPath
    private(set) public var boundingBox: CGRect?
    private(set) public var strokeSettings: StrokeSettings?
    private(set) public var fillSettings: FillSettings?
    
    public init(polygon: SMPolygon, strokeSettings: StrokeSettings? = nil, fillSettings: FillSettings? = nil) {
        self.strokeSettings = strokeSettings?.clone()
        self.fillSettings = fillSettings?.clone()
        self.path = polygon.cgPath
        self.boundingBox = self.path.boundingBox.insetBy(dx: -(self.strokeSettings?.width ?? 0.0), dy: -(self.strokeSettings?.width ?? 0.0))
    }
    
    public func draw(on context: CGContext) {
        guard !(self.strokeSettings == nil && self.fillSettings == nil) else {
            return
        }
        context.saveGState()
        self.strokeSettings?.apply(to: context)
        self.fillSettings?.apply(to: context)
        context.addPath(self.path)
        if self.strokeSettings != nil && self.fillSettings != nil {
            context.drawPath(using: .fillStroke)
        } else if self.strokeSettings != nil {
            context.drawPath(using: .stroke)
        } else {
            context.drawPath(using: .fill)
        }
        context.restoreGState()
    }
    
    public func setPolygon(to polygon: SMPolygon) {
        self.path = polygon.cgPath
        self.boundingBox = self.path.boundingBox.insetBy(dx: -(self.strokeSettings?.width ?? 0.0), dy: -(self.strokeSettings?.width ?? 0.0))
    }
    
    public func setFillSettings(to fillSettings: FillSettings) {
        self.fillSettings = fillSettings.clone()
    }
    
    public func setStrokeSettings(to strokeSettings: StrokeSettings) {
        self.strokeSettings = strokeSettings.clone()
        self.boundingBox = self.path.boundingBox.insetBy(dx: -(self.strokeSettings?.width ?? 0.0), dy: -(self.strokeSettings?.width ?? 0.0))
    }
    
}

public class PolylinePrimitive: Primitive {
    
    private(set) var path: CGPath
    private(set) public var boundingBox: CGRect?
    private(set) public var strokeSettings: StrokeSettings
    
    public init(polyline: SMPolyline, strokeSettings: StrokeSettings) {
        self.strokeSettings = strokeSettings.clone()
        self.path = polyline.cgPath
        self.boundingBox = self.path.boundingBox.insetBy(dx: -self.strokeSettings.width, dy: -self.strokeSettings.width)
    }
    
    public func draw(on context: CGContext) {
        context.saveGState()
        self.strokeSettings.apply(to: context)
        context.addPath(self.path)
        context.drawPath(using: .stroke)
        context.restoreGState()
    }
    
    public func setPolyline(to polyline: SMPolyline) {
        self.path = polyline.cgPath
        self.boundingBox = self.path.boundingBox.insetBy(dx: -self.strokeSettings.width, dy: -self.strokeSettings.width)
    }
    
    public func setStrokeSettings(to strokeSettings: StrokeSettings) {
        self.strokeSettings = strokeSettings.clone()
        self.boundingBox = self.path.boundingBox.insetBy(dx: -self.strokeSettings.width, dy: -self.strokeSettings.width)
    }
    
}

public class CurvilinearPrimitive: Primitive {
    
    private(set) var path: CGPath
    private(set) public var boundingBox: CGRect?
    public var strokeSettings: StrokeSettings?
    public var fillSettings: FillSettings?
    
    init(curvilinear: SMCurvilinearEdges, strokeSettings: StrokeSettings? = nil, fillSettings: FillSettings? = nil) {
        self.strokeSettings = strokeSettings?.clone()
        self.fillSettings = fillSettings?.clone()
        self.path = curvilinear.cgPath
        self.boundingBox = self.path.boundingBox.insetBy(dx: -(self.strokeSettings?.width ?? 0.0), dy: -(self.strokeSettings?.width ?? 0.0))
    }
    
    public func draw(on context: CGContext) {
        guard !(self.strokeSettings == nil && self.fillSettings == nil) else {
            return
        }
        context.saveGState()
        self.strokeSettings?.apply(to: context)
        self.fillSettings?.apply(to: context)
        context.addPath(self.path)
        if self.strokeSettings != nil && self.fillSettings != nil {
            context.drawPath(using: .fillStroke)
        } else if self.strokeSettings != nil {
            context.drawPath(using: .stroke)
        } else {
            context.drawPath(using: .fill)
        }
        context.restoreGState()
    }
    
    public func setCurvilinear(to curvilinear: SMCurvilinearEdges) {
        self.path = curvilinear.cgPath
        self.boundingBox = self.path.boundingBox.insetBy(dx: -(self.strokeSettings?.width ?? 0.0), dy: -(self.strokeSettings?.width ?? 0.0))
    }
    
    public func setFillSettings(to fillSettings: FillSettings) {
        self.fillSettings = fillSettings.clone()
    }
    
    public func setStrokeSettings(to strokeSettings: StrokeSettings) {
        self.strokeSettings = strokeSettings.clone()
        self.boundingBox = self.path.boundingBox.insetBy(dx: -(self.strokeSettings?.width ?? 0.0), dy: -(self.strokeSettings?.width ?? 0.0))
    }
    
}

public class BezierCurvePrimitive: Primitive {
    
    private(set) var path: CGPath
    private(set) public var boundingBox: CGRect?
    public var strokeSettings: StrokeSettings
    
    public init(bezierCurve: SMBezierCurve, strokeSettings: StrokeSettings) {
        self.strokeSettings = strokeSettings.clone()
        self.path = bezierCurve.cgPath
        self.boundingBox = self.path.boundingBox.insetBy(dx: -self.strokeSettings.width, dy: -self.strokeSettings.width)
    }
    
    public func draw(on context: CGContext) {
        context.saveGState()
        self.strokeSettings.apply(to: context)
        context.addPath(self.path)
        context.drawPath(using: .stroke)
        context.restoreGState()
    }
    
    public func setBezierCurve(to bezierCurve: SMBezierCurve) {
        self.path = bezierCurve.cgPath
        self.boundingBox = self.path.boundingBox.insetBy(dx: -self.strokeSettings.width, dy: -self.strokeSettings.width)
    }
    
    public func setStrokeSettings(to strokeSettings: StrokeSettings) {
        self.strokeSettings = strokeSettings.clone()
        self.boundingBox = self.path.boundingBox.insetBy(dx: -self.strokeSettings.width, dy: -self.strokeSettings.width)
    }
    
}

public class QuadCurvePrimitive: Primitive {
    
    private(set) var path: CGPath
    private(set) public var boundingBox: CGRect?
    public var strokeSettings: StrokeSettings
    
    public init(quadCurve: SMQuadCurve, strokeSettings: StrokeSettings) {
        self.strokeSettings = strokeSettings.clone()
        self.path = quadCurve.cgPath
        self.boundingBox = self.path.boundingBox.insetBy(dx: -self.strokeSettings.width, dy: -self.strokeSettings.width)
    }
    
    public func draw(on context: CGContext) {
        context.saveGState()
        self.strokeSettings.apply(to: context)
        context.addPath(self.path)
        context.drawPath(using: .stroke)
        context.restoreGState()
    }
    
    public func setQuadCurve(to quadCurve: SMQuadCurve) {
        self.path = quadCurve.cgPath
        self.boundingBox = self.path.boundingBox.insetBy(dx: -self.strokeSettings.width, dy: -self.strokeSettings.width)
    }
    
    public func setStrokeSettings(to strokeSettings: StrokeSettings) {
        self.strokeSettings = strokeSettings.clone()
        self.boundingBox = self.path.boundingBox.insetBy(dx: -self.strokeSettings.width, dy: -self.strokeSettings.width)
    }
    
}

public class EllipsePrimitive: Primitive {
    
    private(set) var path: CGPath
    private(set) public var boundingBox: CGRect?
    private(set) public var strokeSettings: StrokeSettings?
    private(set) public var fillSettings: FillSettings?
    
    init(ellipse: SMEllipse, strokeSettings: StrokeSettings? = nil, fillSettings: FillSettings? = nil) {
        self.strokeSettings = strokeSettings?.clone()
        self.fillSettings = fillSettings?.clone()
        self.path = ellipse.cgPath
        self.boundingBox = self.path.boundingBox.insetBy(dx: -(self.strokeSettings?.width ?? 0.0), dy: -(self.strokeSettings?.width ?? 0.0))
    }
    
    public func draw(on context: CGContext) {
        guard !(self.strokeSettings == nil && self.fillSettings == nil) else {
            return
        }
        context.saveGState()
        self.strokeSettings?.apply(to: context)
        self.fillSettings?.apply(to: context)
        context.addPath(self.path)
        if self.strokeSettings != nil && self.fillSettings != nil {
            context.drawPath(using: .fillStroke)
        } else if self.strokeSettings != nil {
            context.drawPath(using: .stroke)
        } else {
            context.drawPath(using: .fill)
        }
        context.restoreGState()
    }
    
    public func setEllipse(to ellipse: SMEllipse) {
        self.path = ellipse.cgPath
        self.boundingBox = self.path.boundingBox.insetBy(dx: -(self.strokeSettings?.width ?? 0.0), dy: -(self.strokeSettings?.width ?? 0.0))
    }
    
    public func setFillSettings(to fillSettings: FillSettings) {
        self.fillSettings = fillSettings.clone()
    }
    
    public func setStrokeSettings(to strokeSettings: StrokeSettings) {
        self.strokeSettings = strokeSettings.clone()
        self.boundingBox = self.path.boundingBox.insetBy(dx: -(self.strokeSettings?.width ?? 0.0), dy: -(self.strokeSettings?.width ?? 0.0))
    }
    
}

public class HexagonPrimitive: Primitive {
    
    private(set) var path: CGPath
    private(set) public var boundingBox: CGRect?
    public var strokeSettings: StrokeSettings?
    public var fillSettings: FillSettings?
    
    init(hexagon: SMHexagon, strokeSettings: StrokeSettings? = nil, fillSettings: FillSettings? = nil) {
        self.strokeSettings = strokeSettings?.clone()
        self.fillSettings = fillSettings?.clone()
        self.path = hexagon.cgPath
        self.boundingBox = self.path.boundingBox.insetBy(dx: -(self.strokeSettings?.width ?? 0.0), dy: -(self.strokeSettings?.width ?? 0.0))
    }
    
    public func draw(on context: CGContext) {
        guard !(self.strokeSettings == nil && self.fillSettings == nil) else {
            return
        }
        context.saveGState()
        self.strokeSettings?.apply(to: context)
        self.fillSettings?.apply(to: context)
        context.addPath(self.path)
        if self.strokeSettings != nil && self.fillSettings != nil {
            context.drawPath(using: .fillStroke)
        } else if self.strokeSettings != nil {
            context.drawPath(using: .stroke)
        } else {
            context.drawPath(using: .fill)
        }
        context.restoreGState()
    }
    
    public func setHexagon(to hexagon: SMHexagon) {
        self.path = hexagon.cgPath
        self.boundingBox = self.path.boundingBox.insetBy(dx: -(self.strokeSettings?.width ?? 0.0), dy: -(self.strokeSettings?.width ?? 0.0))
    }
    
    public func setFillSettings(to fillSettings: FillSettings) {
        self.fillSettings = fillSettings.clone()
    }
    
    public func setStrokeSettings(to strokeSettings: StrokeSettings) {
        self.strokeSettings = strokeSettings.clone()
        self.boundingBox = self.path.boundingBox.insetBy(dx: -(self.strokeSettings?.width ?? 0.0), dy: -(self.strokeSettings?.width ?? 0.0))
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
    
    internal func draw(on context: CGContext, canvasRect: CGRect?) {
        for primitive in self.primitives {
            if let canvasRect, let boundingBox = primitive.boundingBox, boundingBox.intersects(canvasRect) {
                primitive.draw(on: context)
            } else if canvasRect == nil {
                primitive.draw(on: context)
            }
        }
    }
    
}

public class CanvasLayerManager {
    
    private var layers = [Int: CanvasLayer]()
    private var layerPositions = [String: Int]()
    private(set) var layerCount = 0
    
    // MARK: - Layers
    
    internal func drawLayers(on context: CGContext, canvasRect: CGRect?, endEarly: (() -> Bool)? = nil) {
        for layerPosition in 0..<self.layerCount {
            let layer = self.layers[layerPosition]!
            layer.draw(on: context, canvasRect: canvasRect)
            if endEarly?() ?? false {
                return
            }
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
    
    @discardableResult
    public func removeAllLayers() -> Self {
        self.layers.removeAll()
        self.layerPositions.removeAll()
        self.layerCount = 0
        return self
    }
    
}
