import Foundation

public typealias LoginCallback = (User?, Error?) -> Void

public protocol PhotonProtocol {
    func startBroadcast(name title: String, onReady: @escaping BroadcastBeginCallback)
}

public class Photon: PhotonProtocol {
    
    internal var webClient: PhotonWebAPI
    internal var currentUser: User?
    
    public init(_ host: String) {
        self.webClient = PhotonWebAPI(host: host)
    }
    
    public func login(countryCode: CountryCode,
                      phoneNumber: String,
                      password: String,
                      onComplete: @escaping LoginCallback)
    {
        let request = PhoneLogin(countryCode: countryCode, phoneNumber: phoneNumber, password: password)
        self.webClient.send(request) { (result) in
            switch result {
            case .success(let user):
                self.currentUser = user
                onComplete(user, nil)
            case .failure(let error):
                self.currentUser = nil
                onComplete(nil, error)
            }
        }
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
