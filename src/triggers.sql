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