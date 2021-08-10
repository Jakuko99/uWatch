import uGatt
import uGattHelper as helper
import DatabaseHelper as db
from datetime import datetime

############
# Database #
############


def databaseExists(appDataPath):
    if db.exists(appDataPath):
        return True
    else:
        return False


def initialSetup(appDataPath, root):
    if db.exists(appDataPath) is False:
        state = db.createDatabase(appDataPath, root)
        return state
    else:
        print("Database exists already! It will not be attempted to create it.")
        return True


def getDevices(appDataPath):
    if db.exists(appDataPath) is True:
        if db.isOpen() is False:
            print("Database is not open! Attempting to open it!")
            db.openDatabase(appDataPath)
            return db.getValues("watches", ["firmware", "mac"], [], "")


def addDevice(mac, deviceName, firmware, firmwareVersion):
    if db.isOpen():
        db.insertValues("watches", ["mac", "devicename", "firmware", "firmwareVersion"], [
                        mac, deviceName, firmware, firmwareVersion])


def getFirmware(mac):
    if db.isOpen():
        return db.getLastValue("watches", ["firmware"], [], "WHERE mac == '" + mac + "'", "")


def getFirmwareVersion(mac):
    if db.isOpen():
        return db.getLastValue("watches", ["firmwareVersion"], [], "WHERE mac == '" + mac + "'", "")


def insertBattery(mac, batteryLevel):
    currentTime = datetime.isoformat(datetime.now())
    if db.isOpen():
        return db.insertValues("battery", ["date", "mac",
                                           "batteryLevel"],
                               [currentTime, mac, str(batteryLevel)])
    else:
        print("Cannot sync battery! Database is not open!")


def getLatestBatteryLevel(mac):
    if db.isOpen():
        return db.getLastValue("battery", ["batteryLevel"], [],
                               "WHERE mac == '" + mac + "'",
                               "ORDER BY date DESC")

#########
# uGatt #
#########


def initialize():
    if uGatt.init():
        return True
    else:
        return False


def add_device(json):
    result = uGatt.scan()
    devices = []
    for device in result:
        if "Device" in device:
            t = device.split("Device ")[1]
            devices.append([t[0:17].strip(), t[17:len(t)].strip()])

    return devices


def pairDevice(mac):
    return uGatt.pair(mac)


def connectDevice(mac):
    return uGatt.connect(mac)


def getConnectionState(mac):
    return uGatt.is_connected(mac)


def syncTime(json, firmware):
    if uGatt.getBackend() == "bluetoothctl":
        uGatt.write_value_uuid(helper.getUUID(
            json, firmware, "Current Time"), helper.currentTimeToHex())
    else:
        uGatt.write_handle(helper.getHandle(
            json, firmware, "Current Time"), helper.currentTimeToHex())


def syncFirmware(json, firmware):
    return helper.parseToString(uGatt.read_value(helper.getUUID(json, firmware, "Software Revision String")))


def syncFirmwareRevision(json, firmware):
    return helper.parseToString(uGatt.read_value(helper.getUUID(json, firmware, "Firmware Revision String")))


def syncBatteryLevel(mac, json, firmware):
    batteryLevel = helper.parseToInt(uGatt.read_value(
        helper.getUUID(json, firmware, "Battery Level")))
    return insertBattery(mac, batteryLevel)


def syncHeartRate(json, firmware):
    return helper.parseToInt(uGatt.read_value(helper.getUUID(json, firmware, "Heart Rate Measurement")))


def syncSteps(json, firmware):
    heartRateLevel = helper.parseToInt(uGatt.read_value(
        helper.getUUID(json, firmware, "Heart Rate Measurement")))
    #return insertBattery(mac, heartRateLevel)


def syncHardwareRevision(json, firmware):
    return helper.parseToString(uGatt.read_value(helper.getUUID(json, firmware, "Hardware Revision String")))


########
# Misc #
########

def getShortISODate():
    currentTime = datetime.now()

    month = ''.join('{:02X}'.format(currentTime.month))
    day = ''.join('{:02X}'.format(currentTime.day))

    return month + "-" + day
