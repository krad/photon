import XCTest
@testable import photon
import Socket

class PupilClientTests: XCTestCase {

    func test_that_we_can_setup_a_streaming_socket_to_a_pupil_server() {
        
        let e      = self.expectation(description: "Wait for the server to start")
        let server = try? Server(3000) { e.fulfill() }
        self.wait(for: [e], timeout: 2)
        XCTAssertNotNil(server)
        
        let p       = PupilPort(proto: "tcp", port: 3000)
        let ps      = PupilServer(host: "0.0.0.0", ports: [p])

        let e4 = self.expectation(description: "Wait for the begin")
        let socket  = try? PupilSocket(identifier: "fake-broadcast-id", server: ps) { _ in
            e4.fulfill()
        }
        self.wait(for: [e4], timeout: 2)
        XCTAssertNotNil(socket)
        
        server?.stop()
    }
    
    func test_that_we_can_create_a_client_from_api_results() {
        
        let port      = PupilPort(proto: "tcp", port: 3001)
        let ps        = PupilServer(host: "0.0.0.0", ports: [port])
        let broadcast = Broadcast(userID: "123-123",
                                  title: "My Stream",
                                  broadcastID: "321-321",
                                  status: "INIT",
                                  thumbnails: nil,
                                  user: nil,
                                  pupil: [ps])
        
        let e = self.expectation(description: "Server start up")
        let server = try? Server(3001) { e.fulfill() }
        self.wait(for: [e], timeout: 2)
        
        let e2 = self.expectation(description: "Connecting using broadcast info")
        PupilSocket.createStream(for: broadcast) { broadcast, socket, err in
            XCTAssertNil(err)
            XCTAssertNotNil(socket)
            e2.fulfill()
        }
        self.wait(for: [e2], timeout: 2)
        
        server?.stop()
    }
    
    func test_that_we_can_try_to_connect_to_multiple_servers() {
        
        let servers = [("0.0.0.0", 3000), ("0.0.0.0", 3001), ("0.0.0.0", 3002), ("0.0.0.0", 3003)].map {
            return PupilServer(host: $0.0, ports: [PupilPort(proto: "tcp", port: $0.1)])
        }
        
        let broadcast = Broadcast(userID: "123-123",
                                  title: "Fake Stream",
                                  broadcastID: "33333",
                                  status: "INIT",
                                  thumbnails: nil,
                                  user: nil,
                                  pupil: servers)
        
        let e = self.expectation(description: "Server start up")
        let server = try? Server(3002) { e.fulfill() }
        self.wait(for: [e], timeout: 2)
        
        let e2 = self.expectation(description: "Attempt to connect to multiple servers")
        PupilSocket.createStream(for: broadcast) { broadcast, ps, err in
            XCTAssertNil(err)
            XCTAssertNotNil(ps)
            XCTAssertNotNil(ps?.hostName)
            XCTAssertEqual(ps?.port, 3002)
            e2.fulfill()
        }
        self.wait(for: [e2], timeout: 9)
        
        server?.stop()
    }
    
}

class Server {
    
    private let socket: Socket
    private let q = DispatchQueue(label: "test.server.q")
    private var running = true
    
    init(_ port: Int, onStart: () -> ()) throws {
        self.socket = try Socket.create()
        try self.socket.listen(on: port)
        self.start()
        onStart()
    }
    
    private func start() {
        self.q.async {
            repeat {
                do {
                    let s = try self.socket.acceptClientConnection()
                    try s.write(from: "HI\n")
                    self.read(s: s)
                } catch { self.running = false }
            } while self.running
        }
    }
    
    private func read(s: Socket) {
        var readBuf = Data(capacity: 1024)
        repeat {
            do {
                let read = try s.read(into: &readBuf)
                if read > 0 { try s.write(from: "BEGIN\n") }
                else { if s.remoteConnectionClosed { self.running = false } }
                readBuf.count = 0
            } catch {
                self.running = false
            }
        } while self.running
    }
    
    func stop() {
        self.socket.close()
    }
    
}
