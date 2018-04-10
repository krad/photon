import Foundation
#if os(iOS)
    import UIKit
#endif

public typealias UserCallback       = (User?, Error?) -> Void
public typealias BroadcastCallback  = (Broadcast?, Error?) -> Void
public typealias BroadcastsCallback = ([Broadcast]?, Error?) -> Void
public typealias MessageCallback    = (Dictionary<String, String>?, Error?) -> Void
public typealias SigningCallback    = (SignedUploadInfo?, Error?) -> Void

public enum Reaction: String, Codable {
    case like       = "like"
    case dislike    = "dislike"
    case report     = "flagged"
}

public protocol PhotonProtocol {
    func signup(countryCode: CountryCode, phoneNumber: String, onComplete: @escaping UserCallback)
    func verify(countryCode: CountryCode, phoneNumber: String, code: String, onComplete: @escaping UserCallback)
    func login(countryCode: CountryCode, phoneNumber: String, password: String, onComplete: @escaping UserCallback)
    func update(username: String?, password: String?, firstName: String?, lastName: String?, onComplete: @escaping UserCallback)
    func getBroadcasts(onComplete: @escaping BroadcastsCallback)
    func getBroadcast(with broadcastID: String, onComplete: @escaping BroadcastCallback)
    func startBroadcast(name title: String, delegate: PupilClientDelegate, onReady: @escaping BroadcastBeginCallback)
    func update(broadcast: Broadcast, onComplete: @escaping BroadcastCallback)
    func getMyProfile(onComplete: @escaping UserCallback)
    func view(broadcastID: String, onComplete: @escaping MessageCallback)
    func react(with opinion: Reaction, for broadcastID: String, onComplete: @escaping MessageCallback)
    func requestUploadSigning(fileName: String, contentType: String, onComplete: @escaping SigningCallback)
}

public class Photon: PhotonProtocol {
    
    internal var webClient: PhotonWebAPI
    public private(set) var currentUser: User?
    public private(set) var currentBroadcast: Broadcast?
    
    public init(_ host: String) {
        self.webClient = PhotonWebAPI(host: host)
    }
    
    
    /// Signs up for an account using a phone number
    ///
    /// - Parameters:
    ///   - countryCode: Country Code of the phone number
    ///   - phoneNumber: Phone number that can receive SMS messages
    ///   - onComplete: Callback on success / failure
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
    
