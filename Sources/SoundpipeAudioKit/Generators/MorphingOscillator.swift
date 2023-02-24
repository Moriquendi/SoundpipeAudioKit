// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
// This file was auto-autogenerated by scripts and templates at http://github.com/AudioKit/AudioKitDevTools/

import AudioKit
import AudioKitEX
import AVFoundation
import CAudioKitEX

/// This is an oscillator with linear interpolation that is capable of morphing
/// between an arbitrary number of wavetables.
///
public class MorphingOscillator: Node {
    public var connections: [Node] { [] }
    public var avAudioNode = instantiate(instrument: "morf")

    fileprivate var waveformArray = [Table]()

    /// Specification details for frequency
    public static let frequencyDef = NodeParameterDef(
        identifier: "frequency",
        name: "Frequency",
        address: akGetParameterAddress("MorphingOscillatorParameterFrequency"),
        defaultValue: 440,
        range: 0.0 ... 22050.0,
        unit: .hertz
    )

    /// Frequency (in Hz)
    @Parameter(frequencyDef) public var frequency: AUValue

    /// Specification details for amplitude
    public static let amplitudeDef = NodeParameterDef(
        identifier: "amplitude",
        name: "Amplitude",
        address: akGetParameterAddress("MorphingOscillatorParameterAmplitude"),
        defaultValue: 0.5,
        range: 0.0 ... 1.0,
        unit: .hertz
    )

    /// Amplitude (typically a value between 0 and 1).
    @Parameter(amplitudeDef) public var amplitude: AUValue

    /// Specification details for index
    public static let indexDef = NodeParameterDef(
        identifier: "index",
        name: "Index",
        address: akGetParameterAddress("MorphingOscillatorParameterIndex"),
        defaultValue: 0.0,
        range: 0.0 ... 3.0,
        unit: .hertz
    )

    /// Index of the wavetable to use (fractional are okay).
    @Parameter(indexDef) public var index: AUValue

    /// Specification details for detuningOffset
    public static let detuningOffsetDef = NodeParameterDef(
        identifier: "detuningOffset",
        name: "Detuning offset",
        address: akGetParameterAddress("MorphingOscillatorParameterDetuningOffset"),
        defaultValue: 0,
        range: -1000.0 ... 1000.0,
        unit: .hertz
    )

    /// Frequency offset in Hz.
    @Parameter(detuningOffsetDef) public var detuningOffset: AUValue

    /// Specification details for detuningMultiplier
    public static let detuningMultiplierDef = NodeParameterDef(
        identifier: "detuningMultiplier",
        name: "Detuning multiplier",
        address: akGetParameterAddress("MorphingOscillatorParameterDetuningMultiplier"),
        defaultValue: 1,
        range: 0.9 ... 1.11,
        unit: .generic
    )

    /// Frequency detuning multiplier
    @Parameter(detuningMultiplierDef) public var detuningMultiplier: AUValue

    // MARK: - Initialization

    /// Initialize this Morpher node
    ///
    /// - Parameters:
    ///   - waveformArray: An array of exactly four waveforms
    ///   - frequency: Frequency (in Hz)
    ///   - amplitude: Amplitude (typically a value between 0 and 1).
    ///   - index: Index of the wavetable to use (fractional are okay).
    ///   - detuningOffset: Frequency offset in Hz.
    ///   - detuningMultiplier: Frequency detuning multiplier
    ///
    public init(
        waveformArray: [Table] = [Table(.triangle), Table(.square), Table(.sine), Table(.sawtooth)],
        frequency: AUValue = frequencyDef.defaultValue,
        amplitude: AUValue = amplitudeDef.defaultValue,
        index: AUValue = indexDef.defaultValue,
        detuningOffset: AUValue = detuningOffsetDef.defaultValue,
        detuningMultiplier: AUValue = detuningMultiplierDef.defaultValue
    ) {
        setupParameters()

        stop()

        for (i, waveform) in waveformArray.enumerated() {
            au.setWavetable(waveform.content, index: i)
        }
        self.waveformArray = waveformArray
        self.frequency = frequency
        self.amplitude = amplitude
        self.index = index
        self.detuningOffset = detuningOffset
        self.detuningMultiplier = detuningMultiplier
    }
}
