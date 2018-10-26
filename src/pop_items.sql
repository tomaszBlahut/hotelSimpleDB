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