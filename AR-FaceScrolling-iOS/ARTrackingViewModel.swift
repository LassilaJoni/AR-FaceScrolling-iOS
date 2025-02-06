//
//  AREyeTrackingViewModel.swift
//  AR-Scrolling-iOS
//
//  Created by Joni Lassila on 6.2.2025.
//

import SwiftUI
import ARKit

class ARTrackingViewModel: NSObject, ObservableObject, ARSessionDelegate {
    
    private var arSession = ARSession()
    
    // Current item index of the scroll
    @Published var scrollIndex: Int = 0
    // Selected item index
    @Published var selectedItemIndex: Int? = nil
    // Triggers the navigation to the detail view
    @Published var navigateToDetail: Bool = false
    
    // Scroll cooldown, fixes double inputs
    private let scrollCooldown: TimeInterval = 0.7
    private let itemCount: Int = 10
    
    //thresholds for minimum values to detect blink or mouth open
    private let blinkThreshold: Float = 0.4
    private let mouthOpenThreshold: Float = 0.4
    // track the last scroll
    private var lastScrollTime: Date = Date()

    
    override init() {
        super.init()
        setupARSession()
    }
    
    // Setup the ARkit session for tracking, resets the tracking and existing anchors that might be in cache
    private func setupARSession() {
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        arSession.delegate = self
        arSession.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        
        guard let faceAnchor = anchors.first as? ARFaceAnchor else { return }
        // Updates to the main thread
        DispatchQueue.main.async {
            // EXtract the expressions from ARkit
            let jawOpen = faceAnchor.blendShapes[.jawOpen] as? Float ?? 0.0
            let eyeBlinkLeft = faceAnchor.blendShapes[.eyeBlinkLeft] as? Float ?? 0.0
            let eyeBlinkRight = faceAnchor.blendShapes[.eyeBlinkRight] as? Float ?? 0.0

            // Detect if blinking left,right or blinking both eyes
            let isBlinkingLeft = eyeBlinkLeft > self.blinkThreshold
            let isBlinkingRight = eyeBlinkRight > self.blinkThreshold
            let isBlinking = isBlinkingLeft && isBlinkingRight
    
            let isMouthOpen = jawOpen > self.mouthOpenThreshold

            // Check if enough time has passed since the last scroll time
            let now = Date()
            if now.timeIntervalSince(self.lastScrollTime) < self.scrollCooldown {
                return
            }

            // Logic for if blinking both eyes navigate out of the detail view
            // If blinking with left scroll up and if with right scroll down
            // If mouth is open select the item in the list that is currently in view
             if isBlinking {
                self.navigateToDetail = false
            }
            else if isBlinkingLeft, self.scrollIndex > 0 {
                self.scrollIndex -= 1
                self.lastScrollTime = now  // ⏳ Reset cooldown
                print("scroll up to index \(self.scrollIndex)")
            } else if isBlinkingRight && self.scrollIndex < self.itemCount - 1 {
                self.scrollIndex += 1
                self.lastScrollTime = now  
                print("scroll down to index \(self.scrollIndex)")
            }
            else if isMouthOpen, self.scrollIndex < self.itemCount - 1 {
                self.selectCenterItem()
            }
        }
    }
    
    // Function for selecting the center item that is currently in view. Navigates to the detail view
    private func selectCenterItem() {
        self.selectedItemIndex = self.scrollIndex
        self.navigateToDetail = true
        print("Opening detailview for index \(self.scrollIndex)")
    }
}
