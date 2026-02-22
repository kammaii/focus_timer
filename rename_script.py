import os
import unicodedata

os.chdir('/Users/jwpark/dev/focus_timer/assets/sounds')
files = os.listdir('.')

for f in files:
    norm_f = unicodedata.normalize('NFC', f)
    if "띠딩" in norm_f: os.rename(f, "ding_ding.mp3")
    elif "띠링" in norm_f: os.rename(f, "ding_ring.mp3")
    elif "예~" in norm_f: os.rename(f, "yeah.mp3")
    elif "따단" in norm_f: os.rename(f, "tada.mp3")
    elif "8.빠밤" in norm_f or ("8." in norm_f and "빠밤" in norm_f): os.rename(f, "ba_bam.wav")
    elif "빠바밤" in norm_f: os.rename(f, "ba_ba_bam.wav")
    elif "촤라라" in norm_f: os.rename(f, "chwarara.wav")
    
print(os.listdir('.'))
