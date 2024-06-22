select * 
from portfoliodatabase..[owid-covid-deaths]
order by 3,4

select * 
from portfoliodatabase..[owid-covid-vaccinations]
order by 3,4

select 
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
from portfoliodatabase..[owid-covid-deaths]
order by 1,2

-- Total cases vs Total deaths

select 
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/
	total_cases) * 100 as PercentageDeaths
from portfoliodatabase..[owid-covid-deaths]
where location like '%states%'
order by 1,2


--Total cases vs population
select 
	location,
	date,
	total_cases,
	population,
	(total_cases/
	population) * 100 as CovidPercentage
from portfoliodatabase..[owid-covid-deaths]
--where location like '%states%'
order by 1,2



alter table [owid-covid-deaths] alter column total_deaths float

--Looking at total cases vs population
--Shows % of population with covid

 select 
	location,
	date,
	population,
	total_cases,
	(total_cases/
	population) * 100 as CovidPercentage
from portfoliodatabase..[owid-covid-deaths]
--where location like '%states%'
order by 1,2


--Looking at countries with highest infection rates
 select 
	location,
	population,
	max(total_cases) as highestInfectionCount,
	max((total_cases/
	population)) * 100 as PercentPopulationInfected
from portfoliodatabase..[owid-covid-deaths]
--where location like '%states%'
group by location,	population
order by PercentPopulationInfected desc


-- Showing countries with Highest death count per population
select location, max(total_cases) as TotalDeathCount
from portfoliodatabase..[owid-covid-deaths]
where continent is not null
group by location
order by TotalDeathCount desc



--LETS BREAK DOWN TO CONTINENTS

select continent, max(total_cases) as TotalDeathCount
from portfoliodatabase..[owid-covid-deaths]
where continent is not  null
group by continent
order by TotalDeathCount desc



--GLOBAL NUMBERS
select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int))  
--sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage
from portfoliodatabase..[owid-covid-deaths]
where continent is not  null and  new_cases is not null and  new_deaths is not null
group by date
order by 1

--Looking for total population vs vaccinations

select 
	dea.continent, 
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)  as RollingPeopleVaccinated,

from portfoliodatabase..[owid-covid-deaths] dea
	join portfoliodatabase..[owid-covid-vaccinations] vac
on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null and 
	  vac.new_vaccinations is not null
	  order by 2,3


-- use CTE
with popvsvac(
	continent, 
	location,
	date,
	population,
	new_vaccinations,
	RollingPeopleVaccinated)
as(
select 
	dea.continent, 
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)  as RollingPeopleVaccinated

from portfoliodatabase..[owid-covid-deaths] dea
	join portfoliodatabase..[owid-covid-vaccinations] vac
on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null and 
	  vac.new_vaccinations is not null
	--  order by 2,3
	  )

select *, (RollingPeopleVaccinated/population)*100 from popvsvac


--Temp table
drop table  if exists #PercentPopulationVaccinated

create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated

select 
	dea.continent, 
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)  as RollingPeopleVaccinated

from portfoliodatabase..[owid-covid-deaths] dea
	join portfoliodatabase..[owid-covid-vaccinations] vac
on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null and 
	  vac.new_vaccinations is not null
	--  order by 2,3
	  

select *, (RollingPeopleVaccinated/population)*100 from #PercentPopulationVaccinated


--create view to store data for future visualizations
create view PercentPopulationVaccinated as 
select 
	dea.continent, 
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)  as RollingPeopleVaccinated

from portfoliodatabase..[owid-covid-deaths] dea
	join portfoliodatabase..[owid-covid-vaccinations] vac
on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null and 
	  vac.new_vaccinations is not null
	--  order by 2,3

SELECT *
  FROM [portfoliodatabase].[dbo].[PercentPopulationVaccinated]
