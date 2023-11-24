SELECT * 
FROM PortfolioProject..CovidDeaths


--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Data to be used in this project

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- total_cases vs new_cases
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--shows percentage population that contracted covid
SELECT location, date, population, total_cases, (total_cases/population)*100 PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Countries with Highest Infected Rate compared to Population
SELECT location, population, MAX(total_cases) HighestInfected, MAX((total_cases/population))*100 PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY HighestInfected DESC

--Countries with highest death count per population
SELECT location, MAX(cast(total_deaths AS INT)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeathCount DESC 

--Continents with highest death count per population
SELECT continent, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS
SELECT SUM(new_cases) total_cases, SUM(cast(new_deaths as INT)) total_deaths, SUM(cast(new_deaths as INT))/SUM(new_cases)*100 DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2 

-- Checking for Total Population vs Total vaccinations

SELECT cdea.continent, cdea.location, cdea.date, cvac.new_vaccinations, SUM(cast(cvac.new_vaccinations as INT)) OVER (Partition by cdea.location Order by 
cdea.location, cdea.date) RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths cdea
JOIN  PortfolioProject..CovidVaccinations cvac
	ON cdea.location = cvac.location
	AND cdea.date = cvac.date
WHERE cdea.continent IS NOT  NULL
ORDER BY 2,3

-- USING CTEs
WITH  PopVsVac (continent, location, date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(SELECT cdea.continent, cdea.location, cdea.date, cdea.population, cvac.new_vaccinations, SUM(cast(cvac.new_vaccinations as INT)) OVER (Partition by cdea.location Order by 
cdea.location, cdea.date) RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths cdea
JOIN  PortfolioProject..CovidVaccinations cvac
	ON cdea.location = cvac.location
	AND cdea.date = cvac.date
WHERE cdea.continent IS NOT  NULL
--ORDER BY 2,3
) 

SELECT *, (RollingPeopleVaccinated/Population)* 100
FROM PopVsVac


--TEMP TABLE
DROP TABLE if exists #PercentagePeopleVaccinated
CREATE TABLE #PercentagePeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vacciinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentagePeopleVaccinated
SELECT cdea.continent, cdea.location, cdea.date, cdea.population, cvac.new_vaccinations, SUM(cast(cvac.new_vaccinations as INT)) OVER (Partition by cdea.location Order by 
cdea.location, cdea.date) RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths cdea
JOIN  PortfolioProject..CovidVaccinations cvac
	ON cdea.location = cvac.location
	AND cdea.date = cvac.date
WHERE cdea.continent IS NOT  NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)* 100 
FROM #PercentagePeopleVaccinated
ORDER BY Location, Date


-- CREATING VIEWS TO STORE DATA 
CREATE VIEW PercentagePeopleVaccinated
AS SELECT cdea.continent, cdea.location, cdea.date, cdea.population, cvac.new_vaccinations, SUM(cast(cvac.new_vaccinations as INT)) OVER (Partition by cdea.location Order by 
cdea.location, cdea.date) RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths cdea
JOIN  PortfolioProject..CovidVaccinations cvac
	ON cdea.location = cvac.location
	AND cdea.date = cvac.date
WHERE cdea.continent IS NOT  NULL
--ORDER BY 2,3

SELECT *
FROM PercentagePeopleVaccinated