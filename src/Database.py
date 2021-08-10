import sqlite3 as db
from os import path, mkdir

connection = None


def exists(appDataPath):
    appDataPath = appDataPath.replace("file://", "")
    databasePath = appDataPath + "/Database"

    if(path.exists(databasePath + "/uWatch.db") is True):
        return True
    else:
        return False


def open(appDataPath):
    appDataPath = appDataPath.replace("file://", "")
    databasePath = appDataPath + "/Database"

    if(path.exists(appDataPath) is False):
        mkdir(appDataPath)

    if(path.exists(databasePath) is False):
        mkdir(databasePath)

    # Will try to open the database and creates it, if it doesn't exist
    global connection
    connection = db.connect(databasePath + "/uWatch.db")

    # connection.total_changes will output the total amount of changes made
    # after the database was opened.
    # Immediately after opening the database no changes were made but the value
    # could be retriefed and therefore the database was successfully opened.
    if(connection.total_changes == 0):
        return True
    else:
        return False


def apply():
    connection.commit()


def close():
    connection.close()


def createTableQuery(tableName, columns, primarykey):
    query = "CREATE TABLE " + tableName + " ("

    for column in columns:
        query += column["name"] + " " + column["type"] + ", "

    query += "PRIMARY KEY ("

    for key in primarykey:
        query += key["name"] + ", "

    query = query[0:len(query)-2]
    query += "));"

    print("Query:", query)

    return query


def createInsertQuery(tableName, columns, values):
    query = "INSERT INTO " + tableName + " ("

    for column in columns:
        query += column + ", "

    query = query[0:len(query)-2]
    query += ") VALUES ("

    for value in values:
        query += "'" + value + "', "

    query = query[0:len(query)-2]
    query += ");"

    return query


def createSelectQuery(tableName, columns, joins, conditions, sort):
    query = "SELECT "

    for column in columns:
        query += column + ", "

    query = query[0:len(query)-2]
    query += " FROM " + tableName

    for join in joins:
        query += " " + join

    if conditions != "":
        query += " " + conditions

    if sort != "":
        query += " " + sort

    query += ";"
    return query
