import XCTest
@testable import photon

class photonTests: XCTestCase {

    func test_that_we_can_start_a_new_broadcast_stream() {
        
        let s = self.expectation(description: "Server startup")
        let server = try? Server(42000) {
            s.fulfill()
        }
        self.wait(for: [s], timeout: 1)
        
        let session    = MockURLSession()
        let fakeClient = PhotonWebAPI(host: "krad.tv", session: session)
        
        let photon     = Photon("krad.tv")
        photon.webClient = fakeClient
        
        XCTAssertTrue(queue(response: "create_broadcast.json", into: session))
        
        let e = self.expectation(description: "Should return a socket connected to the streaming server")
        photon.startBroadcast(name: "My Fake Broadcast") { broadcast, socket, err in
            XCTAssertNil(err)
            XCTAssertNotNil(socket)
            e.fulfill()
        }
        self.wait(for: [e], timeout: 1)
        
        server?.stop()
    }

    func test_that_we_can_get_our_profile() {

        let session         = MockURLSession()
        let client          = PhotonWebAPI(host: "krad.tv", session: session)
        let photon          = Photon("krad.tv")
        photon.webClient    = client
        
        XCTAssertTrue(queue(response: "user.json", into: session))
        XCTAssertNil(photon.currentUser)
        
        let e = self.expectation(description: "Should return a profile when we're logged in")
        photon.getMyProfile { (user, err) in
            XCTAssertNotNil(user)
            XCTAssertNil(err)
            e.fulfill()
        }
        self.wait(for: [e], timeout: 2)
        
        XCTAssertNotNil(photon.currentUser)
        
    }
    
    func test_that_we_can_view_a_broadcast() {
        let session         = MockURLSession()
        let client          = PhotonWebAPI(host: "krad.tv", session: session)
        let photon          = Photon("krad.tv")
        photon.webClient    = client

        XCTAssertTrue(queue(response: "empty_response.json", into: session))
        
        let e = self.expectation(description: "Should submit a 'view' to the broadcast")
        photon.view(broadcastID: "05299e65-2f4c-4c42-8c1a-b1b953b6445b") { msg, err in
            XCTAssertNotNil(msg)
            XCTAssertNil(err)
            e.fulfill()
        }
        
        self.wait(for: [e], timeout: 2)
    }
    
    func test_that_we_can_react_to_a_broadcast() {
        let session         = MockURLSession()
        let client          = PhotonWebAPI(host: "krad.tv", session: session)
        let photon          = Photon("krad.tv")
        photon.webClient    = client
        
        XCTAssertTrue(queue(response: "empty_response.json", into: session))
        XCTAssertTrue(queue(response: "empty_response.json", into: session))
        XCTAssertTrue(queue(response: "empty_response.json", into: session))
        
        let e = self.expectation(description: "Should like a broadcast")
        photon.react(with: .like, for: "05299e65-2f4c-4c42-8c1a-b1b953b6445b") { (msg, err) in
            XCTAssertNotNil(msg)
            XCTAssertNil(err)
            e.fulfill()
        }
        self.wait(for: [e], timeout: 2)
        
        let e2 = self.expectation(description: "Should dislike a broadcast")
        photon.react(with: .dislike, for: "05299e65-2f4c-4c42-8c1a-b1b953b6445b") { (msg, err) in
            XCTAssertNotNil(msg)
            XCTAssertNil(err)
            e2.fulfill()
        }
        self.wait(for: [e2], timeout: 2)

        let e3 = self.expectation(description: "Should flag a broadcast")
        photon.react(with: .report, for: "05299e65-2f4c-4c42-8c1a-b1b953b6445b") { (msg, err) in
            XCTAssertNotNil(msg)
            XCTAssertNil(err)
            e3.fulfill()
        }
        self.wait(for: [e3], timeout: 2)

    }

}
