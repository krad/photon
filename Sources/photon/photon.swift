import Foundation

public typealias UserCallback       = (User?, Error?) -> Void
public typealias BroadcastCallback  = (Broadcast?, Error?) -> Void
public typealias BroadcastsCallback = ([Broadcast]?, Error?) -> Void

public protocol PhotonProtocol {
    func signup(countryCode: CountryCode, phoneNumber: String, onComplete: @escaping UserCallback)
    func verify(countryCode: CountryCode, phoneNumber: String, code: String, onComplete: @escaping UserCallback)
    func login(countryCode: CountryCode, phoneNumber: String, password: String, onComplete: @escaping UserCallback)
    func getBroadcasts(onComplete: @escaping BroadcastsCallback)
    func startBroadcast(name title: String, onReady: @escaping BroadcastBeginCallback)
    func update(broadcast: Broadcast, onComplete: @escaping BroadcastCallback)
    func getMyProfile(onComplete: @escaping UserCallback)
}

public class Photon: PhotonProtocol {
    
    internal var webClient: PhotonWebAPI
    public private(set) var currentUser: User?
    public private(set) var currentBroadcast: Broadcast?
    
    public init(_ host: String) {
        self.webClient = PhotonWebAPI(host: host)
    }
    
    public func signup(countryCode: CountryCode,
                       phoneNumber: String,
                       onComplete: @escaping UserCallback)
    {
        let request = PhoneSignup(countryCode: countryCode, phoneNumber: phoneNumber)
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
    
    public func verify(countryCode: CountryCode, phoneNumber: String, code: String, onComplete: @escaping UserCallback) {
        let request = VerifyPhoneNumber(countryCode: countryCode, phoneNumber: phoneNumber, verificationCode: code)
        self.webClient.send(request) { result in
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
    
    public func login(countryCode: CountryCode,
                      phoneNumber: String,
                      password: String,
                      onComplete: @escaping UserCallback)
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
    
    public func getBroadcasts(onComplete: @escaping BroadcastsCallback) {
        let request = GetBroadcasts()
        self.webClient.send(request) { result in
            switch result {
            case .success(let broadcasts): onComplete(broadcasts, nil)
            case .failure(let error): onComplete(nil, error)
            }
        }
    }
    
    public func startBroadcast(name title: String, onReady: @escaping BroadcastBeginCallback) {
        let request = CreateBroadcast(title: title)
        self.webClient.send(request) { (result) in
            switch result {
            case .success(let broadcast):
                PupilSocket.createStream(for: broadcast) { b, ps, err in
                    if let _ = ps { self.currentBroadcast = broadcast }
                    else { self.currentBroadcast = nil }
                    onReady(b, ps, err)
                }
            case .failure(let error):
                onReady(nil, nil, error)
            }
        }
    }
    
    public func update(broadcast: Broadcast, onComplete: @escaping BroadcastCallback) {
        let request = UpdateBroadcast(broadcastID: broadcast.broadcastID,
                                      title: broadcast.broadcastID,
                                      status: broadcast.status,
                                      thumbnails: broadcast.thumbnails)
        self.webClient.send(request) { (result) in
            switch result {
            case .success(let broadcast): onComplete(broadcast, nil)
            case .failure(let error): onComplete(nil, error)
            }
        }
    }
    
    public func getMyProfile(onComplete: @escaping UserCallback) {
        let request = GetProfile()
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

}
