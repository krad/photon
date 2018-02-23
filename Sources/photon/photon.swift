import Foundation

public protocol PhotonProtocol {
    func startBroadcast(name title: String, onReady: @escaping BroadcastBeginCallback)
}

public class Photon: PhotonProtocol {
    
    internal var webClient: PhotonWebAPI
    
    public init(_ host: String) {
        self.webClient = PhotonWebAPI(host: host)
    }
    
    public func startBroadcast(name title: String, onReady: @escaping BroadcastBeginCallback) {
        let request = CreateBroadcast(title: title)
        self.webClient.send(request) { (result) in
            switch result {
            case .success(let broadcast):
                PupilSocket.createStream(for: broadcast, onReady: onReady)
            case .failure(let error):
                onReady(nil, error)
            }
        }
    }
        
}
