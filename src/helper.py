import JSONHelper
from uGatt import getBackend, format_input
from datetime import datetime

def getUUID(json, softwareRevision, characteristic):
    return JSONHelper.getCharacteristicUUID(json, softwareRevision, characteristic)

def getHandle(json, softwareRevision, characteristic):
    return JSONHelper.getCharacteristicHandle(json, softwareRevision, characteristic)

def currentTimeToHex():
    currentTime = datetime.now()

    year = ''.join('{:04X}'.format(currentTime.year))
    month = ''.join('{:02X}'.format(currentTime.month))
    day = ''.join('{:02X}'.format(currentTime.day))
    hour = ''.join('{:02X}'.format(currentTime.hour))
    minute = ''.join('{:02X}'.format(currentTime.minute))
    second = ''.join('{:02X}'.format(currentTime.second))

    return format_input([year[2:4], year[0:2], month, day, hour, minute, second])

def parseToString(value):
    value = parseOutput(value)
    try:
        return bytearray.fromhex(value.replace(" ", "").rstrip()).decode()
    except:
        return value.rstrip()

def parseToInt(value):
    value = parseOutput(value)

    return int(str(value), 16)

def parseOutput(output):
    value = output[0]
    if getBackend == "bluetoothctl":
        value = value.split("\x1b[K ")[1].replace("]", "").strip()
    else:
        value = value.split("value: ")[1]

    return value.replace(" ", "")
