//
//  FlightSearchService.swift
//  Reiseapp
//
//  Created by Nikolas Kato on 09.09.25.
//

import Foundation

protocol FlightSearching {
    func searchFlights(parameters: FlightSearchParameters) async throws -> [Flight]
    func getFlightDetails(flightId: String) async throws -> Flight
}

final class FlightSearchService: FlightSearching {
    private let networkManager: NetworkManaging
    private let cache = CacheManager.shared
    
    init(networkManager: NetworkManaging = NetworkManager.shared) {
        self.networkManager = networkManager
    }
    
    func searchFlights(parameters: FlightSearchParameters) async throws -> [Flight] {
        print("🔍 Flight Search Started for \(parameters.origin) → \(parameters.destination)")
        
        // Check for API credentials
        guard !APIConfiguration.APIKeys.amadeusClientId.isEmpty,
              APIConfiguration.APIKeys.amadeusClientId != "YOUR_AMADEUS_CLIENT_ID" else {
            print("❌ No Amadeus API credentials, REFUSING to use mock data")
            throw NetworkError.apiKeyMissing
        }
        
        // Get Amadeus token
        let config = APIConfiguration.shared
        let token = try await config.getAmadeusToken()
        print("🔑 Retrieved token: \(token.prefix(20))...")
        print("🔑 Token length: \(token.count)")
        
        // Build query parameters
        var queryItems = [
            URLQueryItem(name: "originLocationCode", value: getAirportCode(for: parameters.origin)),
            URLQueryItem(name: "destinationLocationCode", value: getAirportCode(for: parameters.destination)),
            URLQueryItem(name: "departureDate", value: formatDate(parameters.departureDate)),
            URLQueryItem(name: "adults", value: String(parameters.numberOfAdults)),
            URLQueryItem(name: "currencyCode", value: "EUR"),
            URLQueryItem(name: "max", value: "20")
        ]
        
        if let returnDate = parameters.returnDate {
            queryItems.append(URLQueryItem(name: "returnDate", value: formatDate(returnDate)))
        }
        
        if parameters.numberOfChildren > 0 {
            queryItems.append(URLQueryItem(name: "children", value: String(parameters.numberOfChildren)))
        }
        
        if parameters.numberOfInfants > 0 {
            queryItems.append(URLQueryItem(name: "infants", value: String(parameters.numberOfInfants)))
        }
        
        // Note: nonStop parameter removed as it's causing API issues
        // Note: travelClass parameter removed as it's causing API issues
        // Note: maxPrice parameter removed as it's causing API issues
        
        let endpoint = Endpoint(
            baseURL: APIConfiguration.shared.baseURLs.amadeus,
            path: "/v2/shopping/flight-offers",
            headers: ["Authorization": "Bearer \(token)"],
            queryItems: queryItems
        )
        
        print("🌐 Making request to: \(endpoint.url?.absoluteString ?? "invalid URL")")
        print("🔒 Authorization header: Bearer \(token.prefix(20))...")
        
        do {
            let response = try await networkManager.request(endpoint, type: AmadeusFlightResponse.self)
            let flights = mapAmadeusFlightsToModel(response.data, for: parameters)
            print("✅ Amadeus API successful, got \(flights.count) real flights")
            return flights
        } catch {
            print("❌ Amadeus API failed: \(error)")
            throw error // Only real API data - no mock data fallback
        }
    }
    
    func getFlightDetails(flightId: String) async throws -> Flight {
        // Implementation for getting specific flight details
        throw NetworkError.noData
    }
    
