//
//  OnboardingStepView.swift
//  AR-FaceScrolling-iOS
//
//  Created by Joni Lassila on 7.2.2025.
//

import SwiftUI

struct OnboardingStepView: View {
    var data: OnboardingDataModel
    
    var body: some View {
        VStack {
            Spacer()
            Text(data.image)
                .font(.system(size:80))
                .scaledToFit()
            Spacer()
            Text(data.heading)
                .font(.system(size: 25, design: .rounded))
                .multilineTextAlignment(.center)
                .fontWeight(.bold)
                .padding(.bottom, 20)
            Text(data.hint)
                .font(.system(size: 17, design: .default))
                .foregroundColor(.secondary)
                .padding(.bottom, 10)
            Text(data.text)
                .font(.system(size: 17, design: .rounded))
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
        }
        //padding bottom and right and left
        .padding(.bottom, 100)
        .padding(.horizontal, 20)
        .contentShape(Rectangle())
    }
}

struct OnboardingStepView_Previews: PreviewProvider {
    static var data = OnboardingDataModel.data[0]
    static var previews: some View {
        OnboardingStepView(data: data)
    }
}
