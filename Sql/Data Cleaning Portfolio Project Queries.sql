/*

Cleaning Data in SQL Queries

*/


Select *
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDateConverted
From PortfolioProject.dbo.NashvilleHousing


update PortfolioProject.dbo.NashvilleHousing
set saledate = convert(date,SaleDate)
-- if the above query doesn't work the next 2 querys make a new column with the new values

alter table PortfolioProject.dbo.NashvilleHousing
add SaleDateConverted Date;


update PortfolioProject.dbo.NashvilleHousing
set SaleDateConverted = convert(date,SaleDate)



 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data


select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a 
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)



Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

select
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(propertyaddress) ) as City
From PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
add Propertysplitaddress nvarchar(255);


update PortfolioProject.dbo.NashvilleHousing
set Propertysplitaddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

alter table PortfolioProject.dbo.NashvilleHousing
add Propertysplitcity nvarchar(255);


update PortfolioProject.dbo.NashvilleHousing
set Propertysplitcity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(propertyaddress) )





--Another way

Select *
From PortfolioProject.dbo.NashvilleHousing


Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

select
PARSENAME(replace(OwnerAddress,',','.'),3)
,PARSENAME(replace(OwnerAddress,',','.'),2)
,PARSENAME(replace(OwnerAddress,',','.'),1)
From PortfolioProject.dbo.NashvilleHousing



alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)



alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitCity nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitCity =PARSENAME(replace(OwnerAddress,',','.'),2)



alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitState nvarchar(255);


update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)



--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field



Select *
From PortfolioProject.dbo.NashvilleHousing

Select distinct(SoldAsVacant),count(soldasvacant)
From PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant
,case when SoldAsVacant = 'Y' then 'Yes'
	  when SoldAsVacant = 'n' then 'No'
	  else SoldAsVacant
	  end
From PortfolioProject.dbo.NashvilleHousing

update PortfolioProject.dbo.NashvilleHousing
set SoldAsVacant =
	  case when SoldAsVacant = 'Y' then 'Yes'
	  when SoldAsVacant = 'n' then 'No'
	  else SoldAsVacant
	  end




-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNUMCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY parcelID,
                         propertyAddress,
                         salePrice,
                         saledate,
                         legalReference
            ORDER BY uniqueID
        ) AS Row_num
    FROM PortfolioProject.dbo.NashvilleHousing
    --ORDER BY ParcelID
)
Delete from RowNUMCTE
where Row_num > 1








---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select  *
From PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
drop column owneraddress,taxdistrict,propertyaddress









-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO


















