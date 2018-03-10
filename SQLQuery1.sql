CREATE DATABASE Hotel;
USE Hotel;
CREATE TABLE Client(Id_client int PRIMARY KEY,
					Nume      char(30),
					Email     varchar(50),
					Numar_tel varchar(17),
					);

CREATE TABLE Camera(Id_camera  int PRIMARY KEY,
					Nr_camera  char(4),
					Nr_Pers    char(1),
					Pret       money,
					);

CREATE TABLE Factura(Id_Factura int identity Primary key,
					Total money
)

CREATE TABLE Rezervare(Id_Rezervare int Primary key,
					Data_inceput  date,
					Data_sfarsit  date,
					Id_client  int foreign key references Client(Id_client),
					Id_Factura int UNIQUE FOREIGN KEY REFERENCES Factura(Id_Factura),
					Nr_camere varchar(1),
					)

CREATE TABLE Camere_Rezervate(Id_camera  int foreign key references Camera(Id_camera) on update cascade on delete cascade,
					Id_Rezervare  int foreign key references Rezervare(Id_rezervare) on update cascade on delete cascade,
					Stare bit,
					constraint pk_Camere_Rezervate primary key(Id_camera,Id_Rezervare)
					);

INSERT into Client values(1,'Alexandru','alexandru@yahoo.com',0745322455); 
INSERT into Client values(2,'Maria','maria@yahoo.com','0722314424');
INSERT into Client values(3,'Ioana','ioana@yahoo.com','0725847395');
INSERT into Client values(4,'George','george@gmail.com','0789389043');
INSERT into Client values(5,'Mihai','mihai@gmail.com','0789311143');
INSERT into Client values(6,'Vanesa','vanesa@gmail.com','0789322243');

INSERT into Camera values(1,'01','1',35);
INSERT into Camera values(2,'02','2',35);
INSERT into Camera values(3,'03','4',65);
INSERT into Camera values(4,'04','2',35);
INSERT into Camera values(5,'05','3',43);

set identity_insert Factura ON
insert into Factura(Id_Factura,Total)
values(1,35);
insert into Factura(Id_Factura,Total)
values(2,65);
insert into Factura(Id_Factura,Total) 
values(3,100);
insert into Factura(Id_Factura,Total) 
values(4,35);
set identity_insert Factura OFF

select *from Camere_Rezervate

insert into Rezervare
values(1,'2017-02-12','2017-02-22',1,2,2)
insert into Rezervare
values(2,'2017-11-01','2017-11-04',2,1,1)
insert into Rezervare
values(3,'2017-12-11','2017-12-17',3,4,2)
insert into Rezervare
values(4,'2017-11-01','2017-11-04',4,3,1)
insert into Rezervare
values(5,'2017-11-01','2017-11-04',2,5,1)

insert into Camere_Rezervate values(1,2,1);
insert into Camere_Rezervate values(2,3,1);
insert into Camere_Rezervate values(3,4,1);
insert into Camere_Rezervate values(4,1,1);
insert into Camere_Rezervate values(5,1,1);

USE Hotel;
update Camera
set Pret=20
where Id_camera=1

select * from Factura



delete from Rezervare 
where Id_Rezervare = 4 and Id_client>3

select * from Rezervare


update Client
set Numar_tel='0722233311'
where Id_client=1 or Nume='Alexandru'

select * from Client


delete from Camera 
where Nr_camera = 06 and Pret is not null

select * from Camera



select Nr_camera,Pret from Camera
where Nr_Pers=2
union
select Nr_camera,Pret from Camera
where Nr_Pers=3

select Rezervare.Data_inceput,Rezervare.Data_sfarsit, Client.Nume from Rezervare
left join Client on Client.Id_client=Rezervare.Id_client

select Rezervare.Nr_camere,Camera.Pret,Camere_Rezervate.Stare from ((Camere_Rezervate
inner join Rezervare on Camere_Rezervate.Id_Rezervare=Rezervare.Id_Rezervare)
inner join Camera on Camere_Rezervate.Id_camera=Camera.Id_camera)

