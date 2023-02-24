// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
// This file was auto-autogenerated by scripts and templates at http://github.com/AudioKit/AudioKitDevTools/
// Updated manually for DynamicWaveformNode

import AudioKit
import AudioKitEX
import AVFoundation
import CAudioKitEX

/// Table-lookup tremolo with linear interpolation
public class Tremolo: DynamicWaveformNode {
    let input: Node

    /// Connected nodes
    public var connections: [Node] { [input] }

    /// Underlying AVAudioNode
    public var avAudioNode = instantiate(effect: "trem")

    fileprivate var waveform: Table?

    /// Callback when the wavetable is updated
    public var waveformUpdateHandler: ([Float]) -> Void = { _ in }

    // MARK: - Parameters

    /// Specification details for frequency
    public static let frequencyDef = NodeParameterDef(
        identifier: "frequency",
        name: "Frequency",
        address: akGetParameterAddress("TremoloParameterFrequency"),
        defaultValue: 10.0,
        range: 0.0 ... 100.0,
        unit: .hertz
    )

    /// Frequency (Hz)
    @Parameter(frequencyDef) public var frequency: AUValue

    /// Specification details for depth
    public static let depthDef = NodeParameterDef(
        identifier: "depth",
        name: "Depth",
        address: akGetParameterAddress("TremoloParameterDepth"),
        defaultValue: 1.0,
        range: 0.0 ... 1.0,
        unit: .percent
    )

    /// Depth
    @Parameter(depthDef) public var depth: AUValue

    // MARK: - Initialization

    /// Initialize this tremolo node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - frequency: Frequency (Hz)
    ///   - depth: Depth
    ///   - waveform: Shape of the curve
    ///
    public init(
        _ input: Node,
        frequency: AUValue = frequencyDef.defaultValue,
        depth: AUValue = depthDef.defaultValue,
        waveform: Table = Table(.positiveSine)
    ) {
        self.input = input

        setupParameters()

        au.setWavetable(waveform.content)

        self.frequency = frequency
        self.depth = depth
        self.waveform = waveform
    }

    // MARK: - DynamicWaveformNode Protocol methods

    /// Sets the wavetable of the oscillator node
    /// - Parameter waveform: The waveform of oscillation
    public func setWaveform(_ waveform: Table) {
        au.setWavetable(waveform.content)
        self.waveform = waveform
        waveformUpdateHandler(waveform.content)
    }

    /// Gets the floating point values stored in the oscillator's wavetable
    public func getWaveformValues() -> [Float] {
        return waveform?.content ?? []
    }

    /// Set the waveform change handler
    /// - Parameter handler: Closure with an array of floats as the argument
    public func setWaveformUpdateHandler(_ handler: @escaping ([Float]) -> Void) {
        waveformUpdateHandler = handler
    }
}
