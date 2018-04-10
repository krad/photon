import Foundation
import NIO
import NIOOpenSSL
import grip

public typealias BroadcastBeginCallback = (Broadcast?, PupilClient?, Error?) -> Void


public enum PupilClientError: Error {
    case clientDoesNotSupportProtocols
    case couldNotConnect(host: String, port: Int)
    case noServers
    case allConnectionsFailed
}

public protocol PupilClientDelegate {
    func connected()
    func ready()
    func disconnected()
}

final public class PupilClient {
    
    private var sslContext: NIOOpenSSL.SSLContext
    private var broadcastID: String
    internal var channel: Channel?
    internal var delegate: PupilClientDelegate
    
    private let group = MultiThreadedEventLoopGroup(numThreads: 1)
    
    public class func createStream(for broadcast: Broadcast,
                                   with delegate: PupilClientDelegate,
                                   onReady: @escaping BroadcastBeginCallback)
    {
        guard let servers = broadcast.pupil else {
            onReady(broadcast, nil, PupilClientError.noServers)
            return
        }
        
        class TempDelegate: PupilClientDelegate {
            var client: PupilClient?
            var broadcast: Broadcast?
            var delegate: PupilClientDelegate?
            var onReady: BroadcastBeginCallback?
            
            func connected() { }
            func ready() {
                client?.delegate = delegate!
                onReady?(broadcast, client, nil)
            }
            func disconnected() { }
        }
        
        for server in servers {
            do {
                let tmpDelegate         = TempDelegate()
                tmpDelegate.broadcast   = broadcast
                tmpDelegate.delegate    = delegate
                tmpDelegate.onReady     = onReady
                
                let client = try PupilClient(broadcastID: broadcast.broadcastID, delegate: tmpDelegate)
                tmpDelegate.client = client
                try client.connect(to: server)
                return
                
            } catch {
                print("Problem connecting to server:", error)
            }
        }
        
        onReady(broadcast, nil, PupilClientError.allConnectionsFailed)
        return
        
    }

    public init(broadcastID: String, delegate: PupilClientDelegate) throws {
        self.broadcastID = broadcastID
        self.delegate    = delegate
        
        let configuration = TLSConfiguration.forClient(cipherSuites: defaultCipherSuites,
                                                       minimumTLSVersion: .tlsv1,
                                                       maximumTLSVersion: nil,
                                                       certificateVerification: CertificateVerification.none,
                                                       trustRoots: .default,
                                                       certificateChain: [],
                                                       privateKey: nil,
                                                       applicationProtocols: [])
        
         self.sslContext = try SSLContext(configuration: configuration)
    }
    
    
    public func connect(to pupilServer: PupilServer) throws {
        let bootstrap   = ClientBootstrap(group: group)
        .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
        .channelInitializer { channel in
            channel.pipeline.add(handler: try! OpenSSLClientHandler(context: self.sslContext)).then {
                let handler = SessionHandler(broadcastID: self.broadcastID, delegate: self.delegate)
                return channel.pipeline.add(handler: handler).then {
                    let lineCodec = LineDelimiterCodec()
                    return channel.pipeline.add(handler: lineCodec).then {
                        let configHandler = PupilConfigHandler(broadcastID: self.broadcastID)
                        return channel.pipeline.add(handler: configHandler)
                    }
                }
            }
        }
        
        if let tcpPort = pupilServer.ports.filter({ $0.proto == "tcp" }).first {
            self.channel = try bootstrap.connect(host: pupilServer.host, port: Int(tcpPort.port)).wait()
        } else {
            throw PupilClientError.clientDoesNotSupportProtocols
        }        
    }
    
    public func disconnect() {
        try? self.channel?.close().wait()
    }
    
}

extension PupilClient: Writeable {
    public func write(_ data: Data) {
        var buffer = self.channel?.allocator.buffer(capacity: data.count)
        buffer?.write(bytes: data)
        _ = self.channel?.writeAndFlush(buffer)
    }
}
