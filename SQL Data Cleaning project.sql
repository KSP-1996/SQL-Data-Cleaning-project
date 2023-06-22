/*

Cleaning Data in SQL Queries

*/

Select * 
From NashvilleHousing

--------------------------------------------------------------------

--Standardize Date format

Select SaleDate, Convert(date, Saledate)
From NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert(date, Saledate)

-- If not updating properly

Alter table NashvilleHousing
Add SaleDateConverted date;

Update NashvilleHousing
Set SaleDateConverted = Convert(date, Saledate)

------------------------------------------------------------------------

-- Populate Property Address data(using a self join)

Select *
From NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-------------------------------------------------------------------------------

--Breaking out address into individual columns(Address, City, State)

Select PropertyAddress
From NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

Select
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From NashvilleHousing


Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255)

Update NashvilleHousing
Set PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From NashvilleHousing

-- Seperating Owner address

Select OwnerAddress
From NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 2)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

Select *
From NashvilleHousing

-------------------------------------------------------------------------

-- Changing Y and N to Yes and No in'"Sold as vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, Case When SoldAsVacant = 'N'THEN 'No'
		When SoldAsVacant = 'Y' THEN 'Yes'
		Else SoldAsVacant
		End
From NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'N'THEN 'No'
		When SoldAsVacant = 'Y' THEN 'Yes'
		Else SoldAsVacant
		End

------------------------------------------------------------

--Remove Duplicates

With RowNumCTE as(
Select *,
		ROW_NUMBER() Over (
		Partition by ParcelID,
					 PropertyAddress,
					 SaleDate,
					 SalePrice,
					 LegalReference
					 Order by 
						UniqueID
						) row_num
From NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

-------------------------------------------------

-- Delete unused columns

Alter Table NashvilleHousing
Drop column OwnerAddress, PropertyAddress, TaxDistrict, SaleDate






