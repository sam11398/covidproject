select *
from PortfolioProject..CovidDeaths
where continent is not null--to removie continent as location
order by 3, 4

--select *
--from PortfolioProject..CovidVaccination
--order by 3, 4

--selecting data that we are going to use
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1, 2

--Comparing total cases vs total deaths
--Shows liklihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location = 'India'
order by 1, 2


select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location = 'United States'
order by 1, 2

--Looking at the total cases vs population
-- Shows what percentage of population got covid
select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location = 'India'

select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location = 'United States'
order by 1, 2

--Looking at companies with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location = 'United States'
Group By location, population
order by PercentPopulationInfected desc

--Showing countries with highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group By location
order by TotalDeathCount desc

--Lets Break things down by continent
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group By continent
order by TotalDeathCount desc

--select location, max(cast(total_deaths as int)) as TotalDeathCount
--from PortfolioProject..CovidDeaths
--where continent is null
--Group By location
--order by TotalDeathCount desc

--Showing continents with highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group By continent
order by TotalDeathCount desc

--Global numbers

select date, sum(new_cases) as GlobalTotalCases, sum(cast(new_deaths as int)) as GlobalTotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..covidDeaths_mod
--where location = 'India'
where continent is not null
Group by date
order by 1, 2


select sum(new_cases) as GlobalTotalCases, sum(cast(new_deaths as int)) as GlobalTotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..covidDeaths_mod
--where location = 'India'
where continent is not null
--Group by date
order by 1, 2

select *
from PortfolioProject..CovidVaccination_mod

--Looking at total population vs vaccination
--join
select *
from PortfolioProject..covidDeaths_mod as Dea
join PortfolioProject..CovidVaccination_mod as Vac
on Dea.location=Vac.location
and Dea.date=Vac.date


select dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations
from PortfolioProject..covidDeaths_mod as Dea
join PortfolioProject..CovidVaccination_mod as Vac
on Dea.location=Vac.location
and Dea.date=Vac.date
where Dea.continent is not null
order by 2,3


select dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations,
 sum(cast(Vac.new_vaccinations as int)) over (partition by Dea.location order by Dea.location, Dea.date) as RollingpeopleVaccinated
 -- shows error (Conversion failed when converting the nvarchar value '2859.0' to data type int.)
from PortfolioProject..covidDeaths_mod as Dea
join PortfolioProject..CovidVaccination_mod as Vac
on Dea.location=Vac.location
and Dea.date=Vac.date
where Dea.continent is not null
order by 2,3


-- Use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingpeopleVaccinated
as
(
select dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations,
 sum(cast(Vac.new_vaccinations as int)) over (partition by Dea.location order by Dea.location, Dea.date) as RollingpeopleVaccinated
 -- shows error (Conversion failed when converting the nvarchar value '2859.0' to data type int.)
from PortfolioProject..covidDeaths_mod as Dea
join PortfolioProject..CovidVaccination_mod as Vac
on Dea.location=Vac.location
and Dea.date=Vac.date
where Dea.continent is not null
--order by 2,3
)
select *, (RollingpeopleVaccinated/population)*100
from PopvsVac


--TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations,
 sum(cast(Vac.new_vaccinations as int)) over (partition by Dea.location order by Dea.location, Dea.date) as RollingpeopleVaccinated
 -- shows error (Conversion failed when converting the nvarchar value '2859.0' to data type int.)
from PortfolioProject..covidDeaths_mod as Dea
join PortfolioProject..CovidVaccination_mod as Vac
on Dea.location=Vac.location
and Dea.date=Vac.date
where Dea.continent is not null
--order by 2,3


select *, (RollingpeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- Creating view to store data for later visualizations
Create View PercentPopulationVaccinated as
select dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations,
 sum(cast(Vac.new_vaccinations as int)) over (partition by Dea.location order by Dea.location, Dea.date) as RollingpeopleVaccinated
 -- shows error (Conversion failed when converting the nvarchar value '2859.0' to data type int.)
from PortfolioProject..covidDeaths_mod as Dea
join PortfolioProject..CovidVaccination_mod as Vac
on Dea.location=Vac.location
and Dea.date=Vac.date
where Dea.continent is not null
--order by 2,3