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
    private let viewportImage = UIImageView()
    
    // MARK: - Layer Properties
    
    public let layerManager = CanvasLayerManager()
    
    // MARK: - Rendering Properties
    
    private var canvasSize = CGSize()
    private var viewSize: CGSize {
        return self.view.bounds.size
    }
    private var minZoomScale: CGFloat {
        return self.scrollContainer.minimumZoomScale
    }
    private var maxZoomScale: CGFloat {
        return self.scrollContainer.maximumZoomScale
    }
    private var zoomScale: CGFloat {
        return self.scrollContainer.zoomScale
    }
    private var visibleArea: CGRect {
        let width = self.scrollContainer.bounds.size.width/self.zoomScale
        let height = self.scrollContainer.bounds.size.height/self.zoomScale
        var x = self.scrollContainer.contentOffset.x/self.zoomScale
        var y = self.scrollContainer.contentOffset.y/self.zoomScale
        guard !self.visibleAreaOutOfBounds else {
            return CGRect(x: x, y: y, width: width, height: height)
        }
        if isGreater(x + width, self.canvasSize.width) {
            x -= (x + width - self.canvasSize.width)
        }
        if isGreater(y + height, self.canvasSize.height) {
            y -= (y + height - self.canvasSize.height)
        }
        return CGRect(
            x: max(x, 0.0),
            y: max(y, 0.0),
            width: width,
            height: height
        )
    }
    private var visibleAreaOutOfBounds: Bool {
        return isLess(self.zoomScale, self.minZoomScale)
    }
    
    // MARK: - Config Functions
    
    @discardableResult
    public func setCanvasSize(to size: CGSize) -> Self {
        self.canvasSize = size
        self.canvasContainer.frame = CGRect(origin: CGPoint(), size: self.canvasSize)
        self.scrollContainer.contentOffset = CGPoint(x: size.width/2.0, y: size.height/2.0)
        return self
    }
    
    @discardableResult
    public func setCanvasBounce(to state: Bool) -> Self {
        self.scrollContainer.alwaysBounceVertical = state
        self.scrollContainer.alwaysBounceHorizontal = state
        return self
    }
    
    @discardableResult
    public func setCanvasBackgroundColor(to color: UIColor) -> Self {
        self.view.backgroundColor = color
        return self
    }
    
    @discardableResult
    public func setMinZoomScale(to scale: Double) -> Self {
        self.scrollContainer.minimumZoomScale = scale
        return self
    }
    
    @discardableResult
    public func setMaxZoomScale(to scale: Double) -> Self {
        self.scrollContainer.maximumZoomScale = scale
        return self
    }
    
    @discardableResult
    public func matchMinZoomScaleToCanvasSize() -> Self {
        return self.setMinZoomScale(to: self.viewSize.height/min(self.canvasSize.width, self.canvasSize.height))
    }
    
    @discardableResult
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
        self.canvasContainer.addSubview(self.viewportImage)
        
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
        
        let temp = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        temp.backgroundColor = .red.withAlphaComponent(0.2)
        self.canvasContainer.addSubview(temp)
        
        let temp2 = UIView(frame: CGRect(x: 0, y: 3000 - 200, width: 200, height: 200))
        temp2.backgroundColor = .red.withAlphaComponent(0.2)
        self.canvasContainer.addSubview(temp2)
        
        self.viewportImage.layer.borderColor = UIColor.green.cgColor
        self.viewportImage.layer.borderWidth = 20.0
    }
    
    public override func viewDidLayoutSubviews() {
        self.refresh()
    }
    
    // MARK: - Rendering Functions
    
    private func realignImage() {
        self.viewportImage.frame = self.visibleArea
    }
    
    private func redraw() {
        let renderer = UIGraphicsImageRenderer(size: self.viewSize)
        let renderedImage = renderer.image { ctx in
            ctx.cgContext.scaleBy(x: self.zoomScale, y: self.zoomScale)
            let visibleRect = self.visibleArea
            ctx.cgContext.translateBy(x: -visibleRect.origin.x, y: -visibleRect.origin.y)
            self.layerManager.drawLayers(on: ctx.cgContext)
            ctx.cgContext.translateBy(x: visibleRect.origin.x, y: visibleRect.origin.y)
        }
        self.viewportImage.image = renderedImage
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
        if !self.visibleAreaOutOfBounds || true {
            self.refresh()
        }
        
        // TODO: Clean up, make into a method
        let width = scrollView.bounds.size.width
        let height = scrollView.bounds.size.height
        let contentWidth = scrollView.contentSize.width
        let contentHeight = scrollView.contentSize.height
        let horizontalInset = max(0, (width - contentWidth) / 2)
        let verticalInset = max(0, (height - contentHeight) / 2)
        scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !self.visibleAreaOutOfBounds || true {
            self.refresh()
        }
    }
    
}
