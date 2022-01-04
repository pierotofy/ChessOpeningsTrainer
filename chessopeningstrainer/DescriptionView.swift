//
//  DescriptionWebView.swift
//  chessopeningstrainer (iOS)
//
//  Created by Piero on 12/25/21.
//

import WebKit
import SwiftUI

// https://stackoverflow.com/questions/53238251/swift-splitting-strings-with-regex-ignoring-search-string
extension String {
    func split(usingRegex pattern: String) -> [String] {
        let regex = try! NSRegularExpression(pattern: pattern)
        let matches = regex.matches(in: self, range: NSRange(0..<utf16.count))
        let ranges = [startIndex..<startIndex] + matches.map{Range($0.range, in: self)!} + [endIndex..<endIndex]
        return (0...matches.count).map {String(self[ranges[$0].upperBound..<ranges[$0+1].lowerBound])}
    }
}

struct DescriptionView: View {
    @State var loading = true
    
    var pgn: String
    
    var css: String = """
    <header><meta name="viewport" content='width=device-width, initial-scale=1.0, minimum-scale=1.0'></header>
    
    <style type="text/css">
    :root {
      color-scheme: light dark;
    }
    body{
        -webkit-text-size-adjust: none;
        padding: 20px;
        font-family: -apple-system-body;
        font-size: 20px;
    }
    h1,h2 {
        font-size: 24px;
        font-family: -apple-system-headline;
    }
    h3,h4,h5{
        font-size: 22px;
        font-family: -apple-system-subheadline;
    }
    </style>
    """
    var credits: String = "<br/><br/><i>Source: wikibooks.org</i>"
    
    func pgnToDescrFile(pgn: String) -> String{
        let parts = pgn.split(usingRegex: "[\\d]\\.\\s*")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.count > 0}
        
        var p = ""
        for i in 0...parts.count-1 {
            let moves = parts[i].split(separator: " ")
            p += "-\(i + 1)._\(moves[0])"

            for m in moves[1...] {
                p += "-\(i + 1)...\(m)"
            }
        }
        p.remove(at: p.startIndex)
        
        return p
    }
    
    func loadHtml(pgn: String) -> String{
        let descrFile = pgnToDescrFile(pgn: pgn)
        
        if let fileURL = Bundle.main.url(forResource: descrFile, withExtension: "", subdirectory: "gen/descriptions") {
            if let fileContents = try? String(contentsOf: fileURL) {
                return fileContents
           }else{
                return "Error: Cannot retrieve content"
            }
        }else{
            return "Error: Cannot retrieve \(descrFile)"
        }
    }
    
    var body: some View{
        ZStack {
            HtmlStringView(htmlContent: loadHtml(pgn: pgn) + css + credits, onLoad: { self.loading = false
            })
            if loading {
                ProgressView()
                    .frame(height: 30)
            }
        }
    }
}

struct DescriptionWebView_Previews: PreviewProvider{
    static var previews: some View{
        DescriptionView(pgn: "1. e4")
    }
}
