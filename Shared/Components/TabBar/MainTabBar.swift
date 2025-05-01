//
//  AppTabBar.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 08/04/2025.
//

import SwiftUI

struct MainTabBar: View {
    @EnvironmentObject var viewModel: TabBarViewModel
    
    let icons = ["house", "square.stack", "plus.app", "heart", "person"]
    
    var body: some View {
        HStack {
            ForEach(0..<icons.count, id: \.self) { index in
                Spacer()
                Button(action: {
                    viewModel.activeIndex = index
                }) {
                    Image(systemName: viewModel.activeIndex == index ? "\(icons[index]).fill" : icons[index])
                        .resizable()
                        .scaledToFit()
                        .frame(height: 24)
                        .foregroundColor(.primary)
                }
                Spacer()
            }
        }
        .padding(.top)
        .padding(.bottom)
        .background(.ultraThinMaterial)
    }
}
