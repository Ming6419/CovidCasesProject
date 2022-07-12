
Select * 
From Portfolio1.dbo.CovidDeaths
where continent is null
order by location, date;

Select * 
From Portfolio1.dbo.CovidVaccinations
where continent is not null
order by location, date

--Select Data to be used

Select Location, Date, total_cases, new_cases, total_deaths, population
from Portfolio1.dbo.CovidDeaths
where continent is not null
order by location, Date

-- Looking at Total Cases vs Total Deaths
-- Shows covid death percentage as contracted cases.

Select Location, Date, ISNULL(total_cases, 0), ISNULL(total_deaths, 0), (ISNULL(total_deaths, 0)/total_cases)*100 as DeathPercentage
from Portfolio1.dbo.CovidDeaths
where location like 'Malaysia' and continent is not null
order by location, Date

-- Looking at Total Cases vs Population
-- Shows Covid contraction percentage per population

Select Location, Date, ISNULL(total_cases, 0), population, (ISNULL(total_cases, 0)/population)*100 as CovidPercentage
from Portfolio1.dbo.CovidDeaths
where continent is not null
--where location like 'Malaysia'
order by location, Date

-- Looking at Countries with Highest Infection Rate with respect to Population
-- NUll value are treated as 0 for cases


Select Location, MAX(ISNULL(total_cases, 0)) as [Highest Infection Count], population, MAX((ISNULL(total_cases, 0)/population))*100 as MAXCovidPercentage
from Portfolio1.dbo.CovidDeaths
where continent is not null
Group by Location, Population
order by MAXCovidPercentage DESC

-- Looking at Countries with Highest Death Count
-- NUll value are treated as 0 for cases

Select Location, MAX(ISNULL(cast(total_deaths as int), 0)) as [Highest Total Death Count]
from Portfolio1.dbo.CovidDeaths
where continent is not null
Group by Location
order by [Highest Total Death Count] DESC

-- Looking at Continents with Highest Death Count
-- remove income type data

Select location, MAX(ISNULL(cast(total_deaths as int), 0)) as [Highest Total Death Count]
from Portfolio1.dbo.CovidDeaths
where continent is null and location not like '%income%'
Group by location
order by [Highest Total Death Count] DESC

-- Global numbers with respect to time

Select Date, sum(ISNULL(total_cases, 0)) as [Total Cases Count], sum(ISNULL(cast(total_deaths as float), 0)) as [Total Death Count], (sum(ISNULL(cast(total_deaths as float), 0))/sum(total_cases))*100 as [Death percentage]
from Portfolio1.dbo.CovidDeaths
--where location like 'Malaysia' and continent is not null
group by Date
order by 1 DESC

--Looking at Total polulation vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, isnull(vac.new_vaccinations,0) as new_vaccinations
, sum(isnull(convert(float,vac.new_vaccinations),0)) over (Partition by dea.location Order by dea.location, dea.Date) as [Cummulative vaccinations]
From Portfolio1.dbo.CovidDeaths dea
join Portfolio1.dbo.CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null and dea.location not like '%income%'
order by 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccination, Cummulative_vaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, isnull(vac.new_vaccinations,0) as new_vaccinations
, sum(isnull(convert(float,vac.new_vaccinations),0)) over (Partition by dea.location Order by dea.location, dea.Date) as [Cummulative vaccinations]
From Portfolio1.dbo.CovidDeaths dea
join Portfolio1.dbo.CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null and dea.location not like '%income%'
)

Select *, (Cummulative_vaccinations/population)*100 as Vaccination_Percentage
From PopvsVac
Order by 2,3

--Temp table

Drop Table if exists #PercentagePopulationVaccinated
create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_vaccinations numeric,
Cummulative_vaccinations numeric
)


Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, isnull(vac.new_vaccinations,0) as new_vaccinations
, sum(isnull(convert(float,vac.new_vaccinations),0)) over (Partition by dea.location Order by dea.location, dea.Date) as [Cummulative vaccinations]
From Portfolio1.dbo.CovidDeaths dea
join Portfolio1.dbo.CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null and dea.location not like '%income%'

Select *, (Cummulative_vaccinations/population)*100 as Vaccination_Percentage
from #PercentagePopulationVaccinated

-- Creating View to store data for later visualisations.

drop view if exists PercentagePopulationVaccinated

CREATE VIEW PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, isnull(vac.new_vaccinations,0) as new_vaccinations
, sum(isnull(convert(float,vac.new_vaccinations),0)) over (Partition by dea.location Order by dea.location, dea.Date) as [Cummulative vaccinations]
From Portfolio1.dbo.CovidDeaths dea
join Portfolio1.dbo.CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null and dea.location not like '%income%'


CREATE VIEW CommulativePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, isnull(vac.new_vaccinations,0) as new_vaccinations
, sum(isnull(convert(float,vac.new_vaccinations),0)) over (Partition by dea.location Order by dea.location, dea.Date) as [Cummulative vaccinations]
From Portfolio1.dbo.CovidDeaths dea
join Portfolio1.dbo.CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null and dea.location not like '%income%'


CREATE VIEW GlobalDeathPercentage as
Select Location, Date, sum(ISNULL(total_cases, 0)) as [Total Cases Count], sum(ISNULL(cast(total_deaths as float), 0)) as [Total Death Count], (sum(ISNULL(cast(total_deaths as float), 0))/sum(total_cases))*100 as [Death percentage]
from Portfolio1.dbo.CovidDeaths
--where location like 'Malaysia' and 
where continent is not null
group by Location, Date


CREATE VIEW HighestDeathPerContinent as
Select location, MAX(ISNULL(cast(total_deaths as int), 0)) as [Highest Total Death Count]
from Portfolio1.dbo.CovidDeaths
where continent is null and location not like '%income%'
Group by location


CREATE VIEW HighestDeathPerCountry as
Select Location, MAX(ISNULL(cast(total_deaths as int), 0)) as [Highest Total Death Count]
from Portfolio1.dbo.CovidDeaths
where continent is not null
Group by Location


CREATE VIEW HighestCovidRatePerCountry as
Select Location, MAX(ISNULL(total_cases, 0)) as [Highest Infection Count], population, MAX((ISNULL(total_cases, 0)/population))*100 as MAXCovidPercentage
from Portfolio1.dbo.CovidDeaths
where continent is not null
Group by Location, Population


CREATE VIEW CovidInfectionRateperCountry as
Select Location, Date, ISNULL(total_cases, 0) as total_cases, population, (ISNULL(total_cases, 0)/population)*100 as CovidPercentage
from Portfolio1.dbo.CovidDeaths
where continent is not null


CREATE VIEW CovidDeathRateperCountry as
Select Location, Date, ISNULL(total_cases, 0) as total_cases, ISNULL(total_deaths, 0) as total_deaths, (ISNULL(total_deaths, 0)/total_cases)*100 as DeathPercentage
from Portfolio1.dbo.CovidDeaths
where continent is not null

CREATE VIEW Covid_DeathCasesPerCountry as
Select Location, Date, total_cases, new_cases, total_deaths, population
from Portfolio1.dbo.CovidDeaths
where continent is not null



