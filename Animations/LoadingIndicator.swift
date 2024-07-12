//
//  LoadingBuilder.swift
//  SwiftfulLoadingIndicators
//
//  Created by Nick Sarno on 1/12/21.
//

import SwiftUI

public struct LoadingIndicator: View {
    
    let animation: LoadingAnimation
    let size: CGFloat
    let speed: Double
    let color: Color
    
    public init(
        animation: LoadingAnimation = .threeBalls,
        color: Color = .primary,
        size: Size = .medium,
        speed: Speed = .normal) {
            self.animation = animation
            self.size = size.rawValue
            self.speed = speed.rawValue
            self.color = color
    }
    
    public var body: some View {
        let randomAnimation = LoadingAnimation.allCases.randomElement() ?? .threeBalls // Fallback to a default animation
        
        switch randomAnimation {
        case .threeBalls: return AnyView(LoadingThreeBalls(color: color, size: size, speed: speed))
        case .threeBallsRotation: return AnyView(LoadingThreeBallsRotation(color: color, size: size, speed: speed))
        case .threeBallsBouncing: return AnyView(LoadingThreeBallsBouncing(color: color, size: size, speed: speed))
        case .threeBallsTriangle: return AnyView(LoadingThreeBallsTriangle(color: color, size: size, speed: speed))
        case .fiveLines: return AnyView(LoadingFiveLines(color: color, size: size, speed: speed))
        case .fiveLinesChronological: return AnyView(LoadingFiveLinesChronological(color: color, size: size, speed: speed))
        case .fiveLinesWave: return AnyView(LoadingFiveLinesWave(color: color, size: size, speed: speed))
        case .fiveLinesCenter: return AnyView(LoadingFiveLinesCenter(color: color, size: size, speed: speed))
        case .fiveLinesPulse: return AnyView(LoadingFiveLinesPulse(color: color, size: size, speed: speed))
        case .pulse: return AnyView(LoadingPulse(color: color, size: size, speed: speed))
        case .pulseOutline: return AnyView(LoadingPulseOutline(color: color, size: size, speed: speed))
        case .pulseOutlineRepeater: return AnyView(LoadingPulseOutlineRepeater(color: color, size: size, speed: speed))
        case .circleTrim: return AnyView(LoadingCircleTrim(color: color, size: size, speed: speed))
        case .circleRunner: return AnyView(LoadingCircleRunner(color: color, size: size, speed: speed))
        case .circleBlinks: return AnyView(LoadingCircleBlinks(color: color, size: size, speed: speed))
        case .circleBars: return AnyView(LoadingCircleBars(color: color, size: size, speed: speed))
        case .doubleHelix: return AnyView(LoadingDoubleHelix(color: color, size: size, speed: speed))
        case .bar: return AnyView(LoadingBar(color: color, size: size, speed: speed))
        case .barStripes: return AnyView(LoadingBarStripes(color: color, size: size, speed: speed))
        case .text: return AnyView(LoadingText(color: color, size: size, speed: speed))
        case .heart: return AnyView(LoadingHeart(color: color, size: size, speed: speed))
        }
    }

    
    public enum LoadingAnimation: String, CaseIterable {
        case threeBalls
        case threeBallsRotation
        case threeBallsBouncing
        case threeBallsTriangle
        case fiveLines
        case fiveLinesChronological
        case fiveLinesWave
        case fiveLinesCenter
        case fiveLinesPulse
        case pulse
        case pulseOutline
        case pulseOutlineRepeater
        case circleTrim
        case circleRunner
        case circleBlinks
        case circleBars
        case doubleHelix
        case bar
        case barStripes
        case text
        case heart
    }
    
    public enum Speed: Double, CaseIterable {
        case slow = 1.0
        case normal = 0.5
        case fast = 0.25
        
        var stringRepresentation: String {
            switch self {
            case .slow: return ".slow"
            case .normal: return ".normal"
            case .fast: return ".fast"
            }
        }
    }

    public enum Size: CGFloat, CaseIterable {
        case small = 25
        case medium = 50
        case large = 100
        case extraLarge = 150
        
        var stringRepresentation: String {
            switch self {
            case .small: return ".small"
            case .medium: return ".medium"
            case .large: return ".large"
            case .extraLarge: return ".extraLarge"
            }
        }
    }
}
