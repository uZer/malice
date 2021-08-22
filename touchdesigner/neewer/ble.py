#!/usr/bin/env python3
from bluepy import btle

macaddr='D1:28:C0:6B:32:34'

UUID_CHARACTERISTIC_FOUND1 = btle.UUID('00002a00-0000-1000-8000-00805f9b34fb')
UUID_CHARACTERISTIC_FOUND2 = btle.UUID('00002a01-0000-1000-8000-00805f9b34fb')
UUID_CHARACTERISTIC_FOUND3 = btle.UUID('00002a04-0000-1000-8000-00805f9b34fb')
UUID_CHARACTERISTIC_FOUND4 = btle.UUID('69400003-b5a3-f393-e0a9-e50e24dcca99')
UUID_CHARACTERISTIC_FOUND5 = btle.UUID('69400002-b5a3-f393-e0a9-e50e24dcca99')
UUID_CHARACTERISTIC_FOUND6 = btle.UUID('7f510005-b5a3-f393-e0a9-e50e24dcca9e')
UUID_CHARACTERISTIC_FOUND7 = btle.UUID('7f510006-b5a3-f393-e0a9-e50e24dcca9e')


connection = btle.Peripheral(macaddr, btle.ADDR_TYPE_RANDOM, 0)

# Discovery
#  for service in connection.getServices():
#      for charac in service.getCharacteristics():
#          print("UUID: " + str(charac.uuid))
#          print("Properties: " + str(charac.properties))
#          print("Supports Read: " + str(charac.supportsRead()))
#          print("Properties To String: " + str(charac.propertiesToString()))
#          print("Handle: " + str(charac.getHandle()))
#          print("")
#
connection.writeCharacteristic(14, b"\x78\x87\x02\x62\x26\x00")
connection.writeCharacteristic(14, b"\x78\x87\x02\x62\x16\x00")
connection.writeCharacteristic(14, b"\x78\x87\x02\x42\x26\x00")
connection.writeCharacteristic(14, b"\x78\x27\x02\x62\x26\x00")
#  for i in range(788702622689):
#  connection.writeCharacteristic(14, b'788702622689')
#  sendchar = connection.getCharacteristics(uuid=UUID_CHARACTERISTIC_FOUND1)
#  sendchar.write()
