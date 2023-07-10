SELECT *
	FROM CovidDeaths
	
SELECT *
	FROM CovidDeaths
	WHERE continent IS NOT NULL
	ORDER BY 3,4

--SELECT *
--	FROM CovidVaccinations
--	ORDER BY 3,4

/*Selecting data to be used*/
SELECT location, date,total_cases,new_cases,total_deaths,population
	FROM CovidDeaths
	ORDER BY 1,2

/*Looking at total cases vs total deaths*/
--shows the likelihood of dying if one contracted covid in a specific country

SELECT location, date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
	FROM CovidDeaths
	WHERE location like '%kenya%'
	ORDER BY 1,2

SELECT location, date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
	FROM CovidDeaths
	WHERE location like '%states%'
	ORDER BY 1,2

/*Looking at the total cases vs population*/
--Shows what percentage of the population got Covid

SELECT location,date,population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected 
	FROM CovidDeaths
	--WHERE location like '%states%'
	ORDER BY 1,2

/*Countries with the highest infection rate compared to the population*/

SELECT continent,location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidDeaths
-- WHERE location LIKE '%states%'
GROUP BY location,continent, population
ORDER BY PercentPopulationInfected DESC;

/*Showing countries with the highest death count per population*/
SELECT location, MAX (CAST (total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

/*BREAKING DATA DOWN BY CONTINENT*/
--Showing continents with the highest death counts per population
SELECT continent, MAX (CAST (total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Drill down of continents and the countries within those continents
SELECT continent, location, population
FROM CovidDeaths
WHERE continent = 'North America' 
GROUP BY continent,location,population
ORDER BY location;

--GLOBAL NUMBERS
--SELECT date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
SELECT date, SUM (new_cases) AS total_cases, SUM (CAST (new_deaths AS INT)) AS total_deaths, SUM (CAST (new_deaths AS INT))/SUM(new_cases) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

/*Total cases, deaths and death rates across the world*/
SELECT SUM (new_cases) AS total_cases, SUM (CAST (new_deaths AS INT)) AS total_deaths, SUM (CAST (new_deaths AS INT))/SUM(new_cases) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


/*Table Vaccinations*/
SELECT *
FROM CovidVaccinations

SELECT *
FROM CovidDeaths AS death
JOIN CovidVaccinations AS Vac
ON death.location = vac.location
AND death.date = vac.date

/*looking at the total population vs vaccinations*/
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

/*total population vs vaccinations given*/
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, (vac.new_vaccinations/dea.population)*100 AS vaccination_percentage
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--AND vac.new_vaccinations IS NOT NULL
ORDER BY 2,3

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
    CASE WHEN vac.new_vaccinations = 0 THEN NULL 
         ELSE (vac.new_vaccinations / NULLIF(dea.population, 0)) * 100
    END AS vaccination_percentage
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
    AND vac.new_vaccinations IS NOT NULL
ORDER BY dea.date--dea.location, dea.date,vaccination_percentage DESC;

/*Looking at total population vs vaccinations*/
SELECT dea.continent, dea.location, dea.population, vac.new_vaccinations, SUM (CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

	
/*Use CTE in order to use the newly created column*/
WITH PopVsVac (continent, location, date, population, new_vaccinations, TotalPeopleVaccinated)
AS
(
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
           SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalPeopleVaccinated
    FROM CovidDeaths AS dea
    JOIN CovidVaccinations AS vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *, (TotalPeopleVaccinated/population)*100 AS PercentageVaccinated
FROM PopVsVac
ORDER BY location, date;


/*Using Temp tables*/
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
    continent nvarchar(255),
    location nvarchar(255),
    date datetime,
    population numeric,
    new_vaccinations numeric,
    TotalPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(numeric, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL

SELECT *, (TotalPeopleVaccinated/population)*100 AS PercentageVaccinated
FROM #PercentPopulationVaccinated

/*Creating a view to store data for visualization*/
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(numeric, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated

/*Creating a view to store data for visualization*/
IF OBJECT_ID('dbo.HighestDeathRate', 'V') IS NOT NULL
    DROP VIEW dbo.HighestDeathRate;

GO

CREATE VIEW dbo.HighestDeathRate AS
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL AND total_deaths IS NOT NULL
GROUP BY location;
--ORDER BY TotalDeathCount DESC

SELECT *
FROM HighestDeathRate
