create database gest_voit
use gest_voit


create table Modele(
idModele varchar(256) primary key,
dateModele date)

create table Voiture(
numserie varchar(256) primary key, 
couleur varchar(256), 
prix float, 
cout float, 
solde float,
marque varchar(256),
idmodele varchar(256) foreign key references Modele )


create table Magasin(
Idmagasin int primary key ,
nomM varchar(256))

create table Arrivee(
numserie varchar(256), 
Idmagasin int,
dateArr date,
constraint pk_arrv primary key(numserie,Idmagasin,dateArr),
constraint fk_nums_arrv foreign key(numserie) references Voiture,
constraint fk_idmag_arrv foreign key(Idmagasin) references Magasin
)

create table Client(
Clientid int primary key ,
nom varchar(256),
prenom varchar(256),
adresse varchar(256))

create table Vendeur(
Vendeurid int primary key ,
nomV varchar(256),
prenomV varchar(256),
adresseV varchar(256),
salairefixe float, 
prime float,
Idmagasin int foreign key references Magasin)



create table Vente(
NumV int primary key,
dateV date,
prixachat float,
numserie varchar(256) foreign key references Voiture ,
Vendeurid int foreign key references Vendeur , 
Clientid int foreign key references Client)


insert into Modele values('tdi4' ,'2005-04-02' )
insert into Modele values('tcdi' ,'2007-04-01' )
insert into Modele values('A6' ,'2004-12-14' )
insert into Modele values('twarg' ,'2011-02-01' )

insert into Voiture values('a1a151kh' , 'noir' , '150000' , '100050' , 'Wolswagen' ,'tdi4' )
insert into Voiture values('NKLG4561' , 'rouge' , '170500' , '150050' , 'Audi' ,'A6' )
insert into Voiture values('HGTF554D' , 'noir' , '350000' , '200050' , 'Mercidez' ,'tcdi' )
insert into Voiture values('BHGT154K' , 'blanche' , '550000' , '450050' , 'Wolswagen' ,'twarg' )

insert into Magasin values(155 ,'AutoHall' )
insert into Magasin values(100 ,'Autofarah' )
insert into Magasin values(101 ,'GreenAuto' )


insert into  Arrivee values('a1a151kh', 155, '2014-12-11')
insert into  Arrivee values('a1a151kh', 100, '2014-10-17')
insert into  Arrivee values('a1a151kh', 101, '2014-04-14')
insert into  Arrivee values('NKLG4561', 155, '2014-12-13')
insert into  Arrivee values('NKLG4561', 100, '2011-10-02')
insert into  Arrivee values('NKLG4561', 101, '2014-12-11')
insert into  Arrivee values('HGTF554D', 155, '2012-02-21')
insert into  Arrivee values('BHGT154K', 100, '2014-07-11')

insert into  Client values(12 ,'kamali','anouar','hay anas')
insert into  Client values(5 ,'ahmadi','amal','erriad')
insert into  Client values(4 ,'chihaoui','samira','omnia')
insert into  Client values(122 ,'bennani','kamal','bouab')
insert into  Client values(17 ,'soufiani','yassin','hay anas')

insert into Vendeur values(1 ,'alami','rachid','erriad',5600.10, 155)
insert into Vendeur values(2 ,'khettabi','omar','anas',4200.50, 100)
insert into Vendeur values(3 ,'barih','yassin','lamiaa',4600.10, 155)
insert into Vendeur values(4 ,'nejmaoui','mehdi','massira',6000.10, 155)
insert into Vendeur values(5 ,'benyassin','youness','erriad',3800.10, 101)


insert into Vente values(15,'2015-05-02','350000','HGTF554D' ,1 , 12)
insert into Vente values(11,'2015-05-04','350000','HGTF554D' ,3 , 5)
insert into Vente values(12,'2015-05-01','150000','a1a151kh' ,2 , 4)
insert into Vente values(14,'2015-05-17','550000','BHGT154K' ,2 , 122)
insert into Vente values(18,'2015-05-12','170500','NKLG4561' ,4, 17)

