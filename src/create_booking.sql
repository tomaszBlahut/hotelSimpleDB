create table project1.booking 
(bookingId serial primary key, 
roomId int not null, 
guestId int not null, 
startDate date not null, 
endDate date not null, 
createDate date, 
isClosed boolean default false, 
foreign key (roomId) references project1.room(roomId), 
foreign key (guestId) references project1.guest(guestId));