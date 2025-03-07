//
//  OnboardingDataModel.swift
//  AR-FaceScrolling-iOS
//
//  Created by Joni Lassila on 7.2.2025.
//

import Foundation

struct OnboardingDataModel {
    var image: String
    var hint: String
    var heading: String
    var text: String
}

extension OnboardingDataModel {
    static var data: [OnboardingDataModel] = [
        OnboardingDataModel(image: "😉", hint: "Wink with your right eye!", heading: "Welcome to AR Face Scrolling based list App", text: "This example app uses ARKit to detect your facial expressions to navigate through a list of items. You can continue through this dialog by just winking your right eye. Go ahead and try it!"),
        OnboardingDataModel(image: "😉", hint: "Wink with your right eye to continue! Or press the button with your finger (boring).", heading: "Scrolling through", text: "To navigate through list of items wink with your right eye to scroll down, and wink with your left eye to scroll up."),
        OnboardingDataModel(image: "😮", hint: "Wink with your right eye to continue!", heading: "Opening list items", text: "To open the item from the list just open your mouth."),
        OnboardingDataModel(image: "😛", hint: "Wink with your right eye to continue!", heading: "Closing list items", text: "To close the item you've just opened, just put your tongue out."),
    ]
}
