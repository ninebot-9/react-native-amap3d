import GoogleMaps

@objc(AMapViewManager)
class AMapViewManager: RCTViewManager {
    override class func requiresMainQueueSetup() -> Bool { false }
    
    override func view() -> UIView {
        let view = MapView()
        view.delegate = view
        return view
    }
    
    
    
    @objc func moveCamera(_ reactTag: NSNumber, position: NSDictionary, duration: Int) {
        getView(reactTag: reactTag) { view in
            view.moveCamera(position: position, duration: duration)
        }
    }
    
    @objc func call(_ reactTag: NSNumber, callerId: Double, name: String, args: NSDictionary) {
        getView(reactTag: reactTag) { view in
            view.call(id: callerId, name: name, args: args)
        }
    }
    
    func getView(reactTag: NSNumber, callback: @escaping (MapView) -> Void) {
        bridge.uiManager.addUIBlock { _, viewRegistry in
            callback(viewRegistry![reactTag] as! MapView)
        }
    }
}
public let NBNotificationThemeChange: String = "NBNotificationThemeChange"

class MapView: GMSMapView, GMSMapViewDelegate {
    var initialized = false
//    var overlayMap: [GMSPolyline: Polyline] = [:]
//    var markerMap: [CLLocationCoordinate2D: Marker] = [:]
    var mapStyleName = ""
    @objc var onLoad: RCTBubblingEventBlock = { _ in }
    @objc var onCameraMove: RCTBubblingEventBlock = { _ in }
    @objc var onCameraIdle: RCTBubblingEventBlock = { _ in }
    @objc var onPress: RCTBubblingEventBlock = { _ in }
    @objc var onPressPoi: RCTBubblingEventBlock = { _ in }
    @objc var onLongPress: RCTBubblingEventBlock = { _ in }
    @objc var onLocation: RCTBubblingEventBlock = { _ in }
    @objc var onCallback: RCTBubblingEventBlock = { _ in }
    
    

    
    @objc func setRotateCameraEnabled(_ bool: Bool) {
        debugPrint("rotateCameraEnabled:\(bool)")
    }
    
