import Foundation
import NIO
import NIOOpenSSL
@testable import photon

class Server {
    
    let group = MultiThreadedEventLoopGroup(numThreads: 1)
    let serverChannel: Channel
    
    init(_ port: Int, onReady: () -> ()) throws {
        let chainPath = URL(fileURLWithPath: fixturesPath).appendingPathComponent("krad-test.crt.pem").path
        let keyPath   = URL(fileURLWithPath: fixturesPath).appendingPathComponent("krad-test.key.pem").path
        
        let tlsConfig  = TLSConfiguration.forServer(certificateChain: [.file(chainPath)],
                                                    privateKey: .file(keyPath))
        let sslContext = try? SSLContext(configuration: tlsConfig)


        let sessionHandler = SessionConfigHandler()
        let lineReader     = LineDelimiterCodec()
        let reuseAddrOpt = ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR)
        let bootstrap    =
            ServerBootstrap(group: group)
                .serverChannelOption(ChannelOptions.backlog, value: 256)
                .serverChannelOption(reuseAddrOpt, value: 1)
                .childChannelInitializer { channel in
                    channel.pipeline.add(handler: try! OpenSSLServerHandler(context: sslContext!)).then {
                        channel.pipeline.add(handler: lineReader).then {
                            channel.pipeline.add(handler: sessionHandler)
                        }
                    }
                }
                .childChannelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
                .childChannelOption(reuseAddrOpt, value: 1)
                .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 1)
        
        self.serverChannel = try bootstrap.bind(host: "127.0.0.1", port: port).wait()
        
        onReady()
    }
    
    func stop() throws {
        try self.group.syncShutdownGracefully()
    }
    
}
