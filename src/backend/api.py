#!/usr/bin/env python
import cgi
import json

import bookings
import employee
import guest
import room

form = cgi.FieldStorage()

jsonToDecode = form.getvalue("json", "{}")
jsonDecoded = json.loads(jsonToDecode)

routerOption = {'getBookingsForRoom': bookings.getBookingsForRoom,
				'getBookingsForRoomInDateRange': bookings.getBookingsForRoomInDateRange,
				'registerGuest': guest.registerGuest,
				'addBooking': bookings.addBooking,
				'showGuestBookings': guest.showGuestBookings,
				'showActualBookingsForCategory': bookings.showActualBookingsForCategory,
				'showActualBookingsForComfort': bookings.showActualBookingsForComfort,
				'showActualBookingsForComfortMin': bookings.showActualBookingsForComfortMin,
				'showActualBookingsForCapacity': bookings.showActualBookingsForCapacity,
				'checkInEmployee': employee.checkInEmployee,
				'checkOutEmployee': employee.checkOutEmployee,
				'addEmployee': employee.addEmployee,
				'removeEmployee': employee.removeEmployee,
				'listEmployees': employee.listEmployees,
				'closeBooking': bookings.closeBooking,
				'changeBooking': bookings.changeBooking,
				'checkInBooking': bookings.checkInBooking,
				'checkOutBooking': bookings.checkOutBooking,
				'canGuestEnterCanteen': guest.canGuestEnterCanteen,
				'getGetCountOfActiveBookingsWithExtras': bookings.getGetCountOfActiveBookingsWithExtras,
				'getTotalCostOfBooking': bookings.getTotalCostOfBooking,
				'roomInfo': room.roomInfo,
				'getBookingInfoHistory': bookings.getBookingInfoHistory,
				'getBookingInfo': bookings.getBookingInfo,
				'getGuestInfo': guest.getGuestInfo,
				'getRoomCategories': room.getRoomCategories,
				'getExtras': room.getExtras,
				'getBookingInfoWithId': bookings.getBookingInfoWithId,
				'getExtrasForBooking': bookings.getExtrasForBooking,
				'getRoles': employee.getRoles}

print "Content-type: application/json"
print ""

print routerOption[jsonDecoded['endpoint']](jsonDecoded);
