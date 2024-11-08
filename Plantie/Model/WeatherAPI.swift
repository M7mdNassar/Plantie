import Foundation

class WeatherAPI {
    private static let key = "05d0f5b73d3d8032629902e2cbb33870"
//    private static let key = "490e6c9470a33b93bedb927c4543f36e"
    static func getWeatherData(lat: Double, lon: Double, completionHandler:@escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
        // Specify the URL for the GET request
        let url = URL(string: "https://api.openweathermap.org/data/2.5/onecall?lat=\(lat)&lon=\(lon)&units=imperial&exclude=minutely&appid=\(self.key)")
        // Create a URLSession to handle the request
        let session = URLSession.shared
        // Create a data task with the URL and the completion handler
        let task = session.dataTask(with: url!) { data, response, error in
            if let error = error {
                print("Error fetching data:", error)
                completionHandler(nil, response, error)
                return
            }
            // Print the raw response
            if let data = data {
                print("Raw response:", String(data: data, encoding: .utf8) ?? "No data")
            }
            // Call the completion handler after printing the response
            completionHandler(data, response, error)
        }
        // Execute the task
        task.resume()
    }
    
    static func gettingWeatherIcon(iconKey: String, completionHandler:@escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
        let url = URL(string: "https://openweathermap.org/img/wn/\(iconKey)@2x.png")
        let session = URLSession.shared
        let task = session.dataTask(with: url!) { data, response, error in
            if let error = error {
                print("Error fetching icon:", error)
                completionHandler(nil, response, error)
                return
            }
            // Print the raw icon data (optional)
            if let data = data {
                print("Raw icon response:", String(data: data, encoding: .utf8) ?? "Binary data")
            }
            completionHandler(data, response, error)
        }
        task.resume()
    }
}
