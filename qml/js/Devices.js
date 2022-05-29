function listDevices() {
  let devices = DB.readAll("watches");

  for (var i = 0; i < devices.rows.length; i++) {
    welcomeListModel.append({deviceObject: devices.rows.item(i)});
  }
}

function deleteDevice(index) {
  console.log(index);
  //python.call('uwatch.unpairDevice', [id], function(result) {
    //if(result == true) {
      DB.deleteByID("watches", ++index);
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
