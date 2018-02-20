import XCTest
@testable import photon

class photonTests: XCTestCase {
    
    func test_that_we_can_get_a_broadcast() {
        
        let broadcastID = "9160d225-4f8d-4891-b41f-3d68388b748d"
        let request     = GetBroadcast(broadcastID)
        let client      = Photon(host: "staging.krad.tv")

        let e = self.expectation(description: "Should be able to get a broadcast from the API")
        client.send(request) { result in
            switch result {
            case .success(let v):
                XCTAssertEqual(v.broadcastID, broadcastID)
                print(v)
            case .failure(_):
                XCTFail("We failed to get a broadcast")
            }
            e.fulfill()
        }
        
        self.wait(for: [e], timeout: 2)
        
        
    }

}
