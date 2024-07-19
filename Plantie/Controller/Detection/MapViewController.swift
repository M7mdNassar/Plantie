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
    var userCity: String?
    
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
            addStoreAnnotations()
        } else {
            print("Failed to load plant stores")
        }
    }
    
    // MARK: Helper Methods
    func addStoreAnnotations() {
        for store in stores {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: store.latitude, longitude: store.longitude)
            annotation.title = store.name
            annotation.subtitle = "\(store.contact ?? "")\n\(store.openingHours ?? "")"
            mapView.addAnnotation(annotation)
        }
    }
    
    func findClosestStore() -> CLLocationCoordinate2D? {
        guard let userCoordinate = userCoordinate else { return nil }
        
        if let userCity = determineUserCity(coordinate: userCoordinate) {
            let storesInUserCity = stores.filter { store in
                let storeCoordinate = CLLocationCoordinate2D(latitude: store.latitude, longitude: store.longitude)
                return determineUserCity(coordinate: storeCoordinate) == userCity
            }
            
            let closestStore = storesInUserCity.min { (store1, store2) -> Bool in
                let location1 = CLLocation(latitude: store1.latitude, longitude: store1.longitude)
                let location2 = CLLocation(latitude: store2.latitude, longitude: store2.longitude)
                let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
                return userLocation.distance(from: location1) < userLocation.distance(from: location2)
            }
            
            return closestStore.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        }
        
        return nil
    }
    
    func showRouteToClosestStore() {
        guard let userCoordinate = userCoordinate else { return }
        guard let closestStoreCoordinate = findClosestStore() else { return }
        
        let sourcePlacemark = MKPlacemark(coordinate: userCoordinate)
        let destinationPlacemark = MKPlacemark(coordinate: closestStoreCoordinate)
        
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
        
        // Center map on user location
        let region = MKCoordinateRegion(center: userCoordinate!, latitudinalMeters: 5000, longitudinalMeters: 5000)
        mapView.setRegion(region, animated: true)
        
        // Add user location annotation
        let userAnnotation = MKPointAnnotation()
        userAnnotation.coordinate = userCoordinate!
        userAnnotation.title = "Your Location"
        mapView.addAnnotation(userAnnotation)
        
        // Determine user city and show route to the closest store
        userCity = determineUserCity(coordinate: userCoordinate!)
        showRouteToClosestStore()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error)")
    }
}

// MARK: MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "Annotation"
        
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            let button = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = button
        } else {
            annotationView?.annotation = annotation
        }
        
        // Customize the user location annotation
        if let title = annotation.title, title == "Your Location" {
            annotationView?.markerTintColor = UIColor.red // Custom color for user location
            annotationView?.glyphText = "🏠" // Custom glyph for user location
        } else {
            annotationView?.markerTintColor = UIColor.green // Custom color for store locations
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blue
            polylineRenderer.lineWidth = 5.0
            return polylineRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}

extension CLLocationCoordinate2D {
    func distance(to coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        let location1 = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let location2 = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return location1.distance(from: location2)
    }
}
