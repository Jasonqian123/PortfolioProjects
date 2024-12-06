Use [Profolio Project]
select * from [Nashville Housing]

-------------------------------------------------------------------
--Standardize Data Foramt

select SaleDateConvert, convert(Date,SaleDate) 
from [Nashville Housing]

update [Nashville Housing] 
set SaleDate= CONVERT(Date, SaleDate)

Alter Table [Nashville Housing]
Add SaleDateConvert Date

Update [Nashville Housing]
set SaleDateConvert = convert(date, SaleDate)

select SaleDateConvert from [Nashville Housing]

---------------------------------------------------------------
--Populate Property Address Data

select *
from [Nashville Housing]
where ParcelID ='025 07 0 031.00' 
order by 2

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) 
from [Nashville Housing] a
join [Nashville Housing] b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <>b.[UniqueID ]
where a.PropertyAddress is null

update a
set a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Nashville Housing] a
join [Nashville Housing] b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <>b.[UniqueID ]
where a.PropertyAddress is null

------------------------------------------------------------
--Breaking out Address into Individual Columns (Adress, City, State)

select PropertyAddress, 
substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress)) as City
from [Nashville Housing]

alter table [Nashville Housing]
add ProAddSpliteAddress varchar(255)

update [Nashville Housing]
set ProAddSpliteAddress = substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) 

alter table [Nashville Housing]
add ProAddSpliteCity varchar(255)

update [Nashville Housing]
set ProAddSpliteCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress)) 

select * from [Nashville Housing]

--2. method: parsename()

select PARSENAME(replace(OwnerAddress, ',', '.'), 3),
PARSENAME(replace(OwnerAddress, ',', '.'), 2),
PARSENAME(replace(OwnerAddress, ',', '.'), 1)
from [Nashville Housing]

alter table [Nashville Housing]
add OwnerAddSpliteAddress varchar(255)

update [Nashville Housing]
set OwnerAddSpliteAddress = PARSENAME(replace(OwnerAddress, ',', '.'), 3)

alter table [Nashville Housing]
add OwnerAddSpliteCity varchar(255)

update [Nashville Housing]
set OwnerAddSpliteCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2)

alter table [Nashville Housing]
add OwnerAddSpliteState varchar(255)

update [Nashville Housing]
set OwnerAddSpliteState = PARSENAME(replace(OwnerAddress, ',', '.'), 1)

Select * from [Nashville Housing]

-------------------------------------------------------------------------
--Change Y and N to Yes and No in "SoldAsVacant"

select distinct(SoldAsVacant), count(SoldAsVacant)
from [Nashville Housing]
group by SoldAsVacant
order by 2 desc

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
end
from [Nashville Housing]

update [Nashville Housing]
set SoldAsVacant = 
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
end


--------------------------------------------------------------
--Remove Duplicates

select *, ROW_NUMBER() over (partition by ParcelID, 
										  PropertyAddress, 
										  SalePrice,
										  SaleDate,
										  LegalReference
							  order by UniqueID) as 'Row_Number'
from [Nashville Housing]

--cte

with FindDuplicate as (
select *, ROW_NUMBER() over (partition by ParcelID, 
										  PropertyAddress, 
										  SalePrice,
										  SaleDate,
										  LegalReference
							  order by UniqueID) as 'Row_Number'
from [Nashville Housing]
)

select * from FindDuplicate
where ROW_NUMBER > 1

delete from FindDuplicate
where ROW_NUMBER > 1
--Order by UniqueID

-------------------------------------------------------------------------
--Delete Unused Data

select * from [Nashville Housing]

alter table [Nashville Housing] 
drop column SaleDate, PropertyAddress, OwnerAddress, TaxDistrict
