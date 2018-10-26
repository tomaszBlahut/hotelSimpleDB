create or replace view project1.bookingInfo as
select b.bookingId, b.startDate, b.endDate, b.createDate, b.isClosed, g.guestId, g.firstName, g.surname, g.handicap, g.phoneNumber, r.roomNumber, r.name as roomName, rc.capacity as roomCapacity, rc.cost, rc.comfort, rc.name as categoryName, bc.checkIn, bc.checkOut
from project1.booking as b 
    join project1.guest as g on b.guestId = g.guestId 
    join project1.room as r on r.roomId = b.roomId 
    join project1.roomCategory as rc on r.roomCategoryId = rc.roomCategoryId
    join project1.bookingCheck as bc on bc.bookingId = b.bookingId;

create or replace view project1.bookingInfoHistory as
select b.bookingId, b.startDate, b.endDate, b.createDate, b.isClosed, g.guestId, g.firstName, g.surname, g.handicap, g.phoneNumber, r.roomNumber, r.name as roomName, rc.capacity as roomCapacity, rc.cost, rc.comfort, rc.name as categoryName, bc.checkIn, bc.checkOut, ei.firstName as checkInEmployeeName, ei.surname as checkInEmployeeSurname, eo.firstName as checkOutEmployeeName, eo.surname as checkOutEmployeeSurname
from project1.booking as b 
    join project1.guest as g on b.guestId = g.guestId 
    join project1.room as r on r.roomId = b.roomId 
    join project1.roomCategory as rc on r.roomCategoryId = rc.roomCategoryId
    join project1.bookingCheck as bc on bc.bookingId = b.bookingId
    join project1.employee as ei on bc.checkInEmployeeId = ei.employeeId
    join project1.employee as eo on bc.checkOutEmployeeId = eo.employeeId
where bc.checkInEmployeeId IS NOT NULL and bc.checkOutEmployeeId IS NOT NULL;

create or replace view project1.roomInfo as
select r.roomId, r.roomNumber, r.name as roomName, rc.capacity as roomCapacity, rc.cost, rc.comfort, rc.name as categoryName
from project1.room as r join project1.roomCategory as rc on r.roomCategoryId = rc.roomCategoryId;

create or replace view project1.employeeInfo as
select e.employeeId, e.firstName, e.surname, e.bankAccountNumber, r.name as roleName, r.importance, r.salary
from project1.employee as e join project1.role as r on e.roleId = r.roleId;