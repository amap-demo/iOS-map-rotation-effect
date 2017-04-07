//
//  ViewController.swift
//  iOS-map-rotation-effect-Swift
//
//  Created by 翁乐 on 2017/4/6.
//  Copyright © 2017年 Amap. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIGestureRecognizerDelegate,MAMapViewDelegate {
    
    var mapView:MAMapView?
    var currentMapViewCenter:CGPoint
    
    var startPoint:CGPoint = .zero
    var lastRotationDegree:CGFloat = 0
    let pointReuseIndetifier = "pointReuseIndetifier"
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        if annotation is MAPointAnnotation {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier)
            
            if annotationView == nil {
                annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
            }
            return annotationView
        }
        
        return nil
    }
    
    func distanceFromPointAToPointB(pointA:CGPoint, pointB:CGPoint) -> CGFloat {
        return sqrt(pow((pointA.x - pointB.x),2) + pow((pointA.y - pointB.y),2))
    }
    
    func degressAForPoint(pointA:CGPoint, pointB:CGPoint, centerPoint:CGPoint) -> CGFloat {
        let b = self.distanceFromPointAToPointB(pointA: pointA, pointB: centerPoint)
        let c = self.distanceFromPointAToPointB(pointA: centerPoint, pointB: pointB)
        let a = self.distanceFromPointAToPointB(pointA: pointB, pointB: pointA)
        
        ///余弦定理
        let cosA:CGFloat = (pow(b, 2) + pow(c, 2) - pow(a, 2)) / (2*b*c)
        
        return acos(cosA) / CGFloat(Double.pi) * 180.0
    }
    
    func isCounterClockwiseForPoint(pointA:CGPoint, pointCenter:CGPoint, pointB:CGPoint) -> Bool {
        // 以center point 为原点的向量a
        let vectA = CGPoint(x: pointA.x - pointCenter.x, y: pointA.y - pointCenter.y)
        // 以center point 为原点的向量c
        let vectC = CGPoint(x: pointB.x - pointCenter.x, y: pointB.y - pointCenter.y)
        
        // 向量a 和 向量c 的叉乘
        let vectProduct = vectA.x * vectC.y - vectC.x * vectA.y
        
        return vectProduct > 0 ? true : false
    }
    
    func panToRotateAction(gestureRecognizer:UIGestureRecognizer) {
        
        var degree:CGFloat = 0
        if gestureRecognizer.state == .began {
            startPoint = gestureRecognizer.location(in: mapView)
            lastRotationDegree = (mapView?.rotationDegree)!
        } else if gestureRecognizer.state == .changed {
            let currentPoint:CGPoint = gestureRecognizer.location(in: mapView)
            
            degree = self.degressAForPoint(pointA: startPoint, pointB: currentPoint, centerPoint: currentMapViewCenter)
            
            var newDegree:CGFloat = 0
            if self.isCounterClockwiseForPoint(pointA: startPoint, pointCenter: currentMapViewCenter, pointB: currentPoint) {
                newDegree = CGFloat(Int(lastRotationDegree - degree) % Int(360))
                lastRotationDegree = !newDegree.isNaN ? newDegree : lastRotationDegree
            } else {
                newDegree = CGFloat(Int(lastRotationDegree + degree) % Int(360))
                lastRotationDegree = !newDegree.isNaN ? newDegree : lastRotationDegree
            }
            
            startPoint = currentPoint
            mapView?.rotationDegree = lastRotationDegree
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let annotation:MAPointAnnotation = MAPointAnnotation()
        annotation.coordinate = (mapView?.centerCoordinate)!
        mapView?.addAnnotation(annotation)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = MAMapView(frame: view.bounds)
        mapView?.zoomLevel = 17
        mapView?.cameraDegree = 60
        mapView?.screenAnchor = CGPoint(x: 0.5, y: 0.75)
        currentMapViewCenter = CGPoint(x: 0.5 * view.bounds.size.width, y: 0.75 * view.bounds.size.height)
        
        mapView?.isScrollEnabled = false
        mapView?.isRotateEnabled = false
        mapView?.isZoomEnabled = false
        mapView?.isRotateCameraEnabled = false
        
        let panToRotateGesture = UIPanGestureRecognizer(target: self, action: #selector(ViewController.panToRotateAction(gestureRecognizer:)))
        mapView?.addGestureRecognizer(panToRotateGesture)
        panToRotateGesture.delegate = self
        panToRotateGesture.maximumNumberOfTouches = 1
        panToRotateGesture.minimumNumberOfTouches = 1
        
        view.addSubview(mapView!)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    required init?(coder aDecoder: NSCoder) {
        mapView = nil
        currentMapViewCenter = .zero
        
        super.init(coder: aDecoder)
    }
    
}

