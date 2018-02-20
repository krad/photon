public struct GetBroadcast: APIRequest {
    public typealias Response = Broadcast
    
    public var resourceName: String {
        return ["broadcasts", self.broadcastID].joined(separator: "/")
    }
    
    var broadcastID: String
    
    init(_ broadcastID: String) {
        self.broadcastID = broadcastID
    }
}
