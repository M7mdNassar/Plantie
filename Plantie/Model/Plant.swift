import Foundation

struct Plant: Codable {
    let name: String
    let id: Int
    let category: String
    let npk : String
    let description: String
    let plantingTime: String
    let fertilizer: String
    let storageInfo: StorageInfo
    let nutritionRecommendations: NutritionRecommendations
    let marketingTips: [String]
    let diseaseAndPestControl: DiseaseAndPestControl
    let imageName: String
}

struct StorageInfo: Codable {
    let temperature: String
    let humidity: String
}

struct NutritionRecommendations: Codable {
    let nitrogen: String
    let phosphorus: String?
    let potassium: String?
}

struct DiseaseAndPestControl: Codable {
    let commonDiseases: [CommonDisease]
}

struct CommonDisease: Codable {
    let name: String
    let description: String
    let prevention: String
}