    private func getAirportCode(for city: String) -> String {
        // Map common cities to airport codes
        let airportMappings = [
            "Berlin": "BER",
            "München": "MUC", 
            "Munich": "MUC",
            "Frankfurt": "FRA",
            "Hamburg": "HAM",
            "Düsseldorf": "DUS",
            "Köln": "CGN",
            "Cologne": "CGN",
            "Stuttgart": "STR",
            "Barcelona": "BCN",
            "Paris": "CDG",
            "London": "LHR",  // Heathrow - main airport with direct flights
            "london": "LHR",  // lowercase version
            "Rom": "FCO",
            "Rome": "FCO",
            "Madrid": "MAD",
            "Amsterdam": "AMS",
            "Wien": "VIE",
            "Vienna": "VIE",
            "Zürich": "ZRH",
            "Zurich": "ZRH",
            "New York": "JFK",
            "Los Angeles": "LAX",
            "Tokyo": "NRT",
            "Dubai": "DXB"
        ]
        
        // If the input is already an airport code, return it
        if city.count == 3 && city == city.uppercased() {
            return city
        }
        
        return airportMappings[city] ?? city.prefix(3).uppercased()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    // REMOVED: Mock flight data creation - only real API data allowed
    
    // REMOVED: Mock flight segments creation - only real API data allowed
    
    private func getCabinMultiplier(_ cabinClass: CabinClass) -> Double {
        switch cabinClass {
        case .economy: return 1.0
        case .premiumEconomy: return 1.5
        case .business: return 3.0
        case .first: return 5.0
        }
    }
    
    private func getCountryForCity(_ city: String) -> String {
        let countryMappings = [
            "Berlin": "Deutschland",
            "München": "Deutschland",
            "Frankfurt": "Deutschland",
            "Hamburg": "Deutschland",
            "Barcelona": "Spanien",
            "Madrid": "Spanien",
            "Paris": "Frankreich",
            "London": "Großbritannien",
            "Rom": "Italien",
            "Amsterdam": "Niederlande",
            "Wien": "Österreich",
            "Zürich": "Schweiz"
        ]
        
        return countryMappings[city] ?? "Europa"
    }
    
    // MARK: - API Response Mapping  
    private func mapAmadeusFlightsToModel(_ amadeusFlights: [AmadeusFlightOffer], for parameters: FlightSearchParameters) -> [Flight] {
        let flights = amadeusFlights.compactMap { offer -> Flight? in
            guard let firstItinerary = offer.itineraries.first,
                  let firstSegment = firstItinerary.segments.first,
                  let lastSegment = firstItinerary.segments.last else { return nil }
            
            print("🛫 Flight: \(firstSegment.departure.iataCode) → \(lastSegment.arrival.iataCode)")
            print("🛫 Number of segments (stops): \(firstItinerary.segments.count)")
            print("🛫 API Total Duration: \(firstItinerary.duration)")
            
            // If multiple segments, show each segment's duration
            if firstItinerary.segments.count > 1 {
                for (index, segment) in firstItinerary.segments.enumerated() {
                    print("   Segment \(index + 1): \(segment.departure.iataCode) → \(segment.arrival.iataCode), Duration: \(segment.duration)")
                }
            }
            
            print("🛫 Departure: \(firstSegment.departure.at)")
            print("🛫 Arrival: \(lastSegment.arrival.at)")
            
            let airline = Airline(
                code: firstSegment.carrierCode,
                name: getAirlineName(for: firstSegment.carrierCode),
                logo: nil // Only real API data - no fake logos
            )
            
            let departureAirport = Airport(
                code: firstSegment.departure.iataCode,
                name: getAirportName(for: firstSegment.departure.iataCode),
                city: parameters.origin,
                country: getCountryForCity(parameters.origin),
                coordinates: getCoordinatesForCity(parameters.origin) ?? Coordinates(latitude: 0.0, longitude: 0.0)
            )
            
            let arrivalAirport = Airport(
                code: lastSegment.arrival.iataCode,
                name: getAirportName(for: lastSegment.arrival.iataCode),
                city: parameters.destination,
                country: getCountryForCity(parameters.destination),
                coordinates: getCoordinatesForCity(parameters.destination) ?? Coordinates(latitude: 0.0, longitude: 0.0)
            )
            
            let price = Price(
                amount: Double(offer.price.total) ?? 0.0,
                currency: offer.price.currency
            )
            
            let durationResult = parseDuration(firstItinerary.duration)
            
            return Flight(
                id: UUID().uuidString,
                airline: airline,
                flightNumber: firstSegment.number,
                departure: FlightEndpoint(
                    airport: departureAirport,
                    dateTime: parseFlightDateTime(firstSegment.departure.at),
                    terminal: firstSegment.departure.terminal,
                    gate: nil
                ),
                arrival: FlightEndpoint(
                    airport: arrivalAirport,
                    dateTime: parseFlightDateTime(lastSegment.arrival.at),
                    terminal: lastSegment.arrival.terminal,
                    gate: nil
                ),
                duration: TimeInterval(durationResult.seconds),
                isEstimatedDuration: durationResult.isEstimated,
                price: price,
                availableSeats: offer.numberOfBookableSeats ?? 9,
                cabinClass: parameters.cabinClass,
                stops: firstItinerary.segments.count - 1,
                segments: mapFlightSegments(from: firstItinerary.segments)
            )
        }
        
        // Filter out duplicates based on flight number, departure time, and price
        let uniqueFlights = flights.reduce([Flight]()) { result, flight in
            let isDuplicate = result.contains { existingFlight in
                existingFlight.flightNumber == flight.flightNumber &&
                existingFlight.departure.dateTime == flight.departure.dateTime &&
                existingFlight.price.amount == flight.price.amount
            }
            return isDuplicate ? result : result + [flight]
        }
        
        // Apply filters
        let filteredFlights = uniqueFlights.filter { flight in
            // Filter by direct flights if requested
            if parameters.directFlightsOnly && flight.stops > 0 {
                print("⚠️ Filtering out flight with \(flight.stops) stops (direct flights only)")
                return false
            }
            
            // Filter out unreasonably long flights for European routes
            let maxDuration: TimeInterval
            
            // Set reasonable max durations based on route
            if parameters.origin.contains("Berlin") && parameters.destination.contains("London") ||
               parameters.origin.contains("BER") && parameters.destination.contains("LON") {
                maxDuration = flight.stops == 0 ? 3 * 3600 : 5 * 3600 // 3h for direct, 5h with stops
            } else {
                // General European flights
                maxDuration = flight.stops == 0 ? 5 * 3600 : 8 * 3600
            }
            
            if flight.duration > maxDuration {
                print("⚠️ Filtering out unreasonably long flight: \(flight.duration / 3600)h for \(parameters.origin) → \(parameters.destination)")
                return false
            }
            
            return true
        }
        
        // Sort by duration (shortest first) then by price
        let sortedFlights = filteredFlights.sorted { first, second in
            // Prefer direct flights
            if first.stops != second.stops {
                return first.stops < second.stops
            }
            // Then sort by duration
            if first.duration == second.duration {
                return first.price.amount < second.price.amount
            }
            return first.duration < second.duration
        }
        
        print("✅ Filtered to \(sortedFlights.count) flights from \(flights.count) total")
        if parameters.directFlightsOnly {
            print("✅ Showing only direct flights")
        }
        
        return sortedFlights
    }
    
    private func mapFlightSegments(from amadeusSegments: [AmadeusFlightSegment]) -> [FlightSegment] {
        return amadeusSegments.map { segment in
            FlightSegment(
                id: UUID().uuidString,
                departure: FlightEndpoint(
                    airport: Airport(
                        code: segment.departure.iataCode,
                        name: getAirportName(for: segment.departure.iataCode),
                        city: getCityForAirport(segment.departure.iataCode),
                        country: getCountryForAirport(segment.departure.iataCode),
                        coordinates: getCoordinatesForAirport(segment.departure.iataCode)
                    ),
                    dateTime: parseFlightDateTime(segment.departure.at),
                    terminal: segment.departure.terminal,
                    gate: nil
                ),
                arrival: FlightEndpoint(
                    airport: Airport(
                        code: segment.arrival.iataCode,
                        name: getAirportName(for: segment.arrival.iataCode),
                        city: getCityForAirport(segment.arrival.iataCode),
                        country: getCountryForAirport(segment.arrival.iataCode),
                        coordinates: getCoordinatesForAirport(segment.arrival.iataCode)
                    ),
                    dateTime: parseFlightDateTime(segment.arrival.at),
                    terminal: segment.arrival.terminal,
                    gate: nil
                ),
                flightNumber: segment.number,
                duration: TimeInterval(parseDuration(segment.duration).seconds),
                aircraft: segment.aircraft?.code
            )
        }
    }
    
    private func getAirlineName(for code: String) -> String {
        let airlineNames: [String: String] = [
            "LH": "Lufthansa",
            "EW": "Eurowings", 
            "BA": "British Airways",
            "AF": "Air France",
            "KL": "KLM",
            "IB": "Iberia",
            "LX": "Swiss",
            "OS": "Austrian Airlines",
            "SN": "Brussels Airlines",
            "TK": "Turkish Airlines",
            "VY": "Vueling Airlines",
            "FR": "Ryanair",
            "U2": "easyJet",
            "W6": "Wizz Air",
            "DE": "Condor",
            "4U": "Germanwings",
            "X3": "TUI fly",
            "EN": "Air Dolomiti"
        ]
        return airlineNames[code] ?? code
    }
    
    private func getAirportName(for code: String) -> String {
        let airportNames: [String: String] = [
            "BER": "Berlin Brandenburg Airport",
            "MUC": "München Franz Josef Strauß Airport",
            "FRA": "Frankfurt am Main Airport",
            "HAM": "Hamburg Airport",
            "DUS": "Düsseldorf Airport",
            "CGN": "Köln Bonn Airport",
            "STR": "Stuttgart Airport",
            "BCN": "Barcelona-El Prat Airport",
            "MAD": "Madrid-Barajas Airport",
            "CDG": "Paris Charles de Gaulle Airport",
            "ORY": "Paris Orly Airport",
            "LHR": "London Heathrow Airport",
            "LGW": "London Gatwick Airport",
            "FCO": "Rome Fiumicino Airport",
            "AMS": "Amsterdam Schiphol Airport",
            "VIE": "Vienna International Airport",
            "ZUR": "Zurich Airport",
            "GVA": "Geneva Airport",
            "PRG": "Prague Václav Havel Airport",
            "BUD": "Budapest Ferenc Liszt Airport",
            "WAW": "Warsaw Chopin Airport",
            "CPH": "Copenhagen Airport",
            "ARN": "Stockholm Arlanda Airport",
            "OSL": "Oslo Airport",
            "HEL": "Helsinki Airport",
            "LIS": "Lisbon Airport",
            "DUB": "Dublin Airport",
            "MXP": "Milan Malpensa Airport",
            "VCE": "Venice Marco Polo Airport",
            "NAP": "Naples International Airport",
            "NCE": "Nice Côte d'Azur Airport"
        ]
        return airportNames[code] ?? "\(code) Airport"
    }
    
    private func getCityForAirport(_ airportCode: String) -> String {
        let airportCities: [String: String] = [
            "BER": "Berlin",
            "MUC": "München",
            "FRA": "Frankfurt",
            "HAM": "Hamburg",
            "DUS": "Düsseldorf",
            "CGN": "Köln",
            "STR": "Stuttgart",
            "BCN": "Barcelona",
            "MAD": "Madrid",
            "CDG": "Paris",
            "ORY": "Paris",
            "LHR": "London",
            "LGW": "London",
            "FCO": "Rom",
            "AMS": "Amsterdam",
            "VIE": "Wien",
            "ZUR": "Zürich",
            "GVA": "Genf",
            "PRG": "Prag",
            "BUD": "Budapest",
            "WAW": "Warschau",
            "CPH": "Kopenhagen",
            "ARN": "Stockholm",
            "OSL": "Oslo",
            "HEL": "Helsinki",
            "LIS": "Lissabon",
            "DUB": "Dublin",
            "MXP": "Mailand",
            "VCE": "Venedig",
            "NAP": "Neapel",
            "NCE": "Nizza"
        ]
        return airportCities[airportCode] ?? airportCode
    }
    
    private func getCountryForAirport(_ airportCode: String) -> String {
        let airportCountries: [String: String] = [
            "BER": "Deutschland", "MUC": "Deutschland", "FRA": "Deutschland", "HAM": "Deutschland",
            "DUS": "Deutschland", "CGN": "Deutschland", "STR": "Deutschland",
            "BCN": "Spanien", "MAD": "Spanien",
            "CDG": "Frankreich", "ORY": "Frankreich", "NCE": "Frankreich",
            "LHR": "Großbritannien", "LGW": "Großbritannien",
            "FCO": "Italien", "MXP": "Italien", "VCE": "Italien", "NAP": "Italien",
            "AMS": "Niederlande",
            "VIE": "Österreich",
            "ZUR": "Schweiz", "GVA": "Schweiz",
            "PRG": "Tschechien",
            "BUD": "Ungarn",
            "WAW": "Polen",
            "CPH": "Dänemark",
            "ARN": "Schweden",
            "OSL": "Norwegen",
            "HEL": "Finnland",
            "LIS": "Portugal",
            "DUB": "Irland"
        ]
        return airportCountries[airportCode] ?? "Europa"
    }
    
    private func getCoordinatesForAirport(_ airportCode: String) -> Coordinates {
        let airportCoordinates: [String: Coordinates] = [
            "BER": Coordinates(latitude: 52.3667, longitude: 13.5033),
            "MUC": Coordinates(latitude: 48.3538, longitude: 11.7861),
            "FRA": Coordinates(latitude: 50.0379, longitude: 8.5622),
            "HAM": Coordinates(latitude: 53.6304, longitude: 9.9882),
            "DUS": Coordinates(latitude: 51.2895, longitude: 6.7668),
            "CGN": Coordinates(latitude: 50.8659, longitude: 7.1427),
            "STR": Coordinates(latitude: 48.6898, longitude: 9.2226),
            "BCN": Coordinates(latitude: 41.2971, longitude: 2.0833),
            "MAD": Coordinates(latitude: 40.4719, longitude: -3.5626),
            "CDG": Coordinates(latitude: 49.0128, longitude: 2.5500),
            "ORY": Coordinates(latitude: 48.7233, longitude: 2.3792),
            "LHR": Coordinates(latitude: 51.4700, longitude: -0.4543),
            "LGW": Coordinates(latitude: 51.1481, longitude: -0.1903),
            "FCO": Coordinates(latitude: 41.8003, longitude: 12.2389),
            "AMS": Coordinates(latitude: 52.3086, longitude: 4.7639),
            "VIE": Coordinates(latitude: 48.1103, longitude: 16.5697),
            "ZUR": Coordinates(latitude: 47.4647, longitude: 8.5492),
            "GVA": Coordinates(latitude: 46.2380, longitude: 6.1090),
            "PRG": Coordinates(latitude: 50.1008, longitude: 14.2632),
            "BUD": Coordinates(latitude: 47.4297, longitude: 19.2611),
            "WAW": Coordinates(latitude: 52.1657, longitude: 20.9671),
            "CPH": Coordinates(latitude: 55.6180, longitude: 12.6560),
            "ARN": Coordinates(latitude: 59.6519, longitude: 17.9186),
            "OSL": Coordinates(latitude: 60.1939, longitude: 11.1004),
            "HEL": Coordinates(latitude: 60.3172, longitude: 24.9633),
            "LIS": Coordinates(latitude: 38.7813, longitude: -9.1363),
            "DUB": Coordinates(latitude: 53.4213, longitude: -6.2701),
            "MXP": Coordinates(latitude: 45.6306, longitude: 8.7281),
            "VCE": Coordinates(latitude: 45.5053, longitude: 12.3519),
            "NAP": Coordinates(latitude: 40.8860, longitude: 14.2908),
            "NCE": Coordinates(latitude: 43.6584, longitude: 7.2159)
        ]
        return airportCoordinates[airportCode] ?? Coordinates(latitude: 0.0, longitude: 0.0)
    }
    
    private func parseDuration(_ duration: String) -> (seconds: Int, isEstimated: Bool) {
        // Parse ISO 8601 duration (PT2H30M) to seconds
        print("🕐 Parsing duration: '\(duration)'")
        
        // Remove PT prefix and any whitespace
        let cleanDuration = duration.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "PT", with: "")
        
        print("🕐 Clean duration: '\(cleanDuration)'")
        
        var totalSeconds = 0
        var hasValidData = false
        
        // Parse hours if present (e.g., "2H30M" -> extract "2")
        if let hIndex = cleanDuration.firstIndex(of: "H") {
            let hoursString = String(cleanDuration[..<hIndex])
            if let hours = Int(hoursString) {
                totalSeconds += hours * 3600
                print("🕐   Parsed hours: \(hours) (\(hours * 3600) seconds)")
                hasValidData = true
            }
        }
        
        // Parse minutes if present (e.g., "2H30M" -> extract "30" or "90M" -> extract "90")
        if let mIndex = cleanDuration.firstIndex(of: "M") {
            // Find start of minutes (after H if exists, or from beginning)
            let startIndex: String.Index
            if let hIndex = cleanDuration.firstIndex(of: "H") {
                startIndex = cleanDuration.index(after: hIndex)
            } else {
                startIndex = cleanDuration.startIndex
            }
            
            let minutesString = String(cleanDuration[startIndex..<mIndex])
            if let minutes = Int(minutesString) {
                totalSeconds += minutes * 60
                print("🕐   Parsed minutes: \(minutes) (\(minutes * 60) seconds)")
                hasValidData = true
            }
        }
        
        if hasValidData && totalSeconds > 0 {
            let hours = totalSeconds / 3600
            let mins = (totalSeconds % 3600) / 60
            print("🕐 ✅ Successfully parsed: \(hours)h \(mins)m (total: \(totalSeconds) seconds)")
            return (totalSeconds, false) // Successfully parsed, not estimated
        } else {
            print("🕐 ⚠️ Failed to parse duration, using fallback")
            return parseDurationFallback(duration)
        }
    }
    
