/*COvid 19 Exploration


Skills used: Aggregate Functions, Joins, CTE's, Temp Table, Converting Data Types, Windows Functions

*/
 SELECT *        --Check the dataset
FROM [Covid Portfolio]..CovidDeaths

 
SELECT * 
FROM [Covid Portfolio]..CovidVaccinations


SELECT * 
FROM [Covid Portfolio]..CovidDeaths
WHERE continent is not null
ORDER BY 3,4;

SELECT * 
FROM [Covid Portfolio]..CovidVaccinations
WHERE continent is not null
ORDER BY 3,4;


-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Covid Portfolio]..CovidDeaths
WHERE continent is not null
ORDER BY 1,2;


--looking for total Cases vs Total Deaths 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Covid Portfolio]..CovidDeaths
WHERE continent is not null
	and location like  '%Nigeria%'
ORDER BY 1,2; -- This shows the likelihood of dying if you contract covid in Nigeria


--Looking at the total cases vs the population 
--Shows what percentage of ppopulation got covid

SELECT location, date,population,  total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM [Covid Portfolio]..CovidDeaths
--WHERE continent is not null
ORDER BY 1,2; 


--Looking countries with highest infection rate compared to population

SELECT location,population,  Max(total_cases)as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
FROM [Covid Portfolio]..CovidDeaths
--WHERE continent is not null
GROUP BY population, location
ORDER BY PercentPopulationInfected DESC;


--Showing the countires with the highest Death Count per Population

SELECT location,  Max(cast(total_deaths as int)) as TotalDeathCount
FROM [Covid Portfolio]..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC;


--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing continent with the highest death count

SELECT continent,  Max(cast(total_deaths as int)) as TotalDeathCount 
FROM [Covid Portfolio]..CovidDeaths
WHERE continent is  not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--Worldwide Cases and Deaths Numbers

SELECT sum(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Death, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM [Covid Portfolio]..CovidDeaths
WHERE continent is not null
ORDER BY 1,2; 


-- Looking at Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated

FROM [Covid Portfolio]..CovidDeaths dea
JOIN [Covid Portfolio]..CovidVaccinations vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;

--USE CTE to perform calculation on 'Partition By' in previous query

WITH PopuVac (continent, location, date, population, New_Vaccination, RollingPeopleVaccinated) 
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (PARTITION by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM [Covid Portfolio]..CovidDeaths dea
JOIN [Covid Portfolio]..CovidVaccinations vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentPopulationVaccinated
FROM PopuVac;


--Temp Table

DROP TABLE if exists VaccinatedPopulacePercent
Create Table VaccinatedPopulacePercent
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into VaccinatedPopulacePercent
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (PARTITION by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM [Covid Portfolio]..CovidDeaths dea
JOIN [Covid Portfolio]..CovidVaccinations vac
  ON dea.location = vac.location
  and dea.date = vac.date
--WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM VaccinatedPopulacePercent;


--Creating view to store data for later visualizations

Create View   PercentPopulationInfected as 

SELECT location,population,  Max(total_cases)as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
FROM [Covid Portfolio]..CovidDeaths
WHERE continent is not null
GROUP BY population, location
--ORDER BY PercentPopulationInfected 



SELECT *
FROM PercentPopulationInfected

