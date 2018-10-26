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