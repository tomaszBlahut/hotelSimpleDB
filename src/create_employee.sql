create table project1.employee 
(employeeId serial primary key, 
firstName varchar(40) not null, 
surName varchar(40), 
bankAccountNumber char(26), 
roleId int not null, 
foreign key (roleId) references project1.role(roleId));