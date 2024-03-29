import Foundation

class PlantLoader {
    static func loadPlants(fromJSONFile filename: String) -> [Plant]? {
        if let url = Bundle.main.url(forResource: filename, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let plants = try decoder.decode([Plant].self, from: data)
                return plants
            } catch {
                print("Error decoding JSON: \(error)")
                return nil
            }
        } else {
            print("JSON file not found")
            return nil
        }
    }
}
