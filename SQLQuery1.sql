					SQL Data Exploration - Covid Information

use PortfolioProject

SELECT *FROM PortfolioProject..CovidDeaths
order by 3, 4

SELECT * FROM PortfolioProject..CovidVaccinations
order by 3,4 

Select Location, Date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1, 2

				--looking at total cases vs total deaths
				--shows likelihood of dying if you have covid in PT
			
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_rate
FROM PortfolioProject..CovidDeaths
WHERE location = 'Portugal'
order by 1,2 

				--looking at total cases vs population, shows % of population that got covid
			
Select Location, date, Population, total_cases, (total_cases/population)*100 as %ofpopulationinfected
FROM PortfolioProject..CovidDeaths
WHERE location = 'Portugal'
order by 1,2 

				--looking at countries with highest infection rate vs population

Select Location, Population, MAX(total_cases), MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY Location, population
order by PercentPopulationInfected DESC

				--highest deathCount

SELECT LOCATION, Max(cast(Total_deaths as int)) as TDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
GROUP BY Location
order by TDeathCount DESC

				--by continent - highest death count

SELECT Continent, Max(cast(Total_deaths as int)) as TDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
GROUP BY Continent
order by TDeathCount DESC


				--global numbers per day
				
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
order by 1,2 
				--global numbers in total
				
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 1,2 

				--total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) as addedPeopleVaccinated,

FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


--use CTE or tempTable as we cannot perform a calculation of addedPeopleVaccinated because we just created 
it in the same query. 	

				--Using CTE:


with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, addedPeopleVaccinated)
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) as addedPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
SELECT *, (addedPeopleVaccinated/Population)*100 as PeopleVaccinatedinPopulation FROM PopvsVac

				--using temp table:

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(225),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
addedPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) as addedPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

SELECT *, (addedPeopleVaccinated/population)*100 FROM #PercentPopulationVaccinated

				--create view to store a permanent set of data, which can then be used further.

CREATE VIEW PercentPopulationVaccinated2 as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select * from PercentPopulationVaccinated2
