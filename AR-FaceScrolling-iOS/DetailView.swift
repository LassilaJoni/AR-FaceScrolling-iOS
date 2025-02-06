//
//  DetailView.swift
//  AR-Scrolling-iOS
//
//  Created by Joni Lassila on 6.2.2025.
//

import SwiftUI

struct DetailView: View {
    let itemIndex: Int

    var body: some View {
        VStack {
            Text("Selected Item \(itemIndex)")
                .font(.title)
                .padding()

            Spacer()
        }
        .navigationTitle("Item \(itemIndex)")
    }
}

#Preview {
    DetailView(itemIndex: 0)
}
