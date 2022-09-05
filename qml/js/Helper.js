function getFileContent(fileUrl, callback){
   var xhr = new XMLHttpRequest;
   var result = "";
   xhr.open("GET", fileUrl); // set Method and File
   xhr.send(); // begin the request

   xhr.onreadystatechange = function () {
       if(xhr.readyState === XMLHttpRequest.DONE){ // if request_status == DONE
           var response = xhr.responseText;

           if(callback) callback(response);
       }
   }
}

function checkIfFileExist(src, callback) {
    var xhr = new XMLHttpRequest();
    xhr.open('HEAD', src, false);
    xhr.send();

    return xhr.status;
}

function migrateDatabase(databasePath) {
  if(!settings.migrationRan) {
    if(Helper.checkIfFileExist(databasePath + "/Database/uWatch.db") == 200) {
      console.log("Old database exists, starting migration.");
      python.call('uwatch.getDevices', [], function(result) {
        for(let i = 0; i < result.length; i++) {
          migrateTable("watches", result[i]);
        }
      });

      python.call('uwatch.getBatteryLevels', [], function(result) {
        for(let i = 0; i < result.length; i++) {
          migrateTable("battery", result[i]);
        }
      });

      python.call('uwatch.getHeartRate', [], function(result) {
        for(let i = 0; i < result.length; i++) {
          migrateTable("heartrate", result[i]);
        }
      });

      python.call('uwatch.getSteps', [], function(result) {
        for(let i = 0; i < result.length; i++) {
          migrateTable("steps", result[i]);
        }
      });

      settings.migrationRan = true
    } else {
      console.log("Old database does not exist");
    }
  }
}

function migrateTable(table, data) {
  if(table == "watches")
    DB.createWatch(data);
  else {
    DB.writeStats(table, data);
  }
}

function getWeek(format) {
  let result = [];

  Date.prototype.formatYYYYMMDD = function(){
    return this.getFullYear() +
    "-" + (this.getMonth() < 10 ? '0' : '') + (this.getMonth() + 1) +
    "-" +  (this.getDate() < 10 ? '0' : '') + this.getDate();
  }

  Date.prototype.formatMMDD = function(){
    return (this.getMonth() < 10 ? '0' : '') + (this.getMonth() + 1) +
    "-" +  (this.getDate() < 10 ? '0' : '') + this.getDate();
  }

  for(let i = 0; i < 7; i++) {
    let date = new Date();
    date.setDate(date.getDate() - i);

    //result.push(date.getMonth()+1 + "-" + date.getDate())
    if(format == "long") {
      result.push(date.formatYYYYMMDD());
    } else if (format == "short") {
      result.push(date.formatMMDD())
    }
  }

  return result.reverse();
}

function getToday() {
  Date.prototype.formatYYYYMMDD = function(){
    return this.getFullYear() +
    "-" + (this.getMonth() < 10 ? '0' : '') + (this.getMonth() + 1) +
    "-" +  (this.getDate() < 10 ? '0' : '') + this.getDate();
  }

  return new Date().formatYYYYMMDD();
}

function getMaxValue(values) {
  let max = null;
  for(let i = 0; i < values.length; i++) {
    if(max == null) {
      max = values[i];
    } else if(max < values [i]) {
      max = values[i]
    }
  }

  return max;
}

function currentTimeToHex() {
  let currentDate = new Date();
  let year = currentDate.getFullYear().toString(16).padStart(4, '0');
  let month = (currentDate.getMonth()+1).toString(16).padStart(2, '0');
  let day = currentDate.getDate().toString(16).padStart(2, '0');
  let hour = currentDate.getHours().toString(16).padStart(2, '0');
  let minute = currentDate.getMinutes().toString(16).padStart(2, '0');
  let second = currentDate.getSeconds().toString(16).padStart(2, '0');
  let microsecond = parseInt(currentDate.getMilliseconds() * 1000 / (1e6*256),10).toString(16).padStart(2, '0');
  let binary = "0001".toString(16)

  return [year.substring(2,4), year.substring(0,2), month, day, hour, minute, second, microsecond, binary];
}

function sleep(ms) {
  for(let i = 0; i < ms; i++){}
}
