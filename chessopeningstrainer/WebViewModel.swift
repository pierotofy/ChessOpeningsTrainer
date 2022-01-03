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
    
    
    init(color: String){
        self.mode = "tree"
        self.color = color
    }
    
    init(uci: String, color: String) {
        self.mode = "explore"
        self.uci = uci
        self.color = color
    }
    
    func getURL() -> URL{
        return Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "board")!
            .appending("uci", value: uci)
            .appending("color", value: color)
            .appending("mode", value: mode)
    }
}
