																	--Data Cleaning - SQL
 
--In this document i have made unusable data into data that can be used. 
 
										--standardize Date Format

  Select SaleDateConverted, CONVERT(Date, SaleDate)
  FROM PortfolioProject..NashvilleHousing

  UPDATE NashvilleHousing
  SET SaleDate = Convert(Date, SaleDate)

  ALTER TABLE NashvilleHousing
  ADD SaleDateConverted Date;

  Update NashvilleHousing
  SET SaleDateConverted = Convert(Date,Saledate)

											-- Populate Property Address data (getting rid of the nulls with valid data)

  Select *
  From PortfolioProject..NashvilleHousing
  --WHERE PropertyAddress is null
  ORDER BY ParcelID

  --Checks for all the NULLS within Property Address Column:
  Select Table1.ParcelID,  Table1.PropertyAddress, Table2.ParcelID, Table2.PropertyAddress, ISNULL(Table1.PropertyAddress, Table2.PropertyAddress)
  From PortfolioProject..NashvilleHousing Table1
  JOIN PortfolioProject..NashvilleHousing Table2
  ON Table1.ParcelID = Table2.ParcelID
  AND Table1.[UniqueID ] != Table2.[UniqueID ]
  WHERE Table1.PropertyAddress is null

  --Updates the table, removing any NULLS within the PropertyAddress Column
  UPDATE Table1
  SET PropertyAddress = ISNULL(Table1.PropertyAddress, Table2.PropertyAddress)
  From PortfolioProject..NashvilleHousing Table1
  JOIN PortfolioProject..NashvilleHousing Table2
  ON Table1.ParcelID = Table2.ParcelID
  AND Table1.[UniqueID ] != Table2.[UniqueID ]
  WHERE Table1.PropertyAddress is null

														--Splitting data (method 1)

--Breaking our Address into Individual Columns (Address, City, State), +1 and -1 is to remove Comma from results
--SELECT is used to see that what we are doing is working properly, then we can alter & update the table
  
  Select
  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
  From PortfolioProject..NashvilleHousing

  ---------------------------------------------------------------
  ALTER TABLE NashvilleHousing
  ADD PropertySplitAddress NVARCHAR(255);

  Update NashvilleHousing
  SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

  ---------------------------------------------------------------
  ALTER TABLE NashvilleHousing
  ADD PropertySplitCity NVARCHAR(255);

  Update NashvilleHousing
  SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

  

  ---------------------------------------------------------------------------------------------------------------------------------
													--Splitting data (method 2)

  --(easier than Substring)
  --Parsename separates everything that is separated by a full stop '.'. REPLACE converts (in this case) a comma to a full dot. 


  SELECT 
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
  FROM PortfolioProject..NashvilleHousing

  ALTER TABLE NashvilleHousing
  ADD OwnerSplitAddress NVARCHAR(255);

  Update NashvilleHousing
  SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

  ---------------------------------------------------------------
  ALTER TABLE NashvilleHousing
  ADD OwnerSplitCity NVARCHAR(255);

  Update NashvilleHousing
  SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

  ---------------------------------------------------------------
  ALTER TABLE NashvilleHousing
  ADD OwnerSplitState NVARCHAR(255);

  Update NashvilleHousing
  SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

  
										--Changing Y and N to Yes and No in "Sold as Vacant" field
		--checks:
  SELECT Distinct(SoldAsVacant), count(soldAsVacant)
  FROM PortfolioProject..NashvilleHousing
  Group by SoldAsVacant
  order by 2

		
UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant ='Y' THEN 'YES'
						WHEN SoldAsVacant = 'N' THEN 'NO'
						ELSE SoldAsVacant
						END


												--Removing Duplicates
--The Row_number is used so that if the data repeats itself, the row_number value will be greater than 1, allowing me to delete duplicates with a where statement

WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
				 UniqueID ) row_num

	FROM PortfolioProject..NashvilleHousing
	--Order by ParcelID
	)
DELETE
from RowNumCTE
WHERE row_num > 1

												--Delete Unused columns (usually only used in Views):

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN ownerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate

SELECT *
from PortfolioProject..NashvilleHousing