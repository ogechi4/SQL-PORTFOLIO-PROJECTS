--cleaning Data in SQL Queries

select *
from PortFolioProject..[national-housing]

--Standardize Date Format

select SaleDateConverted,CONVERT(Date,SaleDate)
from PortFolioProject..[national-housing]

--first process

ALTER TABLE [national-housing]
Add SaleDateConverted Date;

update [national-housing]
set SaleDateConverted = CONVERT(Date,SaleDate)

--Populate property address data

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.propertyaddress, b.propertyaddress)
from [national-housing] a
join [national-housing] b
  on a.ParcelID = b.ParcelID
  and a.[UniqueID ] <> b.[UniqueID ]
 where a.PropertyAddress is not null


  -- now we gonna update a
  update a
  SET propertyaddress = isnull(a.propertyaddress, b.propertyaddress)
  from [national-housing] a
join [national-housing] b
  on a.ParcelID = b.ParcelID
  and a.[UniqueID ] <> b.[UniqueID ]
  where a.PropertyAddress is null

  
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from [national-housing] a
join [national-housing] b
  on a.ParcelID = b.ParcelID
  and a.[UniqueID ] <> b.[UniqueID ]
  where a.PropertyAddress is not null


  --breaking out address into individual columns(address, city state)
  
  SELECT 
  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
  ,  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address

  FROM PortfolioProject..[national-housing]


  
ALTER TABLE [national-housing]
Add PropertySplitaddress nvarchar(255);

update [national-housing]
set PropertySplitaddress  = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE [national-housing]
Add PropertySplitCity nvarchar(255);

update [national-housing]
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

select *
from PortfolioProject..[national-housing]

--breaking out Address into diffterent columns using parse

select owneraddress
from PortFolioProject..[national-housing]

select
PARSENAME(replace(owneraddress, ',', '.'), 3),
PARSENAME(replace(owneraddress, ',', '.'), 2),
PARSENAME(replace(owneraddress, ',', '.'), 1)
from PortFolioProject..[national-housing]

  
ALTER TABLE [national-housing]
Add OwnerSplitaddress nvarchar(255);

update [national-housing]
set OwnerSplitaddress  = PARSENAME(replace(owneraddress, ',', '.'), 3)


ALTER TABLE [national-housing]
Add OwnerSplitCity nvarchar(255);

update [national-housing]
set OwnerSplitCity = PARSENAME(replace(owneraddress, ',', '.'), 2)

ALTER TABLE [national-housing]
Add OwnerSplitState nvarchar(255);

update [national-housing]
set OwnerSplitState = PARSENAME(replace(owneraddress, ',', '.'), 1)


select *
from PortFolioProject..[national-housing]

--change Y and N to Yes and No from the SoldAsVacant column

select soldasvacant,
case when soldasvacant = 'y' then 'Yes'
     when soldasvacant = 'n' then 'No'
	 else soldasvacant
	 end as NewsoldAsVacant
from PortFolioProject.. [national-housing]
group by SoldAsVacant
order by 2

--then we update

--this is to create new column for the change made
ALTER TABLE [national-housing]
Add NewsoldAsVacant nvarchar(255);

update  PortFolioProject.. [national-housing]
set NewSoldAsVacant = case when soldasvacant = 'y' then 'Yes'
     when soldasvacant = 'n' then 'No'
	 else soldasvacant
	 end 

	 select distinct(soldasvacant), count(soldasvacant)

from PortFolioProject.. [national-housing]
group by SoldAsVacant

--remove duplicates using a CTE WITH
with ROWNUMCTE AS (
select *,
ROW_NUMBER() OVER (PARTITION BY Parcelid,propertyaddress,saleprice,saledate,legalreference order by uniqueid) Row_Num
from PortFolioProject.. [national-housing]
)
SELECT *     --then we can rpelace the selects with delete
from ROWNUMCTE
where Row_Num > 1


--DELETE COLUMN(UNWANTED)
Select *
from PortFolioProject..[national-housing]
alter table portfolioproject..[national-housing]
drop column taxdistrict,owneraddress

