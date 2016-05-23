//
//  ViewController.m
//  NewMap
//
//  Created by zhidao on 16/5/18.
//  Copyright © 2016年 zhidao. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "Tracking.h"
#import <CoreLocation/CoreLocation.h>
#define BEGIN_FLASH @"Begin flash"
#define kDebugShowArea 0
const double a = 6378245.0;
const double ee = 0.00669342162296594323;

@interface ViewController () <CLLocationManagerDelegate, MKMapViewDelegate, TrackingDelegate>
{
    CLLocationManager *_locationManager;
    MKMapView *_myMapView;
    CLLocationCoordinate2D userCurrLocation;
    Tracking *tracking;
}
@end

@implementation ViewController

+(ViewController *)shared
{
    static ViewController *mainVC = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mainVC = [[ViewController alloc] init];
    });
    return mainVC;
}

-(instancetype)init
{
    if (self = [super init]) {
        _disLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 30)];
        _disLabel.backgroundColor = [UIColor clearColor];
        _disLabel.textColor = [UIColor colorWithRed:0.9108 green:0.6761 blue:0.625 alpha:1.0];
        _disLabel.textAlignment = NSTextAlignmentCenter;
        _disLabel.font = [UIFont systemFontOfSize:17];
        self.navigationItem.titleView = _disLabel;
        
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rightBtn.frame  = CGRectMake(0, 0, 80, 40);
        [rightBtn addTarget:self action:@selector(clickRightButton:) forControlEvents:UIControlEventTouchUpInside];
        [rightBtn setTitle:@"轨迹回放" forState:UIControlStateNormal];
        rightBtn.backgroundColor = [UIColor clearColor];
        [rightBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        rightBtn.selected = NO;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
        
        _heartView = [[HeartView_h alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [self.view addSubview:_heartView];
        _heartView.passThroughViews = [NSArray arrayWithObjects:self.view, nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginFlash) name:BEGIN_FLASH object:nil];
        
        
    }
    
    return self;
}
-(void)dealloc{
    [self removeObserver:self forKeyPath:BEGIN_FLASH];
   
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _myMapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    [_myMapView setUserTrackingMode:MKUserTrackingModeNone];
    _myMapView.showsUserLocation = YES;
    _myMapView.delegate = self;
    
    [self.view addSubview:_myMapView];
    //
    MKUserTrackingBarButtonItem *trackBtn = [[MKUserTrackingBarButtonItem alloc] initWithMapView:_myMapView];
    self.navigationItem.leftBarButtonItem = trackBtn;
    
    [self initLocationTracking];
}
//轨迹回放
- (void)clickRightButton:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        
        [_myMapView removeOverlay:self.crumbs];
        [sender setTitle:@"停止回放" forState:UIControlStateNormal];
        [_locationManager stopUpdatingLocation];
        /* 构建tracking. */
        CLLocationCoordinate2D *pointBuffer = malloc(sizeof(CLLocationCoordinate2D) * self.crumbs.pointCount);
        for (int i = 0; i < self.crumbs.pointCount; i++) {
            pointBuffer[i] = MKCoordinateForMapPoint(self.crumbs.pointBuffer[i]);
        }
        tracking = [[Tracking alloc] initWithCoordinates:pointBuffer count:self.crumbs.pointCount];
        tracking.delegate = self;
        tracking.mapView  = _myMapView;
        tracking.duration = 5.f;
        tracking.edgeInsets = UIEdgeInsetsMake(50, 50, 50, 50);
        
        [self performSelector:@selector(begin) withObject:nil afterDelay:1];
        [self makeMapViewEnable:NO];
        

    }
    else
    {
        [_myMapView addOverlay:self.crumbs];
        [sender setTitle:@"轨迹回放" forState:UIControlStateNormal];
        [_locationManager startUpdatingLocation];
        [tracking clear];
        [self makeMapViewEnable:YES];
    }
}
- (void)begin
{
    [tracking execute];
}
/* Enable/Disable mapView. */
- (void)makeMapViewEnable:(BOOL)enabled
{
    _myMapView.scrollEnabled          = enabled;
    _myMapView.zoomEnabled            = enabled;
    _myMapView.rotateEnabled          = enabled;
    _myMapView.rotateEnabled          = enabled;
}
#pragma mark - TrackingDelegate

- (void)willBeginTracking:(Tracking *)tracking
{
    NSLog(@"%s", __func__);
}

- (void)didEndTracking:(Tracking *)tracking
{
    NSLog(@"%s", __func__);
}
//将用户位置设置为地图中心

