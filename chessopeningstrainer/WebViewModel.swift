import Combine
import Foundation

class WebViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var canGoBack: Bool = false
    @Published var shouldGoBack: Bool = false
    @Published var title: String = ""
    
    var url: URL
    
    init() {
        //self.url = url
        
        self.url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "board")!
        print(self.url)
    }
}
