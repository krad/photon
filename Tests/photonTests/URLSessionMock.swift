import Foundation
import photon


class MockURLSession: URLSessionProtocol {
    
    var responses: [Data]     = []
    var tasks: [MockDataTask] = []
    var taskCnt = 0
    
    func dataTask(with url: URL,
                  completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol
    {
        let task = MockDataTask(completionHandler, taskNumber: self.taskCnt) { self.remove(task: $0) }
        task.response = self.responses[self.taskCnt]
        self.tasks.append(task)
        self.taskCnt += 1
        return task
    }
    
    func dataTask(with request: URLRequest,
                  completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol
    {
        let task = MockDataTask(completionHandler, taskNumber: self.taskCnt) { self.remove(task: $0) }
        task.response = self.responses[self.taskCnt]
        self.tasks.append(task)
        self.taskCnt += 1
        return task
    }
    
    func remove(task: MockDataTask) {
        if let idx = self.tasks.index(of: task) {
            self.responses.remove(at: idx)
            self.tasks.remove(at: idx)
        }
    }

}

class MockDataTask: URLSessionDataTaskProtocol {
    
    var completionHandler: DataTaskResult
    var resumeCalled: (MockDataTask) -> Void
    var taskNumber: Int
    var response: Data?
    
    init(_ handler: @escaping DataTaskResult,
         taskNumber: Int,
         resumeCalled: @escaping (MockDataTask) -> Void)
    {
        self.completionHandler = handler
        self.taskNumber        = taskNumber
        self.resumeCalled      = resumeCalled
    }
    
    func resume() {
        completionHandler(self.response, nil, nil)
        self.resumeCalled(self)
    }
    
}

extension MockDataTask: Hashable {
    var hashValue: Int {
        return taskNumber
    }
}
extension MockDataTask: Equatable {
    static func ==(lhs: MockDataTask, rhs: MockDataTask) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
