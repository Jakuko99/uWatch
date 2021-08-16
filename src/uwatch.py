import uGatt
import uGattHelper as helper
import DatabaseHelper as db
from datetime import datetime, timedelta

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
            return db.getValues("watches", ["firmware", "mac"], [], "", "")


def addDevice(mac, deviceName, firmware, firmwareVersion):
    if db.isOpen():
        db.insertValues("watches", ["mac", "devicename", "firmware",
                                    "firmwareVersion"], [mac, deviceName,
                                                         firmware,
                                                         firmwareVersion])


def deviceExists(mac):
    if db.isOpen():
        count = db.getLastValue("watches", ["*"], [], "WHERE mac == '" + mac + "'",
                                "ORDER BY 'date' DESC")

        if count is not None and count > 0:
            return True
        else:
            return False


def deleteDevice(mac):
    if db.isOpen():
        db.deleteValue("watches", "WHERE mac == '"
                       + mac + "'")

        if deviceExists(mac) is not True:
            return True

    return False


def getFirmware(mac):
    if db.isOpen():
        return db.getLastValue("watches", ["firmware"], [],
                               "WHERE mac == '" + mac + "'", "")


def getFirmwareVersion(mac):
    if db.isOpen():
        return db.getLastValue("watches", ["firmwareVersion"], [],
                               "WHERE mac == '" + mac + "'", "")


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
                               "ORDER BY 'date' DESC")


def getHeartRate(mac):
    if db.isOpen():
        return db.getValues("heartrate", ["heartrate", "date"], [],
                            "WHERE mac == '" + mac + "'",
                            "ORDER BY 'date' DESC")


def getLatestHeartRate(mac):
    if db.isOpen():
        return db.getLastValue("heartrate", ["heartrate"], [],
                               "WHERE mac == '" + mac + "'",
                               "ORDER BY 'date' DESC")


def getHeartRateForDate(mac, date):
    if db.isOpen():
        return db.getValues("heartrate", ["heartrate"], [],
                            "WHERE date like '" + date + "%'", "")


def insertHeartRate(mac, date, heartRate):
    currentTime = ""
    if date == "":
        currentTime = datetime.isoformat(datetime.now())
    else:
        currentTime = date

    if db.isOpen():
        return db.insertValues("heartrate", ["date", "mac",
                                             "heartrate"],
                               [currentTime, mac, str(heartRate)])
    else:
        print("Cannot write heart rate! Database is not open!")


def getSteps(mac):
    if db.isOpen():
        return db.getValues("steps", ["steps", "date"], [],
                            "WHERE mac == '" + mac + "'",
                            "ORDER BY 'date' DESC")


def getStepsForDate(mac, date):
    if db.isOpen():
        stepsArray = db.getValues(
            "steps", ["steps"], [], "WHERE date like '" + date + "%'", "")
        steps = 0
        if len(stepsArray) > 0:
            for element in stepsArray:
                steps += element[0]

        return steps


def insertSteps(mac, date, steps):
    currentTime = ""
    if date == "":
        currentTime = datetime.isoformat(datetime.now())
    else:
        currentTime = date

    if db.isOpen():
        return db.insertValues("steps", ["date", "mac",
                                         "steps"],
                               [currentTime, mac, str(steps)])
    else:
        print("Cannot write steps! Database is not open!")


def deleteValues(table, mac, date):
    if db.isOpen():
        db.deleteValue(table, "WHERE mac == '"
                       + mac + "' AND date == '" + date + "'")

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


def unpairDevice(mac):
    return uGatt.unpair(mac)


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


def syncHeartRate(mac, json, firmware):
    heartRate = helper.parseToInt(uGatt.read_value(
        helper.getUUID(json, firmware, "Heart Rate Measurement")))
    return insertHeartRate(mac, "", heartRate)


def syncSteps(json, firmware):
    heartRateLevel = helper.parseToInt(uGatt.read_value(
        helper.getUUID(json, firmware, "Heart Rate Measurement")))
    #return insertBattery(mac, heartRateLevel)


def syncHardwareRevision(json, firmware):
    return helper.parseToString(uGatt.read_value(helper.getUUID(json, firmware, "Hardware Revision String")))


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
