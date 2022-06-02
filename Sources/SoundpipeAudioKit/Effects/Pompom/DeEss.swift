//
//  DeEss.swift
//
//
//  Created by Michał Śmiałko on 01/06/2022.
//

import AudioKit
import AudioKitEX
import AVFoundation
import CAudioKitEX

public class DeEss: Node {
    let input: Node

    /// Connected nodes
    public var connections: [Node] { [input] }

    /// Underlying AVAudioNode
    public var avAudioNode = instantiate(effect: "dees")

    // MARK: - Parameters

    public static let intensityDef = NodeParameterDef(
        identifier: "intensity",
        name: "Intensity",
        address: akGetParameterAddress("DeEssParameterIntensity"),
        defaultValue: 0.6,
        range: 0.0 ... 1.0,
        unit: .percent) // TODO: ???
    @Parameter(intensityDef) public var intensity: AUValue

    public static let maxDeEssDef = NodeParameterDef(
        identifier: "maxdeess",
        name: "MaxDeEss",
        address: akGetParameterAddress("DeEssParameterMaxDeEss"),
        defaultValue: -16,
        range: -48 ... 0.0,
        unit: .customUnit) // TODO: ???
    @Parameter(maxDeEssDef) public var maxDeEss: AUValue

    public static let frequencyDef = NodeParameterDef(
        identifier: "frequency",
        name: "Frequency",
        address: akGetParameterAddress("DeEssParameterFrequency"),
        defaultValue: 0.6,
        range: 0.0 ... 1.0,
        unit: .hertz) // TODO: ???
    @Parameter(frequencyDef) public var frequency: AUValue

    // MARK: - Initialization

    /// Initialize this compressor node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - intensity: ...
    ///   - maxDeEss:
    ///   - frequency:...
    ///
    public init(
        _ input: Node,
        intensity: AUValue = intensityDef.defaultValue,
        maxDeEss: AUValue = maxDeEssDef.defaultValue,
        frequency: AUValue = frequencyDef.defaultValue)
    {
        self.input = input
        setupParameters()
        self.intensity = intensity
        self.maxDeEss = maxDeEss
        self.frequency = frequency
    }
}
