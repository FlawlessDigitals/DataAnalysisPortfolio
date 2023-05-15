Select *
From PortfolioProject..CovidDeaths
Order by 3,4

Select *
From PortfolioProject..CovidVaccinations
Order by 3,4

-- Selection of the needed columns
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2

-- Comparison of the total cases with total deaths in each country
-- This shows the likehood of dying from the contraction of COVID 19 in each country
Select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathRate
From PortfolioProject..CovidDeaths
Where location = 'Nigeria'
Order by 1,2


-- Comparison of the total cases vs the population
-- Percentage of population with COVID 19
Select location, date, population, total_cases, (total_cases/population)*100 AS CovidRate
From PortfolioProject..CovidDeaths
Where location = 'Italy'
Order by 1,2

-- Looking at the countries with highest infection rate compared to population
Select location, population, max(total_cases), max((total_cases/population)*100) AS CovidRate
From PortfolioProject..CovidDeaths
where continent is not null
group by location, population
Order by CovidRate desc

-- Looking at the countries with highest infection rate compared to population for countries with over 100 million population
Select location, population, max(total_cases) AS HighestCases, max((total_cases/population)*100) AS CovidRate
From PortfolioProject..CovidDeaths
where population > 100000000 AND continent is not null
group by location, population
Order by CovidRate desc 

-- Countries with highest death count with the population
Select location, max(cast(total_deaths as bigint)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
group by location
Order by TotalDeathCount desc 

-- BASED ON CONTINENT
Select location, max(cast(total_deaths as bigint)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is null
group by location
Order by TotalDeathCount desc 

-- HUGE ONE, LET'S DO GLOBAL BREAKDOWN
Select date, sum(new_cases) AS total_cases, sum(cast(new_deaths as int)) AS totaldeaths, (SUM(CAST(new_deaths as int))/SUM(new_cases)*100) AS WordlwideDeathRate
From PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1

-- What is the total cases and deaths globally
Select sum(new_cases) AS total_cases, sum(cast(new_deaths as int)) AS totaldeaths, (SUM(CAST(new_deaths as int))/SUM(new_cases)*100) AS WordlwideDeathRate
From PortfolioProject..CovidDeaths
where continent is not null
order by 1

-- COVID Vacination exploration
Select *
From PortfolioProject..CovidVaccinations
Order by 4

-- Joining the both tables together
Select *
From PortfolioProject..CovidDeaths Deaths
Join PortfolioProject..CovidVaccinations Vac
	On Deaths.location = Vac.location
	And Deaths.date = Deaths.date

-- Total population vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.location = 'Albania'
--where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 As VaccinatedPopsRate
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 As VaccinatedPopsRate
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View VaccinatedPopsRate as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


Select *
From VaccinatedPopsRate
