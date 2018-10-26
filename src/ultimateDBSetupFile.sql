--- Prune and create schema

drop schema project1 cascade;
create schema project1;

--- Creation of tables

create table project1.roomCategory 
(roomCategoryId serial primary key, 
capacity int not null, 
cost real not null, 
comfort int, 
name varchar(40) not null);

create table project1.room 
(roomId serial primary key, 
roomNumber int not null, 
name varchar(40) not null, 
roomCategoryId int not null, 
foreign key (roomCategoryId) references project1.roomCategory(roomCategoryId));

create table project1.guest 
(guestId serial primary key, 
firstName varchar(40) not null, 
surname varchar(40) not null, 
creditCard varchar(40), 
handicap boolean not null, 
email varchar(40), 
phoneNumber char(12) not null,
isDeleted boolean not null default false);

create table project1.extras 
(extrasId serial primary key, 
name varchar(40) not null,
cost real not null);

create table project1.role 
(roleId serial primary key, 
name varchar(40) not null, 
importance int not null, 
salary real not null);

create table project1.employee 
(employeeId serial primary key, 
firstName varchar(40) not null, 
surName varchar(40), 
bankAccountNumber char(26), 
roleId int not null, 
foreign key (roleId) references project1.role(roleId));

create table project1.employeeCheck 
(employeeCheckId serial primary key, 
employeeId int not null, 
checkDate timestamp not null, 
isCheckIn boolean not null, 
foreign key (employeeId) references project1.employee(employeeId));

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

create table project1.extras_booking 
(extras_bookingId serial primary key, 
extrasId int not null, 
bookingId int not null, 
foreign key (extrasId) references project1.extras(extrasId), 
foreign key (bookingId) references project1.booking(bookingId));

--- Create views

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

--- Create functions

create or replace function project1.roomBookings(roomIdP int)
returns table (roomId int, roomNumber int, roomName varchar(40), startDate date, endDate date)
as $$
    begin   
        return query
        select r.roomId, r.roomNumber, r.name, b.startDate, b.endDate
        from project1.room as r join project1.booking as b on r.roomId = b.roomId
        where r.roomId = roomIdP;
    end;
$$
language 'plpgsql';

create or replace function project1.roomBookingsDateRange(roomIdP int, startDateP date, endDateP date)
returns table (roomId int, roomNumber int, roomName varchar(40), startDate date, endDate date)
as $$
    begin   
        if startDateP is NULL then
            startDateP := CURRENT_DATE;
        end if;
        if endDateP is NULL then
            endDateP := cast(CURRENT_DATE + interval '1 month' as date);
        end if;
        return query
        select r.roomId, r.roomNumber, r.name, b.startDate, b.endDate
        from project1.room as r join project1.booking as b on r.roomId = b.roomId
        where r.roomId = roomIdP
            and b.startDate >= startDateP
            and b.endDate <= endDateP
            and b.isClosed is false;
    end;
$$
language 'plpgsql';

create or replace function project1.register(firstNameP varchar(40), surnameP varchar(40), creditCardP varchar(40), handicapP boolean, emailP varchar(40), phoneNumberP varchar(12), out newGuestId int)
as $$
    begin
        if handicapP is NULL then
            handicapP := false;
        end if;

        insert into project1.guest (firstName, surname, creditCard, handicap, email, phoneNumber)
        values (firstNameP, surnameP, creditCardP, handicapP, emailP, phoneNumberP) returning guestId into newGuestId;
        return;
    end;
$$
language 'plpgsql';

create or replace function project1.bookRoom(roomIdP int, guestIdP int, startDateP date, endDateP date, extras varchar(40))
returns int
as $$
    declare 
        newBookingId int;
        bookingsInGivenDateRange int;
        extrasArray text[];        
    begin
        if startDateP > endDateP or startDateP < CURRENT_DATE then
            return -1;
        end if;

        select count(*) into bookingsInGivenDateRange from project1.roomBookingsDateRange(roomIdP, startDateP, endDateP);

        if bookingsInGivenDateRange > 0 then
            return -2;
        end if;

        insert into project1.booking (roomId, guestId, startDate, endDate, createDate)
        values (roomIdP, guestIdP, startDateP, endDateP, CURRENT_DATE) returning bookingId into newBookingId;

        select into extrasArray string_to_array(extras, ';');

        for i in array_lower(extrasArray, 1)..array_upper(extrasArray, 1) loop
            insert into project1.extras_booking (extrasId, bookingId) 
            values (cast(extrasArray[i] as int), newBookingId);
        end loop;

        return newBookingId;

    exception
        when foreign_key_violation then
            return -3;
        when others then
            return -4;
    end;
$$
language 'plpgsql';

