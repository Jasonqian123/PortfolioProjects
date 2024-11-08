--select * from dbo.CovidDeaths order by 1,2;
--use [Profolio Project];

--retrive cases & deaths data
--select location,date,total_cases,new_cases,total_deaths,new_deaths 
--from dbo.CovidDeaths order by 1,2;
use [Profolio Project]
--Looking at Total cases & Total deaths
--Shows likelihood of dying if you affect covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 as DeathPercentage from dbo.CovidDeaths
where location like '%Kingdom%'
order by 1,2;  


--Looking at Total cases vs the population
--Shows what percentage of population got covid
select location, date, population, total_cases, (total_cases/population) * 100 as PercentPopulaInfected from dbo.CovidDeaths
where location like '%Kingdom%'
order by 1,2; 

--Looking at the country with highest infection rate compared to population
select location, max(total_cases) as 'Total Cases', max(total_cases/population) as HighestInfectionCount from dbo.CovidDeaths 
 group by location 
 order by HighestInfectionCount desc;


 --Showing country have highest deaths count 
select location, max(cast(total_deaths as int)) as TotalDeathCount from dbo.CovidDeaths
 where continent is not null
 group by location
 order by TotalDeathCount desc;

 --Break down by continent
  --Showing continents have highest deaths count 
select location, max(cast(total_deaths as int)) as TotalDeathCount from dbo.CovidDeaths
 where continent is null
 group by location
 order by TotalDeathCount desc;

 --Globle number
 --Globle deaths rate
 select sum(new_cases) as 'Total cases', sum(cast(new_deaths as int)) as 'Total death', 
 sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathRate
 from dbo.CovidDeaths
 where continent is not null;

 --Looking at total population vs vacination 
 select cod.continent, cod.location, cod.date,  cod.population, cod.date, cov.new_vaccinations,
 sum(cast(cov.new_vaccinations as int)) over (partition by cod.location order by cod.location, cod.date) as RollingPeopleVaccinated
 from dbo.CovidDeaths cod
 join dbo.CovidVaccinations cov
 on cod.location=cov.location
 and cod.date=cov.date
 where cod.continent is not null
  order by 2,3;

--Lokking at population vs vaccinated 

--CTE
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as 
(
 select cod.continent, cod.location, cod.date,  cod.population, cov.new_vaccinations,
 sum(cast(cov.new_vaccinations as int)) over (partition by cod.location order by cod.location, cod.date) as RollingPeopleVaccinated
 from dbo.CovidDeaths cod
 join dbo.CovidVaccinations cov
 on cod.location=cov.location
 and cod.date=cov.date
 where cod.continent is not null
  )

Select *, (RollingPeopleVaccinated/population) * 100 as PopvsVac 
from PopvsVac

--Temp Table

Drop table if exists #PopulationvsVaccinated
create table #PopulationvsVaccinated
(
continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PopulationvsVaccinated
 select cod.continent, cod.location, cod.date,  cod.population, cov.new_vaccinations,
 sum(cast(cov.new_vaccinations as int)) over (partition by cod.location order by cod.location, cod.date) as RollingPeopleVaccinated
 from dbo.CovidDeaths cod
 join dbo.CovidVaccinations cov
 on cod.location=cov.location
 and cod.date=cov.date
where cod.continent is not null

Select *, (RollingPeopleVaccinated/population) * 100 as PopvsVac 
from #PopulationvsVaccinated

--Create View for later dataviz
create view PercentPopulationVaccinated as 
 select cod.continent, cod.location, cod.date,  cod.population, cov.new_vaccinations,
 sum(cast(cov.new_vaccinations as int)) over (partition by cod.location order by cod.location, cod.date) as RollingPeopleVaccinated
 from dbo.CovidDeaths cod
 join dbo.CovidVaccinations cov
 on cod.location=cov.location
 and cod.date=cov.date
 where cod.continent is not null

 select * 
 from PercentPopulationVaccinated
