public protocol APIRequest: Encodable {
    associatedtype Response: Decodable
    
    var method: APIRequestMethod { get }
    var resourceName: String { get }
}

public enum APIRequestMethod: String {
    case get  = "GET"
    case post = "POST"
}
