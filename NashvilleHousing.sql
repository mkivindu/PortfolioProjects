select * from dbo.NashvilleHouseData

--standardize date format

select SaleDate, cast(SaleDate as Date) from portfoliodatabase.dbo.NashvilleHouseData 


update portfoliodatabase.dbo.NashvilleHouseData set SaleDate = convert(Date,SaleDate) 

alter table  dbo.NashvilleHouseData alter column SaleDate Date


--property address data

select 
a.ParcelID,
a.PropertyAddress,
b.ParcelID,
b.PropertyAddress,
ISNULL(a.PropertyAddress, b.PropertyAddress)
from portfoliodatabase.dbo.NashvilleHouseData a 
join portfoliodatabase.dbo.NashvilleHouseData b  on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


update a set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from portfoliodatabase.dbo.NashvilleHouseData a 
join portfoliodatabase.dbo.NashvilleHouseData b  on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null




--breaking out address into individual columns(address, City, State)


select PropertyAddress from dbo.NashvilleHouseData



select 
substring(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1) as Address,
substring(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
from dbo.NashvilleHouseData


alter table  dbo.NashvilleHouseData
add  PropertySplitAddress nvarchar(255)

update portfoliodatabase.dbo.NashvilleHouseData 
set PropertySplitAddress = substring(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1) 

alter table  dbo.NashvilleHouseData 
add  PropertySplitCity nvarchar(255)

update portfoliodatabase.dbo.NashvilleHouseData 
set PropertySplitCity = substring(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

select * 
from portfoliodatabase.dbo.NashvilleHouseData



select 
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from portfoliodatabase.dbo.NashvilleHouseData



alter table  dbo.NashvilleHouseData
add  OwnerSplitAddress nvarchar(255)

update portfoliodatabase.dbo.NashvilleHouseData 
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3) 

alter table  dbo.NashvilleHouseData 
add  OwnerSplitCity nvarchar(255)

update portfoliodatabase.dbo.NashvilleHouseData 
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)


alter table  dbo.NashvilleHouseData 
add  OwnerSplitCState nvarchar(255)

update portfoliodatabase.dbo.NashvilleHouseData 
set OwnerSplitCState = PARSENAME(replace(OwnerAddress,',','.'),1)


select * 
from portfoliodatabase.dbo.NashvilleHouseData


----change  Y and N to No and Yes

select distinct(SoldAsVacant) 
from portfoliodatabase.dbo.NashvilleHouseData


update NashvilleHouseData
set SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
						end


select distinct(SoldAsVacant) 
from portfoliodatabase.dbo.NashvilleHouseData

---Remove duplicates
WITH RowNumCTE AS(
select *,
	ROW_NUMBER() OVER (
	PARTITION BY	ParcelID,
					PropertyAddress,
					SalePrice,
					saleDate,
					LegalReference
					ORDER BY
						UniqueID
						) row_num

from portfoliodatabase.dbo.NashvilleHouseData
--ORDER BY ParcelID
)

Select * from RowNumCTE
where row_num > 1
--order by PropertyAddress



select * 
from portfoliodatabase.dbo.NashvilleHouseData




----Delete unused columns


alter table portfoliodatabase.dbo.NashvilleHouseData drop column OwnerAddress, TaxDistrict, PropertyAddress

select * 
from portfoliodatabase.dbo.NashvilleHouseData