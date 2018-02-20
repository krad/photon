public protocol APIRequest: Encodable {
    associatedtype Response: Decodable
    
    var method: APIRequestMethod { get }
    var resourceName: String { get }
}

public enum APIRequestMethod {
    case get
    case post
}
