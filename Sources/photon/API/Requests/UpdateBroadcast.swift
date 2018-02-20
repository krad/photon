public struct UpdateBroadcast: APIRequest {
    public typealias Response = Broadcast
    
    public var resourceName: String {
        return ["broadcasts", self.broadcast.broadcastID].joined(separator: "/")
    }
    
    public var method: APIRequestMethod { return .post }
    public var broadcast: Broadcast
    
    init(_ broadcast: Broadcast) {
        self.broadcast = broadcast
    }
}
