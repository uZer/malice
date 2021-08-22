#!/usr/bin/env python3

import logging
import socket
import sys
from bluepy import btle

class NeewerServer:
    """
    A small UDP server to communicate with Neewer RGB 660
    """

    def __init__(self, neewerAddress, listenAddress="0.0.0.0", listenPort=1664):
        """
        :param neewerAddress: Hardware address of the Neewer light
        :param listenAddress: Listening address for the server.
        :param listenPort: Listening port for the server.
        """
        self._btconnection = None
        self._udpsocket = None
        self.neewerAddress = neewerAddress
        self.listenAddress = listenAddress
        self.listenPort = listenPort


    def udpServe(self):
        logging.debug("Launching UDP server...")

        try:
            self._socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            self._socket.bind((self.listenAddress, self.listenPort))
            logging.info("Server is running!")
            logging.info("Please send your messages to {}:{}".format(
                self.listenAddress, self.listenPort))
            while(True):
                addr = self._socket.recvfrom(1024)
                command = addr[0]
                address = addr[1]
                logging.debug("{} running command: {}".format(address, command))
                self.neewerSend(command)


        except Exception as e:
            logging.error('UDP Server failed: {}'.format(e))
            self._socket = None
            return False


    def neewerConnect(self, btAdapter=0):
        logging.debug("Connecting to Neewer device...")

        try:
            connection = btle.Peripheral(self.neewerAddress,
                                         btle.ADDR_TYPE_RANDOM, btAdapter)
            self._btconnection = connection.withDelegate(self)

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


    def neewerSend(self, message, handler=14):
        self._btconnection.writeCharacteristic(handler, message)


def main():
    logging.basicConfig(format='%(levelname)s:%(message)s', level=logging.DEBUG)
    neewerAddress = "D1:28:C0:6B:32:34"
    listenAddress = "0.0.0.0"
    listenPort = 1664

    nee = NeewerServer(neewerAddress, listenAddress, listenPort)
    nee.neewerConnect()
    logging.info('Connected to Neewer device!')
    nee.udpServe()


if __name__ == '__main__':
    sys.exit(main())
