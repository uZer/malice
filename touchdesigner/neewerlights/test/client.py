#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import socket

server = ("127.0.0.1", 1664)
bufferSize = 1024

msgToSend = b'\x78\x87\x02\x62\x26\x89'

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.sendto(msgToSend, server)