select Rezervare.Data_inceput,Rezervare.Data_sfarsit,Camere_Rezervate.Stare from ((Camere_Rezervate
inner join Rezervare on Camere_Rezervate.Id_Rezervare=Rezervare.Id_Rezervare)
inner join Camera on Camere_Rezervate.Id_camera=Camera.Id_camera)

select Nr_camera from Camera
where Nr_Pers in (1,2)

select Total from factura 
where EXISTS (SELECT Id_Factura FROM Rezervare WHERE Id_Factura = Factura.Id_Factura AND Total > 50);

select count(Id_rezervare),Data_sfarsit from Rezervare
group by Data_sfarsit

select sum(Pret) as Pret_total,Nr_Pers from Camera
group by Nr_Pers
having count(Id_camera)<3

select distinct min(Pret) as Cel_mai_mic_pret,Nr_camera from Camera
where (Nr_Pers=2) and (Nr_camera<'06') 
group by Nr_camera


Create procedure Introdu_date_Camera
(@nr_c char(4),@nr_p char(1),@p money)
as
begin
 declare @id_c int
 set @id_c=(select max(Id_camera) from Camera)+1
 if(@nr_p >4)
	print 'Nu se poate introduce un numar de parsoane mai mare decat 4'
 if(@nr_c <=(select max(Nr_camera) from Camera))
    print 'Exista deja o camera cu acest numar'
 else
	insert into Camera values(@id_c,@nr_c,@nr_p,@p)
end
go

select * from Camera
delete from Camera
where Id_camera=6
exec Introdu_date_Camera '06','1',40


Create procedure Introdu_date_Rezervare
(@di date,@ds date,@id_c int,@id_f int,@nr varchar)
as
begin
 declare @id_r int
 set @id_r=(select max(Id_Rezervare) from Rezervare)+1
 if(@di < (SELECT CAST(GETDATE() AS DATE)))
	print 'Data inceput este gresita'
 else if (@ds <(SELECT CAST(GETDATE() AS DATE)))
	print 'Data sfarsit este gresita.'
 else if (@id_c > (select max(Id_client) from Client))
	print 'Id_client nu exista. Dati un id mai mic'
 else if (@id_f > (select max(Id_Factura) from Factura))
	print 'Id_factura nu exista. Dati un id mai mic'
 else if (@id_f <=(select max(Id_Factura) from Rezervare))
	print 'Id_facura gresit. Exista deja o factura cu acest id'
 else
	insert into Rezervare values(@id_r,@di,@ds,@id_c,@id_f,@nr)
end
go

select * from Rezervare
delete from Rezervare
where Id_Rezervare=5
exec Introdu_date_Rezervare '2017-12-20','2017-12-21',2,5,2


Create procedure Introdu_date_Camere_Rezervate
(@id_c int,@id_r int,@s bit)
as
begin
 if(@id_c > (select max(Id_camera) from Camera))
	print 'Nu exista camera cu acest id. Dati un al id'
 else if(@id_r > (select max(Id_Rezervare) from Rezervare))
	print 'Nu exista rezervare cu acest id. Dati un al id'
 else
   insert into Camere_Rezervate values (@id_c,@id_r,@s)
end
go

select * from Camere_Rezervate
delete from Camere_Rezervate
where Id_camera=4
exec Introdu_date_Camere_Rezervate 3,2,5 

drop procedure if exists Introdu_date_Rezervare


create view [Camere disponibile] as
select Rezervare.Data_inceput,Rezervare.Data_sfarsit,Camera.Nr_camera,Camere_Rezervate.Stare from ((Camere_Rezervate
inner join Rezervare on Camere_Rezervate.Id_Rezervare=Rezervare.Id_Rezervare)
inner join Camera on Camere_Rezervate.Id_camera=Camera.Id_camera)


select * from [Camere disponibile]

create trigger Adaugare_Client
on Client
after insert
as
begin 
 print GETDATE()
 print 'Tabela Client'
 print 'Adaugare reusita!'
end
go

create trigger Stergere_Client
on Client
after delete
as
begin
 print GETDATE()
 print 'Tabela Client'
 print 'Stergere reusita!'
end
go

select*from Client
insert into Client VALUES(7,'Madalina','madalina@yahoo.com','0723432554')
delete from Client
where Id_client=7