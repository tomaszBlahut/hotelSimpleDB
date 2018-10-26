create table project1.guest 
(guestId serial primary key, 
firstName varchar(40) not null, 
surname varchar(40) not null, 
creditCard varchar(40), 
handicap boolean not null, 
email varchar(40), 
phoneNumber char(12) not null,
isDeleted boolean not null default false);