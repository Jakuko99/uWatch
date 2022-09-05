function getAvailableFirmware(firmware) {
  var xhr = new XMLHttpRequest();
  xhr.open('HEAD', firmware, false);
  xhr.send();

  return xhr.status == 200 ? true : false;
}


function getGATTObject(firmware) {
  let path = "../assets/devices/firmware/" + firmware.toLowerCase() + ".json";

  if(!getAvailableFirmware(path)) {
    path = "../assets/devices/default.json";
  }

  var request = new XMLHttpRequest();
  request.open('GET', path, false);  // `false` makes the request synchronous
  request.send(null);

  if (request.status === 200) {
    return JSON.parse(request.responseText);
  } else {
    return null;
  }
}

function getUUIDObject(gattObject, name) {
  let uuids = gattObject.UUID;
  //let uuid = null;

  for(let i = 0; i < uuids.length; i++) {
    let object = uuids[i];

    if(object.Name == name) {
      return object;
    }
  }

  if(gattObject.Firmware != "Default") {
    let defaultObject = getUUIDObject(getGATTObject("Default"), name);
    if(defaultObject != null) {
      return defaultObject;
    }
  }

  return null;
}

function formatInput(input) {
  let retVal = ""

  if(input.length > 1) {
    for (let i=0; i < input.length; i++) {
      retVal += '0x' + input[i] + ' ';
    }
  }

  return retVal;
}
