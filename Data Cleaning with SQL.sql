/* Data Cleaning in SQL Queries 
*/

Select *
From [Portfolio Project]..NashvilleHousing

-- Standardizes Date Format

Select SaleDate, CONVERT(Date, SaleDate)
From [Portfolio Project]..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


-- Populate Property Address data

Select *
From [Portfolio Project]..NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

Select a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Portfolio Project]..NashvilleHousing a
JOIN [Portfolio Project]..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ] 
Where a.PropertyAddress is null

Update a
SET PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Portfolio Project]..NashvilleHousing a
JOIN [Portfolio Project]..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] = b.[UniqueID ]
Where a.PropertyAddress is null


-- Breaking out Address into Individual Columns Address, City, State

Select PropertyAddress
From [Portfolio Project]..NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

Select
SUBSTRING(propertyAddress, 1, CHARINDEX(',', propertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
From [Portfolio Project]..NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(propertyAddress, 1, CHARINDEX(',', propertyAddress)-1)  

ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


Select *
From [Portfolio Project]..NashvilleHousing

--Dealing with OwnerAddress

Select OwnerAddress
From [Portfolio Project]..NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From [Portfolio Project]..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)  

ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select *
From [Portfolio Project]..NashvilleHousing


-- Change Y and N to Yes and No in 'Sold as Vacant' field

Select Distinct (SoldAsVacant), Count(SoldAsVacant)
From [Portfolio Project]..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END
From [Portfolio Project]..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END


-- Remove Duplicates

With RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				legalReference
				Order by
					uniqueID
					) row_num

From [Portfolio Project]..NashvilleHousing
--Order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
--Order by propertyAddress

Delete
From RowNumCTE
Where row_num > 1
--Order by propertyAddress

Select *
From [Portfolio Project]..NashvilleHousing


-- Delete Unused Columns (don't do it without permission)

Select *
From [Portfolio Project]..NashvilleHousing

ALTER TABLE [portfolio Project]..nashvillehousing
Drop COLUMN OwnerAddress, TaxDistrict, PropertyAddress
