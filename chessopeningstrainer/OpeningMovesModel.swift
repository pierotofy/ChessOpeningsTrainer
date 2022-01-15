//
//  Opening.swift
//  chessopeningstrainer (iOS)
//
//  Created by Piero on 12/9/21.
//

import Foundation

struct OpeningMove: Identifiable, Decodable, Hashable {
    let id = UUID()
    
    private enum CodingKeys: String, CodingKey {
        case name, uci
    }
    
    var name: String
    var uci: String
}


class OpeningMovesModel: ObservableObject {
    static let shared = OpeningMovesModel()
    
    @Published var opmoves: [[OpeningMove]]
    
    init() {
        self.opmoves = []
        
        do{
            print("Loading opening moves...")
            let opmovesJson = Bundle.main.path(forResource: "gen/openings-moves", ofType: "json")!
            let jsonData = try String(contentsOfFile: opmovesJson).data(using: .utf8)!
            self.opmoves = try JSONDecoder().decode([[OpeningMove]].self, from: jsonData)
            print("Loaded opening moves")
        }catch{
            print("Cannot load JSON")
        }

    }
    
    func getForMaxMovesWithRandom(_ maxMoves: Int) -> [OpeningMove] {
        var result = getForMaxMoves(maxMoves)
        result.insert(OpeningMove(name: "Random", uci: ""), at: 0)
        return result
    }
    
    func getForMaxMoves(_ maxMoves: Int) -> [OpeningMove] {
        return opmoves[maxMoves - 1]
    }
}
