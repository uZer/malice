#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import socket

server = ("127.0.0.1", 1664)
bufferSize = 1024

msgToSend = [
    # CCT: reset
    b"\x78\x87\x02\x62\x26\x89",

    # HCI: Yellow/green
    b"\x78\x86\x04\x4b\x00\x60\x49\xf6",

    # HCI: Blueish
    b"\x78\x86\x04\x16\x00\x11\x49\x72"
]

for msg in msgToSend:
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.sendto(msg, server)
