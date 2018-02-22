public struct GetProfile: APIRequest {

    public typealias Response = User
    
    public var resourceName: String {
        return "users/me"
    }
    
    public var method: APIRequestMethod { return .get }
}
