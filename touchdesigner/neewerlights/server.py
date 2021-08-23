#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
NeewerServer is a small UDP server able to associate with a Neewer RGB 660 LED
Light pannel (Bluetooth Low Energy connection). All UDP messages will be passed
to the bluetooth device.
"""
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
        self._btConnection = None
        self._btResponseDelegate = None
        self._udpSocket = None
        self.neewerAddress = neewerAddress
        self.listenAddress = listenAddress
        self.listenPort = listenPort


    def startUDPServer(self):
        """
        Open a listening socket to receive UDP messages.
        Each message is passed to the neewer device.
        """

        logging.info("Starting UDP server...")

        try:
            self._udpSocket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            self._udpSocket.bind((self.listenAddress, self.listenPort))
            logging.info("UDP Server started.")
            logging.info("Please send your messages to %s:%s",
                self.listenAddress, self.listenPort
            )
            while True:
                addr = self._udpSocket.recvfrom(1024)
                command = addr[0]
                address = addr[1]
                logging.debug("%s - %s", address, command)
                self.neewerSend(command, 14)

        except Exception as e:
            logging.error("UDP Server failed: %s", e)
            self._udpSocket = None
            return False

        return True


    def stopUDPServer(self):
        """
        Stop socket receiving UDP messages
        """

        logging.info("Stopping UDP Server...")

        try:
            self._udpSocket.close()

        except Exception:
            pass

        self._udpSocket = None


    def neewerConnect(self, btAdapter=0):
        """
        Connect to a Neewer RGB Lamp

        :param btAdapter: Bluetooth adapter ID. Defaults to 0
        """

        logging.debug("Connecting to Neewer device...")

        try:
            # Create connection and response delegate object
            connection = btle.Peripheral(self.neewerAddress,
                                         btle.ADDR_TYPE_RANDOM, btAdapter)

            # According to the source code, setDelegate is deprecated
            # https://github.com/IanHarvey/bluepy/blob/master/bluepy/btle.py#L413
            # withDelegate does the same
            self._btResponseDelegate = NeewerResponseDelegate()
            self._btConnection = connection.withDelegate(self._btResponseDelegate)

            logging.info('Connected to Neewer device %s', self.neewerAddress)

        except RuntimeError as e:
            logging.error('Connection failed: %s', e)
            return False

        return True


    def neewerDisconnect(self):
        """
        Disconnect from Neewer Device
        """

        logging.debug("Disconnecting...")

        try:
            self._btConnection.disconnect()

        except btle.BTLEException:
            pass

        self._btConnection = None


    def neewerSend(self, message, cHandle=14):
        """
        Send bytes to Neewer Device

        :param message: bytes to pass to the device
        :param cHandle: handle (int) to use to communicate
        """

        try:
            self._btConnection.writeCharacteristic(cHandle, message)

            ## Should be already called on it's own, nothing to log here!
            # Deal with a potential response (aka Notification)
            notifTimeout = 2.0 # in seconds
            if self._btConnection.waitForNotifications(notifTimeout):
                # self.NeewerResponseDelegate.handleNotification() is called here
                logging.debug("Data received from notification: %s", self._btResponseDelegate.data)
            else:
                logging.debug('No response received in %s seconds', notifTimeout)

        except Exception as e:
            logging.error('Failed to send message: %s', e)


    def neewerScan(self):
        """
        Scan the Neewer device for Services and Characteristics
        """

        try:
            for service in self._btConnection.getServices():
                for charac in service.getCharacteristics():
                    logging.info("UUID: %s", charac.uuid)
                    logging.info("Properties: %s", charac.properties)
                    logging.info("Supports Read: %s", charac.supportsRead())
                    logging.info("Properties To String: %s", charac.propertiesToString())
                    logging.info("Handle: %s", charac.getHandle())
                    logging.info("")

        except Exception as e:
            logging.error('Failed to scan device: %s', e)


class NeewerResponseDelegate(btle.DefaultDelegate):
    """
    Listen for responses from Neewer Device

    Notifications are processed by bluepy's Delegate class
    which is registered with the Peripheral (_btConnection)
    """

    def __init__(self):
        btle.DefaultDelegate.__init__(self)
        self.data = None


    def handleNotification(self, cHandle, data):
        logging.debug('Received notification (cHandle=%s): %s', cHandle, data)
        self.data = data


def main():
    """
    Connect to a Neewer RGB Light, listen to UDP messages
    """
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
