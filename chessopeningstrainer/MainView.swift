//
//  MainView.swift
//  chessopeningstrainer (iOS)
//
//  Created by Piero on 1/1/22.
//

import Foundation
import SwiftUI

struct MainView: View{
    var body: some View{
        TabView{
            BoardTreeView(color: AppSettings.shared.color, maxTreeMoves: AppSettings.shared.maxTreeMoves, mode: "tree")
                .tabItem{
                    Image(systemName: "book.fill")
                    Text("Explore")
                }
            BoardTreeView(color: AppSettings.shared.color, maxTreeMoves: AppSettings.shared.maxTreeMoves, mode: "treetrain")
                .tabItem{
                    Image(systemName: "checkerboard.rectangle")
                    Text("Practice")
                }
            OpeningSelectionView()
                .tabItem{
                    Image(systemName: "list.bullet")
                    Text("List")
                }
        }
    }
}

struct MainView_Previews: PreviewProvider{
    static var previews: some View{
        MainView()
    }
}
