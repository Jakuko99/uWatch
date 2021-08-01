import sqlite3 as db
from os import path, mkdir

connection = None
cursor = None


def open(appDataPath):
    appDataPath = appDataPath.replace("file://", "")
    databasePath = appDataPath + "/Database"

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
        global cursor
        cursor = connection.cursor()
        return True
    else:
        return False


def execute(query):
    print("Executing query: " + query)

    cursor.execute(query)
    connection.commit()


def close():
    connection.close()