    @objc func setShowsCompass(_ bool: Bool) {
        debugPrint("setShowsCompass:\(bool)")
    }
    @objc func setShowsScale(_ bool: Bool) {
        debugPrint("setShowsScale:\(bool)")
    }
    @objc func setRotateEnabled(_ bool: Bool) {
        debugPrint("setRotateEnabled:\(bool)")
    }
    @objc func setDistanceFilter(_ value: Double) {
        debugPrint("setDistanceFilter:\(value)")
    }

    
    
    
    @objc func setInitialCameraPosition(_ json: NSDictionary) {
        if !initialized {
            initialized = true
            moveCamera(position: json)
//            customMapStyleEnabled = true
            NotificationCenter.default.addObserver(self, selector: #selector(changeMapStyle), name: NSNotification.Name(NBNotificationThemeChange), object: nil)
            changeMapStyle()
        }
    }
    
    @objc func changeMapStyle() {
        let isDark = UserDefaults.standard.bool(forKey: "NBTraitCollectionUserInterfaceStyle")
        var mapStyleName = "style.json"
        if isDark {
            mapStyleName = "style_dark.json"
        }

        if mapStyleName == self.mapStyleName {
            return
        }
        self.mapStyleName = mapStyleName
        
        if let path = Bundle.currentBundle()?.path(forResource: mapStyleName, ofType: nil) {
            self.mapStyle = try? GMSMapStyle(contentsOfFileURL: URL(fileURLWithPath: path))
        }
        
    }
    
    func moveCamera(position: NSDictionary, duration: Int = 0) {
        debugPrint("position:\(position)")
        let zoom = position["zoom"] as? Double
        let tilt = position["tilt"] as? Double
        let bearing = position["bearing"] as? Double
        let target = position["target"] as? [String : Double]
        let regin = position["regin"] as? [String : Double]
        let minLoc = position["minLoc"] as? [String : Double]
        let maxLoc = position["maxLoc"] as? [String : Double]
        if let min = minLoc, let max = maxLoc {
            if let min_lat = min["latitude"],
               let min_lon = min["longitude"],
               let max_lat = max["latitude"],
               let max_lon = max["longitude"] {
                let min_coor = CLLocationCoordinate2D(latitude: min_lat, longitude: min_lon)
                let max_coor = CLLocationCoordinate2D(latitude: max_lat, longitude: max_lon)
                let bounds = GMSCoordinateBounds(coordinate: min_coor, coordinate: max_coor)
                let camera = self.camera(for: bounds, insets: UIEdgeInsets(top: 120, left: 80, bottom: 150, right: 80))
                if let c = camera {
//                    self.camera = c
                    self.animate(to: c)

                }
            }
            
            
        } else {
            if let latitude = target?["latitude"], let longitude = target?["longitude"] {
                let coor = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                self.camera = GMSCameraPosition(target: coor, zoom: Float(zoom ?? 16))
            }
         
        }
    }
    
    func call(id: Double, name: String, args: NSDictionary) {
//        switch name {
//        case "getLatLng":
//            callback(id: id, data: convert(args.point, toCoordinateFrom: self).json)
//        default:
//            break
//        }
    }
    
    func callback(id: Double, data: [String: Any]) {
        onCallback(["id": id, "data": data])
    }
    
    override func didAddSubview(_ subview: UIView) {
        debugPrint("didAddSubview-subview:\(subview)")
        if let overlay = (subview as? Polyline) {
//            overlayMap[overlay] = subview as? Polyline
            overlay.polyLine.map = self
        }
        if let mark = (subview as? Marker) {
            mark.marker?.map = self
        }
    }
    
    
    
    
    override func removeReactSubview(_ subview: UIView!) {
        super.removeReactSubview(subview)
        if let overlay = (subview as? Polyline) {
            overlay.polyLine.map = nil
        }
        if let mark = (subview as? Marker) {
            mark.marker?.map = nil
        }
    }
    
    public func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        debugPrint("position:\(position)")
        var dict = [String : Any]()
        dict["cameraPosition"] = ["target" : ["latitude" : position.target.latitude, "longitude" : position.target.longitude]]
        onCameraIdle(dict)
    }
    
//    func mapView(_: MAMapView, render erFor overlay: MAOverlay) -> MAOverlayRenderer? {
//        if let key = overlay as? MABaseOverlay {
//            return overlayMap[key]?.getRenderer()
//        }
//        return nil
//    }
    
//    func mapView(_: MAMapView!, viewFor annotation: MAAnnotation) -> MAAnnotationView? {
//        if let key = annotation as? MAPointAnnotation {
//            return markerMap[key]?.getView()
//        }
//        return nil
//    }
    
//    func mapView(_: MAMapView!, annotationView view: MAAnnotationView!, didChange newState: MAAnnotationViewDragState, fromOldState _: MAAnnotationViewDragState) {
//        if let key = view.annotation as? MAPointAnnotation {
//            let market = markerMap[key]!
//            if newState == MAAnnotationViewDragState.starting {
//                market.onDragStart(nil)
//            }
//            if newState == MAAnnotationViewDragState.dragging {
//                market.onDrag(nil)
//            }
//            if newState == MAAnnotationViewDragState.ending {
//                market.onDragEnd(view.annotation.coordinate.json)
//            }
//        }
//    }
    
//    func mapView(_: MAMapView!, didAnnotationViewTapped view: MAAnnotationView!) {
//        if let key = view.annotation as? MAPointAnnotation {
//            markerMap[key]?.onPress(nil)
//        }
//    }
    
//    func mapInitComplete(_: MAMapView!) {
//        onLoad(nil)
//    }
    
//    func mapView(_: MAMapView!, didSingleTappedAt coordinate: CLLocationCoordinate2D) {
//        onPress(coordinate.json)
//    }
    
//    func mapView(_: MAMapView!, didTouchPois pois: [Any]!) {
//        let poi = pois[0] as! MATouchPoi
//        onPressPoi(["name": poi.name!, "id": poi.uid!, "position": poi.coordinate.json])
//    }
//
//    func mapView(_: MAMapView!, didLongPressedAt coordinate: CLLocationCoordinate2D) {
//        onLongPress(coordinate.json)
//    }
//
//    func mapViewRegionChanged(_: MAMapView!) {
//        onCameraMove(cameraEvent)
//    }
//
//    func mapView(_: MAMapView!, regionDidChangeAnimated _: Bool) {
//        onCameraIdle(cameraEvent)
//    }
//
//    func mapView(_: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation _: Bool) {
//        onLocation(userLocation.json)
//    }
}
