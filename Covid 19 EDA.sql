
/* 
Exploratary Data Analysis of Covid 19
*/


-- looking at the Covid Deaths data

Select *
From [Covid Project]..CovidDeaths
Where continent is not null
order by 3,4

-- looking at the Covid vaccintion data

Select *
From [Covid Project]..CovidVaccins
Where continent is not null 
order by 3,4

-- Select the Data that we are exploring in the Covid Deaths dataset

Select continent, location, date, total_cases, new_cases, new_deaths, total_deaths, population
From [Covid Project]..CovidDeaths
Where continent is not null 
order by 1,4


-- Total Cases vs Population
-- Shows the percentage of the population that are infected in various countries

Select continent, Location, date, Population, total_cases, (total_cases /population)*100 as InfectedPopulationPercentage
From [Covid Project]..CovidDeaths
Where continent Is not null
order by 1,2


-- Shows the percentage of the population that are infected in various Countries in africa

Select continent, Location, cast(date as date) as date, Population, total_cases, (total_cases /population)*100 as InfectedPopulationPercentage
From [Covid Project]..CovidDeaths
Where continent like 'africa'
order by 1,2



-- Countries with the Highest rate of Infection

Select continent, Location, Population, MAX(total_cases) as HighestInfectionCount
, Max((total_cases/population))*100 as InfectedPopulationPercentage
From [Covid Project]..CovidDeaths
Where continent Is not null
Group by continent, location, population
order by InfectedPopulationPercentage desc


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if a person contract covid in various continent and countries

Select continent, Location, date, total_cases, total_deaths, (total_deaths /(cast(total_cases as float)))*100 as DeathPercentage
From [Covid Project]..CovidDeaths
Where continent is not null 
order by 1,2


-- Countries with the Highest Death Count per Population

Select Continent, Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Covid Project]..CovidDeaths
Where continent is not null 
--and continent like 'africa'
Group by Continent, Location
order by TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select Continent,  MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Covid Project]..CovidDeaths
Where continent is not null 
--and continent like 'africa'
Group by Continent
order by TotalDeathCount desc


-- World Percentage

Select continent, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths
, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as NewDeathsPercentage --- SUM(cast(total_deaths as float))/SUM(cast(total_cases as float))*100 as totalDeathPercentage
From [Covid Project]..CovidDeaths
Where continent is not null 
Group By continent
order by 1,2


-- Total Vccination vs Population
-- Shows the Percentage of Population that has recieved at least one Vaccine for Covid 19

Select dth.continent, dth.location, dth.date, dth.population, vcc.total_vaccinations
, SUM(CONVERT(numeric,vcc.total_vaccinations)) OVER (Partition by dth.Location Order by dth.location, dth.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Covid Project]..CovidDeaths dth
Join [Covid Project]..CovidVaccins vcc
	On dth.location = vcc.location
	and dth.date = vcc.date
Where dth.continent is not null 
--and dth.continent like 'africa'
order by 2,3


-- Creating Temp Table to perform Calculation on partition By in the previous query

DROP Table if exists #VaccinatedPopulationPercentage
Create Table #VaccinatedPopulationPercentage
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
Total_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #VaccinatedPopulationPercentage
Select dth.continent, dth.location, dth.date, dth.population, vcc.total_vaccinations
, SUM(cast(vcc.total_vaccinations as numeric)) OVER (Partition by dth.Location Order by dth.location, dth.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Covid Project]..CovidDeaths dth
Join [Covid Project]..CovidVaccins vcc
	On dth.location = vcc.location
	and dth.date = vcc.date
--Where dth.continent is not null 
--and dth.continent like 'africa'
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #VaccinatedPopulationPercentage


-- Shows the Percentage of African Population that has recieved at least one Vaccine for Covid 19

Select *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPercentage
From #VaccinatedPopulationPercentage
Where Continent like 'Africa'


-- Creating View to store data for later visualizations


Create View VaccinatedPopulationPercentage as 
Select dth.continent, dth.location, dth.date, dth.population, vcc.total_vaccinations
, SUM(CONVERT(numeric,vcc.total_vaccinations)) OVER (Partition by dth.Location Order by dth.location, dth.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Covid Project]..CovidDeaths dth
Join [Covid Project]..CovidVaccins vcc
	On dth.location = vcc.location
	and dth.date = vcc.date
Where dth.continent is not null 
--and dth.continent like 'africa'













