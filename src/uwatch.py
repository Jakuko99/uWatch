import uGatt
import uGattHelper as helper
from datetime import datetime, timedelta
from distutils.version import StrictVersion

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


def syncTime(json, firmware, firmwareVersion):
    UUIDValidVersion = helper.getValidVersion(json, firmware, "Current Time")

    if StrictVersion(firmwareVersion) >= StrictVersion(UUIDValidVersion):
        if uGatt.getBackend() == "bluetoothctl":
            uGatt.write_value_uuid(helper.getUUID(
                json, firmware, "Current Time"), helper.currentTimeToHex())
        else:
            uGatt.write_handle(helper.getHandle(
                json, firmware, "Current Time"), helper.currentTimeToHex())


def syncFirmware(json, firmware, firmwareVersion):
    UUIDValidVersion = helper.getValidVersion(
        json, firmware, "Software Revision String")
    if StrictVersion(firmwareVersion) >= StrictVersion(UUIDValidVersion):
        return helper.parseToString(uGatt.read_value(helper.getUUID(json, firmware, "Software Revision String")), "big-endian")


def syncFirmwareRevision(json, mac, firmware):
    version = helper.parseToString(uGatt.read_value(helper.getUUID(
        json, firmware, "Firmware Revision String")), "big-endian")

    return version


def syncBatteryLevel(mac, json, firmware, firmwareVersion):
    UUIDValidVersion = helper.getValidVersion(json, firmware, "Battery Level")
    if StrictVersion(firmwareVersion) >= StrictVersion(UUIDValidVersion):
        batteryLevel = helper.parseToInt(uGatt.read_value(
                helper.getUUID(json, firmware, "Battery Level")), "big-endian")
        return batteryLevel


def syncHeartRate(mac, json, firmware, firmwareVersion):
    UUIDValidVersion = helper.getValidVersion(
        json, firmware, "Heart Rate Measurement")
    if StrictVersion(firmwareVersion) >= StrictVersion(UUIDValidVersion):
        heartRate = helper.parseToInt(uGatt.read_value(
                helper.getUUID(json, firmware, "Heart Rate Measurement")), "big-endian")
        return heartRate


def syncSteps(mac, json, firmware, firmwareVersion):
    UUIDValidVersion = helper.getValidVersion(json, firmware, "Step count")
    if StrictVersion(firmwareVersion) >= StrictVersion(UUIDValidVersion):
        stepCount = helper.parseToInt(uGatt.read_value(
                helper.getUUID(json, firmware, "Step count")), "little-endian")

        return stepCount


def syncHardwareRevision(json, firmware, firmwareVersion):
    UUIDValidVersion = helper.getValidVersion(
        json, firmware, "Hardware Revision String")
    if StrictVersion(firmwareVersion) >= StrictVersion(UUIDValidVersion):
        return helper.parseToString(uGatt.read_value(helper.getUUID(json, firmware, "Hardware Revision String")), "big-endian")


########
# Misc #
########

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
