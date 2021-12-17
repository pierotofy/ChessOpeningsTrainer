//
//  GameSelectionView.swift
//  chessopeningstrainer (iOS)
//
//  Created by Piero on 12/8/21.
//

import Foundation
import SwiftUI

struct OpeningSelectionView: View{
    @State private var searchText = ""
    @State private var opening: Opening?
    private var opModel: OpeningsModel = OpeningsModel()
    
    private var openings: [Opening] {
        if !searchText.isEmpty {
            return opModel.openings.filter { $0.name.contains(searchText)
                
            }
        } else {
            return opModel.openings
        }
    }
    
    
    var body: some View{
        NavigationView{
            List(openings, children: \.variations) { o in
                VStack(alignment: .leading){
                    Text(o.name)
                    Text(o.pgn).font(.footnote).foregroundColor(.gray)
                    }
                
                HStack(alignment: .center){
                        Button(action: {
                            self.opening = o
                        }){
                            Image(systemName: "magnifyingglass")
                        }.background(NavigationLink(
                            destination: BoardView(o),
                            tag: o,
                            selection: $opening,
                            label: { EmptyView() }
                        ).hidden())
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        .padding(.trailing, 10)
                    
                }.frame(maxWidth: .infinity, alignment: .trailing)
                

            }
            
            .navigationTitle("Openings")
            .searchable(text: $searchText)
        }.navigationViewStyle(.stack)
            
    }
}

struct OpeningSelectionScene_Previews: PreviewProvider{
    static var previews: some View{
        OpeningSelectionView().previewInterfaceOrientation(.portrait)
    }
}
