//
//  HotelRepository.swift
//  Reiseapp
//
//  Created by Nikolas Kato on 11.09.25.
//

import Foundation

// MARK: - Hotel Repository Protocol

protocol HotelRepositoryProtocol {
    func searchHotels(parameters: HotelSearchParameters) async throws -> [Hotel]
    func getPopularHotels(for destination: String, parameters: HotelSearchParameters) async throws -> [Hotel]
    func getCachedHotels(for cacheKey: String) -> [Hotel]?
    func cacheHotels(_ hotels: [Hotel], for cacheKey: String)
    func getFavoriteHotels() async throws -> [Hotel]
    func addToFavorites(_ hotel: Hotel) async throws
    func removeFromFavorites(hotelId: String) async throws
}

// MARK: - Hotel Repository Implementation

class HotelRepository: HotelRepositoryProtocol {
    
    // MARK: - Dependencies
    
    private let hotelService: HotelSearchService
    private let cacheManager: HotelCacheManager
    
    // MARK: - Constants
    
    private struct CacheKeys {
        static let popularHotels = "popularHotels"
        static let searchResults = "searchResults"
        static let favorites = "favoriteHotels"
    }
    
    private struct CacheExpiration {
        static let popularHotels: TimeInterval = 3600 // 1 hour
        static let searchResults: TimeInterval = 1800 // 30 minutes
    }
    
    // MARK: - Initialization
    
    init(
        hotelService: HotelSearchService = HotelSearchService(),
        cacheManager: HotelCacheManager = HotelCacheManager.shared
    ) {
        self.hotelService = hotelService
        self.cacheManager = cacheManager
    }
    
    // MARK: - Hotel Search
    
    func searchHotels(parameters: HotelSearchParameters) async throws -> [Hotel] {
        // Generate cache key based on search parameters
        let cacheKey = generateSearchCacheKey(parameters: parameters)
        
        // Check cache first
        if let cachedResults = getCachedHotels(for: cacheKey) {
            return cachedResults
        }
        
        // Fetch from API
        let hotels = try await hotelService.searchHotels(parameters: parameters)
        
        // Cache results
        cacheHotels(hotels, for: cacheKey)
        
        return hotels
    }
    
    func getPopularHotels(for destination: String, parameters: HotelSearchParameters) async throws -> [Hotel] {
        let cacheKey = "\(CacheKeys.popularHotels)_\(destination)"
        
        // Check cache first
        if let cachedHotels = getCachedHotels(for: cacheKey) {
            return cachedHotels
        }
        
        // Create parameters for popular hotels
        let popularParameters = HotelSearchParameters(
            destination: destination,
            checkInDate: parameters.checkInDate,
            checkOutDate: parameters.checkOutDate,
            numberOfAdults: parameters.numberOfAdults,
            numberOfChildren: parameters.numberOfChildren,
            numberOfRooms: parameters.numberOfRooms,
            maxPrice: parameters.maxPrice,
            minRating: parameters.minRating,
            accommodationType: parameters.accommodationType,
            hasWiFi: parameters.hasWiFi,
            hasKitchen: parameters.hasKitchen,
            hasParking: parameters.hasParking,
            hasWashingMachine: parameters.hasWashingMachine,
            isPetFriendly: parameters.isPetFriendly,
            hasAirConditioning: parameters.hasAirConditioning,
            hasPool: parameters.hasPool,
            hasGym: parameters.hasGym,
            hasCrib: parameters.hasCrib
        )
        
        // Fetch from API
        let hotels = try await hotelService.searchHotels(parameters: popularParameters)
        
        // Limit to reasonable number for popular section
        let popularHotels = Array(hotels.prefix(18))
        
        // Cache results with longer expiration for popular hotels
        cacheHotelsWithExpiration(popularHotels, for: cacheKey, expiration: CacheExpiration.popularHotels)
        
        return popularHotels
    }
    
    // MARK: - Caching
    
    func getCachedHotels(for cacheKey: String) -> [Hotel]? {
        return cacheManager.getCachedData(
            for: cacheKey,
            type: [Hotel].self,
            maxAge: CacheExpiration.searchResults
        )
    }
    
    func cacheHotels(_ hotels: [Hotel], for cacheKey: String) {
        cacheManager.cacheData(hotels, for: cacheKey)
    }
    
    private func cacheHotelsWithExpiration(_ hotels: [Hotel], for cacheKey: String, expiration: TimeInterval) {
        cacheManager.cacheDataWithExpiration(hotels, for: cacheKey, expiration: expiration)
    }
    
    // MARK: - Favorites Management
    
    func getFavoriteHotels() async throws -> [Hotel] {
        guard let favorites = cacheManager.getCachedData(
            for: CacheKeys.favorites,
            type: [Hotel].self,
            maxAge: TimeInterval.greatestFiniteMagnitude // Never expire favorites
        ) else {
            return []
        }
        return favorites
    }
    
    func addToFavorites(_ hotel: Hotel) async throws {
        var favorites = try await getFavoriteHotels()
        
        // Check if already in favorites
        if !favorites.contains(where: { $0.id == hotel.id }) {
            favorites.append(hotel)
            cacheManager.cacheData(favorites, for: CacheKeys.favorites)
        }
    }
    
