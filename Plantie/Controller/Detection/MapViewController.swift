import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Variables
    let locationManager = CLLocationManager()
    
    var stores: [PlantStore] = []
    
    var userCoordinate: CLLocationCoordinate2D?
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        getStores()
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
    }
    
    func getStores() {
        if let stores = PlantStoresLoader.loadStores(fromJSONFile: "StoresData") {
            self.stores = stores
        } else {
            print("Failed to load plant stores")
        }
    }
    
    // MARK: Helper Methods
    func showRoutesToClosestShops() {
        guard let userCoordinate = userCoordinate else { return }
        
        let storeCoordinates = stores.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        
        let sortedDestinations = storeCoordinates.sorted {
            userCoordinate.distance(to: $0) < userCoordinate.distance(to: $1)
        }
        
        let closestDestinations = sortedDestinations.prefix(2)
        
        for destinationCoordinate in closestDestinations {
            addDestinationAnnotation(destinationCoordinate: destinationCoordinate)
            showRouteOnMap(pickupCoordinate: userCoordinate, destinationCoordinate: destinationCoordinate)
        }
    }
    
    func addDestinationAnnotation(destinationCoordinate: CLLocationCoordinate2D) {
        guard let store = store(at: destinationCoordinate) else { return }
        
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.coordinate = destinationCoordinate
        destinationAnnotation.title = store.name
        destinationAnnotation.subtitle = "\(store.contact ?? "")\n\(store.openingHours ?? "")"
        mapView.addAnnotation(destinationAnnotation)
    }
    
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
        
        if userCoordinate != nil {
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    func store(at coordinate: CLLocationCoordinate2D) -> PlantStore? {
        return stores.first { $0.latitude == coordinate.latitude && $0.longitude == coordinate.longitude }
    }
}

// MARK: CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.last else { return }
        userCoordinate = userLocation.coordinate
        
        // Stop updating location to save battery
        locationManager.stopUpdatingLocation()
        
        // Show routes to the closest shops
        showRoutesToClosestShops()
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
            let button = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = button
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
}

extension CLLocationCoordinate2D {
    func distance(to coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        let location1 = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let location2 = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return location1.distance(from: location2)
    }
}
