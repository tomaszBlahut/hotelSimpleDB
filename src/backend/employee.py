import json
from dbHelpers import executeQuery

def checkInEmployee(jsonParams):
	return executeQuery("select * from project1.checkInEmployee(" + jsonParams['employeeId'] + ");")

def checkOutEmployee(jsonParams):
	return executeQuery("select * from project1.checkOutEmployee(" + jsonParams['employeeId'] + ");")

def removeEmployee(jsonParams):
	return executeQuery("select * from project1.removeEmployee(" + jsonParams['employeeId'] + "," + jsonParams['userId'] + ");")

def listEmployees(jsonParams):
	return executeQuery("select * from project1.employeeInfo;")

def addEmployee(jsonParams):
	query = "select * from project1.addEmployee('"
	query += jsonParams['firstName'] + "','"
	query += jsonParams['surname'] + "','"
	query += jsonParams['bankAccountNumber'] + "',"
	query += jsonParams['roleId'] + ","
	query += jsonParams['userId'] + ");"
	return executeQuery(query)

def getRoles(jsonParams):
	return executeQuery("select * from project1.role;")
