
import GoogleMaps

@objc(AMapPolylineManager)
class AMapPolylineManager: RCTViewManager {
    override class func requiresMainQueueSetup() -> Bool { false }
    override func view() -> UIView { Polyline() }
}

class Polyline: UIView {
    //  var overlay = MAMultiPolyline()
    //  var renderer: MAMultiColoredPolylineRenderer?
    var linePath = GMSMutablePath()
    var polyLine = GMSPolyline()
    var isGradient = false
    
    @objc var width = 1.0 {
        didSet {
            polyLine.strokeWidth = CGFloat(width)
            
        }
        
    }
    @objc var color = UIColor.black {
        didSet {
            polyLine.strokeColor = color
            
        }
        
    }
    @objc var gradient = false {
        didSet {
            isGradient = gradient
            
        }
        
    }
    @objc var dotted = false { didSet { setDotted() } }
    @objc var colors: [UIColor] = [] { didSet {
        //    renderer?.strokeColors = colors
        //    overlay.drawStyleIndexes = (0 ..< colors.count).map { it in NSNumber(value: it) }
        if colors.count > 0 {
            var styles = [GMSStyleSpan]()
            _ = colors.enumerated().map({ (argum) in
                let index = argum.offset
                let color = argum.element
                if index < colors.count - 1 {
                    let nextColor = colors[index + 1]
                    let gradientStyle =
                    GMSStrokeStyle.gradient(from: color, to: nextColor)
                    let styleSpan = GMSStyleSpan(style: gradientStyle)
                    styles.append(styleSpan)
                }
            })
            polyLine.spans = styles
        }
       
    } }
    
    @objc func setPoints(_ points: NSArray) {
        debugPrint("setPoints-points:\(points)")
        let coordinates = points.map { it -> CLLocationCoordinate2D in (it as! NSDictionary).coordinate }
        coordinates.forEach { model in
            linePath.add(model)
        }
        polyLine.path = linePath
        //      polyLine.map =
    }
    
    func setDotted() {
        //    renderer?.lineDashType = dotted ? kMALineDashTypeDot : kMALineDashTypeNone
    }
    
    //  func getOverlay() -> MABaseOverlay { overlay }
    //  func getRenderer() -> MAOverlayRenderer {
    //    if renderer == nil {
    //      renderer = MAMultiColoredPolylineRenderer(multiPolyline: overlay)
    //      renderer?.strokeColor = color
    //      renderer?.lineWidth = CGFloat(width)
    //      renderer?.isGradient = gradient
    //      renderer?.strokeColors = colors
    //      setDotted()
    //    }
    //    return renderer!
    //  }
}