    private func parseDurationFallback(_ duration: String) -> (seconds: Int, isEstimated: Bool) {
        // Simple fallback: assume realistic flight time based on route length
        print("🕐 Using fallback duration parsing for: '\(duration)'")
        
        // More realistic estimate: 2 hours for European flights
        let estimatedSeconds = 2 * 3600 // 2 hours as default
        
        print("🕐 Fallback duration: 2h 0m (\(estimatedSeconds) seconds)")
        return (estimatedSeconds, true) // Estimated duration
    }
    
    private func parseFlightDateTime(_ dateString: String) -> Date {
        print("🕐 Parsing datetime: '\(dateString)'")
        
        // Try multiple date formats for Amadeus API responses
        let formatters: [(DateFormatter, String)] = [
            // Amadeus format: "2025-09-12T06:25:00"
            ({
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                formatter.timeZone = TimeZone(abbreviation: "UTC") // Amadeus uses UTC
                return formatter
            }(), "Amadeus standard UTC"),
            // ISO format with timezone
            ({
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                return formatter
            }(), "ISO with timezone"),
            // ISO format with fractional seconds
            ({
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                return formatter
            }(), "ISO with fractional seconds")
        ]
        
        for (formatter, description) in formatters {
            if let date = formatter.date(from: dateString) {
                print("🕐 Successfully parsed datetime using: \(description)")
                return date
            }
        }
        
        // Debug log for parsing failures
        print("⚠️ Failed to parse flight datetime: '\(dateString)'")
        return Date()
    }
    
    
    private func getCoordinatesForCity(_ cityName: String) -> Coordinates? {
        let cityCoordinates = [
            "Berlin": Coordinates(latitude: 52.5200, longitude: 13.4050),
            "Munich": Coordinates(latitude: 48.1351, longitude: 11.5820),
            "Hamburg": Coordinates(latitude: 53.5511, longitude: 9.9937),
            "Cologne": Coordinates(latitude: 50.9375, longitude: 6.9603),
            "Frankfurt": Coordinates(latitude: 50.1109, longitude: 8.6821),
            "Stuttgart": Coordinates(latitude: 48.7758, longitude: 9.1829),
            "Barcelona": Coordinates(latitude: 41.3851, longitude: 2.1734),
            "Madrid": Coordinates(latitude: 40.4168, longitude: -3.7038),
            "Paris": Coordinates(latitude: 48.8566, longitude: 2.3522),
            "London": Coordinates(latitude: 51.5074, longitude: -0.1278),
            "Rome": Coordinates(latitude: 41.9028, longitude: 12.4964),
            "Amsterdam": Coordinates(latitude: 52.3676, longitude: 4.9041),
            "Vienna": Coordinates(latitude: 48.2082, longitude: 16.3738),
            "Prague": Coordinates(latitude: 50.0755, longitude: 14.4378),
            "Budapest": Coordinates(latitude: 47.4979, longitude: 19.0402),
            "Warsaw": Coordinates(latitude: 52.2297, longitude: 21.0122),
            "Zurich": Coordinates(latitude: 47.3769, longitude: 8.5417),
            "Geneva": Coordinates(latitude: 46.2044, longitude: 6.1432),
            "Brussels": Coordinates(latitude: 50.8503, longitude: 4.3517),
            "Copenhagen": Coordinates(latitude: 55.6761, longitude: 12.5683),
            "Stockholm": Coordinates(latitude: 59.3293, longitude: 18.0686),
            "Oslo": Coordinates(latitude: 59.9139, longitude: 10.7522),
            "Helsinki": Coordinates(latitude: 60.1699, longitude: 24.9384),
            "Lisbon": Coordinates(latitude: 38.7223, longitude: -9.1393),
            "Dublin": Coordinates(latitude: 53.3498, longitude: -6.2603),
            "Milan": Coordinates(latitude: 45.4642, longitude: 9.1900),
            "Venice": Coordinates(latitude: 45.4408, longitude: 12.3155),
            "Florence": Coordinates(latitude: 43.7696, longitude: 11.2558),
            "Naples": Coordinates(latitude: 40.8518, longitude: 14.2681),
            "Nice": Coordinates(latitude: 43.7102, longitude: 7.2620),
            "Lyon": Coordinates(latitude: 45.7640, longitude: 4.8357)
        ]
        
        return cityCoordinates[cityName]
    }
}