---------------------------------------------------------------------------------------------------
select * from Voiture
select * from Client
select * from Magasin
select * from Modele
select * from Vente
select * from Vendeur
select * from Arrivee

------------------------------------------ Benefice de chaque magasin
create view v1(benef,nom,prenom,magasin)
as 
(SELECT SUM(Vente.prixachat-Voiture.cout-0.05*(Voiture.prix-Voiture.cout))-salairefixe as 'benef',Vendeur.nomV,Vendeur.prenomV,Vendeur.Idmagasin

FROM Voiture,Vente,Vendeur
WHERE Voiture.numserie = Vente.numserie
AND Vendeur.Vendeurid=Vente.Vendeurid
AND Vente.dateV between DATEADD(MM,-1,getdate()) and getdate()
GROUP BY Vendeur.nomV,Vendeur.prenomV,Vendeur.Idmagasin,Vendeur.salairefixe
)

create view v2(magasin,beneficeTotal)
as 
SELECT magasin, SUM(benef) as'beneficeTotal'
FROM v1
GROUP BY magasin
alter table vendeur alter column prime float
-------------------------------------------Maximum benefice
create proc sp_max_benef 
@idmag int,@prctg int
as begin
update Vendeur set prime=salairefixe*(5/100.0) where Idmagasin=155
 end

------------------------------------------------------Minmum benefice

create proc sp_min_benef 
@idmag_MinBenef int,@prctg int
as begin 
declare @idmag int ,@auto varchar(50)
set @idmag=(select magasin from v2 where beneficeTotal in (select MAX(beneficeTotal) from v2) )
set @auto=(select top 1 numserie from Arrivee,v2 where Arrivee.Idmagasin=v2.magasin and v2.magasin=@idmag)
begin transaction tr_deplacer
begin try
insert into Arrivee values(@auto,@idmag,getdate())
delete from Arrivee where Idmagasin=@idmag and numserie=@auto and dateArr<>getdate()
update Voiture set solde=prix*(@prctg/100.0) where numserie in(select numserie from Arrivee where Idmagasin=@idmag)
commit transaction tr_deplacer
end try
begin catch
print error_message()
rollback transaction tr_deplacer
end catch
end

------------------------------------------------------Cursor
create proc sp_separer_benef
 @mycursor cursor varying output 
 as begin
set  @mycursor= cursor   for SELECT magasin, SUM(benef) as'beneficeTotal'
FROM v1
 group by magasin
open @mycursor
end
--------------------------------------------------dessision pour chaque magasin
create proc sp_batch
@prctg1 int,@prctg2 int
		as begin
		declare @cursor cursor 
		declare @idmag int,@totben float
		exec sp_separer_benef @cursor output
		fetch next from @cursor into @idmag,@totben
		while @@FETCH_STATUS=0
		begin
				if(@totben=(select max(beneficeTotal) from v2))
					begin
						exec sp_max_benef @idmag,1
						print 'ajout avc sucee'
						end
				else if(@totben=(select Min(beneficeTotal) from v2))
				begin
				         exec sp_min_benef  @idmag,1
						 print 'terminer avc sucee'
				end
				fetch next from @cursor into @idmag,@totben
			end

			close @cursor
			deallocate @cursor
 end
 exec sp_batch 1,1
----------------------------------------------- procedure d'affichage
CREATE PROC sp_magasin
AS BEGIN
SELECT Magasin.Idmagasin,Magasin.nomM,v2.beneficeTotal
FROM v2,Magasin
WHERE	Magasin.Idmagasin=v2.magasin
GROUP BY Magasin.Idmagasin,Magasin.nomM,v2.beneficeTotal
ORDER BY v2.beneficeTotal
END

create proc sp_report
as begin
select sum(beneficeTotal) from v2
end