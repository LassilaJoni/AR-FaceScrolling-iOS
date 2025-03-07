
//
//  OnboardingViewPure.swift
//  AR-FaceScrolling-iOS
//
//  Created by Joni Lassila on 7.2.2025.
//

import SwiftUI

struct OnboardingViewPure: View {
    var data: [OnboardingDataModel]
    var doneFunction: () -> ()
    
    @ObservedObject var arViewModel: ARTrackingViewModel
    @State private var curSlideIndex = 0

    var body: some View {
        ZStack {
            Color(.systemBackground).edgesIgnoringSafeArea(.all)

            ZStack(alignment: .center) {
                ForEach(0..<data.count) { i in
                    OnboardingStepView(data: self.data[i])
                        .offset(x: CGFloat(i) * UIScreen.main.bounds.width)
                        .offset(x: -CGFloat(curSlideIndex) * UIScreen.main.bounds.width)
                        .animation(.spring())
                }
            } //ZStack

            VStack {
                Spacer()
                HStack {
                    progressView() // ✅ Now calling a defined function
                    Spacer()
                    Button(action: nextButton) {
                        arrowView() // ✅ Now calling a defined function
                    }
                } //HStack
            } // Vstack
            .padding(20)
        } // ZStack
        .onAppear {
            arViewModel.isOnboardingActive = true
            arViewModel.onOnboardingNavigate = { direction in
                withAnimation {
                    if direction == .right {
                        if curSlideIndex < data.count - 1 {
                            curSlideIndex += 1
                        } else {
                            // Last slide reached: complete onboarding and call doneFunction()
                            arViewModel.completeOnboarding()
                            doneFunction()
                        }
                    } else if direction == .left, curSlideIndex > 0 {
                        curSlideIndex -= 1
                    }
                }
            }
        } // OnAppear

    } // Body

    // Next button to complete the onboarding after all the onboarding steps
    func nextButton() {
        if curSlideIndex == data.count - 1 {
            arViewModel.completeOnboarding()
            doneFunction()
        } else {
            withAnimation {
                curSlideIndex += 1
            }
        }
    }

    
    private func progressView() -> some View {
        HStack {
            ForEach(0..<data.count, id: \.self) { i in
                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundColor(curSlideIndex >= i ? Color(.systemIndigo) : Color(.systemGray))
            }
        }
    }

    // Arrow fow navigating through onboarding steps
    private func arrowView() -> some View {
        Group {
            if curSlideIndex == data.count - 1 {
                HStack {
                    Text("Done")
                        .font(.system(size: 27, weight: .medium, design: .rounded))
                        .foregroundColor(Color(.systemBackground))
                }
                .frame(width: 120, height: 50)
                .background(Color(.label))
                .cornerRadius(25)
            } else {
                Image(systemName: "arrow.right.circle.fill")
                    .resizable()
                    .foregroundColor(Color(.label))
                    .scaledToFit()
                    .frame(width: 50)
            }
        }
    }
}

/*
struct OnboardingViewPure_Previews: PreviewProvider {
    static let sample = OnboardingDataModel.data
    static var previews: some View {
        OnboardingViewPure(data: sample, doneFunction: { print("done") })
    }
}
*/
