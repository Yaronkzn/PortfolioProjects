USE portfolio_project;

SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM CovidDeaths ORDER BY 1, 2;

-- Looking at Total Cases vs Total Deaths
-- Likelihood of dying from Covid

SELECT 
    Location, 
    date, 
    total_cases, 
    total_deaths, 
    CASE 
        WHEN total_cases = 0 THEN 0 
        ELSE (total_deaths / total_cases) * 100 
    END AS Death_percentage 
FROM 
    CovidDeaths 
ORDER BY 
    1, 2;

-- Total cases vs population
-- Shows what percentage of the population had Covid

SELECT 
    Location, 
    date, 
    total_cases, 
    population, 
    CASE 
        WHEN total_cases = 0 THEN 0 
        ELSE (total_cases / population) * 100 
    END AS cases_per_population 
FROM 
    CovidDeaths 
ORDER BY 
    1, 2;

-- Countries with the highest infection rate compared to population 

SELECT 
    Location,  
	population,
    MAX(total_cases) as Highest_infection_count, 
    MAX((total_cases/population))*100 as percent_population_infected
FROM 
    CovidDeaths 
GROUP BY Location, population
ORDER BY 
percent_population_infected DESC;

-- Countries with the highest death count compared to population

SELECT 
    Location,  
	population,
    MAX(total_deaths) as total_death_count, 
    ROUND(MAX((total_deaths/population))*100, 2) as percent_population_died
FROM 
    CovidDeaths 
GROUP BY Location, population
ORDER BY 
percent_population_died DESC;

-- Continents with highest death counts 

SELECT 
    continent,
    MAX(cast(total_deaths as int)) as total_death_count
FROM 
    CovidDeaths 
WHERE continent is not null
GROUP BY continent
ORDER BY 
total_death_count DESC;

-- GLOBAL NUMBERS

SELECT  
    SUM(ISNULL(new_cases, 0)) as sum_new_cases,
    SUM(ISNULL(new_deaths, 0)) as sum_new_deaths,
    CASE 
        WHEN SUM(ISNULL(new_cases, 0)) = 0 THEN 0 
        ELSE (SUM(ISNULL(new_deaths, 0)) / SUM(ISNULL(new_cases, 0))) * 100 
    END as death_percentage
FROM 
    CovidDeaths 
WHERE 
    continent IS NOT NULL
ORDER BY 
    1, 2;

-- Rolling vaccination count

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
FROM CovidDeaths dea JOIN CovidVaccinations vac ON dea.location = vac.location and dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL
ORDER BY 2, 3;

-- CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, rolling_people_vaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
FROM CovidDeaths dea JOIN CovidVaccinations vac ON dea.location = vac.location and dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL)
SELECT *, (rolling_people_vaccinated/Population)*100 FROM PopvsVac;

-- Creating view to store data for later vizualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
FROM CovidDeaths dea JOIN CovidVaccinations vac ON dea.location = vac.location and dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL;

SELECT * FROM PercentPopulationVaccinated;


