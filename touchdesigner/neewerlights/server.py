#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import logging
import socket
import sys
from bluepy import btle

class NeewerServer:
    """
    A small UDP server to communicate with Neewer RGB 660 lights
    """

    def __init__(self, neewerAddress, listenAddress="0.0.0.0", listenPort=1664):
        """
        Init Neewer Server

        :param neewerAddress: Hardware address of the Neewer light
        :param listenAddress: Listening address for the server.
        :param listenPort: Listening port for the server.
        """
        self._btconnection = None
        self._udpsocket = None
        self.neewerAddress = neewerAddress
        self.listenAddress = listenAddress
        self.listenPort = listenPort


    def startUDPServer(self):
        logging.info("Starting UDP server...")

        try:
            self._socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            self._socket.bind((self.listenAddress, self.listenPort))
            logging.info('UDP Server started.')
            logging.info('Please send your messages to {}:{}'.format(
                self.listenAddress, self.listenPort
            ))
            while(True):
                addr = self._socket.recvfrom(1024)
                command = addr[0]
                address = addr[1]
                logging.debug("{} - {}".format(address, command))
                self.neewerSend(command, 14)

        except Exception as e:
            logging.error('UDP Server failed: {}'.format(e))
            self._socket = None
            return False

        return True


    def stopUDPServer(self):
        """
        Stop receiving UDP messages
        """
        logging.info("Stopping UDP Server...")

        try:
            self._socket.close()

        except Exception:
            pass

        self._socket = None


    def neewerConnect(self, btAdapter=0):
        logging.debug("Connecting to Neewer device...")

        try:
            connection = btle.Peripheral(self.neewerAddress,
                                         btle.ADDR_TYPE_RANDOM, btAdapter)
            self._btconnection = connection.withDelegate(self)
            logging.info('Connected to Neewer device {}'.format(
                self.neewerAddress
            ))

        except RuntimeError as e:
            logging.error('Connection failed : {}'.format(e))
            return False

        return True


    def neewerDisconnect(self):
        """
        Disconnect from Neewer Device
        """
        logging.debug("Disconnecting...")

        try:
            self._btconnection.disconnect()

        except btle.BTLEException:
            pass

        self._btconnection = None


    def neewerSend(self, message, handle=14):
        """
        Send bytes to Neewer Device

        :param message: bytes to pass to the device
        :param handle: handle to use to communicate
        """

        try:
            self._btconnection.writeCharacteristic(handle, message)

        except Exception as e:
            logging.error('Failed to send message: {}'.format(e))


    def neewerScan(self):
        """
        Scan the Neewer device for Services and Characteristics
        """

        try:
            for service in self._btconnection.getServices():
                for charac in service.getCharacteristics():
                    logging.info("UUID: " + str(charac.uuid))
                    logging.info("Properties: " + str(charac.properties))
                    logging.info("Supports Read: " + str(charac.supportsRead()))
                    logging.info("Properties To String: " + str(charac.propertiesToString()))
                    logging.info("Handle: " + str(charac.getHandle()))
                    logging.info("")

        except Exception as e:
            logging.error('Failed to scan device: {}'.format(e))


def main():
    logging.basicConfig(format='%(levelname)s:%(message)s', level=logging.DEBUG)
    neewerAddress = "D1:28:C0:6B:32:34"
    listenAddress = "0.0.0.0"
    listenPort = 1664

    nee = NeewerServer(neewerAddress, listenAddress, listenPort)
    nee.neewerConnect()
    #  nee.neewerScan()
    nee.startUDPServer()


if __name__ == '__main__':
    sys.exit(main())
