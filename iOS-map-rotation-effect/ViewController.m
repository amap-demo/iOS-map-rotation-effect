//
//  ViewController.m
//  iOS-map-rotation-effect
//
//  Created by 翁乐 on 2017/4/6.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import "ViewController.h"
#import <MAMapKit/MAMapKit.h>

@interface ViewController ()<UIGestureRecognizerDelegate,MAMapViewDelegate>
{
    MAMapView *_mapview;
    CGPoint _currentMapViewCenter;
    CGFloat _rotationRecord;
    BOOL _testAlert;
}

@end

@implementation ViewController

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (ABS(_rotationRecord - mapView.rotationDegree) >= 20 && _testAlert) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"alert" message:@"rotation changed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
        _testAlert = NO;
    }
    
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation
                                                             reuseIdentifier:pointReuseIndetifier];
        }
        return annotationView;
    }
    
    return nil;
}

- (CGFloat)distanceFromPointA:(CGPoint)pointA toPointB:(CGPoint)pointB
{
    return sqrt(pow((pointA.x - pointB.x),2) + pow((pointA.y - pointB.y),2));
}

- (CGFloat)degressAForPointA:(CGPoint)pointA pointB:(CGPoint)pointB centerPoint:(CGPoint)centerPoint
{
    CGFloat b = [self distanceFromPointA:pointA toPointB:centerPoint];
    CGFloat c = [self distanceFromPointA:centerPoint toPointB:pointB];
    CGFloat a = [self distanceFromPointA:pointB toPointB:pointA];
    
    ///余弦定理
    CGFloat cosA = (pow(b, 2) + pow(c, 2) - pow(a, 2)) / (2*b*c);
    
    // 0 到 180度
    return acos(cosA)/M_PI * 180;
}

- (BOOL)isCounterClockwiseForPointA:(CGPoint)pointA centerPoint:(CGPoint)pointCenter pointB:(CGPoint)pointB
{
    // 以center point 为原点的向量a
    CGPoint vectA = CGPointMake(pointA.x - pointCenter.x, pointA.y - pointCenter.y);
    // 以center point 为原点的向量c
    CGPoint vectC = CGPointMake(pointB.x - pointCenter.x, pointB.y - pointCenter.y);
    // 向量a 和 向量c 的叉乘
    
    CGFloat vectProduct = vectA.x * vectC.y - vectC.x * vectA.y;
    
    /* 大于0, 向量a为于向量c的顺时针方向, 即A->C 逆时针
     小于0，向量a 位于向量c的逆时针方向, 即A -> C 顺时针
     等于 0，共线，可忽略*/
    return vectProduct > 0 ? YES : NO;
}

- (void)panToRotateAction:(UIGestureRecognizer *)gestureRecognizer
{
    static CGPoint startPoint;
    static CGFloat lastRotationDegree;
    
    CGFloat degree = 0;
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        startPoint = [gestureRecognizer locationInView:_mapview];
        lastRotationDegree = _mapview.rotationDegree;
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged){
        CGPoint currentPoint = [gestureRecognizer locationInView:_mapview];
        
        degree = [self degressAForPointA:startPoint pointB:currentPoint centerPoint:_currentMapViewCenter];
        
        CGFloat newDegree = 0;
        if ([self isCounterClockwiseForPointA:startPoint centerPoint:_currentMapViewCenter pointB:currentPoint]) {
            newDegree = (int)(lastRotationDegree-degree) % (int)360;
            lastRotationDegree = newDegree != NAN ? newDegree : lastRotationDegree;
        } else {
            newDegree = (int)(lastRotationDegree+degree) % (int)360;
            lastRotationDegree = newDegree != NAN ? newDegree : lastRotationDegree;
        }
        
        startPoint = currentPoint;
        
        [_mapview setRotationDegree:lastRotationDegree];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
    annotation.coordinate = _mapview.centerCoordinate;
    [_mapview addAnnotation:annotation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _testAlert = YES;
    
    _mapview = [[MAMapView alloc] initWithFrame:self.view.bounds];
    _mapview.zoomLevel = 17;
    _mapview.cameraDegree = 60;
    
    _mapview.delegate = self;
    
    
    _rotationRecord = _mapview.rotationDegree;
    _currentMapViewCenter = CGPointMake(0.5 * self.view.bounds.size.width, 0.75 * self.view.bounds.size.height);
    _mapview.scrollEnabled = NO;
    _mapview.rotateEnabled = NO;
    _mapview.zoomEnabled = NO;
    _mapview.rotateCameraEnabled = NO;
    _mapview.screenAnchor = CGPointMake(0.5, 0.75);
    
    
    UIPanGestureRecognizer *panToRotateGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panToRotateAction:)];
    [_mapview addGestureRecognizer:panToRotateGesture];
    panToRotateGesture.delegate = self;
    panToRotateGesture.maximumNumberOfTouches = 1;
    panToRotateGesture.minimumNumberOfTouches = 1;
    
    [self.view addSubview:_mapview];
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
