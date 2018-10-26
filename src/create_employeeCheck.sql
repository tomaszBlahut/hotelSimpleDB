create table project1.employeeCheck 
(employeeCheckId serial primary key, 
employeeId int not null, 
checkDate timestamp not null, 
isCheckIn boolean not null, 
foreign key (employeeId) references project1.employee(employeeId));