create or replace function project1.getAllBookingsForGuest(guestIdP int)
returns setof project1.bookingInfo
as $$
    begin
        return query
        select * from project1.bookingInfo where guestId = guestIdP order by createDate;
    end;
$$
language 'plpgsql';

create or replace function project1.roomCategoryActualBookings(categoryNameP varchar(40))
returns setof project1.bookingInfo
as $$
    begin   
        return query
        select * from project1.bookingInfo 
            where categoryName = categoryNameP and startDate >= CURRENT_DATE 
            order by createDate;
    end;
$$
language 'plpgsql';

create or replace function project1.roomComfortActualBookings(comfortP int)
returns setof project1.bookingInfo
as $$
    begin   
        return query
        select * from project1.bookingInfo 
            where comfort = comfortP and startDate >= CURRENT_DATE 
            order by createDate;
    end;
$$
language 'plpgsql';

create or replace function project1.roomComfortMinActualBookings(comfortP int)
returns setof project1.bookingInfo
as $$
    begin   
        return query
        select * from project1.bookingInfo 
            where comfort >= comfortP and startDate >= CURRENT_DATE 
            order by createDate;
    end;
$$
language 'plpgsql';

create or replace function project1.roomCapacityActualBookings(capacityP int)
returns setof project1.bookingInfo
as $$
    begin   
        return query
        select * from project1.bookingInfo 
            where capacity = capacityP and startDate >= CURRENT_DATE 
            order by createDate;
    end;
$$
language 'plpgsql';

create or replace function project1.checkInEmployee(employeeIdP int)
returns void
as $$
    begin   
        insert into project1.employeeCheck (employeeId, checkDate, isCheckIn) 
            values (employeeIdP, CURRENT_TIMESTAMP, true);
    end;
$$
language 'plpgsql';

create or replace function project1.checkOutEmployee(employeeIdP int)
returns void
as $$
    begin  
        insert into project1.employeeCheck (employeeId, checkDate, isCheckIn) 
            values (employeeIdP, CURRENT_TIMESTAMP, false);
    end;
$$
language 'plpgsql';

create or replace function project1.getImportanceOfEmployee(employeeIdP int, out importancy int)
as $$
    begin        
        select importance into importancy from project1.employeeInfo where employeeId = employeeIdP;
        if importancy is NULL then
            importancy := -1;
        end if;
    end;
$$
language 'plpgsql';

create or replace function project1.addEmployee(firstNameP varchar(40), surnameP varchar(40), bankAccountNumberP varchar(40), roleIdP int, userId int)
returns int
as $$
    declare
        newEmployeeId int;
    begin
        if project1.getImportanceOfEmployee(userId) < 750 then
            return -1;
        end if;

        insert into project1.employee (firstName, surname, bankAccountNumber, roleId)
            values (firstNameP, surnameP, bankAccountNumberP, roleIdP)
            returning employeeId into newEmployeeId;
        return newEmployeeId;
    end;
$$
language 'plpgsql';

create or replace function project1.removeEmployee(employeeIdP int, userId int)
returns int
as $$
    begin
        if project1.getImportanceOfEmployee(userId) < 750 then
            return -1;
        end if;

        delete from project1.employee where employeeId = employeeIdP;
        return employeeIdP;
    end;
$$
language 'plpgsql';

create or replace function project1.closeBooking(bookingIdP int, userId int)
returns boolean
as $$
    begin
        if project1.getImportanceOfEmployee(userId) < 250 and not project1.isEmployeeInWork(userId) then
            return false;
        end if;

        update project1.booking set isClosed = true where bookingId = bookingIdP;
        return true;
    end;
$$
language 'plpgsql';

create or replace function project1.changeBooking(bookingIdP int, roomIdP int, startDateP date, endDateP date, extras varchar(40), userId int)
returns int
as $$
    declare
        changeNumber int;
        reservations int;
        extrasArray text[];  
    begin
        changeNumber := 0;
        if project1.getImportanceOfEmployee(userId) < 250 and not project1.isEmployeeInWork(userId) then
            return -1;
        end if;

        if roomIdP is NULL then
            select roomId into roomIdP from project1.booking where bookingId = bookingIdP;
        else
            changeNumber := changeNumber +1;
        end if;

        if startDateP is NULL then
            select startDate into startDateP from project1.booking where bookingId = bookingIdP;
        else
            changeNumber := changeNumber +1;
        end if;

        if endDateP is NULL then
            select endDate into endDateP from project1.booking where bookingId = bookingIdP;
        else
            changeNumber := changeNumber +1;
        end if;

        select count(*) into reservations from project1.roomBookingsDateRange(roomIdP, startDateP, endDateP);
        if reservations > 1 then
            return -2;
        end if;

        if extras is NOT NULL then
            delete from project1.extras_booking where bookingId = bookingIdP;

            select into extrasArray string_to_array(extras, ';');

            for i in array_lower(extrasArray, 1)..array_upper(extrasArray, 1) loop
                insert into project1.extras_booking (extrasId, bookingId) 
                values (cast(extrasArray[i] as int), bookingIdP);
            end loop;
        end if;

        update project1.booking set endDate = endDateP, startDate = startDateP, roomId = roomIdP where bookingId = bookingIdP;
        return changeNumber;
    end;
