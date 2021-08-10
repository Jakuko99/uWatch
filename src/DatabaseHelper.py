import JSONHelper
import json
import Database as db
import sys

########
# Main #
########


def exists(appDataPath):
    if db.exists(appDataPath):
        return True
    else:
        return False


def openDatabase(appDataPath):
    try:
        db.open(appDataPath)
        return True
    except Exception as e:
        return False


def isOpen():
    if db.connection is not None:
        return True
    else:
        return False


def getValues(tableName, columns, joins, conditions):
    if isOpen():
        cursor = db.connection.cursor()
        cursor.execute(db.createSelectQuery(
            tableName, columns, joins, conditions, ""))

        return cursor.fetchall()


def getLastValue(tableName, columns, joins, conditions, orderBy):
    if isOpen():
        cursor = db.connection.cursor()
        cursor.execute(db.createSelectQuery(tableName, columns,
                                            joins, conditions, orderBy))

        return cursor.fetchone()


def insertValues(tableName, columns, values):

    if isOpen():
        try:
            cursor = db.connection.cursor()
            cursor.execute(db.createInsertQuery(tableName, columns, values))
            db.apply()
            return True
        except Exception as e:
            print("Error:", e)
            return False
    return False

########################################
# Initial setup to create the database #
########################################


def createDatabase(appDataPath, node):
    if openDatabase(appDataPath):
        tables = getDatabaseTableNameFromJSON(node)

        for table in tables:
            cursor = db.connection.cursor()
            cursor.execute(db.createTableQuery(
                table["name"], getTableColumns(json.dumps(table)), getTablePrimaryKeys(json.dumps(table))))

        db.apply()


def getDatabaseTableNameFromJSON(root):
    return json.loads(root)["tables"]


def getTableColumns(root):
    return json.loads(root)["columns"]


def getTablePrimaryKeys(root):
    return json.loads(root)["primarykey"]
