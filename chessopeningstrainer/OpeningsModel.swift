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
        case name, uci, pgn, variations, descr, rank
    }
    
    public static func loadfromJSON(_ json: String) -> Opening?{
        if json == "{}" {
            return nil
        }
            
        do{
            return try JSONDecoder().decode(Opening.self, from: json.data(using: .utf8)!)
        }catch{
            print("Cannot decode opening from JSON \(json)")
            return nil
        }
    }
    
    var name: String
    var uci: String
    var pgn: String
    var variations: [Opening]? = []
    var descr: Bool?
    var rank: Int
    
    func rankString() -> String{
        let v = String(format: "%.2f", Float(rank) / 100.0)
        if rank >= 0{
            return "+" + v
        }else{
            return v
        }
    }
}


class OpeningsModel: ObservableObject {
    @Published var openings: [Opening]
    
    init() {
        self.openings = []
        
        do{
            print("Loading openings...")
            let openingsJson = Bundle.main.path(forResource: "gen/openings-ranked", ofType: "json")!
            let jsonData = try String(contentsOfFile: openingsJson).data(using: .utf8)!
            self.openings = try JSONDecoder().decode([Opening].self, from: jsonData)
            print("Loaded openings")
        }catch{
            print("Cannot load JSON")
        }

    }
}
