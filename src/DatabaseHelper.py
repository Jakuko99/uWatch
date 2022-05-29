import sqlite3 as sqlite


def getValues(tableName, columns, joins, conditions, orderBy):
    database = sqlite.connect(
        "/home/phablet/.local/share/uwatch.jiho/Database/uWatch.db")

    print("Database is open.")
    cursor = database.cursor()
    cursor.execute(createSelectQuery(
        tableName, columns, joins, conditions, orderBy))

    return cursor.fetchall()


def createSelectQuery(tableName, columns, joins, conditions, sort):
    query = "SELECT "

    for column in columns:
        query += column + ', '

    query = query[0:len(query)-2]
    query += " FROM " + tableName

    for join in joins:
        query += " " + join

    if conditions != "":
        query += " " + conditions

    if sort != "":
        query += " " + sort

    query += ";"
    print(query)
    return query
