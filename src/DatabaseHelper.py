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
                table["name"], getTableColumns(json.dumps(table))))


def getDatabaseTableNameFromJSON(root):
    return json.loads(root)["tables"]


def getTableColumns(root):
    return json.loads(root)["columns"]


def createTableQuery(name, columns):
    query = "CREATE TABLE " + name + " ("

    for column in columns:
        line = column["name"] + " " + column["type"]
        if column["primarykey"] == "true":
            line += " PRIMARY KEY"

        line += ", "
        query += line

    query = query[0:len(query)-2]
    query += ");"
    return query
