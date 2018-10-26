import json
from dbHelpers import executeQuery

def getBookingsForRoom(jsonParams):
	return executeQuery("select * from project1.roomBookings(" + jsonParams['roomId'] + ");")

def getBookingsForRoomInDateRange(jsonParams):
	return executeQuery("select * from project1.roomBookingsDateRange(" + jsonParams['roomId'] + ",'" + jsonParams['startDate'] + "','" + jsonParams['endDate'] + "');")

def addBooking(jsonParams):
	query = "select * from project1.bookRoom("
	query += jsonParams['roomId'] + ","
	query += jsonParams['guestId'] + ",'"
	query += jsonParams['startDate'] + "','"
	query += jsonParams['endDate'] + "','"
	query += jsonParams['extras'] + "');"
	return executeQuery(query);

def showActualBookingsForCategory(jsonParams):
	return executeQuery("select * from project1.roomCategoryActualBookings('" + jsonParams['categoryName'] + "');")

def showActualBookingsForComfortMin(jsonParams):
	return executeQuery("select * from project1.roomComfortMinActualBookings(" + jsonParams['comfort'] + ");")

def showActualBookingsForComfort(jsonParams):
	return executeQuery("select * from project1.roomComfortActualBookings(" + jsonParams['comfort'] + ");")

def showActualBookingsForCapacity(jsonParams):
	return executeQuery("select * from project1.roomCapacityActualBookings(" + jsonParams['capacity'] + ");")
	
def closeBooking(jsonParams):
	return executeQuery("select * from project1.closeBooking(" + jsonParams['bookingId'] + "," + jsonParams['userId'] + ");")

def changeBooking(jsonParams):
	query = "select * from project1.changeBooking("
	query += jsonParams['bookingId'] + ","
	query += jsonParams['roomId'] + ","
	query += "null," if jsonParams['startDate'] == "null" else "'" + jsonParams['startDate'] + "',"
	query += "null," if jsonParams['endDate'] == "null"  else "'" + jsonParams['endDate'] + "',"
	query += "null," if jsonParams['extras'] == "null" else "'" + jsonParams['extras'] + "',"
	query += jsonParams['userId'] + ");"
	return executeQuery(query)

def checkInBooking(jsonParams):
	return executeQuery("select * from project1.checkInBooking(" + jsonParams['bookingId'] + "," + jsonParams['userId'] + ");")

def checkOutBooking(jsonParams):
	return executeQuery("select * from project1.checkOutBooking(" + jsonParams['bookingId'] + "," + jsonParams['userId'] + ");")

def getGetCountOfActiveBookingsWithExtras(jsonParams):
	return executeQuery("select * from project1.countOfActiveBookingWithExtras(" + jsonParams['extrasId'] + ");")

def getTotalCostOfBooking(jsonParams):
	return executeQuery("select * from project1.getTotalCostOfBooking(" + jsonParams['bookingId'] + ");")
	
def getBookingInfoHistory(jsonParams):
	return executeQuery("select * from project1.bookingInfoHistory;")

def getBookingInfo(jsonParams):
	return executeQuery("select * from project1.bookingInfo;")

def getBookingInfoWithId(jsonParams):
	return executeQuery("select * from project1.booking where bookingId = " + jsonParams['bookingId'] + ";")

def getExtrasForBooking(jsonParams):
	return executeQuery("select * from project1.extras_booking where bookingId =" + jsonParams['bookingId'] + ";")

	
