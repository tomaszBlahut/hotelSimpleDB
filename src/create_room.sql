create table project1.room 
(roomId serial primary key, 
roomNumber int not null, 
name varchar(40) not null, 
roomCategoryId int not null, 
foreign key (roomCategoryId) references project1.roomCategory(roomCategoryId));