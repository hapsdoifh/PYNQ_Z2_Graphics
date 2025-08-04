from pynq import Overlay
from pynq import MMIO
from pynq.lib.video import *
import time

overlay = Overlay("/home/xilinx/base_wrapper.bit")  # Change to your bitstream file name
print(overlay.ip_dict.keys())
overlay.download()

graphicsIP = MMIO(0x43C10000,0x1000)

hdmi_out = overlay.video.hdmi_out
hdmi_out.configure(VideoMode(640, 480, 24))  

hdmi_out.start()

frame = hdmi_out.newframe()

fb_addr = frame.physical_address - 0x10000000
print(f'fb_addr: {hex(fb_addr)}')


frame.invalidate()      

hdmi_out.writeframe(frame)



time.sleep(10)

print("done")


graphicsIP.write(0, 0)
graphicsIP.write(4, 0)
graphicsIP.write(8, 0)
graphicsIP.write(16, fb_addr)

graphicsIP.write(12, 5 + (1 << 9))
graphicsIP.write(12, 5 + (1 << 8) + (1 << 9))

frame.invalidate()  

hdmi_out.writeframe(frame)

time.sleep(10)  

hdmi_out.close()
print("done")