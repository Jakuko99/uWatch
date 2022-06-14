function openDatabase() {
  var database = LocalStorage.openDatabaseSync("uWatchDatabase", "1.0", "uWatch Database", 1000);
  try {
    database.transaction(function(tx) {
        tx.executeSql('CREATE TABLE IF NOT EXISTS watches(' +
                      'id INTEGER PRIMARY KEY, ' +
                      'mac TEXT, ' +
                      'devicename TEXT, '+
                      'firmware TEXT, '+
                      'firmwareVersion TEXT)');
        tx.executeSql('CREATE TABLE IF NOT EXISTS battery('+
                      'id INTEGER PRIMARY KEY, '+
                      'date TEXT, '+
                      'mac TEXT, '+
                      'value INTEGER)');
        tx.executeSql('CREATE TABLE IF NOT EXISTS steps('+
                      'id INTEGER PRIMARY KEY, '+
                      'date TEXT, '+
                      'mac TEXT, '+
                      'value INTEGER)');
        tx.executeSql('CREATE TABLE IF NOT EXISTS heartrate('+
                      'id INTEGER PRIMARY KEY, '+
                      'date TEXT, '+
                      'mac TEXT, '+
                      'value INTEGER)');
    });
  } catch (err) {
      console.log("Error creating table in database: " + err);
  }

  return database;
}


//****************************************
//**            Read functions          **
//****************************************

function readAll(table)
{
  var database = openDatabase();
  var result = null;

  try {
    database.transaction(function (tx) {
        result = tx.executeSql(
                    'SELECT * FROM ' + table)
    })
  } catch (err) {
      console.log("Error reading from database: " + err);
  }

  return result;
}

function readLastRow(table) {
  var database = openDatabase();
  var result = null;

  try {
    database.transaction(function (tx) {
        result = tx.executeSql(
                    'SELECT * FROM ' + table + ' ORDER BY id DESC LIMIT 1;');
    })
  } catch (err) {
      console.log("Error reading from database: " + err);
  }

  if(result.rows.item(0) == null) {
      return "0";
  } else {
      return result.rows.item(0).value;
  }
}

function read(table, id)
{
  var database = openDatabase();
  var result = null;

  try {
    database.transaction(function (tx) {
        result = tx.executeSql(
                    'SELECT * FROM ' + table + ' WHERE id == ' + id + ';')
    })
  } catch (err) {
      console.log("Error reading from database: " + err);
  }

  return result
}

function readByMAC(table, mac) {
  var database = openDatabase();
  var result = null;

  try {
    database.transaction(function (tx) {
        result = tx.executeSql(
                    'SELECT * FROM ' + table + ' WHERE mac == "' + mac + '";')
    })
  } catch (err) {
      console.log("Error reading from database: " + err);
  }

  return result
}

function readLastByMAC(table, mac) {
  var database = openDatabase();
  var result = null;

  try {
    database.transaction(function (tx) {
        result = tx.executeSql(
                    'SELECT * FROM ' + table + ' WHERE mac == "' + mac + '" ORDER BY id DESC LIMIT 1;');
    })
  } catch (err) {
      console.log("Error reading from database: " + err);
  }

  if(result.rows.item(0) == null) {
      return "0";
  } else {
      return result.rows.item(0).value;
  }
}

function readByDate(table, mac, date) {
  var database = openDatabase();
  var result = null;

  try {
    database.transaction(function (tx) {
        result = tx.executeSql(
                    'SELECT * FROM ' + table + ' WHERE mac == "' + mac + '" AND date LIKE "' + date + '%";');
    })
  } catch (err) {
      console.log("Error reading from database: " + err);
  }

  return result.rows;
}

function readLastByDate(table, mac, date) {
  var database = openDatabase();
  var result = null;

  try {
    database.transaction(function (tx) {
        result = tx.executeSql(
                    'SELECT * FROM ' + table + ' WHERE mac == "' + mac + '" AND date LIKE "' + date + '%" ORDER BY id DESC LIMIT 1;');
    })
  } catch (err) {
      console.log("Error reading from database: " + err);
  }

  if(result.rows.item(0) == null) {
      return "0";
  } else {
      return result.rows.item(0).value;
  }
}

function readSumByDate(table, mac, date) {
  var database = openDatabase();
  var result = null;

  try {
    database.transaction(function (tx) {
        result = tx.executeSql(
                    'SELECT SUM(value) as sum_val FROM ' + table + ' WHERE mac == "' + mac + '" AND date LIKE "' + date + '%" ORDER BY id DESC LIMIT 1;');
    })
  } catch (err) {
      console.log("Error reading from database: " + err);
  }

  if(result.rows.item(0) == null) {
      return "0";
  } else {
      return result.rows.item(0).sum_val;
  }
}

//****************************************
//**           Write functions          **
//****************************************

function createWatch(values) {
  var database = openDatabase();

  if(readByMAC("watches", values[0]).rows.length == 0) {
    try {
      database.transaction(function (tx) {
          tx.executeSql('INSERT INTO watches (mac, devicename, firmware,firmwareVersion) VALUES (?, ?, ?, ?)', values)
      })
    } catch (err) {
        console.log("Error writing to database: " + err);
    }
  }
}

function writeStats(table, values) {
  var database = openDatabase();

  try {
    database.transaction(function (tx) {
        tx.executeSql('INSERT INTO ' + table + ' (date, mac, value) VALUES (?, ?, ?)', values)
    })
  } catch (err) {
      console.log("Error writing to database: " + err);
  }
}

//****************************************
//**          Delete functions          **
//****************************************

function deleteByID(table, id) {
  var database = openDatabase();

  try {
    database.transaction(function (tx) {
        tx.executeSql('DELETE FROM ' + table + ' WHERE id == ' + id)
    })
  } catch (err) {
      console.log("Error writing to database: " + err);
  }
}

function deleteByMAC(table, mac) {
  var database = openDatabase();

  try {
    database.transaction(function (tx) {
        tx.executeSql('DELETE FROM ' + table + ' WHERE mac == "' + mac + '";')
    })
  } catch (err) {
      console.log("Error writing to database: " + err);
  }
}

//****************************************
//**         Update functions           **
//****************************************

function update(id, table, column, value) {
  var database = openDatabase();

  try {
    database.transaction(function (tx) {
        tx.executeSql('UPDATE ' + table + ' SET ' + column + ' = "' + value + '" WHERE id == ' + id + ';')
    })
  } catch (err) {
      console.log("Error updating the database: " + err);
  }
}
