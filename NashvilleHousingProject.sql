-- Cleaning data in sql

Select *
from NashvilleHousing

-- Standardize date format

Select SaleDateUpdated, Convert(Date,SaleDate)
from NashvilleHousing

Alter Table NashvilleHousing
Add SaleDateUpdated Date;

update NashvilleHousing
set SaleDateUpdated = Convert(Date,SaleDate)



-- Populate Property Address
Select *
From NashvilleHousing
where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Separate address into individual columns (Address, City, State)
Select PropertyAddress
from NashvilleHousing


Select 
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
from NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
set PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
set PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


Select OwnerAddress
from NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress, ',', '.'),3)
, PARSENAME(Replace(OwnerAddress, ',', '.'),2)
, PARSENAME(Replace(OwnerAddress, ',', '.'),1)
from NashvilleHousing

Alter Table NashvilleHousing
Add OwnerAddressStreet nvarchar(255)

Update NashvilleHousing
set OwnerAddressStreet = PARSENAME(Replace(OwnerAddress, ',', '.'),3)

Alter Table NashvilleHousing
Add OwnerAddressCity nvarchar(255)

Update NashvilleHousing
set OwnerAddressCity = PARSENAME(Replace(OwnerAddress, ',', '.'),2)

Alter Table NashvilleHousing
Add OwnerAddressState nvarchar(255)

Update NashvilleHousing
set OwnerAddressState = PARSENAME(Replace(OwnerAddress, ',', '.'),1)



-- Change Y and N to Yes and No in SoldAsVacant column
Select Distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant,
	Case
	When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
	End
from NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = CASE
					When SoldAsVacant = 'Y' THEN 'Yes'
					When SoldAsVacant = 'N' THEN 'No'
					Else SoldAsVacant
					END;

-- Remove Duplicates
WITH RowNumCTE as (
Select *,
		ROW_NUMBER() OVER (
		Partition by ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 Order by 
						UniqueId
						) row_num
from NashvilleHousing
--order by ParcelId
)
select *
from RowNumCte
where row_num > 1
order by PropertyAddress

-- Delete Unused Columns

Alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress,  SaleDate

Select *
from NashvilleHousing
