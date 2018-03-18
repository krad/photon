import workshop

public struct UploadSignRequest: APIRequest {
    public typealias Response = SignedUploadInfo
    
    public var resourceName: String { return "/uploads/sign" }
    public var method: APIRequestMethod { return .post }
    
    var fileName: String
    var contentType: String
    
    public init(fileName: String, contentType: String) {
        self.fileName    = fileName
        self.contentType = contentType
    }
    
}
