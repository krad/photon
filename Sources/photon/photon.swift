import Foundation

public typealias BroadcastBeginCallback = (GenericSocket) -> Void

public protocol Photon {
    func startBroadcast(name title: String, onReady: @escaping BroadcastBeginCallback)
}

public class photon: Photon {
    
    internal var webClient: PhotonWebAPI
    
    public init(host: String) {
        self.webClient = PhotonWebAPI(host: host)
    }
    
    public func startBroadcast(name title: String, onReady: @escaping BroadcastBeginCallback) {
        let request = CreateBroadcast(title: title)
        self.webClient.send(request) { (result) in
//            switch result {
//            case .success(let broadcast):
//            case .failure(let error):
//
//            }
        }
    }
        
}
