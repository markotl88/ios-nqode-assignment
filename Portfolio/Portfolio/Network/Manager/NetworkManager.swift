//
//  NetworkManager.swift
//  Portfolio
//

import Foundation

enum NetworkingError: Error, Equatable {
    case invalidURL
    case dataError
    case decodingError
    case encodingError
    case urlError(statusCode: Int)
    case serverError(statusCode: Int)
    case authenticationError
    
    var message: String {
        switch self {
        case .invalidURL:
            "Invalid URL"
        case .dataError:
            "Data error"
        case .encodingError:
            "Encoding error"
        case .decodingError:
            "Decoding error"
        case .serverError(let statusCode):
            "Server error: \(statusCode)"
        case .urlError(let statusCode):
            "URL error: \(statusCode)"
        case .authenticationError:
            "Authentication error"
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
}

protocol NetworkManagerProtocol {
    func performRequest<T: Decodable>(url: URL, httpMethod: HTTPMethod, headers: [String: String]?, body: Encodable?, completion: @escaping (Result<T, Error>) -> Void)
    func get<T: Codable>(url: URL, headers: [String: String]?, completion: @escaping (Result<T, Error>) -> ())
}

protocol URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol
}

protocol URLSessionDataTaskProtocol {
    func resume()
    func cancel()
}

extension URLSession: URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        return (dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask) as URLSessionDataTaskProtocol
    }
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {}

struct NetworkManager: NetworkManagerProtocol {
    
    private let session: URLSessionProtocol
    
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    func get<T>(url: URL, headers: [String: String]? = nil, completion: @escaping (Result<T, Error>) -> ()) where T : Codable {
        
        var request = URLRequest(url: url)

        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        perform(request: request, completion: completion)
    }
    
    func performRequest<T>(url: URL, httpMethod: HTTPMethod, headers: [String : String]?, body: (any Encodable)?, completion: @escaping (Result<T, any Error>) -> Void) where T : Decodable {
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
                let encodedData = try encoder.encode(body)
                request.httpBody = encodedData
            } catch {
                completion(.failure(NetworkingError.encodingError))
                return
            }
        }
        
        perform(request: request, completion: completion)
    }
    
    private func perform<T: Decodable>(request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
        let task = session.dataTask(with: request) { data, response, error in

            if let error = error as? URLError {
                completion(.failure(NetworkingError.urlError(statusCode: error.code.rawValue)))
                return
            }

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkingError.dataError))
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                switch httpResponse.statusCode {
                case 401, 403:
                    completion(.failure(NetworkingError.authenticationError))
                default:
                    completion(.failure(NetworkingError.serverError(statusCode: httpResponse.statusCode)))
                }
                return
            }

            guard let data = data else {
                completion(.failure(NetworkingError.dataError))
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedData = try decoder.decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(NetworkingError.decodingError))
            }
        }
        task.resume()
    }
}
