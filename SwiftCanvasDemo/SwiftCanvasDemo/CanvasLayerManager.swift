//
//  CanvasLayerManager.swift
//  SwiftCanvasDemo
//
//  Created by Andre Pham on 1/3/2024.
//

import Foundation
import SwiftMath
import UIKit

// TODO: Add text primitive and ShadowSettings and a tap primitive thing so that I can interact with the canvas via taps
// ALSO fix the bug where if you leave the app and come back the scrollview has gone off the canvas
// ALSO fix the bug where if you zoom out and tap a hit target the canvas glitches

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
    
    var boundingBox: CGRect? { get }
    func draw(on context: CGContext)
    
}

public class LinePrimitive: Primitive {
    
    private(set) var lineSegment: SMLineSegment
    private(set) public var boundingBox: CGRect?
    public var strokeSettings: StrokeSettings
    
    public init(lineSegment: SMLineSegment, strokeSettings: StrokeSettings) {
        self.lineSegment = lineSegment.clone()
        self.boundingBox = lineSegment.boundingBox?.cgRect
        self.strokeSettings = strokeSettings
    }
    
    public func draw(on context: CGContext) {
        context.saveGState()
        self.strokeSettings.apply(to: context)
        context.addPath(self.lineSegment.cgPath)
        context.drawPath(using: .stroke)
        context.restoreGState()
    }
    
    public func setLine(to lineSegment: SMLineSegment) {
        self.lineSegment = lineSegment.clone()
        self.boundingBox = lineSegment.boundingBox?.cgRect
    }
    
}

public class ArcPrimitive: Primitive {
    
    private(set) var arc: SMArc
    private(set) public var boundingBox: CGRect?
    public var strokeSettings: StrokeSettings
    
    public init(arc: SMArc, strokeSettings: StrokeSettings) {
        self.arc = arc.clone()
        self.boundingBox = arc.boundingBox.cgRect
        self.strokeSettings = strokeSettings
    }
    
    public func draw(on context: CGContext) {
        context.saveGState()
        self.strokeSettings.apply(to: context)
        context.addPath(self.arc.cgPath)
        context.drawPath(using: .stroke)
        context.restoreGState()
    }
    
    public func setArc(to arc: SMArc) {
        self.arc = arc.clone()
        self.boundingBox = arc.boundingBox.cgRect
    }
    
}

public class RectPrimitive: Primitive {
    
    private(set) var rect: SMRect
    private(set) public var boundingBox: CGRect?
    public var strokeSettings: StrokeSettings?
    public var fillSettings: FillSettings?
    
    public init(rect: SMRect, strokeSettings: StrokeSettings? = nil, fillSettings: FillSettings? = nil) {
        self.rect = rect.clone()
        self.boundingBox = rect.cgRect
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
    
    public func setRect(to rect: SMRect) {
        self.rect = rect.clone()
        self.boundingBox = rect.cgRect
    }
    
}

public class PolygonPrimitive: Primitive {
    
    private(set) var polygon: SMPolygon
    private(set) public var boundingBox: CGRect?
    public var strokeSettings: StrokeSettings?
    public var fillSettings: FillSettings?
    
    public init(polygon: SMPolygon, strokeSettings: StrokeSettings? = nil, fillSettings: FillSettings? = nil) {
        self.polygon = polygon.clone()
        self.boundingBox = polygon.boundingBox?.cgRect
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
    
    public func setPolygon(to polygon: SMPolygon) {
        self.polygon = polygon.clone()
        self.boundingBox = polygon.boundingBox?.cgRect
    }
    
}

public class PolylinePrimitive: Primitive {
    
    private(set) var polyline: SMPolyline
    private(set) public var boundingBox: CGRect?
    public var strokeSettings: StrokeSettings
    
    public init(polyline: SMPolyline, strokeSettings: StrokeSettings) {
        self.polyline = polyline.clone()
        self.boundingBox = polyline.boundingBox?.cgRect
        self.strokeSettings = strokeSettings
    }
    
    public func draw(on context: CGContext) {
        context.saveGState()
        self.strokeSettings.apply(to: context)
        context.addPath(self.polyline.cgPath)
        context.drawPath(using: .stroke)
        context.restoreGState()
    }
    
    public func setPolyline(to polyline: SMPolyline) {
        self.polyline = polyline.clone()
        self.boundingBox = polyline.boundingBox?.cgRect
    }
    
}

extension SMQuadCurve {
    
    public var boundingBoxApproximate: SMRect {
        return SMPointCollection(points: [self.origin, self.controlPoint, self.end]).boundingBox!
    }
    
}

extension SMBezierCurve {
    
    public var boundingBoxApproximate: SMRect {
        return SMPointCollection(points: [self.origin, self.originControlPoint, self.end, self.endControlPoint]).boundingBox!
    }
    
}

extension SMCurvilinearEdges {
    
