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
                      'mac TEXT, '+
                      'date TEXT, '+
                      'value INTEGER)');
        tx.executeSql('CREATE TABLE IF NOT EXISTS steps('+
                      'id INTEGER PRIMARY KEY, '+
                      'mac TEXT, '+
                      'date TEXT, '+
                      'value INTEGER)');
        tx.executeSql('CREATE TABLE IF NOT EXISTS heartrate('+
                      'id INTEGER PRIMARY KEY, '+
                      'mac TEXT, '+
                      'date TEXT, '+
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
                    'SELECT * FROM ? ORDER BY id DESC LIMIT 1', [table])
    })
  } catch (err) {
      console.log("Error reading from database: " + err);
  }

  return result.rows.item(0).id;
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

//****************************************
//**           Write functions          **
//****************************************

function createWatch(values) {
  var database = openDatabase();

  try {
    database.transaction(function (tx) {
        tx.executeSql('INSERT INTO watches (mac, devicename, firmware,firmwareVersion) VALUES (?, ?, ?, ?)', values)
    })
  } catch (err) {
      console.log("Error writing to database: " + err);
  }
}

function writeStats(table, values) {
  var database = openDatabase();

  try {
    database.transaction(function (tx) {
        tx.executeSql('INSERT INTO ' + table + ' (mac, date, value) VALUES (?, ?, ?)', values)
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
        tx.executeSql('DELETE FROM ? WHERE mac == ?;', [table, mac])
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
        tx.executeSql('UPDATE ? SET ? = ? WHERE id == ?;', [table, column, value, id])
    })
  } catch (err) {
      console.log("Error updating the database: " + err);
  }
}
