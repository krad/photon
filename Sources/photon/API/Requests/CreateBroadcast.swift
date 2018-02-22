public struct CreateBroadcast: APIRequest {

    public typealias Response = Broadcast
    
    public var resourceName: String {
        return "broadcasts"
    }
    
    public var method: APIRequestMethod {
        return .post
    }

    var title: String
    let status: String = "INIT"
    
    init(title: String) {
        self.title = title
    }
    
}
