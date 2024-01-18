select * from
[Portfolio project]..CovidDeaths
where continent is not null
order by 3,4

select * from
[Portfolio project]..CovidVaccinations
order by 3,4;

select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio project]..CovidDeaths
order by 1,2

---looking at total cases vs total deaths
---show the likelihood of dying if you cantract covid in different countries
select location, date, total_cases, new_cases, total_deaths, (total_deaths/ total_cases)*100 as persentageoftotaldeaths
from [Portfolio project]..CovidDeaths
where location like '%states%'
order by 1,2

---looking at the total cases vs population
--show the percentage of the population got covid
select location, date, population, total_cases, new_cases, (total_cases/ population)*100 as persentage_of_total_deaths
from [Portfolio project]..CovidDeaths
order by 1,2

--looking at the countries with hihest infection rates compared to populations

select location,  population, MAX(total_cases) as HighestInfectionount, MAX((total_cases/ population))*100 as percentage_of_total_deaths
from [Portfolio project]..CovidDeaths
group by location,population
order by percentage_of_total_deaths

---break things doun  by continent
select continent, MAX(cast(total_deaths as int)) as Total_death_count
from [Portfolio project]..CovidDeaths
where continent is not null 
group by continent
order by Total_death_count desc

--showing countries with hihest death count per population
select location, MAX(cast(total_deaths as int)) as Total_death_count
from [Portfolio project]..CovidDeaths
where continent is null
group by location
order by Total_death_count desc

---global numbers
select date, SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/ SUM(new_cases)  *100 as DeathPercentage
from [Portfolio project]..CovidDeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2

select SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/ SUM(new_cases)  *100 as DeathPercentage
from [Portfolio project]..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,

--LOOKING AT TOTAL POPILATION VS TOTAL VACCINATIONS

select dea.continent, dea.location, dea.date, dea.population, vaci.new_vaccinations,
SUM(cast(vaci.new_vaccinations as int)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio project]..CovidDeaths as dea
join
[Portfolio project]..CovidVaccinations as vaci
on dea.location = vaci.location
and dea.date = vaci.date
where dea.continent  is not null
order by 1,2,3


--USE CTE

with popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as(
select dea.continent, dea.location, dea.date, dea.population, vaci.new_vaccinations,
SUM(cast(vaci.new_vaccinations as int)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio project]..CovidDeaths as dea
join
[Portfolio project]..CovidVaccinations as vaci
on dea.location = vaci.location
and dea.date = vaci.date
where dea.continent  is not null
)
select continent, location, date, population, new_vaccinations, (RollingPeopleVaccinated/population) *100
from
popvsvac


---TEMT TABLES
drop table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated
 (
 continent nvarchar(255), 
 location nvarchar(255), 
 date datetime, 
 population numeric, 
 new_vaccinations numeric, 
 RollingPeopleVaccinated numeric)
 insert into #PercentagePopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vaci.new_vaccinations,
SUM(cast(vaci.new_vaccinations as int)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio project]..CovidDeaths as dea
join
[Portfolio project]..CovidVaccinations as vaci
on dea.location = vaci.location
and dea.date = vaci.date
where dea.continent  is not null
select *, (RollingPeopleVaccinated/population) *100
from #PercentagePopulationVaccinated

--CREATING VIEWS FOR DATA VISUALIZATION
drop view if exists PercentagePopulationVaccinated
create view PercentagePopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vaci.new_vaccinations,
SUM(cast(vaci.new_vaccinations as int)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio project]..CovidDeaths as dea
join
[Portfolio project]..CovidVaccinations as vaci
on dea.location = vaci.location
and dea.date = vaci.date
where dea.continent  is not null
 select *
 from PercentagePopulationVaccinated