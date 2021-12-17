//
//  URLQueryParams.swift
//  chessopeningstrainer (iOS)
//
//  Created by Piero on 12/16/21.
//
import Foundation

//https://stackoverflow.com/questions/34060754/how-can-i-build-a-url-with-query-parameters-containing-multiple-values-for-the-s
extension URL {

    func appending(_ queryItem: String, value: String?) -> URL {

        guard var urlComponents = URLComponents(string: absoluteString) else { return absoluteURL }

        // Create array of existing query items
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []

        // Create query item
        let queryItem = URLQueryItem(name: queryItem, value: value)

        // Append the new query item in the existing query items array
        queryItems.append(queryItem)

        // Append updated query items array in the url component object
        urlComponents.queryItems = queryItems

        // Returns the url from new url components
        return urlComponents.url!
    }
}
