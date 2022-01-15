import Combine
import Foundation
import SwiftUI

class WebViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var canPlayBack: Bool = false
    @Published var canPlayFoward: Bool = true
    @Published var title: String = ""
    @Published var mode: String = "explore"
    @Published var playedOpening: Opening?
    @Published var showOpenings: [Opening]?
    @Published var color: String = "white"
    @Published var uci: String = ""
    
    var maxTreeMoves: Int = 0
    
    init(color: String, maxTreeMoves: Int, mode: String){
        self.color = color
        self.maxTreeMoves = maxTreeMoves
        self.mode = mode
    }
    
    init(color: String, maxTreeMoves: Int, mode: String, uci: String){
        self.color = color
        self.maxTreeMoves = maxTreeMoves
        self.mode = mode
        self.uci = uci
    }
    
    
    init(uci: String, color: String) {
        self.mode = "explore"
        self.uci = uci
        self.color = color
    }
    
    init(uci: String, color: String, mode: String){
        self.mode = mode
        self.uci = uci
        self.color = color
    }
    
    func getURL() -> URL{
        var url =  Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "board")!
            .appending("uci", value: uci)
            .appending("color", value: color)
            .appending("mode", value: mode)
        
        if mode == "tree" || mode == "treetrain" {
            url = url.appending("maxTreeMoves", value: String(maxTreeMoves))
        }
        
        return url
    }
}
