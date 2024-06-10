-- Adding the Table to postgresql

Drop table if exists NashvilleHousingData;
Create table NashvilleHousingData 
(
	UniqueID Integer,
	ParcelID varchar(255),
	LandUse varchar(255),
	PropertyAddress varchar(255),
	SaleDate date,
	SalePrice varchar(255),
	LegalReference varchar(255),
	SoldAsVacant varchar(255),
	OwnerName varchar(255),
	OwnerAddress varchar(255),
	Acreage numeric,
	TaxDistrict varchar(255),
	LandValue numeric,
	BuildingValue numeric,
	TotalValue numeric,
	YearBuilt integer,
	Bedrooms integer,
	FullBath integer,
	HalfBath integer
)

---------------------------------------------------------------------------------------------------------------------------------------------
-- lets check the data

select * from nashvillehousingdata


-- Populate property address data


select *
from nashvillehousingdata
where propertyaddress is null
order by ParcelId



select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, NULLIF(b.propertyaddress, a.propertyaddress)
from nashvillehousingdata a
join nashvillehousingdata b
on a.parcelid = b.parcelid
and a.uniqueid <> b.uniqueid
where a.propertyaddress is null


SELECT 
    a.parcelid, 
    a.propertyaddress, 
    b.parcelid, 
    b.propertyaddress, 
COALESCE(NULLIF(b.propertyaddress, a.propertyaddress), 'Default_Value') AS modified_propertyaddress
FROM nashvillehousingdata a
JOIN a.parcelid = b.parcelid
AND a.uniqueid <> b.uniqueid
WHERE 
 a.propertyaddress IS NULL;


UPDATE nashvillehousingdata a
SET propertyaddress = COALESCE(NULLIF(b.propertyaddress, a.propertyaddress), 'Default_Value')
FROM nashvillehousingdata b
WHERE a.parcelid = b.parcelid
  AND a.uniqueid <> b.uniqueid
  AND a.propertyaddress IS NULL;

---------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking property Address into Individual  Columns( Addres, City, States)

select PropertyAddress 
	from nashvillehousingdata

SELECT 
    SPLIT_PART(PropertyAddress, ',', 1) AS Address,
    SPLIT_PART(PropertyAddress, ',', 2) AS City
FROM  nashvillehousingdata

alter table nashvillehousingdata
add column propertysplitaddress varchar(255),
add column propertysplitcity varchar(255);

update  nashvillehousingdata
set propertysplitaddress = SPLIT_PART(PropertyAddress, ',', 1),
	propertysplitcity = SPLIT_PART(PropertyAddress, ',', 2);


select * from nashvillehousingdata

-- Splitting owner address into individual
	
select owneraddress
from nashvillehousingdata

select
SPLIT_PART(Owneraddress, ',', 1) AS Address,
SPLIT_PART(owneraddress, ',', 2) AS City,
SPLIT_PART(owneraddress, ',', 3) AS State
from nashvillehousingdata

alter table nashvillehousingdata
add column ownersplitaddress varchar(255),
add column ownersplitcity varchar(255),
add column ownersplitstate varchar(255);

update  nashvillehousingdata
set ownersplitaddress = SPLIT_PART(Owneraddress, ',', 1),
	ownersplitcity = SPLIT_PART(Owneraddress, ',', 2),
	Ownersplitstate = SPLIT_PART(Owneraddress, ',',3);



---------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes And No in 'Sold as vacant' column


select distinct soldasvacant, count(soldasvacant)
from nashvillehousingdata
group by soldasvacant
order by 2


select soldasvacant
, case when soldasvacant = 'Y' then 'Yes'
 	   when soldasvacant = 'N' then 'No'
		else soldasvacant
		end
from nashvillehousingdata

update nashvillehousingdata
set soldasvacant = case when soldasvacant = 'Y' then 'Yes'
 	   when soldasvacant = 'N' then 'No'
		else soldasvacant
		end
---------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


select * from nashvillehousingdata

-- This query shows all duplicate rows
	
with row_num_cte as (
select * ,
 ROW_Number() over (
	partition by parcelid,
	propertyaddress,
	saledate,
	saleprice,
	legalreference
	order by uniqueid
 ) row_num
from nashvillehousingdata
--order by parcelid
)
select *
from row_num_cte
where row_num > 1
order by propertyaddress

-- Following query was used to delete all duplicate rows
	
WITH duplicates_cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY parcelid,
                            propertyaddress,
                            saledate,
                            saleprice,
                            legalreference
               ORDER BY uniqueid
           ) AS row_num
    FROM nashvillehousingdata
)
DELETE FROM nashvillehousingdata
WHERE uniqueid IN (
    SELECT uniqueid
    FROM duplicates_cte
    WHERE row_num > 1
);

---------------------------------------------------------------------------------------------------------------------------------------------

-- Droping the Unsused Columns

select * 
	from nashvillehousingdata

Alter table nashvillehousingdata
Drop column propertyaddress

Alter table nashvillehousingdata
Drop column owneraddress

Alter table nashvillehousingdata
Drop column taxdistrict


