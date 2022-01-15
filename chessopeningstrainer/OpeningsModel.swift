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
    
    public static func loadFromJSON(_ json: String) -> Opening?{
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
    
    public static func loadFromJSONArray(_ json: String) -> [Opening]?{
        if json == "[]"{
            return nil
        }
        
        do{
            return try JSONDecoder().decode([Opening].self, from: json.data(using: .utf8)!)
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
    static let shared = OpeningsModel()
    
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
    
    func ofDepthWithRandom(_ depth: Int) -> [Opening] {
        var result = ofDepth(depth)
        result.insert(Opening(name: "Random", uci: "", pgn: "", rank: 0), at: 0)
        return result
    }
    
    func ofDepth(_ depth: Int) -> [Opening] {
        var stack: [Opening] = []
        var result: [Opening] = []
        
        var curDepth = 0
        for o in self.openings {
            result.append(o)
            stack.append(o)
        }
        
        while curDepth < depth{
            var newStack: [Opening] = []
            
            while !stack.isEmpty {
                let o = stack.popLast()!
                if let variations = o.variations{
                    for op in variations {
                        result.append(op)
                        newStack.append(op)
                    }
                }
            }
            
            curDepth += 1
            stack = newStack
        }
        
        result.sort { $0.name < $1.name }
        
        return result
    }
}
