public struct PhoneSignup: APIRequest {
    public typealias Response = User
    
    public var resourceName: String {
        return "users/signup"
    }
    
    public var method: APIRequestMethod { return .post }
    
    var countryCode: CountryCode
    var phoneNumber: String
    
    public init(countryCode: CountryCode, phoneNumber: String) {
        self.countryCode = countryCode
        self.phoneNumber = phoneNumber
    }
    
}
