import JSONHelper
import json
from uGatt import getBackend, format_input
from datetime import datetime


def getDevices(root):
    devices = []

    for node in JSONHelper.getNodes(root)["Devices"]:
        devices.append(node["Firmware"])

    return devices


def getUUID(root, firmware, characteristic):
    for node in JSONHelper.getNodes(root)["Devices"]:
        if node["Firmware"] == firmware:
            for uuid in node["UUID"]:
                uuidInfo = JSONHelper.getNodes(json.dumps(uuid))
                if uuidInfo["Name"] == characteristic:
                    return uuidInfo["UUID"]

    return getUUID(root, "Default", characteristic)


def getHandle(root, firmware, characteristic):
    for node in JSONHelper.getNodes(root)["Devices"]:
        if node["Firmware"] == firmware:
            for uuid in node["UUID"]:
                uuidInfo = JSONHelper.getNodes(json.dumps(uuid))
                if uuidInfo["Name"] == characteristic:
                    return uuidInfo["Handle"]

    return getHandle(root, "Default", characteristic)


def getValidVersion(root, firmware, characteristic):
    for node in JSONHelper.getNodes(root)["Devices"]:
        if node["Firmware"] == firmware:
            for uuid in node["UUID"]:
                uuidInfo = JSONHelper.getNodes(json.dumps(uuid))
                if uuidInfo["Name"] == characteristic:
                    print(uuidInfo["ValidSinceFirmware"])
                    return uuidInfo["ValidSinceFirmware"]

    return getValidVersion(root, "Default", characteristic)


def currentTimeToHex():
    currentTime = datetime.now()

    year = ''.join('{:04X}'.format(currentTime.year))
    month = ''.join('{:02X}'.format(currentTime.month))
    day = ''.join('{:02X}'.format(currentTime.day))
    hour = ''.join('{:02X}'.format(currentTime.hour))
    minute = ''.join('{:02X}'.format(currentTime.minute))
    second = ''.join('{:02X}'.format(currentTime.second))

    return format_input([year[2:4], year[0:2], month, day, hour, minute, second])


def parseToString(value, endian):
    value = parseOutput(value, endian)
    try:
        return bytearray.fromhex(value.replace(" ", "").rstrip()).decode()
    except:
        return value.rstrip()


def parseToInt(value, endian):
    value = parseOutput(value, endian)

    return int(str(value), 16)


def parseOutput(output, endian):
    value = output[0]
    if getBackend == "bluetoothctl":
        value = value.split("\x1b[K ")[1].replace("]", "").strip()
    else:
        value = value.split("value: ")[1]

    if endian == "little-endian":
        value = ''.join(reverseList(value.split(" ")))
        print(value)
        return value
    else:
        return value.replace(" ", "")


def reverseList(list):
    newList = []
    for i in range(len(list)):
        newList.append(list[len(list)-1-i])

    return newList
