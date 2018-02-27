public struct UpdateBroadcast: APIRequest {
    public typealias Response = Broadcast
    
    public var resourceName: String {
        return ["broadcasts", self.bid].joined(separator: "/")
    }
    
    public var method: APIRequestMethod { return .post }
    
    private var bid: String
    public var title: String?
    public var status: String?
    public var thumbnails: [String]?
    
    public init(broadcastID: String,
                title: String? = nil,
                status: String? = nil,
                thumbnails: [String]? = nil)
    {
        self.bid        = broadcastID
        self.title      = title
        self.status     = status
        self.thumbnails = thumbnails
    }
    
}
