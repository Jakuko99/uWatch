import uGatt
import uGattHelper as helper
import DatabaseHelper as dbHelper

############
# Database #
############


def initialSetup(appDataPath, root):
    state = dbHelper.createDatabase(appDataPath, root)
    return state

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


def connect_device(mac):
    return uGatt.connect(mac)


def getConnectionState(mac):
    return uGatt.is_connected(mac)


def syncTime(json, softwareRevision):
    if uGatt.getBackend == "bluetoothctl":
        uGatt.write_value_uuid(helper.getUUID(
            json, softwareRevision, "Current Time"), helper.currentTimeToHex())
    else:
        uGatt.write_handle(helper.getHandle(
            json, softwareRevision, "Current Time"), helper.currentTimeToHex())


def syncFirmware(json, softwareRevision):
    return helper.parseToString(uGatt.read_value(helper.getUUID(json, softwareRevision, "Firmware Revision String")))


def syncBatteryLevel(json, softwareRevision):
    return helper.parseToInt(uGatt.read_value(helper.getUUID(json, softwareRevision, "Battery Level")))


def syncHeartRate(json, softwareRevision):
    return helper.parseToInt(uGatt.read_value(helper.getUUID(json, softwareRevision, "Heart Rate Measurement")))


def syncSteps(json, softwareRevision):
    return helper.parseToInt(uGatt.read_value(helper.getUUID(json, softwareRevision, "Heart Rate Measurement")))


def syncHardwareRevision(json, softwareRevision):
    return helper.parseToString(uGatt.read_value(helper.getUUID(json, softwareRevision, "Firmware Revision String")))
