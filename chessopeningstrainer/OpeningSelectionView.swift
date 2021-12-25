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
    @State private var descrPgn: String = ""
    
    private var opModel = OpeningsModel()
    
    private var openings: [Opening] {
        if !searchText.isEmpty {
            return opModel.openings.filter { $0.name.contains(searchText)
                
            }
        } else {
            return opModel.openings
        }
    }
    
    
    var body: some View{
        let showDescription = Binding(get: { descrPgn != "" }, set: { descrPgn = $0 ? descrPgn : "" })
        
        NavigationView{
            List(openings, children: \.variations) { o in
                VStack(alignment: .leading){
                    Text(o.name)
                    Text(o.pgn).font(.footnote).foregroundColor(.gray)
                    }
                
                HStack(alignment: .center){
                    if let _ = o.descr {
                        Button(action: {
                            self.descrPgn = o.pgn
                        }){
                            Image(systemName: "info.circle")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                    }
                    
                    Button(action: {
                        self.opening = o
                    }){
                        Image(systemName: "magnifyingglass")
                    }.background(NavigationLink(
                        destination: BoardView(o, color: AppSettings.shared.color),
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
            .toolbar{
                Button(action: {
                    
                }){
                    Image(systemName: "gearshape")
                }
            }
            
        }.navigationViewStyle(.stack)
        .sheet(isPresented: showDescription, onDismiss: {
        }){
            VStack{
                HStack{
                    Spacer()
                    Button(action: {
                        descrPgn = ""
                    }, label: {
                        Image(systemName: "xmark.circle.fill")
                    })
                    .padding()
                }
                DescriptionView(pgn: descrPgn)
            }
        }
    }
}

struct OpeningSelectionScene_Previews: PreviewProvider{
    static var previews: some View{
        OpeningSelectionView().previewInterfaceOrientation(.portrait)
    }
}
