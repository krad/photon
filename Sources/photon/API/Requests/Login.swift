public struct PhoneLogin: APIRequest {
    public typealias Response = User
    
    public var resourceName: String {
        return "users/login"
    }
    
    public var method: APIRequestMethod { return .post }

    var countryCode: CountryCode
    var phoneNumber: String
    var password: String
    
    public init(countryCode: CountryCode, phoneNumber: String, password: String) {
        self.countryCode = countryCode
        self.phoneNumber = phoneNumber
        self.password    = password
    }
    
}

public struct VerifyPhoneNumber: APIRequest {
    public typealias Response = User
    
    public var resourceName: String {
        return "users/login"
    }
    
    public var method: APIRequestMethod { return .post }
    
    var countryCode: CountryCode
    var phoneNumber: String
    var verificationCode: String
    
    public init(countryCode: CountryCode, phoneNumber: String, verificationCode: String) {
        self.countryCode      = countryCode
        self.phoneNumber      = phoneNumber
        self.verificationCode = verificationCode
    }
    
}
