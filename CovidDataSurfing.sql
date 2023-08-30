
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Viewing total cases compared to total deaths
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE LOCATION like '%canada%'
AND continent is not null
ORDER BY 1,2

-- Viewing Total Cases vs Population
SELECT Location, date, total_cases, Population, (total_cases/Population)*100 as CasePercentage
FROM PortfolioProject..CovidDeaths
WHERE LOCATION like '%canada%'
AND continent is not null
ORDER BY 1,2

-- Viewing Countries with Highest Infection Rate compared to population
SELECT Location, MAX(total_cases) as HighestInfectionCount, Population, MAX((total_cases/Population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

-- Viewing Countries with Highest Death Count per Population
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- Breaking things down by continent
-- Viewing Continents with the highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Global Numbers
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Viewing Total Population vs Vaccinations
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations
, SUM(Cast(vacs.new_vaccinations as int)) OVER (PARTITION BY deaths.Location ORDER BY deaths.location,
deaths.Date) as SummingPeopleVaccinated
FROM PortfolioProject..CovidDeaths deaths
JOIN PortfolioProject..CovidVaccinations vacs
	ON deaths.location = vacs.location
	and deaths.date = vacs.date
WHERE deaths.continent is not null
ORDER BY 2,3

-- Using CTE
WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, SummingPeopleVaccinated)
as
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations
, SUM(Cast(vacs.new_vaccinations as int)) OVER (PARTITION BY deaths.Location ORDER BY deaths.location,
deaths.Date) as SummingPeopleVaccinated
FROM PortfolioProject..CovidDeaths deaths
JOIN PortfolioProject..CovidVaccinations vacs
	ON deaths.location = vacs.location
	and deaths.date = vacs.date
WHERE deaths.continent is not null
--ORDER BY 2,3
)
SELECT *, (SummingPeopleVaccinated/Population)*100
FROM PopvsVac

-- Temp Table
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
SummingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations
, SUM(Cast(vacs.new_vaccinations as int)) OVER (PARTITION BY deaths.Location ORDER BY deaths.location,
deaths.Date) as SummingPeopleVaccinated
FROM PortfolioProject..CovidDeaths deaths
JOIN PortfolioProject..CovidVaccinations vacs
	ON deaths.location = vacs.location
	and deaths.date = vacs.date
--WHERE deaths.continent is not null
--ORDER BY 2,3

SELECT *, (SummingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Creating views to store for later visuals
CREATE VIEW PercentPopulationVaccinated as
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations
, SUM(Cast(vacs.new_vaccinations as int)) OVER (PARTITION BY deaths.Location ORDER BY deaths.location,
deaths.Date) as SummingPeopleVaccinated
FROM PortfolioProject..CovidDeaths deaths
JOIN PortfolioProject..CovidVaccinations vacs
	ON deaths.location = vacs.location
	and deaths.date = vacs.date
WHERE deaths.continent is not null
--ORDER BY 2,3

CREATE VIEW GlobalNumbers as
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
--ORDER BY 1,2

CREATE VIEW CasesToDeaths as
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE LOCATION like '%canada%'
AND continent is not null
--ORDER BY 1,2

-- Viewing Total Cases vs Population
CREATE VIEW CasesToPopulation as
SELECT Location, date, total_cases, Population, (total_cases/Population)*100 as CasePercentage
FROM PortfolioProject..CovidDeaths
WHERE LOCATION like '%canada%'
AND continent is not null
--ORDER BY 1,2
