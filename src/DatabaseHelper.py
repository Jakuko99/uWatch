import JSONHelper
import json
import Database as db

#################
# Initial setup #
#################


def createDatabase(appDataPath, node):
    if db.open(appDataPath):
        tables = getDatabaseTableNameFromJSON(node)

        for table in tables:
            db.execute(createTableQuery(
                table["name"], getTableColumns(json.dumps(table)), getTablePrimaryKeys(json.dumps(table))))

        db.apply()


def getDatabaseTableNameFromJSON(root):
    return json.loads(root)["tables"]


def getTableColumns(root):
    return json.loads(root)["columns"]


def getTablePrimaryKeys(root):
    return json.loads(root)["primarykey"]


def createTableQuery(tableName, columns, primarykey):
    query = "CREATE TABLE " + tableName + " ("

    for column in columns:
        query += column["name"] + " " + column["type"] + ", "

    query += "PRIMARY KEY ("

    for key in primarykey:
        query += key["name"] + ", "

    query = query[0:len(query)-2]
    query += "));"
    print(query)
    return query
