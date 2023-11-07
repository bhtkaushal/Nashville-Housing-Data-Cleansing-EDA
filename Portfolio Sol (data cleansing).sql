
									--DATA CLEANSING AND STANDARDIZING THE DATA--

--Standardizing date format:

SELECT SaleDate
FROM [Portfolio Projects]..NashvilleHousing;

--UPDATE [Portfolio Projects]..NashvilleHousing
--SET SaleDate = CONVERT(date, Saledate);

ALTER TABLE [Portfolio Projects]..NashvilleHousing
ALTER COLUMN SaleDate date;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Populating the 'Property Address':

SELECT nas1.ParcelID, nas1.PropertyAddress, nas2.ParcelID, nas2.PropertyAddress,
	ISNULL(nas1.PropertyAddress, nas2.PropertyAddress)
FROM [Portfolio Projects]..NashvilleHousing nas1
JOIN [Portfolio Projects]..NashvilleHousing nas2
	ON nas1.ParcelID = nas2.ParcelID
		AND nas1.[UniqueID ] <> nas2.[UniqueID ]
--WHERE nas1.PropertyAddress IS NULL;

UPDATE nas1
SET nas1.PropertyAddress = ISNULL(nas1.PropertyAddress, nas2.PropertyAddress)
FROM [Portfolio Projects]..NashvilleHousing nas1
JOIN [Portfolio Projects]..NashvilleHousing nas2
	ON nas1.ParcelID = nas2.ParcelID
		AND nas1.[UniqueID ] <> nas2.[UniqueID ]
WHERE nas1.PropertyAddress IS NULL;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Segregating 'Property Address' into 'Street Name' & 'City':

SELECT 
	SUBSTRING(
		PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) StreetName,
	SUBSTRING(
		PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) City
FROM [Portfolio Projects]..NashvilleHousing;

ALTER TABLE [Portfolio Projects]..NashvilleHousing
ADD PropertyStreetName nvarchar(255);
UPDATE [Portfolio Projects]..NashvilleHousing
SET PropertyStreetName = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

ALTER TABLE [Portfolio Projects]..NashvilleHousing
ADD PropertyCity nvarchar(255);
UPDATE [Portfolio Projects]..NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

SELECT *
FROM [Portfolio Projects]..NashvilleHousing;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Segregating 'Owner Address' into 'Street Name', 'City' & 'State':

SELECT 
	PARSENAME(REPLACE(OwnerAddress, ',','.'), 1) State,
	PARSENAME(REPLACE(OwnerAddress, ',','.'), 2) City,
	PARSENAME(REPLACE(OwnerAddress, ',','.'), 3) StreetName
FROM [Portfolio Projects]..NashvilleHousing;

ALTER TABLE [Portfolio Projects]..NashvilleHousing
ADD OwnerState nvarchar(255);
UPDATE [Portfolio Projects]..NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1);

ALTER TABLE [Portfolio Projects]..NashvilleHousing
ADD OwnerCity nvarchar(255);
UPDATE [Portfolio Projects]..NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2);

ALTER TABLE [Portfolio Projects]..NashvilleHousing
ADD OwnerStreetName nvarchar(255);
UPDATE [Portfolio Projects]..NashvilleHousing
SET OwnerStreetName = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3);

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Replacing 'Y' & 'N' to 'Yes' & 'No' for 'SoldAsVacant' field:

SELECT DISTINCT(SoldAsVacant),
	COUNT(SoldAsVacant)
FROM [Portfolio Projects]..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT
    SoldAsVacant,
    CASE 
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END 
FROM [Portfolio Projects]..NashvilleHousing;

UPDATE [Portfolio Projects]..NashvilleHousing
SET SoldAsVacant =  CASE 
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
					END 
					FROM [Portfolio Projects]..NashvilleHousing;
	
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Removing the duplicate data to simplify the data:

WITH XtraCTE AS (
SELECT *, 
	ROW_NUMBER() OVER (
		PARTITION BY
				ParcelID,
				PropertyAddress,
				SaleDate,
				SalePrice,
				LegalReference,
				OwnerAddress
			ORDER BY UniqueID
		) RowNum
FROM [Portfolio Projects]..NashvilleHousing
)
SELECT *
FROM XtraCTE
WHERE RowNum > 1;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Removing the unused data & columns:

ALTER TABLE [Portfolio Projects]..NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict;

SELECT *
FROM [Portfolio Projects]..NashvilleHousing;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- *NOTE:
-- In data processing, it's crucial to preserve the original raw data without making any direct modifications to the data itself. Instead, we employ techniques like
-- Temp Tables' or 'Views' to cleanse and manipulate the data while ensuring that the original dataset remains intact and accessible for future reference.
-- For the sole sake of the above project I've done deletion and formatting in the original project but is not a good practice for sound workflow.