$$
language 'plpgsql';

create or replace function project1.isEmployeeInWork(employeeIdP int, out isInWork boolean)
as $$
    begin
        select isCheckIn into isInWork 
        from project1.employeeCheck 
        where checkDate = (select max(checkDate) from project1.employeeCheck where employeeId = employeeIdP);
    end;
$$
language 'plpgsql';

create or replace function project1.checkInBooking(bookingIdP int, userId int)
returns boolean
as $$
    begin
        if project1.getImportanceOfEmployee(userId) > 50 and project1.isEmployeeInWork(userId) then
            update project1.bookingCheck set checkInEmployeeId = userId, checkIn = CURRENT_DATE where bookingId = bookingIdP;
            return true;
        else
            return false;
        end if;
    end;
$$
language 'plpgsql';


create or replace function project1.checkOutBooking(bookingIdP int, userId int)
returns boolean
as $$
    begin
        if project1.getImportanceOfEmployee(userId) > 50 and project1.isEmployeeInWork(userId) then
            update project1.bookingCheck set checkOutEmployeeId = userId, checkOut = CURRENT_DATE where bookingId = bookingIdP;
            return true;
        else
            return false;
        end if;
    end;
$$
language 'plpgsql';

create or replace function project1.canGuestEnterCanteen(guestIdP int, out canEnter boolean)
as $$
    begin
        select count(*) > 0 
            into canEnter
        from project1.booking b 
            join project1.bookingCheck bc on b.bookingId = bc.bookingId 
            join project1.extras_booking eb on eb.bookingId = b.bookingId 
        where b.guestId = guestIdP 
            and checkIn is not null 
            and checkOut is null 
            and extrasId = 1
            and checkIn <= CURRENT_DATE;
    end;
$$
language 'plpgsql';

create or replace function project1.countOfActiveBookingWithExtras(extrasIdP int, out count int)
as $$
    begin
        select count(*) 
            into count
        from project1.bookingInfo bi 
            join project1.extras_booking eb on bi.bookingId = eb.bookingId
        where checkIn is not null 
            and checkOut is null
            and checkIn <= CURRENT_DATE
        group by eb.extrasId
        having eb.extrasId = extrasIdP;
    end;
$$
language 'plpgsql';

create or replace function project1.getTotalCostOfBooking(bookingIdP int)
returns real
as $$
    declare
        costOfRoom real;
        costOfExtras real;
    begin
        select cost 
            into costOfRoom 
        from project1.bookingInfo 
        where bookingId = bookingIdP;

        select sum(cost) 
            into costOfExtras
        from project1.bookingInfo bi 
            join project1.extras_booking eb on bi.bookingId = eb.bookingId
        where eb.bookingId = bookingIdP;

        if costOfExtras is NULL then
            costOfExtras := 0.0;
        end if;

        return costOfRoom + costOfExtras;
    end;
$$
language 'plpgsql';

--- Create triggers

create or replace function project1.blockCreateReservationOfNotExistingRoomFunc()
returns trigger
as $$
    declare
        roomExists int;
    begin
        select count(*) into roomExists from project1.room as r where r.roomId = NEW.roomId;
        if roomExists > 0 then
            return NEW;
        else
            return NULL;
        end if;
    end;
$$
language 'plpgsql';

create trigger blockCreateReservationOfNotExistingRoom before insert on project1.booking
for each row execute procedure project1.blockCreateReservationOfNotExistingRoomFunc();

---

create or replace function project1.closeBookingAfterSoftDeleteGuestFunc()
returns TRIGGER
as $$
    begin
        update project1.booking set isClosed = true where guestId = OLD.guestId;
        update project1.guest set isDeleted = true where guestId = OLD.guestId;
        return NULL;
    end;
$$
language 'plpgsql';

create trigger closeBookingAfterSoftDeleteGuest before delete on project1.guest
for each row execute procedure project1.closeBookingAfterSoftDeleteGuestFunc();

---

create or replace function project1.deleteEmployeeChecksAfterDeleteEmployeeFunc()
returns TRIGGER
as $$
    begin
        delete from project1.employeeCheck where employeeId = OLD.employeeId;
        return OLD;
    end;
$$
language 'plpgsql';

create trigger deleteEmployeeChecksAfterDeleteEmployee before delete on project1.employee
for each row execute procedure project1.deleteEmployeeChecksAfterDeleteEmployeeFunc();

