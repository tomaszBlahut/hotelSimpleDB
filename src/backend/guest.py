import json
from dbHelpers import executeQuery

def registerGuest(jsonParams):
	try:
		query = "select * from project1.register('"
		query += jsonParams['firstName'] + "','"
		query += jsonParams['surname'] + "','"
		query += jsonParams['creditCard'] + "',"
		query += jsonParams['handicap'] + ",'"
		query += jsonParams['email'] + "','"
		query += jsonParams['phoneNumber'] + "');"
	except:
		with open("log.txt", "a") as myfile:
			myfile.write(query + "\n")
	return executeQuery(query)

def showGuestBookings(jsonParams):
	return executeQuery("select * from project1.getAllBookingsForGuest(" + jsonParams['guestId'] + ");")

def canGuestEnterCanteen(jsonParams):
	return executeQuery("select * from project1.canGuestEnterCanteen(" + jsonParams['guestId'] + ");")

def getGuestInfo(jsonParams):
	return executeQuery("select * from project1.guest;")
