function listDevices() {
  python.call('uwatch.getPairedDevices', [], function(devices) {
    if(devices.length > 0) {
      for (var i = 0; i < devices.length; i++) {
        let deviceArray = devices[i].split(" ")

        if(!settings.displayUnsupportedDevices && GATT.getAvailableFirmware("../assets/devices/firmware/" + deviceArray[2].toLowerCase() + ".json")) {
          if(DB.readByMAC("watches", deviceArray[1]).rows.length == 0) {
            DB.createWatch([deviceArray[1], " ", deviceArray[2], " "]);
          }
          welcomeListModel.append({deviceObject: DB.readByMAC("watches", deviceArray[1]).rows.item(0)});
        } else if (settings.displayUnsupportedDevices) {
          if(DB.readByMAC("watches", deviceArray[1]).rows.length == 0) {
            DB.createWatch([deviceArray[1], " ", deviceArray[2], " "]);
          }
          welcomeListModel.append({deviceObject: DB.readByMAC("watches", deviceArray[1]).rows.item(0)});
        }
      }
    }
  })
}

function deleteDevice(index, mac) {
  //python.call('uwatch.unpairDevice', [id], function(result) {
    //if(result == true) {
      DB.deleteByMAC("watches", mac);
      welcomeListModel.remove(index)
    //}
  //})
}

function scanDevices() {
  listModel.clear()
  scanLabel.text = i18n.tr("Scanning...")
  python.call('uwatch.add_device', function(devices) {
    if(devices.length > 0) {
      devices.forEach((el, i) => listModel.append({firmware: el[1], deviceMAC: el[0]}));
    } else {
      scanLabel.text = i18n.tr("Could not find any devices.")
    }
  })
}

function getInitialDeviceData(id, mac, firmware) {
  let gattobject = GATT.getGATTObject(firmware);
  let firmwareObject = GATT.getUUIDObject(gattobject, "Firmware Revision String");

  python.call('uwatch.readValue', [mac,
   "0.1",
   firmwareObject.ValidSinceFirmware,
   firmwareObject.UUID,
   "big-endian", "string"], function(result) {
     if(result != null) {
      DB.update(id, "watches", "firmwareVersion", result);
     }
  });
}
