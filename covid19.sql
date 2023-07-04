--looking at the data
SELECT *
FROM `orbital-concord-386515.Covid19.covid_deaths`
ORDER BY 3, 4


SELECT
   location,
   date,
   total_cases,
   new_cases,
   total_deaths,
   population,
FROM `orbital-concord-386515.Covid19.covid_deaths`
ORDER BY 1, 2

-- Looking at total cases vs total deaths, showing likelyhood of dying if infected by covid in your country

SELECT
   location,
   date,
   total_cases,
   total_deaths,
   population,
   (total_deaths/total_cases)*100 AS death_percentage
FROM `orbital-concord-386515.Covid19.covid_deaths`
WHERE location LIKE '%States%'
ORDER BY 1, 2

--Looking at the total cases vs the population
-- Shows what percentage of the population got covid

SELECT
   location,
   date,
   population,
   total_cases,
   (total_cases/population)*100 AS covid_infected_percentage
FROM `orbital-concord-386515.Covid19.covid_deaths`
WHERE location LIKE '%States%'
ORDER BY 1, 2

--Looking at countries with highest infection rate compared to the population

SELECT
   location,
   population,
   MAX(total_cases) AS highest_infection_count,
   MAX((total_cases/population))*100 AS infected_percentage,
FROM `orbital-concord-386515.Covid19.covid_deaths`
GROUP BY location, population
ORDER BY infected_percentage desc

SELECT
   location,
   population,
   date,
   MAX(total_cases) AS highest_infection_count,
   MAX((total_cases/population))*100 AS infected_percentage,
FROM `orbital-concord-386515.Covid19.covid_deaths`
GROUP BY location, population, date
ORDER BY infected_percentage desc

--Countries with highest death count per population
SELECT
   location,
   MAX(total_deaths) AS covid_death_count,
FROM `orbital-concord-386515.Covid19.covid_deaths`
WHERE continent is null and location NOT IN ('European union', 'Lower middle income', 'Low income', 'World', 'High income', 'Upper middle income')
GROUP BY location
ORDER BY covid_death_count desc

--continents deaths count per population
SELECT
   continent,
   MAX(total_deaths) AS covid_deaths_count,
FROM `orbital-concord-386515.Covid19.covid_deaths`
WHERE continent is not null
GROUP BY continent
ORDER BY covid_deaths_count desc

--Global numbers

SELECT
   date,
   SUM(new_cases) AS total_cases,
   SUM(new_deaths) AS total_deaths,
   SUM(new_deaths)/SUM(new_cases)* 100 death_percentage
FROM `orbital-concord-386515.Covid19.covid_deaths`
WHERE continent is not null AND new_cases <> 0
GROUP BY date
ORDER BY 1, 2

SELECT

   SUM(new_cases) AS total_cases,
   SUM(new_deaths) AS total_deaths,
   SUM(new_deaths)/SUM(new_cases)* 100 death_percentage
FROM `orbital-concord-386515.Covid19.covid_deaths`
WHERE continent is not null AND new_cases <> 0

ORDER BY 1, 2


--JOINING TABLES

SELECT *
FROM `Covid19.covid_deaths` AS dea
JOIN `Covid19.covid_vaccinations`AS vac
ON dea.location = vac.location
AND dea.date = vac.date

--looking at total population vs vaccinations

SELECT
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS ppl_vaccinated_adding
FROM `Covid19.covid_deaths` AS dea
    JOIN `Covid19.covid_vaccinations`AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 1,2,3

--Using CTE

WITH  pop_vs_vac
AS
(SELECT
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS ppl_vaccinated_adding
FROM `Covid19.covid_deaths` AS dea
    JOIN `Covid19.covid_vaccinations`AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not NULL
)
SELECT
*,
(ppl_vaccinated_adding/population)* 100 AS percentage_vaccinated
FROM pop_vs_vac


--CREATING VIEWS

CREATE VIEW `orbital-concord-386515.Covid19.covid_mortality_us`
AS
SELECT
   location,
   date,
   total_cases,
   total_deaths,
   population,
   (total_deaths/total_cases)*100 AS death_percentage
FROM `orbital-concord-386515.Covid19.covid_deaths`
WHERE location LIKE '%States%'
ORDER BY 1, 2

CREATE VIEW `orbital-concord-386515.Covid19.covid_mortality_world`
AS
SELECT
   location,
   date,
   total_cases,
   total_deaths,
   population,
   (total_deaths/total_cases)*100 AS death_percentage
FROM `orbital-concord-386515.Covid19.covid_deaths`
ORDER BY 1, 2

--view of covid infected by country
CREATE VIEW `orbital-concord-386515.Covid19.covid_infected`
AS
SELECT
   location,
   population,
   MAX(total_cases) AS highest_infection_count,
   MAX((total_cases/population))*100 AS covid_infected_percentage,
FROM `orbital-concord-386515.Covid19.covid_deaths`
GROUP BY location, population
ORDER BY covid_infected_percentage desc
