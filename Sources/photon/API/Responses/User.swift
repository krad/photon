import Foundation

#if os(iOS)
    import UIKit
#endif

public struct User: Codable {
    
    public var userID: String
    public var username: String?
    public var firstName: String?
    public var lastName: String?
    public var createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case userID
        case username
        case firstName
        case lastName
        case createdAt
    }
    
    #if os(iOS)
    public var image: UIImage? = nil
    #endif
    
}