- (void)setMapCenter
{
    [UIView animateWithDuration:0.5 animations:^{
        [_myMapView setCenterCoordinate:userCurrLocation];
        [self setZoomLevel:200];
    }];
   

}
- (void)initLocationTracking
{
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [_locationManager requestWhenInUseAuthorization];
    }
    _locationManager.distanceFilter = 1;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    [_locationManager startUpdatingLocation];
    
}
- (MKCoordinateRegion)coordinateRegionWithCerter:(CLLocationCoordinate2D)centerCoordinate approximateRadiusInMeters:(CLLocationDistance)radiusInMeters
{
    //
    double radiusInMapPoints = radiusInMeters*MKMapPointsPerMeterAtLatitude(centerCoordinate.latitude);
    MKMapSize radiusSquared = {radiusInMapPoints,radiusInMapPoints};
    
    MKMapPoint regionOrigin = MKMapPointForCoordinate(centerCoordinate);
    MKMapRect regionRect = (MKMapRect){regionOrigin, radiusSquared}; //origin is the top-left corner
    
    regionRect = MKMapRectOffset(regionRect, -radiusInMapPoints/2, -radiusInMapPoints/2);
    
    // clamp the rect to be within the world
    regionRect = MKMapRectIntersection(regionRect, MKMapRectWorld);
    
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(regionRect);
    return region;

}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    
    
    if (locations != nil && locations.count > 0) {
    
        CLLocation *newLocation = [locations lastObject];
        CLLocationCoordinate2D coordinate = newLocation.coordinate;
        NSLog(@"%f, %f", coordinate.latitude, coordinate.longitude);
        //转化为火星坐标
        CLLocationCoordinate2D gLocation = [self convertWGSToGCJ:coordinate];
        userCurrLocation  = gLocation;
        if (_myMapView.centerCoordinate.latitude  != gLocation.latitude &&
            _myMapView.centerCoordinate.longitude != gLocation.longitude) {
            [self setMapCenter];
            

        }

        if (self.crumbs == nil) {
            _crumbs = [[CrumbPath alloc] initWithCenterCoordinate:gLocation];
            [_myMapView addOverlay:self.crumbs level:MKOverlayLevelAboveRoads];
           
//            MKCoordinateRegion region = [self coordinateRegionWithCerter:gLocation approximateRadiusInMeters:800];
//            [_myMapView setRegion:region animated:YES];
            [self setZoomLevel:200];
        }
        else
        {
            BOOL boundingMapRectChanged = NO;
            MKMapRect updateRect = [self.crumbs addCoordinate:gLocation boundingMapRectChanged:&boundingMapRectChanged];
            self.disLabel.text = [NSString stringWithFormat:@"%d 米", (int)self.crumbs.userDistance];
            
            if (boundingMapRectChanged)
            {
                // MKMapView expects an overlay's boundingMapRect to never change (it's a readonly @property).
                // So for the MapView to recognize the overlay's size has changed, we remove it, then add it again.
                [_myMapView removeOverlays:_myMapView.overlays];
                _crumbPathRenderer = nil;
                [_myMapView addOverlay:self.crumbs level:MKOverlayLevelAboveRoads];
                
                MKMapRect r = self.crumbs.boundingMapRect;
                MKMapPoint pts[] = {
                    MKMapPointMake(MKMapRectGetMinX(r), MKMapRectGetMinY(r)),
                    MKMapPointMake(MKMapRectGetMinX(r), MKMapRectGetMaxY(r)),
                    MKMapPointMake(MKMapRectGetMaxX(r), MKMapRectGetMaxY(r)),
                    MKMapPointMake(MKMapRectGetMaxX(r), MKMapRectGetMinY(r)),
                };
                NSUInteger count = sizeof(pts) / sizeof(pts[0]);
                MKPolygon *boundingMapRectOverlay = [MKPolygon polygonWithPoints:pts count:count];
                [_myMapView addOverlay:boundingMapRectOverlay level:MKOverlayLevelAboveRoads];
            }
            else if (!MKMapRectIsNull(updateRect))
            {
                MKZoomScale currentZoomScale = (CGFloat)(_myMapView.bounds.size.width/_myMapView.visibleMapRect.size.width);
                CGFloat lineWidth = MKRoadWidthAtZoomScale(currentZoomScale);
                updateRect = MKMapRectInset(updateRect, -lineWidth, -lineWidth);
                [self.crumbPathRenderer setNeedsDisplayInMapRect:updateRect];
            }

        }
    }

}
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%s:%d %@", __func__, __LINE__, error);
}
-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKOverlayRenderer *renderer = nil;
    
    if ([overlay isKindOfClass:[CrumbPath class]])
    {
        if (self.crumbPathRenderer == nil)
        {
            _crumbPathRenderer = [[CrumbPathRenderer alloc] initWithOverlay:overlay];
        }
        renderer = self.crumbPathRenderer;
    }
    else if ([overlay isKindOfClass:[MKPolygon class]])
    {
#if kDebugShowArea
        if (![self.drawingAreaRenderer.polygon isEqual:overlay])
        {
            _drawingAreaRenderer = [[MKPolygonRenderer alloc] initWithPolygon:overlay];
            self.drawingAreaRenderer.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.25];
        }
        renderer = self.drawingAreaRenderer;
