import CoreLocation

struct CityBoundary {
    let name: String
    let minLatitude: Double
    let maxLatitude: Double
    let minLongitude: Double
    let maxLongitude: Double
    
    func contains(coordinate: CLLocationCoordinate2D) -> Bool {
        return coordinate.latitude >= minLatitude && coordinate.latitude <= maxLatitude &&
               coordinate.longitude >= minLongitude && coordinate.longitude <= maxLongitude
    }
}

let cityBoundaries: [CityBoundary] = [
    CityBoundary(name: "Jenin", minLatitude: 32.4433, maxLatitude: 32.4987, minLongitude: 35.2809, maxLongitude: 35.3426),
    // Add other cities with their boundaries
]


func determineUserCity(coordinate: CLLocationCoordinate2D) -> String? {
    for boundary in cityBoundaries {
        if boundary.contains(coordinate: coordinate) {
            return boundary.name
        }
    }
    return nil
}
