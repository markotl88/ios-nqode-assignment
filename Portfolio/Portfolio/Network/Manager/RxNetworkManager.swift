//
//  RxNetworkManager.swift
//  Portfolio
//

import Foundation
import RxSwift

protocol RxNetworkManagerProtocol {
    func get<T: Decodable>(url: URL, headers: [String: String]?) -> Single<T>
    func performRequest<T: Decodable>(url: URL, httpMethod: HTTPMethod, headers: [String: String]?, body: Encodable?) -> Single<T>
}

struct RxNetworkManager: RxNetworkManagerProtocol {
    
    private let session: URLSessionProtocol
    
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    func get<T: Decodable>(url: URL, headers: [String: String]? = nil) -> Single<T> {
        var request = URLRequest(url: url)

        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }

        return perform(request: request)
    }
    
    func performRequest<T: Decodable>(url: URL, httpMethod: HTTPMethod, headers: [String: String]?, body: Encodable?) -> Single<T> {
        var request = URLRequest(url: url)
        request.timeoutInterval = 60
        request.httpMethod = httpMethod.rawValue
        
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }

        if let body = body {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            do {
                let encoded = try encoder.encode(body)
                request.httpBody = encoded
            } catch {
                return .error(NetworkingError.encodingError)
            }
        }
        
        return perform(request: request)
    }
    
    private func perform<T: Decodable>(request: URLRequest) -> Single<T> {
        return Single<T>.create { single in
            let task = self.session.dataTask(with: request) { data, response, error in
                
                if let error = error as? URLError {
                    single(.failure(NetworkingError.urlError(statusCode: error.code.rawValue)))
                    return
                }
                
                if let error = error {
                    single(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    single(.failure(NetworkingError.dataError))
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
                        single(.failure(NetworkingError.authenticationError))
                    } else {
                        single(.failure(NetworkingError.serverError(statusCode: httpResponse.statusCode)))
                    }
                    return
                }
                
                guard let data = data else {
                    single(.failure(NetworkingError.dataError))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let decoded = try decoder.decode(T.self, from: data)
                    single(.success(decoded))
                } catch {
                    single(.failure(NetworkingError.decodingError))
                }
            }
            task.resume()
            return Disposables.create { task.cancel() }
        }
    }
}
