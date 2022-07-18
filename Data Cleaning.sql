--Data Cleaning in SQL Queries

Select *
from Portfolio1..NashVilleHousing


--Standardize Date Format

Select [SaleDate], CONVERT(Date, SaleDate)
from Portfolio1..NashVilleHousing

Update Portfolio1..NashVilleHousing
Set SaleDate = CONVERT(Date, SaleDate)


--Failed to update data, add new column to insert data
Alter Table NashVilleHousing
Add SaleDateConverted Date;

Update Portfolio1..NashVilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)


-- Checking Converted Format
Select [SaleDate], CONVERT(Date, SaleDate), SaleDateConverted
from Portfolio1..NashVilleHousing


--Populate Property Address data

Select *
from Portfolio1..NashVilleHousing
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from Portfolio1..NashVilleHousing a
join Portfolio1..NashVilleHousing b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null
	order by 1

Update a
Set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from Portfolio1..NashVilleHousing a
join Portfolio1..NashVilleHousing b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null
	order by 1


--Breaking out Address into Individual Columns ( Address, City, State)
--PropertyAddress
Select *
from Portfolio1..NashVilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address1,
--SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, Len(PropertyAddress)) as Address2,
Right(PropertyAddress, Len(PropertyAddress) - CHARINDEX(',',PropertyAddress)) as Address2
from Portfolio1..NashVilleHousing

Alter Table Portfolio1..NashVilleHousing
Add PropertySplitAddress nvarchar(255);

Update Portfolio1..NashVilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

Alter Table Portfolio1..NashVilleHousing
Add PropertySplitCity nvarchar(255);

Update Portfolio1..NashVilleHousing
Set PropertySplitCity = Right(PropertyAddress, Len(PropertyAddress) - CHARINDEX(',',PropertyAddress))

--OwnerAddress
Select parsename(replace(owneraddress, ',','.'),1),
parsename(replace(owneraddress, ',','.'),2),
parsename(replace(owneraddress, ',','.'),3)
from Portfolio1..NashVilleHousing

Alter Table Portfolio1..NashVilleHousing
Add OwnerSplitAddress nvarchar(255);

Update Portfolio1..NashVilleHousing
Set OwnerSplitAddress = parsename(replace(owneraddress, ',','.'),3)

Alter Table Portfolio1..NashVilleHousing
Add OwnerSplitCity nvarchar(255);

Update Portfolio1..NashVilleHousing
Set OwnerSplitCity = parsename(replace(owneraddress, ',','.'),2)

Alter Table Portfolio1..NashVilleHousing
Add OwnerSplitState nvarchar(255);

Update Portfolio1..NashVilleHousing
Set OwnerSplitState = parsename(replace(owneraddress, ',','.'),1)


-- Change Y and N to Yes and No in "Sold in vacant" field
Select Distinct SoldAsVacant, count(SoldAsVacant),
--Select Replace(SoldAsVacant, 'Y', 'Yes'), Replace(SoldAsVacant, 'N', 'No')
case
when SoldAsVacant = 'Y' Then 'Yes'
when SoldAsVacant = 'N' Then 'No'
else SoldAsVacant
end
from Portfolio1..NashVilleHousing
Group by SoldAsVacant

Update Portfolio1..NashVilleHousing
Set SoldAsVacant = 
case
when SoldAsVacant = 'Y' Then 'Yes'
when SoldAsVacant = 'N' Then 'No'
else SoldAsVacant
end


--Remove Duplicates
--assume that ParcelID, PropertyAddress, SalePrice, SaleDate and LegalReference defines the dataset
Select *,
Row_number() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
				 UniqueID
				 ) row_num
From Portfolio1..NashVilleHousing
order by ParcelID

--row_num CTE
With RowNumCTE as(
Select *,
Row_number() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
				 UniqueID
				 ) row_num
From Portfolio1..NashVilleHousing
)
Delete
--Select *
From RowNumCTE
where row_num > 1

--Delete Unused Column
Alter Table Portfolio1..NashVilleHousing
Drop column PropertyAddress, SaleDate, OwnerAddress, TaxDistrict