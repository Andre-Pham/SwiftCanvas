//
//  CanvasController.swift
//  SwiftCanvasDemo
//
//  Created by Andre Pham on 29/2/2024.
//

import Foundation
import UIKit

public class CanvasController: UIViewController, UIScrollViewDelegate {
    
    // MARK: - Default Constants
    
    private static let DEFAULT_CANVAS_WIDTH = 3000.0
    private static let DEFAULT_CANVAS_HEIGHT = 3000.0
    private static let DEFAULT_CANVAS_COLOR = UIColor.clear
    private static let DEFAULT_BOUNCE = true
    private static let DEFAULT_MIN_ZOOM_SCALE = 0.2
    private static let DEFAULT_MAX_ZOOM_SCALE = 10.0
    private static let DEFAULT_SHOW_SCROLL_BARS = true
    
    // MARK: - View Properties
    
    private let scrollContainer = UIScrollView()
    private let canvasContainer = UIView()
    private let visibleImage = UIImageView()
    
    // MARK: - Layer Properties
    
    public let layerManager = CanvasLayerManager()
    
    // MARK: - Rendering Properties
    
    private var canvasSize = CGSize()
    private var viewSize: CGSize {
        return self.view.bounds.size
    }
    private var zoomScale: CGFloat {
        return self.scrollContainer.zoomScale
    }
    private var visibleRect: CGRect {
        return CGRect(
            x: self.scrollContainer.contentOffset.x/self.zoomScale,
            y: self.scrollContainer.contentOffset.y/self.zoomScale,
            width: self.scrollContainer.bounds.size.width/self.zoomScale,
            height: self.scrollContainer.bounds.size.height/self.zoomScale
        )
    }
    
    // MARK: - Config Functions
    
    public func setCanvasSize(to size: CGSize) -> Self {
        self.canvasSize = size
        self.canvasContainer.frame = CGRect(origin: CGPoint(), size: self.canvasSize)
        self.scrollContainer.contentOffset = CGPoint(x: size.width/2.0, y: size.height/2.0)
        return self
    }
    
    public func setCanvasBounce(to state: Bool) -> Self {
        self.scrollContainer.alwaysBounceVertical = state
        self.scrollContainer.alwaysBounceHorizontal = state
        return self
    }
    
    public func setCanvasBackgroundColor(to color: UIColor) -> Self {
        self.view.backgroundColor = color
        return self
    }
    
    public func setMinZoomScale(to scale: Double) -> Self {
        self.scrollContainer.minimumZoomScale = scale
        return self
    }
    
    public func setMaxZoomScale(to scale: Double) -> Self {
        self.scrollContainer.maximumZoomScale = scale
        return self
    }
    
    public func setScrollBarVisibility(to visible: Bool) -> Self {
        self.scrollContainer.showsVerticalScrollIndicator = visible
        self.scrollContainer.showsHorizontalScrollIndicator = visible
        return self
    }
    
    // MARK: - View Loading Functions
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup properties
        self.canvasSize = CGSize(width: Self.DEFAULT_CANVAS_WIDTH, height: Self.DEFAULT_CANVAS_HEIGHT)
        self.view.backgroundColor = Self.DEFAULT_CANVAS_COLOR
        
        // View hierarchy
        self.view.addSubview(self.scrollContainer)
        self.scrollContainer.addSubview(self.canvasContainer)
        self.canvasContainer.addSubview(self.visibleImage)
        
        // Setup scroll container
        self.scrollContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.scrollContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.scrollContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.scrollContainer.topAnchor.constraint(equalTo: view.topAnchor),
            self.scrollContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        self.scrollContainer.delegate = self
        self.scrollContainer.alwaysBounceVertical = Self.DEFAULT_BOUNCE
        self.scrollContainer.alwaysBounceHorizontal = Self.DEFAULT_BOUNCE
        self.scrollContainer.contentSize = self.canvasSize
        self.scrollContainer.minimumZoomScale = Self.DEFAULT_MIN_ZOOM_SCALE
        self.scrollContainer.maximumZoomScale = Self.DEFAULT_MAX_ZOOM_SCALE
        self.scrollContainer.showsVerticalScrollIndicator = Self.DEFAULT_SHOW_SCROLL_BARS
        self.scrollContainer.showsHorizontalScrollIndicator = Self.DEFAULT_SHOW_SCROLL_BARS
        self.scrollContainer.contentOffset = CGPoint(x: Self.DEFAULT_CANVAS_WIDTH/2.0, y: Self.DEFAULT_CANVAS_HEIGHT/2.0)
        
        // Setup canvas container
        self.canvasContainer.frame = CGRect(origin: CGPoint(), size: self.canvasSize)
    }
    
    public override func viewDidLayoutSubviews() {
        self.refresh()
    }
    
    // MARK: - Rendering Functions
    
    private func realignImage() {
        self.visibleImage.frame = self.visibleRect
    }
    
    private func redraw() {
        let renderer = UIGraphicsImageRenderer(size: self.viewSize)
        let renderedImage = renderer.image { ctx in
            ctx.cgContext.scaleBy(x: self.zoomScale, y: self.zoomScale)
            let visibleRect = self.visibleRect
            ctx.cgContext.translateBy(x: -visibleRect.origin.x, y: -visibleRect.origin.y)
            self.layerManager.drawLayers(on: ctx.cgContext)
            ctx.cgContext.translateBy(x: visibleRect.origin.x, y: visibleRect.origin.y)
        }
        self.visibleImage.image = renderedImage
    }
    
    public func refresh() {
        self.realignImage()
        self.redraw()
    }
    
    // MARK: - Scroll Delegate Functions
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.canvasContainer
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.refresh()
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        self.refresh()
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.refresh()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.refresh()
    }
    
}
