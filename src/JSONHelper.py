import json
import os
import posixpath
from pathlib import Path

def getDevices(root):
    devices = []

    for node in getNodes(root)["Devices"]:
        devices.append(node["Firmware"])

    return devices

def getCharacteristicUUID(root, firmware, characteristic):
    for node in getNodes(root)["Devices"]:
        if node["Firmware"] == firmware:
            for uuid in node["UUID"]:
                uuidInfo = getNodes(json.dumps(uuid))
                if uuidInfo["Name"] == characteristic:
                    return uuidInfo["UUID"]

    return getCharacteristicUUID(root, "Default", characteristic)

def getCharacteristicHandle(root, firmware, characteristic):
    for node in getNodes(root)["Devices"]:
        if node["Firmware"] == firmware:
            for uuid in node["UUID"]:
                uuidInfo = getNodes(json.dumps(uuid))
                if uuidInfo["Name"] == characteristic:
                    return uuidInfo["Handle"]

    return getCharacteristicHandle(root, "Default", characteristic)

def getNodes(node):
    return json.loads(node)
