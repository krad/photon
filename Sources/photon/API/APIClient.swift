import Result

public protocol APIClient {
    func send<T: APIRequest>(_ request: T,
                             completion: @escaping ResultCallback<T.Response>)
}
