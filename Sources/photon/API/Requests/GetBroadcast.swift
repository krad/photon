import workshop

public struct GetBroadcast: APIRequest {
    public typealias Response = Broadcast
    
    public var resourceName: String { return ["broadcasts", self.broadcastID].joined(separator: "/") }
    public var method: APIRequestMethod { return .get }
    
    var broadcastID: String
    
    public init(_ broadcastID: String) {
        self.broadcastID = broadcastID
    }
}
