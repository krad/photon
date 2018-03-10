import workshop

public struct UpdateProfile: APIRequest {
    public typealias Response = User
    
    public var resourceName: String { return "users/me" }
    public var method: APIRequestMethod { return .post }
    
    var username: String?
    var password: String?
    var firstName: String?
    var lastName: String?
    
    public init(username: String?, password: String?, firstName: String?, lastName: String?) {
        self.username  = username
        self.password  = password
        self.firstName = firstName
        self.lastName  = lastName
    }

}
