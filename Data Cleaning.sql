/*Cleaning Data in SQL Queries*/
SELECT *
FROM [Portfolio Project1].dbo.NashvilleHousing

/*Standardize date format*/
SELECT SaleDateConverted, CONVERT(Date, Saledate)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, Saledate)

/*Populate Property Address data*/
SELECT *
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress) AS PropertyAddress1
FROM NashvilleHousing AS a
JOIN NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing AS a
JOIN NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL


/*Breaking out address into individual columns (Address, City, State)*/

SELECT PropertyAddress
FROM NashvilleHousing
--WHERE PropertyAddress IS NULLww
--ORDER BY ParcelID

SELECT *
FROM NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) AS State
FROM NashvilleHousing

/*creating 2 new columns to fit the new columns we have created.*/
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR (255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR (255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

/*Splitting the addresss, city and the state on Owner address info.*/
SELECT OwnerAddress
FROM NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS Address,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS City,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS State
FROM NashvilleHousing
WHERE OwnerAddress IS NOT NULL

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR (255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM NashvilleHousing
WHERE OwnerAddress IS NOT NULL

/*Change Y and N to Yes and No in the SoldAsVacant column */
SELECT DISTINCT (SoldAsVacant), COUNT (SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM NashvilleHousing

--SELECT SoldAsVacant
--FROM NashvilleHousing
--WHERE SoldAsVacant LIKE '%N%'

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

/*Removing duplicates*/
--using a CTE so as to be able to access the temporarily created colum row_num
WITH RowNumCTE AS (
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress, 
				 Saledate, 
				 SalePrice, 
				 LegalReference
	ORDER BY UniqueID
	) AS row_num
FROM NashvilleHousing
--ORDER BY ParcelID
)
--SELECT *
--FROM RowNumCTE
--WHERE row_num > 1
--ORDER BY PropertyAddress

DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


/*Deleting unused columns*/
SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate