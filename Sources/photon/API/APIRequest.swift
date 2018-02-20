public protocol APIRequest: Encodable {
    associatedtype Response: Decodable
    
    var resourceName: String { get }
}
