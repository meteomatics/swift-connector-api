//
//  Meteomatics.swift
//  MeteomaticsConnector
//
//  Created by Alin Fusaru on 29.03.2022.
//

import Foundation
import CoreLocation


struct Meteomatics {
    
    var startDate: Date
    var endDate: Date?
    var parameters: [String]
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var user: String
    var password: String
    
    init(startDate: Date, endDate: Date?, parameters: [String], latitude: CLLocationDegrees, longitude: CLLocationDegrees, user: String, password: String) {
        
        self.startDate = startDate
        self.endDate = endDate
        self.parameters = parameters
        self.latitude = latitude
        self.longitude = longitude
        self.user = user
        self.password = password
    }
    
    init(forDate: Date, parameters: [String], latitude: CLLocationDegrees, longitude: CLLocationDegrees, user: String, password: String) {
        self.startDate = forDate
        self.parameters = parameters
        self.latitude = latitude
        self.longitude = longitude
        self.user = user
        self.password = password
    }
    
    private func createPath() -> String {
        var validDateTime = ""
        if endDate != nil {
            validDateTime = "\(startDate.ISO8601Format())--\(endDate?.ISO8601Format() ?? Date().ISO8601Format())"
        } else {
            validDateTime = startDate.ISO8601Format()
        }
        let params = parameters.joined(separator: ",")
        let location = "\(latitude),\(longitude)"
        
        let path = "/\(validDateTime)/\(params)/\(location)/json"
        
        return path
    }
    
    func fetchWeather<T: Decodable>() async throws -> T {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.meteomatics.com"
        components.path = createPath()
        guard let url = components.url else { fatalError("Missing URL")}
        
        let passwordString = "\(user):\(password)"
        let passwordData = passwordString.data(using:String.Encoding.utf8)!
        let base64EncodedCredential = passwordData.base64EncodedString()
        let authString = "Basic \(base64EncodedCredential)"
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
                    
        configuration.httpAdditionalHeaders = ["Authorization" : authString]
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("Basic \(base64EncodedCredential)", forHTTPHeaderField: "Authorization")
        urlRequest.httpMethod = "GET"
        
        let (data, response) = try await session.data(for: urlRequest)
        
//        check the list of errors https://www.meteomatics.com/en/api/response/api-response-error-codes/ 
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("\((response as? HTTPURLResponse)!.statusCode)")}
        
        let decodedData = try JSONDecoder().decode(T.self, from: data)
        return decodedData
    }
    
}
