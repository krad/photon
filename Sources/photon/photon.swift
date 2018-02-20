import Foundation

class Photon: APIClient {
    
    private var host: String
    private var proto: String = "https"
    private let session: URLSessionProtocol
    
    init(host: String,
         proto: String? = nil,
         session: URLSessionProtocol = URLSession(configuration: .default))
    {
        self.host = host
        self.session = session
    }
    
    func send<T>(_ request: T, completion: @escaping ResultCallback<T.Response>) where T: APIRequest {
        let url = self.endpoint(for: request)
        let task = self.session.dataTask(with: URLRequest(url: url)) { data, response, err in
            if let jsonData = data {
                do {
                    let apiResponse = try JSONDecoder().decode(T.Response.self, from: jsonData)
                    completion(.success(apiResponse))
                } catch let err {
                    completion(.failure(err))
                }
            }
        }
        task.resume()
    }
    
    private func endpoint<T: APIRequest>(for request: T) -> URL {
        return URL(string: "\(proto)://\(host)/\(request.resourceName)")!
    }
    
}
