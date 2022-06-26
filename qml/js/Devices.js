function listDevices() {
  let devices = DB.readAll("watches");

  for (var i = 0; i < devices.rows.length; i++) {
    welcomeListModel.append({deviceObject: devices.rows.item(i)});
  }
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
     DB.update(id, "watches", "firmwareVersion", result);
  });
}