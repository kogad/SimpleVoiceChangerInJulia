using PortAudio
using QML
using Observables

function get_input_devices(devices)
    idxs = Int[]
    for i in 1:length(devices)
        if devices[i].maxinchans > 0
            push!(idxs, i)
        end
    end

    return devices[idxs]
end

function get_output_devices(devices)
    idxs = Int[]
    for i in 1:length(devices)
        if devices[i].maxoutchans > 0
            push!(idxs, i)
        end
    end

    return devices[idxs]
end

function get_device_by_name(name, devices)
    idx = findfirst(x->x.name == name, devices)
    return devices[idx]
end

const device_list = PortAudio.devices()



const sl1_val = Observable(1.0)
const sl2_val = Observable(1.0)
const sw_val = Observable(false)

const input_devices = get_input_devices(device_list)
const output_devices = get_output_devices(device_list)

const input_names = getfield.(input_devices, :name)
const output_names = getfield.(output_devices, :name)
const input_name = Observable(input_names[1])
const output_name = Observable(output_names[1])

load("app.qml", observables=JuliaPropertyMap("sl1_val" => sl1_val, "sl2_val" => sl2_val, "sw_val" => sw_val, "input_name" => input_name, "output_name" => output_name), input_names=input_names, output_names=output_names)
exec_async()


include("./voicechanger.jl")

const bsize = 25600
const dioopt = DioOption(f0floor=71.0, f0ceil=800.0, channels_in_octave=2.0, period=period, speed=1)

# ---------------------------

while sw_val[] == false
    sleep(0.2)
end

input_device = get_device_by_name(input_name[], input_devices)
output_device = get_device_by_name(output_name[], output_devices)

stream_in  = PortAudioStream(input_device, 1, 0, latency=0.1)
stream_out = PortAudioStream(output_device, 0, 2, latency=0.1)

println("Press Ctrl-C to quit.")
while true
    if sw_val[]
        sig_in = read(stream_in, bsize) 
        vp = VoiceParameter(sig_in, dioopt)
        pitchshift!(vp, sl1_val[])
        shift_spectrum_envelop!(vp, sl2_val[])
        sig_out = synthesis(vp)
        write(stream_out, sig_out)
    else
        while sw_val[] == false
            sleep(0.2)
        end
        global input_device = get_device_by_name(input_name[], input_devices)
        global output_device = get_device_by_name(output_name[], output_devices)

        global stream_in  = PortAudioStream(input_device, 1, 0, latency=0.1)
        global stream_out = PortAudioStream(output_device, 0, 2, latency=0.1)
    end
end