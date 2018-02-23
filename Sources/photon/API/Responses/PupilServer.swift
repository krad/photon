import Foundation

public struct PupilServer: Codable {
    var host: String
    var ports: [PupilPort]
}

public struct PupilPort: Codable {
    public var proto: String
    public var port: Int32
    
    enum CodingKeys: String, CodingKey {
        case proto = "protocol"
        case port  = "port"
    }
}
