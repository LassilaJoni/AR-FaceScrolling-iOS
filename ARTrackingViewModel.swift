//
//  AREyeTrackingViewModel.swift
//  AR-Scrolling-iOS
//
//  Created by Joni Lassila on 6.2.2025.
//

import SwiftUI
import ARKit

// ARTrackingViewModel handles the ARKit face tracking, scrolling, detail view navigation and onboarding logic.
class ARTrackingViewModel: NSObject, ObservableObject, ARSessionDelegate {
    
    // MARK: Properties
    
    // ARsession
    private var arSession = ARSession()
    
    //Current index for scrolling
    @Published var scrollIndex: Int = 0
    // The index of the currently selected item.
    @Published var selectedItemIndex: Int? = nil
    // Trigger navigation to detail view
    @Published var navigateToDetail: Bool = false
    // Tracks the onboarding step
    @Published var onboardingStep: Int = 0
    // Indicate whether onboarding view is active
    @Published var isOnboardingActive: Bool = false
    // Callback for onboarding navigation events
    var onOnboardingNavigate: ((OnboardingDirection) -> Void)?
    
    // The interval between allowed scroll events. This prevents double inputs of events
    private let scrollCooldown: TimeInterval = 0.7
    
    private let itemCount: Int = 10
    
    // Thresholds for detecting every event.
    private let blinkThreshold: Float = 0.4
    private let mouthOpenThreshold: Float = 0.4
    private let tonqueOutThreshold: Float = 0.4
    
    // set the last scroll time. used to prevent double inputs.
    private var lastScrollTime: Date = Date()

    override init() {
        super.init()
        setupARSession()
    }
    
    // MARK: ARSession setup
    
    //Configure and start the ARsession if the frace tracking is supported on current device.
    private func setupARSession() {
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        arSession.delegate = self
        arSession.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    // MARK: ARSession methods
    
    // Called when ar session updates
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let faceAnchor = anchors.first as? ARFaceAnchor else { return }
        // Process on the main thread
        DispatchQueue.main.async {
            // Retrieve the blendshapes of ARKit
            let jawOpen = faceAnchor.blendShapes[.jawOpen] as? Float ?? 0.0
            let eyeBlinkLeft = faceAnchor.blendShapes[.eyeBlinkLeft] as? Float ?? 0.0
            let eyeBlinkRight = faceAnchor.blendShapes[.eyeBlinkRight] as? Float ?? 0.0
            let tongueOut = faceAnchor.blendShapes[.tongueOut] as? Float ?? 0.0

            // Check if facial expression matches exceeds the given threshold
            let isBlinkingLeft = eyeBlinkLeft > self.blinkThreshold
            let isBlinkingRight = eyeBlinkRight > self.blinkThreshold
            let isBlinking = isBlinkingLeft && isBlinkingRight
            let isMouthOpen = jawOpen > self.mouthOpenThreshold
            let isTongueOut = tongueOut > self.tonqueOutThreshold
            
            // Check the cooldown
            let now = Date()
            if now.timeIntervalSince(self.lastScrollTime) < self.scrollCooldown {
                return
            }
            
            // Check if tonque is out and item is selected, then navigate out of detailview
            if isTongueOut, self.selectedItemIndex != nil {
                self.selectedItemIndex = nil
                // Set cooldown
                self.lastScrollTime = now
                print("Navigate out of detail view")
                return
            }
            
            // Handle navigation if onboarding is active
            if self.isOnboardingActive {
                self.handleOnboardingBlink(isBlinkingLeft: isBlinkingLeft, isBlinkingRight: isBlinkingRight)
                self.lastScrollTime = now
            } else {
                self.didBlink(isBlinking: isBlinking, isBlinkingLeft: isBlinkingLeft, isBlinkingRight: isBlinkingRight) {
                    self.lastScrollTime = now
                }
                
                // If mouth is open, open the detail view of item
                if isMouthOpen, self.scrollIndex < self.itemCount - 1 {
                    self.selectCenterItem()
                }
            }
        }
    }
    
    /*
    Function for checking if user did blink.
     isBlinking, isBlinkingLeft, isBlinkingRight are used whether useer blinks given thing.
     completion is a closure after processing each of the blinks.
    */
    private func didBlink(isBlinking: Bool, isBlinkingLeft: Bool, isBlinkingRight: Bool, completion: @escaping () -> Void) {
        // If both eyes are blinking then do nothing, prevents accidentally scrolling
        if isBlinking {
            return
        // right eye blink, scroll down
        } else if isBlinkingRight, self.scrollIndex > 0 {
            self.scrollIndex -= 1
            completion()
            print("Scroll down to index \(self.scrollIndex)")
        // blink left eye, scroll up
        } else if isBlinkingLeft, self.scrollIndex < self.itemCount - 1 {
            self.scrollIndex += 1
            completion()
            print("Scroll up to index \(self.scrollIndex)")
        }
    }
    // Function for handling the onboarding.
    // Had to make a seperate function since couldn't find a way to integrate the didblink to onboarding.
    private func handleOnboardingBlink(isBlinkingLeft: Bool, isBlinkingRight: Bool) {
        let onboardingItemCount = 4

        if isBlinkingLeft {
            if onboardingStep < onboardingItemCount - 1 {
                onboardingStep += 1
            }
            onOnboardingNavigate?(.right)
            print("Onboarding step forward: \(onboardingStep)")
        } else if isBlinkingRight {
            if onboardingStep > 0 {
                onboardingStep -= 1
            }
            onOnboardingNavigate?(.left)
            print("Onboarding step back: \(onboardingStep)")
        }
    }
    
    // Function for changing onboarding to false
    func completeOnboarding() {
        self.isOnboardingActive = false
        onOnboardingNavigate = nil
        print("Onboarding completed")
    }
    
    // Select the current item
    private func selectCenterItem() {
        self.selectedItemIndex = self.scrollIndex
        self.navigateToDetail = true
        print("Opening detail view for index \(self.scrollIndex)")
    }
    
}

enum OnboardingDirection {
    case left, right
}
