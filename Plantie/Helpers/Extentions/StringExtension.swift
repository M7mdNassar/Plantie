
import Foundation

extension String {
    
    // MARK: Convert String -> Date
    
    func toDate(withFormat format: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZ") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
    
    // MARK: Shorthand Localization
    
    var localized : String {
        return NSLocalizedString(self, comment: "")
    }
    
}
