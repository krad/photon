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
        photon.startBroadcast(name: "My Fake Broadcast") { socket, err in
            XCTAssertNil(err)
            XCTAssertNotNil(socket)
            e.fulfill()
        }
        self.wait(for: [e], timeout: 1)
        
        server?.stop()
    }
    
//    func test_comeon() {
//        let photon = Photon("krad.tv")
//
//        let e = self.expectation(description: "actually hit the api")
//        photon.login(countryCode: .usa,
//                     phoneNumber: "5555551212",
//                     password: "password")
//        { (user, err) in
//            XCTAssertNotNil(user)
//            XCTAssertNil(err)
//            print(user!)
//            photon.startBroadcast(name: "kubrick for the win.", onReady: { (socket, err) in
//                print(socket)
//                print(err)
//                XCTAssertNotNil(socket)
//                XCTAssertNil(err)
//                e.fulfill()
//            })
//        }
//
//        self.wait(for: [e], timeout: 10)
//
//    }

}
