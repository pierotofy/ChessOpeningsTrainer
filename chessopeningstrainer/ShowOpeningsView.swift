//
//  DescriptionWebView.swift
//  chessopeningstrainer (iOS)
//
//  Created by Piero on 12/25/21.
//

import SwiftUI

struct OpsList : Identifiable{
    let id = UUID()
    
    var opening: Opening
    var items: [OpsList]?
}

struct ShowOpeningsView: View {
    var openings: [Opening]
    var onExploreOpening: ((Opening) -> Void)?
    var onTrainOpening: ((Opening) -> Void)?
    var onClose: (() -> Void)?

    func opsList() -> [OpsList]{
        return openings.map { OpsList( opening: $0, items: [OpsList(opening: $0)] )}
    }
    
    var body: some View{
        VStack{
            HStack(alignment: .top){
                Spacer()
                Button(action: {
                    if onClose != nil{
                        onClose!()
                    }
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                })
                .padding()
            }
            
            if (openings.count == 1){
                SOViewItem(opening: openings[0], onExploreOpening: onExploreOpening, onTrainOpening: onTrainOpening)
            }else{
                List(opsList(), children: \.items){ ol in
                    if ol.items != nil{
                        Text(ol.opening.name)
                    }else{
                        SOViewItem(opening: ol.opening, onExploreOpening: onExploreOpening, onTrainOpening: onTrainOpening).padding()
                    }
                }
            }
        }.frame(maxHeight: .infinity, alignment: .top)
         .background(){
            RoundedRectangle(cornerRadius: 16).fill(.white)
        }
            

    }
}

struct ShowOpeningsView_Previews: PreviewProvider{
    static var previews: some View{
        ShowOpeningsView(openings: [Opening(name: "test", uci: "e2e4", pgn: "1. e4", rank: 20), Opening(name: "test2", uci: "d2d4", pgn: "1. d4", rank: 22)])
    }
}