#endif
    }
    
    else if (overlay == tracking.polyline){
        MKPolylineRenderer *polylineRenderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        polylineRenderer.lineWidth = 4.f;
        polylineRenderer.strokeColor = [UIColor blueColor];
        return  polylineRenderer;
        
    }
    
    return renderer;

}
- (void)beginFlash
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.heartView.begin = YES;
    });
    
}
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        MKAnnotationView *cview = (MKAnnotationView*)[_myMapView dequeueReusableAnnotationViewWithIdentifier:@"USER_ANNONTATION"];
        if (cview == nil) {
            cview = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"USER_ANNONTATION"];
        }
        
        UIImage *img = [UIImage imageNamed:@"pig.jpg"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:img];
        imageView.frame = CGRectMake(0, 0, 50, 50);
        imageView.center = cview.center;
        imageView.layer.cornerRadius = 25;
        imageView.clipsToBounds = YES;
        [cview addSubview:imageView];
        cview.layer.cornerRadius = 25;
        
        cview.canShowCallout = YES;
        cview.draggable = NO;
        return cview;
    }
    if ([annotation isEqual: tracking.annotation]) {
        MKAnnotationView *trackingView = (MKAnnotationView *)[_myMapView dequeueReusableAnnotationViewWithIdentifier:@"TRACKING_ID"];
        if (trackingView == nil) {
            trackingView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"TRACKING_ID"];
        }
        trackingView.canShowCallout = NO;
        trackingView.image = [UIImage imageNamed:@"ball"];
        return trackingView;
    }
    return nil;
}
/**
 *  从地球坐标系 (WGS-84) 到火星坐标系 (GCJ-02) 的转换算法
 *
 *  @param wgsCoordinate GPS坐标
 *
 *  @return GCJ坐标
 */
- (CLLocationCoordinate2D)convertWGSToGCJ:(CLLocationCoordinate2D)wgsCoordinate
{
    // 地球坐标的经纬度
    double wgLat = wgsCoordinate.latitude;
    double wgLon = wgsCoordinate.longitude;
    // 火星坐标的经纬度，返回值
    double mgLat = 0.0f;
    double mgLon = 0.0f;
    
    // 不在中国，则直接返回地球坐标
    if(wgLon < 72.004 || wgLon > 137.8347 || wgLat < 0.8293 || wgLat > 55.8271)
    {
        mgLat = wgLat;
        mgLon = wgLon;
        return CLLocationCoordinate2DMake(mgLat, mgLon);
    }
    double dLat = [self transformLatWithX:wgLon - 105.0 Y:wgLat - 35.0];
    double dLon = [self transformLonWithX:wgLon - 105.0 Y:wgLat - 35.0];
    double radLat = wgLat / 180.0 * M_PI;
    double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * M_PI);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * M_PI);
    mgLat = wgLat + dLat;
    mgLon = wgLon + dLon;
    return CLLocationCoordinate2DMake(mgLat, mgLon);
}
- (double)transformLatWithX:(double)x Y:(double)y
{
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * M_PI) + 320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0;
    return ret;
}

- (double)transformLonWithX:(double)x Y:(double)y
{
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0;
    return ret;
}
//返回地图缩放级别
- (CGFloat)getMapZoomLevel{
    return log2(360.0f * ((_myMapView.frame.size.width/256.0f) / _myMapView.region.span.longitudeDelta));
}
//设置地图缩放级别
-(void)setZoomLevel:(float)level{
//    MKCoordinateSpan span = MKCoordinateSpanMake(0, 360.0f/pow(2, level) * _myMapView.frame.size.width/256.0f);
//    [_myMapView setRegion:MKCoordinateRegionMake(_myMapView.centerCoordinate, span)];
    
    MKCoordinateRegion region = [self coordinateRegionWithCerter:userCurrLocation approximateRadiusInMeters:level];
    [_myMapView setRegion:region animated:YES];


}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
