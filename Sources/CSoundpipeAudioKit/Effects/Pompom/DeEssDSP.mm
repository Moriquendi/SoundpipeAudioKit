//
//  DeEssDSP.mm
//  
//
//  Created by Michał Śmiałko on 01/06/2022.
//

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

class DeEssKernel {
private:
    Float64 s1;
    Float64 s2;
    Float64 s3;
    Float64 s4;
    Float64 s5;
    Float64 s6;
    Float64 s7;
    Float64 m1;
    Float64 m2;
    Float64 m3;
    Float64 m4;
    Float64 m5;
    Float64 m6;
    Float64 c1;
    Float64 c2;
    Float64 c3;
    Float64 c4;
    Float64 c5;
    Float64 ratioA;
    Float64 ratioB;
    Float64 iirSampleA;
    Float64 iirSampleB;
    bool flip;
    uint32_t fpd;
    
public:
    
    int sampleRate;
    float raw_intensity;
    float raw_maxDess;
    float raw_frequency;
    
    void reset() {
        s1 = s2 = s3 = s4 = s5 = s6 = s7 = 0.0;
        m1 = m2 = m3 = m4 = m5 = m6 = 0.0;
        c1 = c2 = c3 = c4 = c5 = 0.0;
        ratioA = ratioB = 1.0;
        iirSampleA = 0.0;
        iirSampleB = 0.0;
        flip = false;
        fpd = 1.0; while (fpd < 16386) fpd = rand()*UINT32_MAX;
    }
    
    void processSample(float *in, float *out) {
        Float64 overallscale = 1.0;
        overallscale /= 44100.0;
        overallscale *= sampleRate;
        
        Float64 intensity = pow(raw_intensity,5)*(8192/overallscale);
        Float64 maxdess = 1.0 / pow(10.0,raw_maxDess/20);
        Float64 iirAmount = pow(raw_frequency,2)/overallscale;
        
        Float64 offset;
        Float64 sense;
        Float64 recovery;
        Float64 attackspeed;
        
        double inputSample = *in;
        
        
        if (fabs(inputSample)<1.18e-23) inputSample = fpd * 1.18e-17;
        
        s3 = s2;
        s2 = s1;
        s1 = inputSample;
        m1 = (s1-s2)*((s1-s2)/1.3);
        m2 = (s2-s3)*((s1-s2)/1.3);
        sense = fabs((m1-m2)*((m1-m2)/1.3));
        //this will be 0 for smooth, high for SSS
        attackspeed = 7.0+(sense*1024);
        //this does not vary with intensity, but it does react to onset transients
        
        sense = 1.0+(intensity*intensity*sense);
        if (sense > intensity) {sense = intensity;}
        //this will be 1 for smooth, 'intensity' for SSS
        recovery = 1.0+(0.01/sense);
        //this will be 1.1 for smooth, 1.0000000...1 for SSS
        
        offset = 1.0-fabs(inputSample);
        
        if (flip) {
            iirSampleA = (iirSampleA * (1 - (offset * iirAmount))) + (inputSample * (offset * iirAmount));
            if (ratioA < sense)
            {ratioA = ((ratioA*attackspeed)+sense)/(attackspeed+1.0);}
            else
            {ratioA = 1.0+((ratioA-1.0)/recovery);}
            //returny to 1/1 code
            if (ratioA > maxdess){ratioA = maxdess;}
            inputSample = iirSampleA+((inputSample-iirSampleA)/ratioA);
        }
        else {
            iirSampleB = (iirSampleB * (1 - (offset * iirAmount))) + (inputSample * (offset * iirAmount));
            if (ratioB < sense)
            {ratioB = ((ratioB*attackspeed)+sense)/(attackspeed+1.0);}
            else
            {ratioB = 1.0+((ratioB-1.0)/recovery);}
            //returny to 1/1 code
            if (ratioB > maxdess){ratioB = maxdess;}
            inputSample = iirSampleB+((inputSample-iirSampleB)/ratioB);
        } //have the ratio chase Sense
        
        flip = !flip;
        
        //begin 32 bit floating point dither
        int expon; frexpf((float)inputSample, &expon);
        fpd ^= fpd << 13; fpd ^= fpd >> 17; fpd ^= fpd << 5;
        inputSample += ((double(fpd)-uint32_t(0x7fffffff)) * 5.5e-36l * pow(2,expon+62));
        //end 32 bit floating point dither
        
        
        *out = inputSample;
    }
    
};

enum DeEssParameter : AUParameterAddress {
    DeEssParameterIntensity,
    DeEssParameterMaxDeEss,
    DeEssParameterFrequency,
};

class DeEssDSP : public SoundpipeDSPBase {
private:
    DeEssKernel *kernel0;
    DeEssKernel *kernel1;
    
    ParameterRamper intensityRamp;
    ParameterRamper maxDeEssRamp;
    ParameterRamper frequencyRamp;
    
public:
    DeEssDSP() {
        parameters[DeEssParameterIntensity] = &intensityRamp;
        parameters[DeEssParameterMaxDeEss] = &maxDeEssRamp;
        parameters[DeEssParameterFrequency] = &frequencyRamp;
    }
    
    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        
        kernel0 = new DeEssKernel();
        kernel0->reset();
        
        kernel1 = new DeEssKernel();
        kernel1->reset();
    }
    
    void deinit() override {
        SoundpipeDSPBase::deinit();
        delete kernel0;
        delete kernel1;
    }
    
    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        
        kernel0->reset();
        kernel1->reset();
    }
    
    void processSample(int channel, float *in, float *out) override {
        if (channel == 0) {
            kernel0->processSample(in, out);
        } else if (channel == 1) {
            kernel1->processSample(in, out);
        } else {
            // oops...
        }
    }
    
    void process(FrameRange range) override {
        kernel0->sampleRate = sampleRate;
        kernel0->raw_intensity = intensityRamp.getAndStep();
        kernel0->raw_maxDess = maxDeEssRamp.getAndStep();
        kernel0->raw_frequency = frequencyRamp.getAndStep();
        
        kernel1->sampleRate = sampleRate;
        kernel1->raw_intensity = kernel0->raw_intensity;
        kernel1->raw_maxDess = kernel0->raw_maxDess;
        kernel1->raw_frequency = kernel0->raw_frequency;
        
        // will call 'process sample' for each channel
        SoundpipeDSPBase::process(range);
    }
};

AK_REGISTER_DSP(DeEssDSP, "dees")
AK_REGISTER_PARAMETER(DeEssParameterIntensity)
AK_REGISTER_PARAMETER(DeEssParameterMaxDeEss)
AK_REGISTER_PARAMETER(DeEssParameterFrequency)
