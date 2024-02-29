//
//  CanvasLayerManager.swift
//  SwiftCanvasDemo
//
//  Created by Andre Pham on 1/3/2024.
//

import Foundation

public class CanvasLayer {
    
    private(set) var id: String
    
    init(id: String = UUID().uuidString) {
        self.id = id
    }
    
}

public class CanvasLayerManager {
    
    private var layers = [Int: CanvasLayer]()
    private var layerPositions = [String: Int]()
    private(set) var layerCount = 0
    
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
