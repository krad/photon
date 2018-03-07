import XCTest
@testable import photon

class GetBroadcastsTests: XCTestCase {

    func test_that_we_can_get_broadcasts() {
        let session     = MockURLSession()
        XCTAssert(queue(response: "broadcasts.json", into: session))

        let client       = PhotonWebAPI(host: "krad.tv", session: session)
        let photon       = Photon("krad.tv")
        photon.webClient = client
        
        let e = self.expectation(description: "Ensure we can get broadcasts")
        photon.getBroadcasts { (broadcasts, err) in
            XCTAssertNotNil(broadcasts)
            XCTAssertNil(err)
            e.fulfill()
        }
        self.wait(for: [e], timeout: 2)
        
    }
    
}
