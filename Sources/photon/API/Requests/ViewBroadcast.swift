import workshop

public struct ViewBroadcast: APIRequest {
    public typealias Response = Dictionary<String, String>
    
    public var resourceName: String {
        return ["broadcasts", self.broadcastID, "viewed"].joined(separator: "/")
    }
    
    public var method: APIRequestMethod { return .post }
    
    private var broadcastID: String
    
    public init(broadcastID: String) {
        self.broadcastID = broadcastID
    }
    
}

