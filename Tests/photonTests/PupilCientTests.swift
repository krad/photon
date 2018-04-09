import XCTest
@testable import photon
import NIO
import NIOOpenSSL

class PupilCientTests: XCTestCase {
    
    class MockDelegate: PupilClientDelegate {
        
        var connectExp: XCTestExpectation?
        var readyExp: XCTestExpectation?
        var disconnectExp: XCTestExpectation?
        
        func connected() {
            self.connectExp?.fulfill()
        }
        
        func ready() {
            self.readyExp?.fulfill()
        }
        
        func disconnected() {
            self.disconnectExp?.fulfill()
        }
    }
    
    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false
    }

    func test_that_we_can_build_a_session() {
        
        let chainPath = URL(fileURLWithPath: fixturesPath).appendingPathComponent("krad-test.crt.pem").path
        let keyPath   = URL(fileURLWithPath: fixturesPath).appendingPathComponent("krad-test.key.pem").path
        
        let group = MultiThreadedEventLoopGroup(numThreads: 1)
        defer { XCTAssertNoThrow(try group.syncShutdownGracefully()) }
        
        let tlsConfig  = TLSConfiguration.forServer(certificateChain: [.file(chainPath)],
                                                    privateKey: .file(keyPath))
        let sslContext = try? SSLContext(configuration: tlsConfig)
        XCTAssertNotNil(sslContext)
        
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

        let serverChannel = try? bootstrap.bind(host: "127.0.0.1", port: 3201).wait()
        XCTAssertNotNil(serverChannel)
        
        let delegate       = MockDelegate()
        let connectionInfo = PupilServer(host: "127.0.0.1",
                                         ports: [PupilPort(proto: "tcp", port: 3201)])
        
        var client: PupilClient?
        XCTAssertNoThrow(client = try PupilClient(broadcastID: "FAKE-ID", delegate: delegate))
        XCTAssertNotNil(client)
        
        delegate.connectExp = self.expectation(description: "We should connect to the server")
        delegate.readyExp   = self.expectation(description: "We should get notified when the session has been negotiated")
        
        XCTAssertNoThrow(try client?.connect(to: connectionInfo))
        
        self.wait(for: [delegate.connectExp!, delegate.readyExp!], timeout: 2)

    }

}
