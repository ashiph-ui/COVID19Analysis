SELECT * FROM CovidDeaths
ORDER BY 3,4

--SELECT * FROM CovidVaccinations
--ORDER BY 3,4


-- General facts and data from CovidDeaths:
SELECT location, date, total_cases, new_cases, population 
FROM CovidDeaths 
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shows the percentage of cases that result in death for the United States
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRatePercentage
FROM CovidDeaths 
WHERE location like '%states%'
ORDER BY 1,2


-- Looking at Countries' max number of recorded infections compared to population
SELECT location, max(total_cases) as PeakInfectionCount, population, (MAX(total_cases)/population)*100 AS PercentagePopulationInfected
FROM CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC



-- Showing Countries with the highest death count per population
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount 
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


-- For all locations, the total death count
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is null 
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Breaking Global Numbers 
SELECT SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- JOIN 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
FROM  PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location	
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2,3


-- CTE

WITH PopvsVac (Continent, Location, Date, Population, NewVaccinations, CumulativeVaccinations)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as CumulativeVaccinations
FROM  PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location	
	and dea.date = vac.date
WHERE dea.continent is not null

)

SELECT *, (CumulativeVaccinations/Population) FROM PopvsVac