---

create or replace function project1.freeBookingAfterCheckOutFunc()
returns TRIGGER
as $$
    begin
        if NEW.checkOut IS NOT NULL then
            update project1.booking set endDate = NEW.checkOut where bookingId = NEW.bookingId;
        end if;
        return NULL;
    end;
$$
language 'plpgsql';

create trigger freeBookingAfterCheckOut after update on project1.bookingCheck
for each row execute procedure project1.freeBookingAfterCheckOutFunc();

---

create or replace function project1.disableDeleteOwnerFunc()
returns TRIGGER
as $$
    begin
        if OLD.employeeId = 1 then
            return NULL;
        else
            return OLD;
        end if;
    end;
$$
language 'plpgsql';

create trigger disableDeleteOwner before delete on project1.employee
for each row execute procedure project1.disableDeleteOwnerFunc();

---

create or replace function project1.createBookingCheckOnBookingCreateFunc()
returns TRIGGER
as $$
    begin
        insert into project1.bookingCheck (bookingId) values (NEW.bookingId);
        return NULL;
    end;    
$$
language 'plpgsql';

create trigger createBookingCheckOnBookingCreate after insert on project1.booking
for each row execute procedure project1.createBookingCheckOnBookingCreateFunc();

--- Pop initial data

delete from project1.extras_booking      ;
delete from project1.bookingcheck        ;
delete from project1.booking             ;
delete from project1.employeecheck       ;
ALTER TABLE project1.employee DISABLE TRIGGER disableDeleteOwner;
delete from project1.employee            ;
ALTER TABLE project1.employee ENABLE TRIGGER disableDeleteOwner;
delete from project1.role                ;
delete from project1.extras              ;
ALTER TABLE project1.guest DISABLE TRIGGER closeBookingAfterSoftDeleteGuest;
delete from project1.guest               ;
ALTER TABLE project1.guest ENABLE TRIGGER closeBookingAfterSoftDeleteGuest;
delete from project1.room                ;
delete from project1.roomcategory        ;

insert into project1.roomcategory values (1, 1, 200.0, 1, 'singleBieda');
insert into project1.roomcategory values (2, 1, 400.0, 3, 'singleMansion');
insert into project1.roomcategory values (3, 2, 300.0, 1, 'doubleBieda');
insert into project1.roomcategory values (4, 2, 600.0, 2, 'doubleUiarkowanaBieda');
insert into project1.roomcategory values (5, 3, 1000.0, 3, 'penthouse');
alter sequence project1.roomcategory_roomcategoryid_seq restart with 6;

insert into project1.room values (1, 101, 'bitek', 1);
insert into project1.room values (2, 102, 'bajtek', 1);
insert into project1.room values (3, 111, 'floatek', 2);
insert into project1.room values (4, 112, 'floajtek', 2);
insert into project1.room values (5, 201, 'triplet', 3);
insert into project1.room values (6, 211, 'tripletPlus', 4);
insert into project1.room values (7, 301, 'testo', 5);
insert into project1.room values (8, 302, 'klejnotNilu', 5);
insert into project1.room values (9, 303, 'blendzior', 5);
alter sequence project1.room_roomid_seq restart with 10;

insert into project1.role values (1, 'administrator', 1000, 15000);
insert into project1.role values (2, 'kieronwik', 500, 5000);
insert into project1.role values (3, 'recepcjonista', 100, 2500);
insert into project1.role values (4, 'sprzataczka', 0, 1500);
alter sequence project1.role_roleid_seq restart with 5;

insert into project1.employee values (1, 'Grazyna', 'Wspaniala', null, 1);
insert into project1.employee values (2, 'Janusz', 'Nosacz', null, 3);
insert into project1.employee values (3, 'Karyna', 'Osiedlowa', null, 3);
insert into project1.employee values (4, 'Mieciu', 'Podgladacz', null, 4);
insert into project1.employee values (5, 'Brajan', 'Fiutowski', null, 2);
alter sequence project1.employee_employeeid_seq restart with 6;

insert into project1.extras values (1, 'wyzywienie', 150.0);
insert into project1.extras values (2, 'dodatkowe lozko', 50.5);
alter sequence project1.extras_extrasid_seq restart with 3;

insert into project1.guest values (1, 'Gosc', 'Testowy', null, false, null, '+48123123123');
alter sequence project1.guest_guestid_seq restart with 2;

insert into project1.booking values (1, 1, 1, CURRENT_DATE - 5, CURRENT_DATE - 2, CURRENT_DATE - 7, false);
alter sequence project1.booking_bookingid_seq restart with 2;
select * from project1.bookRoom(8, 1, CURRENT_DATE, CURRENT_DATE + 5, '1;2');