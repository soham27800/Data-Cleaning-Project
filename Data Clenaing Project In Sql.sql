/*

Cleaning Data in SQL Queries

*/

Select *
From [Data Cleaning]..Nashville_Housing


-- Standardize Date Format

Select saleDateConverted, CONVERT(Date,SaleDate)
From [Data Cleaning]..Nashville_Housing

Update Nashville_Housing
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE Nashville_Housing
Add SaleDateConverted Date;

Update Nashville_Housing
SET SaleDateConverted = CONVERT(Date,SaleDate)


-- Populate Property Address data

Select *
From [Data Cleaning]..Nashville_Housing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From  [Data Cleaning]..Nashville_Housing a
JOIN [Data Cleaning]..Nashville_Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Data Cleaning]..Nashville_Housing a
JOIN [Data Cleaning]..Nashville_Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From [Data Cleaning]..Nashville_Housing
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From [Data Cleaning]..Nashville_Housing

ALTER TABLE Nashville_Housing
Add Property_Split_Address Nvarchar(255);

Update Nashville_Housing
SET Property_Split_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE Nashville_Housing
Add Property_Split_City Nvarchar(255);

Update Nashville_Housing
SET Property_Split_City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

select OwnerAddress
from [Data Cleaning]..Nashville_Housing

select
PARSENAME(replace(OwnerAddress, ',','.'), 3)
,PARSENAME(replace(OwnerAddress, ',','.'), 2)
,PARSENAME(replace(OwnerAddress, ',','.'), 1)
from [Data Cleaning]..Nashville_Housing 

alter table Nashville_Housing
Add Owner_Split_Address nvarchar(255);

update Nashville_Housing
set Owner_Split_Address = PARSENAME(replace(OwnerAddress, ',','.'), 3)

alter table Nashville_Housing
Add Owner_Split_City nvarchar(255);

update Nashville_Housing
set Owner_Split_City = PARSENAME(replace(OwnerAddress, ',','.'), 2)

alter table Nashville_Housing
Add Owner_Split_State nvarchar(255);

update Nashville_Housing
set Owner_Split_State = PARSENAME(replace(OwnerAddress, ',','.'), 1)


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from [Data Cleaning]..Nashville_Housing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'y' then 'YES'
	 when SoldAsVacant = 'N' then 'NO'
	 else SoldAsVacant
	 end
from [Data Cleaning]..Nashville_Housing

update Nashville_Housing
set SoldAsVacant = case when SoldAsVacant = 'y' then 'YES'
	 when SoldAsVacant = 'N' then 'NO'
	 else SoldAsVacant
	 end


--Remove Duplicates

with rowNumCTE as( 
select *,
	ROW_NUMBER() over (
	partition by ParcelID,
				PropertyAddress,
				SaleDate,
				SalePrice,
				LegalReference
				order by
					UniqueID
					) row_num
from [Data Cleaning]..Nashville_Housing
--order by ParcelID
)
select *
from rowNumCTE
where row_num > 1
order by PropertyAddress


-- Delete Unused Columns

select *
from [Data Cleaning]..Nashville_Housing

alter table Nashville_Housing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