    func removeFromFavorites(hotelId: String) async throws {
        var favorites = try await getFavoriteHotels()
        favorites.removeAll { $0.id == hotelId }
        cacheManager.cacheData(favorites, for: CacheKeys.favorites)
    }
    
    // MARK: - Helper Methods
    
    private func generateSearchCacheKey(parameters: HotelSearchParameters) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let checkIn = dateFormatter.string(from: parameters.checkInDate)
        let checkOut = dateFormatter.string(from: parameters.checkOutDate)
        
        return "\(CacheKeys.searchResults)_\(parameters.destination)_\(checkIn)_\(checkOut)_\(parameters.numberOfAdults)_\(parameters.numberOfRooms)"
    }
}

// MARK: - Hotel Cache Manager

class HotelCacheManager {
    
    static let shared = HotelCacheManager()
    
    private init() {}
    
    private struct CacheEntry {
        let data: Data
        let timestamp: Date
        let expiration: TimeInterval
    }
    
    private var memoryCache: [String: CacheEntry] = [:]
    private let queue = DispatchQueue(label: "com.reiseapp.cache", attributes: .concurrent)
    
    func getCachedData<T: Codable>(for key: String, type: T.Type, maxAge: TimeInterval) -> T? {
        return queue.sync {
            // Check memory cache first
            if let entry = memoryCache[key] {
                let age = Date().timeIntervalSince(entry.timestamp)
                if age <= maxAge {
                    do {
                        return try JSONDecoder().decode(type, from: entry.data)
                    } catch {
                        print("Error decoding cached data for key \(key): \(error)")
                        return nil
                    }
                } else {
                    // Remove expired entry
                    memoryCache.removeValue(forKey: key)
                }
            }
            
            // Check UserDefaults as fallback
            return getUserDefaultsCachedData(for: key, type: type, maxAge: maxAge)
        }
    }
    
    func cacheData<T: Codable>(_ data: T, for key: String) {
        cacheDataWithExpiration(data, for: key, expiration: 1800) // Default 30 minutes
    }
    
    func cacheDataWithExpiration<T: Codable>(_ data: T, for key: String, expiration: TimeInterval) {
        queue.async(flags: .barrier) {
            do {
                let encodedData = try JSONEncoder().encode(data)
                let entry = CacheEntry(
                    data: encodedData,
                    timestamp: Date(),
                    expiration: expiration
                )
                
                // Store in memory cache
                self.memoryCache[key] = entry
                
                // Also store in UserDefaults for persistence
                UserDefaults.standard.set(encodedData, forKey: key)
                UserDefaults.standard.set(Date(), forKey: "\(key)_timestamp")
                
                // Cleanup old entries periodically
                self.cleanupExpiredEntries()
            } catch {
                print("Error caching data for key \(key): \(error)")
            }
        }
    }
    
    private func getUserDefaultsCachedData<T: Codable>(for key: String, type: T.Type, maxAge: TimeInterval) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key),
              let timestamp = UserDefaults.standard.object(forKey: "\(key)_timestamp") as? Date else {
            return nil
        }
        
        let age = Date().timeIntervalSince(timestamp)
        guard age <= maxAge else {
            // Remove expired data
            UserDefaults.standard.removeObject(forKey: key)
            UserDefaults.standard.removeObject(forKey: "\(key)_timestamp")
            return nil
        }
        
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            print("Error decoding UserDefaults cached data for key \(key): \(error)")
            return nil
        }
    }
    
    private func cleanupExpiredEntries() {
        let now = Date()
        memoryCache = memoryCache.filter { _, entry in
            let age = now.timeIntervalSince(entry.timestamp)
            return age <= entry.expiration
        }
    }
}

// MARK: - Mock Hotel Repository for Testing

class MockHotelRepository: HotelRepositoryProtocol {
    
    private var mockHotels: [Hotel] = []
    private var favoriteHotels: [Hotel] = []
    
    func searchHotels(parameters: HotelSearchParameters) async throws -> [Hotel] {
        // Return mock data for testing
        return mockHotels
    }
    
    func getPopularHotels(for destination: String, parameters: HotelSearchParameters) async throws -> [Hotel] {
        return Array(mockHotels.prefix(6))
    }
    
    func getCachedHotels(for cacheKey: String) -> [Hotel]? {
        return nil
    }
    
    func cacheHotels(_ hotels: [Hotel], for cacheKey: String) {
        // Mock implementation
    }
    
    func getFavoriteHotels() async throws -> [Hotel] {
        return favoriteHotels
    }
    
    func addToFavorites(_ hotel: Hotel) async throws {
        if !favoriteHotels.contains(where: { $0.id == hotel.id }) {
            favoriteHotels.append(hotel)
        }
    }
    
    func removeFromFavorites(hotelId: String) async throws {
        favoriteHotels.removeAll { $0.id == hotelId }
    }
    
    // Test helper methods
    func setMockHotels(_ hotels: [Hotel]) {
        mockHotels = hotels
    }
}