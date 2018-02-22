public enum CountryCode: String, Codable {
    case usa = "US"
    
    public var flag: String {
        switch self {
        case .usa:
            return "🇺🇸"
        }
    }
    
    public var code: String {
        switch self {
        case .usa:
            return "+1"
        }
    }
}