// MARK: - Amadeus Flight API Models
struct AmadeusFlightResponse: Codable {
    let data: [AmadeusFlightOffer]
}

struct AmadeusFlightOffer: Codable {
    let id: String
    let source: String?
    let instantTicketingRequired: Bool?
    let nonHomogeneous: Bool?
    let oneWay: Bool?
    let lastTicketingDate: String?
    let numberOfBookableSeats: Int?
    let itineraries: [AmadeusItinerary]
    let price: AmadeusFlightPrice
    let pricingOptions: AmadeusPricingOptions?
    let validatingAirlineCodes: [String]?
    let travelerPricings: [AmadeusTravelerPricing]?
}

struct AmadeusItinerary: Codable {
    let duration: String
    let segments: [AmadeusFlightSegment]
}

struct AmadeusFlightSegment: Codable {
    let departure: AmadeusFlightEndpoint
    let arrival: AmadeusFlightEndpoint
    let carrierCode: String
    let number: String
    let aircraft: AmadeusAircraft?
    let operating: AmadeusOperatingFlight?
    let duration: String
    let id: String
    let numberOfStops: Int?
    let blacklistedInEU: Bool?
}

struct AmadeusFlightEndpoint: Codable {
    let iataCode: String
    let terminal: String?
    let at: String
}

