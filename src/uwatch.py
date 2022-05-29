import uGatt
import uGattHelper as helper
import DatabaseHelper as db
from datetime import datetime, timedelta
from distutils.version import StrictVersion

############
# Database #
############


def getDevices():
    return db.getValues("watches", ["*"], [], "", "")


def getBatteryLevels():
    return db.getValues("battery", ["*"], [], "", "")


def getHeartRate():
    return db.getValues("heartrate", ["*"], [], "", "")


def getSteps():
    return db.getValues("steps", ["*"], [], "", "")

#########
# uGatt #
#########


def initialize():
    if uGatt.init():
        return True
    else:
        return False


def add_device():
    result = uGatt.scan()
    devices = []
    for device in result:
        if "Device" in device:
            t = device.split("Device ")[1]
            devices.append([t[0:17].strip(), t[17:len(t)].strip()])

    return devices


def pairDevice(mac):
    return uGatt.pair(mac)


def unpairDevice(mac):
    return uGatt.unpair(mac)


def connectDevice(mac):
    return uGatt.connect(mac)


def getConnectionState(mac):
    return uGatt.is_connected(mac)


##################
# Device actions #
##################


def writeValue(mac, currentFirmwareVersion, validFirmwareVersion, identifier):
    if compareVersions(currentFirmwareVersion, validFirmwareVersion):
        if uGatt.getBackend() == "bluetoothctl":
            uGatt.write_value_uuid(identifier, helper.currentTimeToHex())
        else:
            uGatt.write_handle(identifier, helper.currentTimeToHex())


def readValue(mac, currentFirmwareVersion, validFirmwareVersion, uuid, interpreter):
    if compareVersions(currentFirmwareVersion, validFirmwareVersion):
        val = helper.parseToInt(uGatt.read_value(uuid), interpreter)
        return val


########
# Misc #
########

def compareVersions(currentFirmwareVersion, validFirmwareVersion):
    if StrictVersion(currentFirmwareVersion) >= StrictVersion(validFirmwareVersion):
        return True
    else:
        return False


def getShortISODateArray(max):
    dateArray = []

    for i in range(0, max):
        currentTime = datetime.now() - timedelta(days=(max-1-i))

        month = ''.join('{:02}'.format(currentTime.month))
        day = ''.join('{:02}'.format(currentTime.day))

        date = month + "-" + day
        dateArray.append(date)

    return dateArray


def getISODateArray(max):
    dateArray = []

    for i in range(0, max):
        currentTime = datetime.now() - timedelta(days=(max-1-i))

        year = ''.join('{:04}'.format(currentTime.year))
        month = ''.join('{:02}'.format(currentTime.month))
        day = ''.join('{:02}'.format(currentTime.day))

        date = year + "-" + month + "-" + day
        dateArray.append(date)

    return dateArray
