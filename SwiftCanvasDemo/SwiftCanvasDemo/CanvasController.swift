//
//  CanvasController.swift
//  SwiftCanvasDemo
//
//  Created by Andre Pham on 29/2/2024.
//

import Foundation
import UIKit

class CanvasController: UIViewController, UIScrollViewDelegate {
    
    private let scrollView = UIScrollView()
    private let canvasView = UIView()
    private let imageView = UIImageView()
    
    private var canvasSize: CGSize {
        return self.view.bounds.size
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .red
        
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.scrollView)
        NSLayoutConstraint.activate([
            self.scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        self.scrollView.delegate = self
        
        self.scrollView.alwaysBounceVertical = true
        self.scrollView.alwaysBounceHorizontal = true
        
        self.scrollView.contentSize = CGSize(width: 3000, height: 3000)
        
        self.scrollView.minimumZoomScale = 0.2
        self.scrollView.maximumZoomScale = 10.0
        
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        
        // This is where the user "starts" in the scroll view
        self.scrollView.contentOffset = CGPoint(x: 1500, y: 1500)
        
        self.canvasView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.addSubview(self.canvasView)
        NSLayoutConstraint.activate([
            self.canvasView.widthAnchor.constraint(equalToConstant: 3000), // Match scrollView contentSize width
            self.canvasView.heightAnchor.constraint(equalToConstant: 3000), // Match scrollView contentSize height
            self.canvasView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
            self.canvasView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor)
        ])
//        self.imageView.backgroundColor = .green
        self.canvasView.addSubview(self.imageView)
    }
    
    override func viewDidLayoutSubviews() {
        self.imageView.frame = CGRect(origin: CGPoint(), size: self.canvasSize)
        self.imageView.backgroundColor = .green
        
        
        
        
        let renderer = UIGraphicsImageRenderer(size: self.canvasSize)

        let img = renderer.image { ctx in
            let rectangle = CGRect(x: 0, y: 0, width: 100, height: 100)

            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(10)

            ctx.cgContext.addRect(rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
        }

        self.imageView.image = img
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.canvasView
    }
    
}
