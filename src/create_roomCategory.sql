create table project1.roomCategory 
(roomCategoryId serial primary key, 
capacity int not null, 
cost real not null, 
comfort int, 
name varchar(40) not null);