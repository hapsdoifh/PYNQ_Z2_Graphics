from pynq import Overlay
from pynq import MMIO
from pynq.lib.video import *
import time

overlay = Overlay("/home/xilinx/base_wrapper.bit")  # Change to your bitstream file name
print(overlay.ip_dict.keys())
overlay.download()

graphicsIP = MMIO(0x43C10000,0x1000)

hdmi_out = overlay.video.hdmi_out
hdmi_out.configure(VideoMode(1920, 1080, 24))

hdmi_out.start()
time.sleep(3)

frame = hdmi_out.newframe()
#frame[0:250, 0:300] = [255, 0, 0]


fb_addr = frame.physical_address - 0x10000000
print(f'fb_addr: {hex(fb_addr)}')


#frame.invalidate()

hdmi_out.writeframe(frame)

print("done setup")

while True:
    result = input("coords: ")
    if result == "exit":
        break
    result = [int(x) for x in result.split(',')]
    print(result)
    x0, y0, x1, y1 = result
    graphicsIP.write(0, x0)
    graphicsIP.write(4, y0)
    graphicsIP.write(8, x1)
    graphicsIP.write(16, fb_addr)

    graphicsIP.write(12, y1 + (1 << 17))
    graphicsIP.write(12, y1 + (1 << 17) + (1 << 16))
    # graphicsIP.write(12, y1 + (1 << 17))

    # frame.invalidate()

    # hdmi_out.writeframe(frame)
    print(hex(graphicsIP.read(0)))
    print(hex(graphicsIP.read(4)))
    print(hex(graphicsIP.read(8)))
    print(hex(graphicsIP.read(12)))
    print(hex(graphicsIP.read(16)))
    print(hex(graphicsIP.read(20)))
    print(hex(graphicsIP.read(24)))
    print(hex(graphicsIP.read(28)))



hdmi_out.close()
print("done")
