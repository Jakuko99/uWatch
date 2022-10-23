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

function syncDevices() {
  python.call('uwatch.getConnectedDevices', [], function(devices) {
    for(let i = 0; i < devices.length; i++) {
      if(!settings.displayUnsupportedDevices && GATT.getAvailableFirmware("../assets/devices/firmware/" + devices[i][1].toLowerCase() + ".json")) {
        let device = DB.readByMAC("watches", devices[i][0]).rows.item(0);
        if(device.firmwareVersion != " ") {
          syncDevice(device.id, device.mac, device.firmware, device.firmwareVersion, false);
        }
      } else if (settings.displayUnsupportedDevices) {
        let device = DB.readByMAC("watches", devices[i][0]).rows.item(0);
        if(device.firmwareVersion != " ") {
          syncDevice(device.id, device.mac, device.firmware, device.firmwareVersion, false);
        }
      }

      let wait = 5000;
      for(let j = 0; j < wait; j++) {}
    }
  });
}

function syncDevice(id, mac, firmware, firmwareVersion, updateUI) {
  let gattobject = GATT.getGATTObject(firmware);
  let timeObject = GATT.getUUIDObject(gattobject, "Current Time");
  let firmwareObject = GATT.getUUIDObject(gattobject, "Firmware Revision String");
  let batteryObject = GATT.getUUIDObject(gattobject, "Battery Level");
  let heartrateObject = GATT.getUUIDObject(gattobject, "Heart Rate Measurement");
  let stepsObject = GATT.getUUIDObject(gattobject, "Step count");

  python.call('uwatch.writeValue', [mac, firmwareVersion, firmwareObject.ValidSinceFirmware, timeObject.UUID, GATT.formatInput(Helper.currentTimeToHex())], function() {})
  python.call('uwatch.readValue', [mac,
   firmwareVersion,
   firmwareObject.ValidSinceFirmware,
   firmwareObject.UUID,
   "big-endian", "string"], function(result) {
     if(result != firmwareVersion) {
       DB.update(id, "watches", "firmwareVersion", result);

       if(updateUI) {
         deviceObject.id = result;
         deviceView.updateView();
       }
     }
  });
  python.call('uwatch.readValue', [mac,
   firmwareVersion,
   batteryObject.ValidSinceFirmware,
   batteryObject.UUID,
   "big-endian", "int"], function(result) {
     DB.writeStats("battery", [new Date().toISOString(), mac, result]);

     if(updateUI) {
       deviceView.battery = result;
       deviceView.updateView();
     }
  });

  python.call('uwatch.readValue',  [mac, firmwareVersion, heartrateObject.ValidSinceFirmware, heartrateObject.UUID, "big-endian", "int"],  function(result) {
    if(result != 0) {
      DB.writeStats("heartrate", [new Date().toISOString(), mac, result]);

      if(updateUI) {
        deviceView.heartrate = result;

        deviceView.updateView();
      }
    }
  });

  python.call('uwatch.readValue',  [mac, firmwareVersion, stepsObject.ValidSinceFirmware, stepsObject.UUID, "little-endian", "int"],  function(result) {
    let value = result - DB.readSumByDate("steps", mac, Helper.getToday());

    if(value > 0) {
      DB.writeStats("steps", [new Date().toISOString(), mac, value]);
    }

    if(updateUI) {
      deviceView.steps = DB.readSumByDate("steps", mac, Helper.getToday());
      deviceView.updateView();
    }
  });
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
