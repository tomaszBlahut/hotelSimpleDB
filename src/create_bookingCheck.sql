create table project1.bookingCheck 
(bookingCheckId serial primary key, 
bookingId int not null, 
checkIn date, 
checkOut date, 
checkInEmployeeId int, 
checkOutEmployeeId int, 
foreign key (bookingId) references project1.booking(bookingId), 
foreign key (checkInEmployeeId) references project1.employee(employeeId), 
foreign key (checkOutEmployeeId) references project1.employee(employeeId));