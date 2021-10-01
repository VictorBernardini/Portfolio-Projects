Select *
From PortfolioProject..CovidDeaths
WHERE continent is not NULL
Order By 3,4

--Removing NULL data
DELETE From PortfolioProject..CovidDeaths
WHERE population is NULL

--Select *
--From PortfolioProject..CovidVaccinations
--Order By 3,4

--Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
WHERE continent is not NULL
Order by 1,2 

-- Looking at Total Cases vs Total Deaths in Canada

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths
Where location = 'Canada' and continent is not NULL
Order by 1,2	

--Looking at Total Cases vs Population (Percentage of people that contracted Covid)

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Order by 1,2	

--Countries with highest infection rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
GROUP BY Location, population 
ORDER BY PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY Location
ORDER BY TotalDeathCount desc


-- Showing continents with Highest Death Count per Population

Select location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
WHERE continent is NULL
GROUP BY location
ORDER BY TotalDeathCount desc


-- Global numbers by date

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY date
ORDER BY 1, 2


-- Overall death percentage

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 1, 2


-- Joining tables

Select *
FROM PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
     On dea.location = vac.location 
	 and dea.date = vac.date


-- Total Population vs Vaccinations per day

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
     On dea.location = vac.location 
	 and dea.date = vac.date
Where dea.continent is not NULL
Order by 2, 3

-- Total population vs Total Vaccination accumulated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as AccumulatedVaccinations
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
     On dea.location = vac.location 
	 and dea.date = vac.date
Where dea.continent is not NULL
Order by 2, 3


-- Using CTE to perform calculations

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, AccumulatedVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as AccumulatedVaccinations
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
     On dea.location = vac.location 
	 and dea.date = vac.date
Where dea.continent is not NULL
)

Select *, (AccumulatedVaccinations/Population)*100
From PopvsVac

-- Data has second dose included on total vaccinations


-- Creating a Temp Table

DROP table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
new_vaccinations numeric,
AccumulatedVaccinations numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as AccumulatedVaccinations
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
     On dea.location = vac.location 
	 and dea.date = vac.date
Where dea.continent is not NULL

Select *, (AccumulatedVaccinations/Population)*100
From #PercentPopulationVaccinated


-- Creating a few views for visualization 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as AccumulatedVaccinations
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
     On dea.location = vac.location 
	 and dea.date = vac.date
Where dea.continent is not NULL



Create View TotalDeathByCountry as
Select Location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY Location
--ORDER BY TotalDeathCount desc


Create view HighestInfectionsByCountry as
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
GROUP BY Location, population 
--ORDER BY PercentPopulationInfected desc


Create view TotalDeathsByContinent as
Select location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
WHERE continent is NULL
GROUP BY location
--ORDER BY TotalDeathCount desc