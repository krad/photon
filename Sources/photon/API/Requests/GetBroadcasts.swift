import workshop

public struct GetBroadcasts: APIRequest {
    public typealias Response = [Broadcast]
    
    public var resourceName: String { return "broadcasts" }
    public var method: APIRequestMethod { return .get }
        
    public init() { }
}

