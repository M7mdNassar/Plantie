import Foundation

class PlantStoresLoader {
    static func loadStores(fromJSONFile filename: String) -> [PlantStore]? {
        if let url = Bundle.main.url(forResource: filename, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let stores = try decoder.decode([PlantStore].self, from: data)
                return stores
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
