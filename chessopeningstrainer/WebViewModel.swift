import Combine
import Foundation

class WebViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var canPlayBack: Bool = false
    @Published var canPlayFoward: Bool = true
    @Published var title: String = ""
    
    var url: URL
    
    init() {
        //self.url = url
        
        self.url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "board")!
        print(self.url)
    }
}
