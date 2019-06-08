import Foundation

extension String {
    func toDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.dateFormat
        dateFormatter.locale = Locale(identifier: Constants.locale) // set locale to reliable US_POSIX
        return dateFormatter.date(from: self) ?? Date()
    }
}
