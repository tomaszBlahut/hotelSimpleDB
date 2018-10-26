-- Test: blockCreateReservationOfNotExistingRoom

insert into project1.booking (roomId, guestId, startDate, endDate)
values (66, 1, '3-3-2018', '4-3-2018');
select count(*) as blockCreateReservationOfNotExistingRoom from project1.booking where roomId = 66;

-- Test: closeBookingAfterDeleteGuest

insert into project1.guest 
values (123, 'Trigger', 'test', null, false, null, '+48123123123');

insert into project1.booking (roomId, guestId, startDate, endDate)
values (1, 123, '3-3-2018', '4-3-2018');

delete from project1.guest where guestId = 123;

select isClosed as closeBookingAfterDeleteGuest from project1.booking where guestId = 123;
select isDeleted as softDelete from project1.guest where guestId = 123;
delete from project1.booking where guestId = 123;

ALTER TABLE project1.guest DISABLE TRIGGER closeBookingAfterSoftDeleteGuest;
delete from project1.guest where guestId = 123;
ALTER TABLE project1.guest ENABLE TRIGGER closeBookingAfterSoftDeleteGuest;

-- Test: deleteEmployeeChecksAfterDeleteEmployee

insert into project1.employee values (123, 'Trigger', 'test', null, 3);
insert into project1.employeeCheck (employeeId, checkDate, isCheckIn)
values (123, '3-3-2018', true);

delete from project1.employee where employeeId = 123;

select count(*) as deleteEmployeeChecksAfterDeleteEmployee from project1.employeeCheck where employeeId = 123;

-- Test: freeBookingAfterCheckOut

insert into project1.guest 
values (123, 'Trigger', 'test', null, false, null, '+48123123123');

insert into project1.booking (bookingId, roomId, guestId, startDate, endDate)
values (123, 1, 123, '3-3-2018', '4-3-2018');

insert into project1.bookingCheck (bookingId, checkIn, checkInEmployeeId)
values (123, '3-3-2018', 1);
update project1.bookingCheck set checkOut = '3-3-2018' where bookingId = 123;
select endDate as freeBookingAfterCheckOut from project1.booking where bookingId = 123;

delete from project1.bookingCheck where bookingId = 123;
delete from project1.booking where guestId = 123;
ALTER TABLE project1.guest DISABLE TRIGGER closeBookingAfterSoftDeleteGuest;
delete from project1.guest where guestId = 123;
ALTER TABLE project1.guest ENABLE TRIGGER closeBookingAfterSoftDeleteGuest;

-- Test: disableDeleteOwner

delete from project1.employee where employeeId = 1;
select count(*) as disableDeleteOwner from project1.employee where employeeId = 1;