    public var boundingBoxApproximate: SMRect? {
        var boundingBox: SMRect? = nil
        for line in self.assortedLinearEdges {
            if boundingBox != nil, let lineBoundingBox = line.boundingBox {
                boundingBox = boundingBox!.union(lineBoundingBox)
            }
        }
        for arc in self.assortedArcEdges {
            if boundingBox != nil {
                boundingBox = boundingBox!.union(arc.boundingBox)
            }
        }
        for quad in self.assortedQuadEdges {
            if boundingBox != nil {
                boundingBox = boundingBox!.union(quad.boundingBoxApproximate)
            }
        }
        for bezier in self.assortedBezierEdges {
            if boundingBox != nil {
                boundingBox = boundingBox!.union(bezier.boundingBoxApproximate)
            }
        }
        return boundingBox
    }
    
}

public class CurvilinearPrimitive: Primitive {
    
    private(set) var curvilinear: SMCurvilinearEdges
    private(set) public var boundingBox: CGRect?
    public var strokeSettings: StrokeSettings?
    public var fillSettings: FillSettings?
    
    init(curvilinear: SMCurvilinearEdges, strokeSettings: StrokeSettings? = nil, fillSettings: FillSettings? = nil) {
        self.curvilinear = curvilinear.clone()
        self.boundingBox = curvilinear.boundingBoxApproximate?.cgRect
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
    
    public func setCurvilinear(to curvilinear: SMCurvilinearEdges) {
        self.curvilinear = curvilinear.clone()
        self.boundingBox = curvilinear.boundingBoxApproximate?.cgRect
    }
    
}

public class BezierCurvePrimitive: Primitive {
    
    private(set) var bezierCurve: SMBezierCurve
    private(set) public var boundingBox: CGRect?
    public var strokeSettings: StrokeSettings
    
    public init(bezierCurve: SMBezierCurve, strokeSettings: StrokeSettings) {
        self.bezierCurve = bezierCurve.clone()
        self.boundingBox = bezierCurve.boundingBoxApproximate.cgRect
        self.strokeSettings = strokeSettings
    }
    
    public func draw(on context: CGContext) {
        context.saveGState()
        self.strokeSettings.apply(to: context)
        context.addPath(self.bezierCurve.cgPath)
        context.drawPath(using: .stroke)
        context.restoreGState()
    }
    
    public func setBezierCurve(to bezierCurve: SMBezierCurve) {
        self.bezierCurve = bezierCurve.clone()
        self.boundingBox = bezierCurve.boundingBoxApproximate.cgRect
    }
    
}

public class QuadCurvePrimitive: Primitive {
    
    private(set) var quadCurve: SMQuadCurve
    private(set) public var boundingBox: CGRect?
    public var strokeSettings: StrokeSettings
    
    public init(quadCurve: SMQuadCurve, strokeSettings: StrokeSettings) {
        self.quadCurve = quadCurve.clone()
        self.boundingBox = quadCurve.boundingBoxApproximate.cgRect
        self.strokeSettings = strokeSettings
    }
    
    public func draw(on context: CGContext) {
        context.saveGState()
        self.strokeSettings.apply(to: context)
        context.addPath(self.quadCurve.cgPath)
        context.drawPath(using: .stroke)
        context.restoreGState()
    }
    
    public func setQuadCurve(to quadCurve: SMQuadCurve) {
        self.quadCurve = quadCurve.clone()
        self.boundingBox = quadCurve.boundingBoxApproximate.cgRect
    }
    
}

public class EllipsePrimitive: Primitive {
    
    private(set) var ellipse: SMEllipse
    private(set) public var boundingBox: CGRect?
    public var strokeSettings: StrokeSettings?
    public var fillSettings: FillSettings?
    
    init(ellipse: SMEllipse, strokeSettings: StrokeSettings? = nil, fillSettings: FillSettings? = nil) {
        self.ellipse = ellipse.clone()
        self.boundingBox = ellipse.boundingBox.cgRect
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
    
    public func setEllipse(to ellipse: SMEllipse) {
        self.ellipse = ellipse.clone()
        self.boundingBox = ellipse.boundingBox.cgRect
    }
    
}

public class HexagonPrimitive: Primitive {
    
    private(set) var hexagon: SMHexagon
    private(set) public var boundingBox: CGRect?
    public var strokeSettings: StrokeSettings?
    public var fillSettings: FillSettings?
    
    init(hexagon: SMHexagon, strokeSettings: StrokeSettings? = nil, fillSettings: FillSettings? = nil) {
        self.hexagon = hexagon.clone()
        self.boundingBox = hexagon.boundingBox.cgRect
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
    
    public func setHexagon(to hexagon: SMHexagon) {
        self.hexagon = hexagon.clone()
        self.boundingBox = hexagon.boundingBox.cgRect
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
                // TODO: Primitive bounding boxes need to account for stroke length
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
