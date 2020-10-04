using WORLD
using SampledSignals

const period = 5.0

mutable struct VoiceParameter
    f0::Vector{Float64}
    spec::Matrix{Float64}
    aperiodicity::Matrix{Float64}

    fs::Int64
    num_frames::Int64

    function VoiceParameter(buf, dioopt)
        x = vec(convert.(Float64, buf.data))

        fs = Int(buf.samplerate)
        num_frames = nframes(buf)
        f0, timeaxis = dio(x, fs, dioopt)
        f0 = stonemask(x, fs, timeaxis, f0)
        spec = cheaptrick(x, fs, timeaxis, f0)
        aperiodicity = d4c(x, fs, timeaxis, f0)

        new(f0, spec, aperiodicity, fs, num_frames)
    end
end


function pitchshift!(vp, n)
    vp.f0 *= n
end

function shift_spectrum_envelop!(vp, n)
    len = size(vp.spec)[1]
    idxs = 1:len
    if n > 1
        idxs = len:-1:1
    end
    for i in idxs
        j = clamp(round(Int,i/n), 1, len)
        vp.spec[i, :] = vp.spec[j, :]
    end
end

function WORLD.synthesis(vp::VoiceParameter) 
    y = synthesis(vp.f0, vp.spec, vp.aperiodicity, period, vp.fs, vp.num_frames)
    return SampleBuf(y, vp.fs)
end

function voice2wav(vp, len)
    y = synthesis(vp.f0, vp.spec, vp.aperiodicity, period, vp.fs, len)
    clamp!(y, typemin(Int16), typemax(Int16))
    wav = WAVArray(vp.fs, trunc.(Int16, y))

    return wav
end