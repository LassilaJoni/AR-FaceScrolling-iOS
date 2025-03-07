//
//  ContentView.swift
//  AR-FaceScrolling-iOS
//
//  Created by Joni Lassila on 6.2.2025.
//

import SwiftUI

    
struct ContentView: View {
    @StateObject private var arViewModel = ARTrackingViewModel()
    @State private var onboardingDone = false
    var data = OnboardingDataModel.data

    var body: some View {
        Group {
            // Show onboarding if not done
            if !onboardingDone {
                OnboardingViewPure(data: data, doneFunction: {
                    self.onboardingDone = true
                    arViewModel.completeOnboarding()
                }, arViewModel: arViewModel)
            } else {
                
                NavigationView {
                    ZStack {
                        Color.black.edgesIgnoringSafeArea(.all)
                        VStack {
                            ScrollViewReader { proxy in
                                ScrollView {
                                    VStack(spacing: 10) {
                                        ForEach(0..<10, id: \.self) { index in
                                            listItem(index)
                                        }
                                    } //VSTACK
                                    .padding()
                                } // ScrollView
                                .onChange(of: arViewModel.scrollIndex) { newIndex in
                                    DispatchQueue.main.async {
                                        withAnimation {
                                            proxy.scrollTo(newIndex, anchor: .center)
                                        }
                                    } //Dispatch
                                } //Onchange
                            } // ScrollViewReader
                        } // VSTACK
                    } // ZStack
                } // NavigationView
            } // Else
        } // Group
    } // Body
    private func listItem(_ index: Int) -> some View {
        // Wrap each navigation item to navigationlink
        NavigationLink(
            destination: DetailView(itemIndex: index),
            tag: index,
            selection: $arViewModel.selectedItemIndex
        ) {
            Text("Item \(index)")
                .frame(maxWidth: .infinity)
                .frame(height: UIScreen.main.bounds.height * 0.8)
                .background(arViewModel.selectedItemIndex == index
                            ? Color.green
                            : Color.blue.opacity(0.2))
                .cornerRadius(20)
        }
        .id(index)
    }
}

#Preview {
    ContentView()
}
