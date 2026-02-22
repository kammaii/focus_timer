import wave
import struct
import math

def generate_beep(filename, freq=440.0, duration=1.0, volume=0.5):
    sample_rate = 44100.0
    with wave.open(filename, 'w') as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(sample_rate)
        
        for i in range(int(duration * sample_rate)):
            # Add simple envelope to avoid clicks
            env = 1.0
            if i < 4410:
                env = i / 4410.0
            elif i > (duration * sample_rate) - 4410:
                env = ((duration * sample_rate) - i) / 4410.0
                
            value = int(volume * env * 32767.0 * math.sin(2.0 * math.pi * freq * i / sample_rate))
            data = struct.pack('<h', value)
            f.writeframesraw(data)

# generated sound 1: Focus end (high pitched, double beep type conceptually but just a clean tone for now)
generate_beep('assets/sounds/focus_end.wav', 659.25, 1.5, 0.4) # E5
# generated sound 2: Rest end (mid pitch)
generate_beep('assets/sounds/rest_end.wav', 523.25, 1.5, 0.4) # C5
