/*

Cleaning Data in SQL Queries

*/


-- Full data set
select *
from nashvillehousing;


-- Converting all empty string values to NULL
update nashvillehousing
set
UniqueID = CASE UniqueID WHEN '' THEN NULL ELSE UniqueID END,
ParcelID = CASE ParcelID WHEN '' THEN NULL ELSE ParcelID END,
LandUse = CASE LandUse WHEN '' THEN NULL ELSE LandUse END,
PropertyAddress = CASE PropertyAddress WHEN '' THEN NULL ELSE PropertyAddress END,
SaleDate = CASE SaleDate WHEN '' THEN NULL ELSE SaleDate END,
SalePrice = CASE SalePrice WHEN '' THEN NULL ELSE SalePrice END,
LegalReference = CASE LegalReference WHEN '' THEN NULL ELSE LegalReference END,
SoldAsVacant = CASE SoldAsVacant WHEN '' THEN NULL ELSE SoldAsVacant END,
OwnerName = CASE OwnerName WHEN '' THEN NULL ELSE OwnerName END,
OwnerAddress = CASE OwnerAddress WHEN '' THEN NULL ELSE OwnerAddress END,
Acreage = CASE Acreage WHEN '' THEN NULL ELSE Acreage END,
TaxDistrict = CASE TaxDistrict WHEN '' THEN NULL ELSE TaxDistrict END,
LandValue = CASE LandValue WHEN '' THEN NULL ELSE LandValue END,
BuildingValue = CASE BuildingValue WHEN '' THEN NULL ELSE BuildingValue END,
TotalValue = CASE TotalValue WHEN '' THEN NULL ELSE TotalValue END,
YearBuilt = CASE YearBuilt WHEN '' THEN NULL ELSE YearBuilt END,
Bedrooms = CASE Bedrooms WHEN '' THEN NULL ELSE Bedrooms END,
FullBath = CASE FullBath WHEN '' THEN NULL ELSE FullBath END,
HalfBath = CASE HalfBath WHEN '' THEN NULL ELSE HalfBath END

-- Standardize date format

select 
SaleDate
,convert(SaleDate,Date)
from nashvillehousing;

ALTER TABLE nashvillehousing
Add SaleDateConverted date;

update nashvillehousing
set 
SaleDateConverted = convert(SaleDate,Date);

update nashvillehousing
set 
SaleDate= convert(SaleDate,Date);

select SaleDateConverted
from nashvillehousing;

-- Populate property address data
select 
a.parcelid
,a.propertyaddress
,b.parcelid
,b.propertyaddress
,IFNULL(a.propertyaddress, b.propertyaddress)
from nashvillehousing a
JOIN nashvillehousing b ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
where a.propertyaddress IS NULL;

UPDATE nashvillehousing a JOIN nashvillehousing b ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
set a.propertyaddress = IFNULL(a.propertyaddress, b.propertyaddress)
where a.propertyaddress IS NULL;


-- Breaking out the property address into individual columns (Address, City, State)
select propertyaddress
from nashvillehousing;

select 
substring(propertyaddress, 1, LOCATE(',',PropertyAddress)-1) AS Address
,substring(propertyaddress, LOCATE(',',PropertyAddress)+1,LENGTH(propertyaddress)) AS City
from nashvillehousing;


ALTER TABLE nashvillehousing
ADD PropertySplitAddress VARCHAR(255);

UPDATE nashvillehousing
set PropertySplitAddress = substring(propertyaddress, 1, LOCATE(',',PropertyAddress)-1);

ALTER TABLE nashvillehousing
ADD PropertySplitCity VARCHAR(255);

UPDATE nashvillehousing
set PropertySplitCity = substring(propertyaddress, LOCATE(',',PropertyAddress)+1,LENGTH(propertyaddress));

-- Owner address
select OwnerAddress
from nashvillehousing;

select
SUBSTRING_INDEX(OwnerAddress, ',', 1) as Address
,SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1) AS City
,SUBSTRING_INDEX(OwnerAddress, ' ', -1) as State
from nashvillehousing;

ALTER TABLE nashvillehousing
ADD OwnerSplitAddress VARCHAR(255);

UPDATE nashvillehousing
set OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);

ALTER TABLE nashvillehousing
ADD OwnerSplitCity VARCHAR(255);

UPDATE nashvillehousing
set OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1);

ALTER TABLE nashvillehousing
ADD OwnerSplitState VARCHAR(255);

UPDATE nashvillehousing
set OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ' ', -1);

-- Change "Y" to "Yes" and "N" to "No" in the "Sold as Vacant" field
select 
Distinct(SoldAsVacant)
,Count(SoldAsVacant)
from nashvillehousing
group by SoldAsVacant
order by 2;

select 
soldasvacant
, CASE WHEN soldasvacant = 'Y' THEN 'Yes'
		WHEN soldasvacant = 'N' THEN 'No'
		Else soldasvacant
		END
from nashvillehousing;

UPDATE nashvillehousing
set SoldAsVacant = CASE WHEN soldasvacant = 'Y' THEN 'Yes'
		WHEN soldasvacant = 'N' THEN 'No'
		Else soldasvacant
		END;
		
-- Remove duplicates

WITH RowNumCTE AS(

select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID
				,PropertyAddress
				,SalePrice
				,SaleDate
				,LegalReference
				ORDER BY UniqueID
				) as row_num
from nashvillehousing
-- order by ParcelID;
)

DELETE FROM nashvillehousing USING nashvillehousing JOIN RowNumCTE ON nashvillehousing.ParcelID = RowNumCTE.ParcelID
where RowNumCTE.row_num > 1;


-- Delete unused columns
select *
from nashvillehousing;

ALTER TABLE nashvillehousing
DROP COLUMN OwnerAddress *\/
,DROP COLUMN TaxDistrict
,DROP COLUMN PropertyAddress
,DROP COLUMN SaleDate;






	
	