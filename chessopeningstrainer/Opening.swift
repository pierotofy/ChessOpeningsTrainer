//
//  Opening.swift
//  chessopeningstrainer (iOS)
//
//  Created by Piero on 12/9/21.
//

import Foundation

struct Opening: Identifiable {
    let id: String
    let name: String
    var variations: [Opening]? = nil

    static let test = Opening(id: "A02", name: "Test")
    static let dragon = Opening(id: "A00", name: "Dragon Variation very long name indeed wow there are a lot of variations here", variations: [Opening.test])

    static let sicilian = Opening(id: "A01", name: "Sicilian Defense", variations: [Opening.dragon])
}
