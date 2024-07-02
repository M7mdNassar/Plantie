import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Variables
    let locationManager = CLLocationManager()
    let destinationCoordinate = CLLocationCoordinate2D(latitude: 32.4595, longitude: 35.3009) // Mock location in Jenin, Palestine
    var userCoordinate: CLLocationCoordinate2D?

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        setupMapView()
    }
    
    // MARK: Setup Methods
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func setupMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        addDestinationAnnotation()
    }
    
    func addDestinationAnnotation() {
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.coordinate = destinationCoordinate
        destinationAnnotation.title = "Plant Store"
        mapView.addAnnotation(destinationAnnotation)
    }
    
    // MARK: Helper Methods
    func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        let sourcePlacemark = MKPlacemark(coordinate: pickupCoordinate)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourcePlacemark)
        directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate { response, error in
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                return
            }
            
            let route = response.routes[0]
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
            
            // Display distance and travel time
            self.displayRouteInfo(route: route, pickupCoordinate: pickupCoordinate)
        }
    }
    
    func displayRouteInfo(route: MKRoute, pickupCoordinate: CLLocationCoordinate2D) {
        let distance = route.distance / 1000 // Convert to kilometers
        let travelTime = route.expectedTravelTime / 60 // Convert to minutes
        
        let distanceString = String(format: "Distance: %.2f km", distance)
        let travelTimeString = String(format: "Estimated Travel Time: %.0f mins", travelTime)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = pickupCoordinate
        annotation.title = distanceString
        annotation.subtitle = travelTimeString
        mapView.addAnnotation(annotation)
        
        if let userCoordinate = userCoordinate {
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
}

// MARK: CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.last else { return }
        userCoordinate = userLocation.coordinate
        
        // Stop updating location to save battery
        locationManager.stopUpdatingLocation()
        
        // Show route on map
        showRouteOnMap(pickupCoordinate: userCoordinate!, destinationCoordinate: destinationCoordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error)")
    }
}

// MARK: MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blue
            polylineRenderer.lineWidth = 5.0
            return polylineRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "Annotation"
        
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
}
