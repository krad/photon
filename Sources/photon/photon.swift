import Foundation

public class Photon: APIClient {
    
    private var host: String
    private var proto: String = "https"
    private let session: URLSessionProtocol
    
    public init(host: String,
                proto: String? = nil,
                session: URLSessionProtocol = URLSession(configuration: .default))
    {
        self.host = host
        self.session = session
    }
    
    public func send<T>(_ request: T, completion: @escaping ResultCallback<T.Response>) where T: APIRequest {
        let req = self.urlRequest(for: request)
        let task = self.session.dataTask(with: req) { data, response, err in
            if let jsonData = data {
                do {
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            let apiResponse = try JSONDecoder().decode(T.Response.self, from: jsonData)
                            completion(.success(apiResponse))
                        } else {
                            print(String(data: jsonData, encoding: .utf8))
                            let errorResponse = try JSONDecoder().decode(APIResponseError.self,
                                                                         from: jsonData)
                            completion(.failure(errorResponse))
                        }
                    }
                } catch let err {
                    completion(.failure(err))
                }
            }
        }
        task.resume()
    }
    
    
    private func urlRequest<T: APIRequest>(for apiRequest: T) -> URLRequest {
        let url             = self.endpoint(for: apiRequest)
        var request         = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod  = apiRequest.method.rawValue
        
        if apiRequest.method == .post {
            do {
                let body = try JSONEncoder().encode(apiRequest)
                request.httpBody = body
            } catch let err {
                print("Error making request", err)
            }
        }
        
        return request
    }
    
    private func endpoint<T: APIRequest>(for request: T) -> URL {
        return URL(string: "\(proto)://\(host)/\(request.resourceName)")!
    }
    
}
