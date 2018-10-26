create table project1.extras_booking 
(extras_bookingId serial primary key, 
extrasId int not null, 
bookingId int not null, 
foreign key (extrasId) references project1.extras(extrasId), 
foreign key (bookingId) references project1.booking(bookingId));