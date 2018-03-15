import workshop

public struct ReactionRequest: APIRequest {
    
    public typealias Response = Dictionary<String, String>
    
    public var resourceName: String {
        return ["broadcasts", self.broadcastID, self.reaction.rawValue].joined(separator: "/")
    }
    
    public var method: APIRequestMethod { return .post }
    
    private var broadcastID: String
    private var reaction: Reaction
    
    public init(broadcastID: String, reaction: Reaction) {
        self.broadcastID = broadcastID
        self.reaction    = reaction
    }
    
}


