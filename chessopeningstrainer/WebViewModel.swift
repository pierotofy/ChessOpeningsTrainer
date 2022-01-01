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
    
    var url: URL
    
    init(color: String){
        self.mode = "tree"
        
        self.url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "board")!
            .appending("color", value: color)
            .appending("mode", value: "tree")
    }
    
    init(uci: String, color: String) {
        self.mode = "explore"
        self.url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "board")!
            .appending("uci", value: uci)
            .appending("color", value: color)
    }
}
