/*

Covid 19 Data Exploration from https://ourworldindata.org/covid-deaths
I used the .csv files and import it to SSMS
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM PortfolioProject_SQL..Covid19_TotalCase
ORDER BY 3,4

-- Data Selecting

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject_SQL..Covid19_TotalCase
ORDER BY 1,2

-- Death Percentage in Indonesia

SELECT Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject_SQL..Covid19_TotalCase
WHERE Location like 'indo%'
ORDER BY 1,2

-- Cases Percentage in Indonesia

SELECT Location, date, population, total_cases, (total_cases/population)*100 as CasePercentage
FROM PortfolioProject_SQL..Covid19_TotalCase
WHERE Location like 'indo%'
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject_SQL..Covid19_TotalCase
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

-- Countries with Highest Death Count per Population

SELECT Location, MAX(CONVERT(int, Total_deaths)) as TotalDeathCount
FROM PortfolioProject_SQL..Covid19_TotalCase
WHERE continent IS NOT NULL 
GROUP BY Location
ORDER BY TotalDeathCount DESC


-- Continents with The Total Death per Population

SELECT continent, MAX(CAST(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject_SQL..Covid19_TotalCase
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- The Global Numbers of Total Cases, Total Deaths also Death Percentage of Covid-19

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProject_SQL..Covid19_TotalCase
WHERE continent IS NOT NULL 
ORDER BY 1,2


-- People Getting Covid Vaccine in Every Countries

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(numeric, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject_SQL..Covid19_TotalCase dea
JOIN PortfolioProject_SQL..Covid19_Vac vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- Using Common Table Expressions (CTE) to Get Percentage of People Getting Vaccinated

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(numeric, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject_SQL..Covid19_TotalCase dea
JOIN PortfolioProject_SQL..Covid19_Vac vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
FROM PopvsVac


-- Using Temp Table to Get Percentage of People Getting Vaccinated

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(numeric, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject_SQL..Covid19_TotalCase dea
JOIN PortfolioProject_SQL..Covid19_Vac vac
	ON dea.location = vac.location
	and dea.date = vac.date 

SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
FROM #PercentPopulationVaccinated


-- Creating View for Data Visualizations

CREATE VIEW PercentPopulationVaccinated
as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(numeric, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject_SQL..Covid19_TotalCase dea
JOIN PortfolioProject_SQL..Covid19_Vac vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL