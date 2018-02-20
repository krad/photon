import Foundation

class Photon: APIClient {
    
    private let host: String
    private let proto: String = "https"
    private let session = URLSession(configuration: .default)
    
    init(host: String) {
        self.host = host
    }
    
    func send<T>(_ request: T, completion: @escaping ResultCallback<T.Response>) where T: APIRequest {
        let url = self.endpoint(for: request)
        print(url)
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
