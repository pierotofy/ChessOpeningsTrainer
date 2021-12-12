//
//  Opening.swift
//  chessopeningstrainer (iOS)
//
//  Created by Piero on 12/9/21.
//

import Foundation

struct Opening: Identifiable, Decodable, Hashable {
    let id = UUID()
    
    private enum CodingKeys: String, CodingKey {
        case name, uci, pgn, variations
    }
    
    var name: String
    var uci: String
    var pgn: String
    var variations: [Opening]? = []
}

class OpeningsModel: ObservableObject {
    @Published var openings: [Opening]
    
    init() {
        self.openings = []
        
        do{
            print("Loading openings...")
            let openingsJson = Bundle.main.path(forResource: "gen/openings", ofType: "json")!
            let jsonData = try String(contentsOfFile: openingsJson).data(using: .utf8)!
            self.openings = try JSONDecoder().decode([Opening].self, from: jsonData)
            print("Loaded openings")
        }catch{
            print("Cannot load JSON")
        }

    }
}