struct AmadeusAircraft: Codable {
    let code: String
}

struct AmadeusOperatingFlight: Codable {
    let carrierCode: String?
}

struct AmadeusFlightPrice: Codable {
    let currency: String
    let total: String
    let base: String?
    let fees: [AmadeusFee]?
    let grandTotal: String?
}

struct AmadeusFee: Codable {
    let amount: String
    let type: String
}

struct AmadeusPricingOptions: Codable {
    let fareType: [String]?
    let includedCheckedBagsOnly: Bool?
}

struct AmadeusTravelerPricing: Codable {
    let travelerId: String
    let fareOption: String
    let travelerType: String
    let price: AmadeusTravelerPrice
    let fareDetailsBySegment: [AmadeusFareDetails]
}

struct AmadeusTravelerPrice: Codable {
    let currency: String
    let total: String
    let base: String
}

struct AmadeusFareDetails: Codable {
    let segmentId: String
    let cabin: String
    let fareBasis: String
    let bookingClass: String
    let includedCheckedBags: AmadeusCheckedBags?
    
    enum CodingKeys: String, CodingKey {
        case segmentId, cabin, fareBasis, includedCheckedBags
        case bookingClass = "class"
    }
}

struct AmadeusCheckedBags: Codable {
    let quantity: Int?
}

