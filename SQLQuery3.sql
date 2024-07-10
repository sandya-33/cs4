use cs4;
select * from Nashvillehousing;
-- Change SaleDate format
select SaleDate, CONVERT(date, SaleDate) from Nashvillehousing;

Alter table NashvilleHousing add SaleDateConv DATE;

UPDATE Nashvillehousing
SET SaleDateConv = CAST(SaleDate AS DATE);

select SaleDateConv from Nashvillehousing;
 
 -- fill PropertyAddress null values
select PropertyAddress from Nashvillehousing;

select count(UniqueID) from Nashvillehousing where PropertyAddress is null;


select a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress from Nashvillehousing a 
join Nashvillehousing b on a.ParcelID=b.ParcelID where a.UniqueID <> b.UniqueID and a.PropertyAddress is null;

begin transaction;

update a set PropertyAddress= isnull(a.PropertyAddress,b.PropertyAddress)
from Nashvillehousing a 
join Nashvillehousing b on a.ParcelID=b.ParcelID 
and a.UniqueID <> b.UniqueID where a.PropertyAddress is null;

select count(UniqueID) from Nashvillehousing where PropertyAddress is null;


rollback transaction;

-- Split PropertyAddress

select PropertyAddress from Nashvillehousing;

select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as city from Nashvillehousing;

Alter table NashvilleHousing add PropertySplitAddress nvarchar(255);

UPDATE Nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);

Alter table NashvilleHousing add PropertySplitCity nvarchar(255);

UPDATE Nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress));

-- split OwnerAddress
SELECT 
    PARSENAME(REPLACE(OwnerAddress, ', ', '.'), 3) AS Address,
    PARSENAME(REPLACE(OwnerAddress, ', ', '.'), 2) AS City,
    PARSENAME(REPLACE(OwnerAddress, ', ', '.'), 1) AS State
FROM Nashvillehousing;

Alter table NashvilleHousing add OwnerSplitAddress nvarchar(255);

UPDATE Nashvillehousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ', ', '.'), 3);

Alter table NashvilleHousing add OwnerSplitCity nvarchar(255);

UPDATE Nashvillehousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ', ', '.'), 2);

Alter table NashvilleHousing add OwnerSplitState nvarchar(255);

UPDATE Nashvillehousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ', ', '.'), 1);

-- replace y n as yes and no;

select distinct(SoldAsVacant),count(SoldAsVacant) from Nashvillehousing group by SoldAsVacant order by 2;

update Nashvillehousing set SoldAsVacant='Yes' where SoldAsVacant='Y';
update Nashvillehousing set SoldAsVacant='No' where SoldAsVacant='N';

-- remove duplicates

WITH CTE AS(
Select *,ROW_NUMBER() OVER (
	PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
	ORDER BY UniqueID)row_num
From NashvilleHousing
)
delete
From CTE
Where row_num > 1

-- remove unused columns
alter table NashvilleHousing
drop column OwnerAddress, PropertyAddress,SaleDate,TaxDistrict


Select * From NashvilleHousing
