import NIO
import NIOOpenSSL

public enum PupilClientError: Error {
    case clientDoesNotSupportProtocols
    case couldNotConnect(host: String, port: Int)
}

final public class PupilClient {
    
    private var sslContext: SSLContext
    private var broadcastID: String
    internal var channel: Channel?
    
    public init(broadcastID: String) throws {
        self.broadcastID = broadcastID
        
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
        let group       = MultiThreadedEventLoopGroup(numThreads: 1)
        let bootstrap   = ClientBootstrap(group: group)
        .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
        .channelInitializer { channel in
            channel.pipeline.add(handler: try! OpenSSLClientHandler(context: self.sslContext)).then {
                channel.pipeline.add(handler: SessionHandler(broadcastID: self.broadcastID))
            }
        }
        defer { try? group.syncShutdownGracefully() }
        
        if let tcpPort = pupilServer.ports.filter({ $0.proto == "tcp" }).first {
           self.channel = try bootstrap.connect(host: pupilServer.host, port: Int(tcpPort.port)).wait()
        } else {
            throw PupilClientError.clientDoesNotSupportProtocols
        }        
    }
    
}

