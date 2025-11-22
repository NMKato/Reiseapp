//
//  NetworkManager.swift
//  Reiseapp
//
//  Created by Nikolas Kato on 09.09.25.
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(Int)
    case networkError(Error)
    case apiKeyMissing
    case rateLimitExceeded
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Ungültige URL"
        case .noData:
            return "Keine Daten empfangen"
        case .decodingError:
            return "Fehler beim Verarbeiten der Daten"
        case .serverError(let code):
            return "Server Fehler: \(code)"
        case .networkError(let error):
            return "Netzwerkfehler: \(error.localizedDescription)"
        case .apiKeyMissing:
            return "API-Schlüssel fehlt"
        case .rateLimitExceeded:
            return "API-Limit überschritten"
        case .unauthorized:
            return "Nicht autorisiert"
        }
    }
}

protocol NetworkManaging {
    func request<T: Decodable>(_ endpoint: Endpoint, type: T.Type) async throws -> T
    func requestData(_ endpoint: Endpoint) async throws -> Data
}

struct Endpoint {
    let baseURL: String
    let path: String
    let method: HTTPMethod
    let headers: [String: String]
    let queryItems: [URLQueryItem]?
    let body: Data?
    
    enum HTTPMethod: String {
        case GET, POST, PUT, DELETE, PATCH
    }
    
    init(
        baseURL: String,
        path: String,
        method: HTTPMethod = .GET,
        headers: [String: String] = [:],
        queryItems: [URLQueryItem]? = nil,
        body: Data? = nil
    ) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.headers = headers
        self.queryItems = queryItems
        self.body = body
    }
    
    var url: URL? {
        var components = URLComponents(string: baseURL + path)
        components?.queryItems = queryItems
        return components?.url
    }
}

final class NetworkManager: NetworkManaging {
    static let shared = NetworkManager()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        configuration.waitsForConnectivity = true
        
        self.session = URLSession(configuration: configuration)
        
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
    }
    
    func request<T: Decodable>(_ endpoint: Endpoint, type: T.Type) async throws -> T {
        let data = try await requestData(endpoint)
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw NetworkError.decodingError
        }
    }
    
    func requestData(_ endpoint: Endpoint) async throws -> Data {
        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        
        // Set headers
        endpoint.headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Default headers
        if request.value(forHTTPHeaderField: "Content-Type") == nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        // Debug logging
        print("🌐 NetworkManager Request:")
        print("📍 URL: \(url)")
        print("🔧 Method: \(request.httpMethod ?? "unknown")")
        if let headers = request.allHTTPHeaderFields {
            for (key, value) in headers {
                if key.lowercased().contains("authorization") {
                    print("🔒 \(key): \(value.prefix(30))...")
                } else {
                    print("📋 \(key): \(value)")
                }
            }
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.noData
            }
            
            print("📨 Response Status: \(httpResponse.statusCode)")
            print("📦 Response Size: \(data.count) bytes")
            
            switch httpResponse.statusCode {
            case 200...299:
                return data
            case 401:
                print("❌ 401 Unauthorized - Token invalid or expired")
                // Log response body for debugging
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📄 Response Body: \(responseString.prefix(200))...")
                }
                throw NetworkError.unauthorized
            case 429:
                throw NetworkError.rateLimitExceeded
            case 400...499:
                print("❌ Client Error \(httpResponse.statusCode)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📄 Response Body: \(responseString.prefix(200))...")
                }
                throw NetworkError.serverError(httpResponse.statusCode)
            case 500...599:
                throw NetworkError.serverError(httpResponse.statusCode)
            default:
                throw NetworkError.serverError(httpResponse.statusCode)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            print("❌ Network Error: \(error)")
            throw NetworkError.networkError(error)
        }
    }
}

// Cache Manager for offline support
final class CacheManager {
    static let shared = CacheManager()
    private let cache = NSCache<NSString, NSData>()
    private let fileManager = FileManager.default
    private let documentsDirectory: URL
    
    private init() {
        documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func cache(data: Data, for key: String) {
        cache.setObject(data as NSData, forKey: key as NSString)
        
        // Also save to disk for persistence
        let fileURL = documentsDirectory.appendingPathComponent("\(key).cache")
        try? data.write(to: fileURL)
    }
    
    func getCachedData(for key: String) -> Data? {
        // Try memory cache first
        if let cachedData = cache.object(forKey: key as NSString) {
            return cachedData as Data
        }
        
        // Try disk cache
        let fileURL = documentsDirectory.appendingPathComponent("\(key).cache")
        return try? Data(contentsOf: fileURL)
    }
    
    func clearCache() {
        cache.removeAllObjects()
        
        // Clear disk cache
        if let cacheFiles = try? fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil) {
            for file in cacheFiles where file.pathExtension == "cache" {
                try? fileManager.removeItem(at: file)
            }
        }
    }
}