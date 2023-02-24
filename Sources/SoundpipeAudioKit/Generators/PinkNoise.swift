// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
// This file was auto-autogenerated by scripts and templates at http://github.com/AudioKit/AudioKitDevTools/

import AudioKit
import AudioKitEX
import AVFoundation
import CAudioKitEX

/// Faust-based pink noise generator
public class PinkNoise: Node {
    public var connections: [Node] { [] }
    public var avAudioNode = instantiate(instrument: "pink")

    /// Specification details for amplitude
    public static let amplitudeDef = NodeParameterDef(
        identifier: "amplitude",
        name: "Amplitude",
        address: akGetParameterAddress("PinkNoiseParameterAmplitude"),
        defaultValue: 1.0,
        range: 0.0 ... 1.0,
        unit: .generic
    )

    /// Amplitude. (Value between 0-1).
    @Parameter(amplitudeDef) public var amplitude: AUValue

    // MARK: - Initialization

    /// Initialize this noise node
    ///
    /// - Parameters:
    ///   - amplitude: Amplitude. (Value between 0-1).
    ///
    public init(
        amplitude: AUValue = amplitudeDef.defaultValue
    ) {
        setupParameters()

        stop()

        self.amplitude = amplitude
    }
}
