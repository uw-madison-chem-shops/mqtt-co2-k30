import settings

import sys
import machine
from machine import Pin, I2C
import network
import time
import struct

import mqtt_as
mqtt_as.MQTT_base.DEBUG = True

from homie.constants import FALSE, TRUE, BOOLEAN, FLOAT, STRING
from homie.device import HomieDevice
from homie.node import HomieNode
from homie.property import HomieNodeProperty
from uasyncio import get_event_loop, sleep_ms


def read_co2():
    for _ in range(10):
        try:
            i2c = I2C(scl=Pin(4), sda=Pin(5), freq=10000)
            i2c.writeto(104, "\x22\x00\x08\x2A".encode())
            time.sleep_ms(100)
            out = i2c.readfrom(104, 4)
            out = struct.unpack(">h", out[1:3])[0]
            return out
        except Exception as e:
            time.sleep_ms(250)
            print(e)


class K30(HomieNode):
    def __init__(self, name="k30", device=None):
        super().__init__(id="k30", name=name, type="sensor")
        self.device = device
        self.co2 = HomieNodeProperty(
            id="co2", name="co2", unit="ppm", settable=False, datatype=FLOAT, default=0,
        )
        self.add_property(self.co2)
        self.uptime = HomieNodeProperty(
            id="uptime", name="uptime", settable=False, datatype=STRING, default="PT0S"
        )
        self.add_property(self.uptime)
        loop = get_event_loop()
        loop.create_task(self.update_data())
        loop.create_task(self.reset())
        self.led = Pin(0, Pin.OUT)
        self.start = time.time()
        self.last_onine = 0

    async def reset(self):
        await sleep_ms(5 * 60 * 1000)   # 5 minutes
        machine.reset()

    async def update_data(self):
        # wait until connected
        for _ in range(60):
            await sleep_ms(1_000)
            if self.device.mqtt.isconnected():
                break
        # loop forever
        while self.device.mqtt.isconnected():
            self.last_onine = time.time()
            self.led.value(0)  # on
            self.co2.data = read_co2()
            self.uptime.data = self.get_uptime()
            self.led.value(1)  # on
            await sleep_ms(5000)
        while not self.device.mqtt.isconnected():
            self.led.value(0)  # illuminate onboard LED
            await sleep_ms(100)
            self.led.value(1)  # onboard LED off
            await sleep_ms(1000)

    def get_uptime(self):
        diff = int(time.time() - self.start)
        out = "PT"
        # hours
        if diff // 3600:
            out += str(diff // 3600) + "H"
            diff %= 3600
        # minutes
        if diff // 60:
            out += str(diff // 60) + "M"
            diff %= 60
        # seconds
        out += str(diff) + "S"
        return out


def main():
    # homie
    homie = HomieDevice(settings)
    homie.add_node(K30(device=homie))
    homie.run_forever()


if __name__ == "__main__":
    main()