    /// Verify phone number using an authentication token
    ///
    /// - Parameters:
    ///   - countryCode: Country Code of the phone number associated with the account
    ///   - phoneNumber: Phone number that can receive SMS messages
    ///   - code: Code recieved via an SMS used to verify account identity
    ///   - onComplete: Callback on success / failure
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
    
    
    /// Login with a phone number
    ///
    /// - Parameters:
    ///   - countryCode: Country code of the phone number associated with the account
    ///   - phoneNumber: Phone number tied to the account
    ///   - password: Password for the account
    ///   - onComplete: Callback on success / failure
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
    
    
    /// Update's a user profile (requires prior authentication)
    /// Leave a value blank if you do not wish to update that particular attribute
    ///
    /// - Parameters:
    ///   - username: Username you wish to have associated with your account
    ///   - password: Password to be set on the account
    ///   - firstName: First Name you wish to have associated with your account
    ///   - lastName: Last Name you wish to have associated with your account
    ///   - onComplete: Callback on success / failure
    public func update(username: String?, password: String?, firstName: String?, lastName: String?, onComplete: @escaping UserCallback) {
        let request = UpdateProfile(username: username, password: password, firstName: firstName, lastName: lastName)
        self.webClient.send(request) { result in
            switch result {
            case .success(let user):
                self.currentUser = user
                onComplete(user, nil)
            case .failure(let error): onComplete(nil, error)
            }
        }
    }

    
    /// Gets the most recent broadcasts available for viewing on the server
    ///
    /// - Parameter onComplete: Callback on success / failure
    public func getBroadcasts(onComplete: @escaping BroadcastsCallback) {
        let request = GetBroadcasts()
        self.webClient.send(request) { result in
            switch result {
            case .success(let broadcasts): onComplete(broadcasts, nil)
            case .failure(let error): onComplete(nil, error)
            }
        }
    }
    
    
    /// Fetches details for a particular broadcast
    ///
    /// - Parameters:
    ///   - broadcastID: The ID of the broadcast you are interested in
    ///   - onComplete: Callback on success / failure
    public func getBroadcast(with broadcastID: String, onComplete: @escaping BroadcastCallback) {
        let request = GetBroadcast(broadcastID)
        self.webClient.send(request) { (result) in
            switch result {
            case .success(let broadcast): onComplete(broadcast, nil)
            case .failure(let error): onComplete(nil, error)
            }
        }
    }
    
    
    /// Notifies the API you would like to begin streaming.
    /// Returns a socket you can immediately start streaming audio / video samples to
    ///
    /// - Parameters:
    ///   - title: The title of the broadcast
    ///   - onReady: Callback on success / failure.  On success returns a broadcast struct and a socket that you can write to
    public func startBroadcast(name title: String,
                               delegate: PupilClientDelegate,
                               onReady: @escaping BroadcastBeginCallback) {
        let request = CreateBroadcast(title: title)
        self.webClient.send(request) { (result) in
            switch result {
            case .success(let broadcast):
                PupilClient.createStream(for: broadcast, with: delegate) { b, pc, err in
                    if let _ = pc { self.currentBroadcast = broadcast }
                    else { self.currentBroadcast = nil }
                    onReady(b, pc, err)
                }
            case .failure(let error):
                onReady(nil, nil, error)
            }
        }
    }
    
    
    /// Update broadcast details
    ///
    /// - Parameters:
    ///   - broadcast: Broadcast struct with modified attribetus
    ///   - onComplete: Callback on success / failure
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
    
    
    /// Gets your account profile details (requires authentication)
    ///
    /// - Parameter onComplete: Callback on success / failure
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
    
    
    /// Signal to the API that you have watched a broadcast.  Essentially an optional hit counter
    ///
    /// - Parameters:
    ///   - broadcastID: ID of the broadcast you are watching
    ///   - onComplete: Callback on success / failure
    public func view(broadcastID: String, onComplete: @escaping MessageCallback) {
        let request = ViewBroadcast(broadcastID: broadcastID)
        self.webClient.send(request) { result in
            switch result {
            case .success(let msg): onComplete(msg, nil)
            case .failure(let error): onComplete(nil, error)
            }
        }
    }
    
    
    /// React to a broadcast.  Used to express an opinion or notify the admin about the content of a broadcast
    ///
    /// - Parameters:
    ///   - opinion: The opinion you wish to express
    ///   - broadcastID: The ID about the broadcast you wish to react to
    ///   - onComplete: Callback on success / failure
    public func react(with opinion: Reaction, for broadcastID: String, onComplete: @escaping MessageCallback) {
        let request = ReactionRequest(broadcastID: broadcastID, reaction: opinion)
        self.webClient.send(request) { result in
            switch result {
            case .success(let msg): onComplete(msg, nil)
            case .failure(let error): onComplete(nil, error)
            }
        }
    }
    
    
    /// Ask for a URL for an arbitrary file upload
    ///
    /// - Parameters:
    ///   - fileName: The name of the file you wish to upload
    ///   - contentType: The content-type of the file you wish to uploa
    ///   - onComplete: Callback on success / failure.  Returns a URL you can begin a multipart upload with
    public func requestUploadSigning(fileName: String,
                                     contentType: String,
                                     onComplete: @escaping SigningCallback)
    {
        let request = UploadSignRequest(fileName: fileName, contentType: contentType)
        self.webClient.send(request) { (result) in
            switch result {
            case .success(let resp): onComplete(resp, nil)
            case .failure(let err): onComplete(nil, err)
            }
        }
    }
    
    #if os(iOS)
    public func setCurrentUserImage(image: UIImage) {
        self.currentUser?.image = image
    }
    #endif
}
