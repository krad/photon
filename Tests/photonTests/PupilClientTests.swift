import XCTest
@testable import photon
import NIO
import NIOOpenSSL

class MockDelegate: PupilClientDelegate {
    
    var connectExp: XCTestExpectation?
    var readyExp: XCTestExpectation?
    var disconnectExp: XCTestExpectation?
    
    func connected() { self.connectExp?.fulfill() }
    func ready() { self.readyExp?.fulfill() }
    func disconnected() { self.disconnectExp?.fulfill() }
}


class PupilCientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false
    }

    func test_that_we_can_build_a_session() {

        let s = self.expectation(description: "Wait for server to start")
        let server = try? Server(3201) { s.fulfill() }
        self.wait(for: [s], timeout: 2)
        defer { XCTAssertNoThrow(try server?.stop()) }
        
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
        
        delegate.disconnectExp = self.expectation(description: "We should disconnect from the server")
        client?.disconnect()
        self.wait(for: [delegate.disconnectExp!], timeout: 1)

    }

}
