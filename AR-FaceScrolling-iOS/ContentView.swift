//
//  ContentView.swift
//  AR-FaceScrolling-iOS
//
//  Created by Joni Lassila on 6.2.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var arViewModel = ARTrackingViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                VStack {
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(0..<10, id: \.self) { index in
                                    Text("item \(index)")
                                        .frame(maxWidth: .infinity)
                                        .frame(height: UIScreen.main.bounds.height * 0.8)
                                        .background(arViewModel.selectedItemIndex == index ? Color.green : Color.blue.opacity(0.2))
                                        .cornerRadius(20)
                                        .id(index)
                                }
                            }
                            .padding()
                        }
                        .onChange(of: arViewModel.scrollIndex) { newIndex in
                            withAnimation {
                                proxy.scrollTo(newIndex, anchor: .center)
                            }
                        }
                    }
                }
                NavigationLink(
                    destination: DetailView(itemIndex: arViewModel.selectedItemIndex ?? 0),
                    isActive: $arViewModel.navigateToDetail
                ) { EmptyView() }
                .hidden()
            }
        }
    }
}

#Preview {
    ContentView()
}
