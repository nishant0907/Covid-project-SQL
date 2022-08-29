--Reading Tables

select * from coviddeaths
order by 3,4

select * from covidvaccinations
order by 3,4

-- Selecting data that we are going to use in coviddeaths table

select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
order by location,date

-- Looking at Total cases vs Total deaths

select location, date, (total_cases), (population), (total_cases/population)*100 as PercentCases 
from coviddeaths
where location like 'india'
order by location,date

-- Countries with highest infection rate compared to population

select location,max(population), max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentInfected, max((cast(total_deaths as int)/total_cases))*100 as PercentDeaths
from coviddeaths
--where location like 'india'
group by location
order by 5 desc

-- India's Death percentage

select location,population, max(cast(total_cases as int)) as TotalCasesCount, max(cast(total_deaths as int)) as TotalDeathCount, (max(cast(total_deaths as int))/max(total_cases))*100 as DeathPercentage
from coviddeaths
where continent is not null and location like 'india'
group by location, population


--Total cases and Deaths by Continents

select continent, max(total_cases) as TotalCases, max(cast(total_deaths as int)) as TotalDeaths
from coviddeaths
where continent is not null
group by continent
order by TotalDeaths desc


-- Joining coviddeaths table and covidvaccinations table

select coviddeaths.continent, coviddeaths.location,coviddeaths.date,coviddeaths.population, covidvaccinations.new_vaccinations
from coviddeaths
join covidvaccinations
on coviddeaths.location = covidvaccinations.location
and coviddeaths.date = covidvaccinations.date
where coviddeaths.continent is not null
order by 1,2,3


--Vaccinations Count

select coviddeaths.continent, coviddeaths.location,coviddeaths.date,coviddeaths.population, covidvaccinations.new_vaccinations
, sum(convert(bigint, covidvaccinations.new_vaccinations)) over (partition by coviddeaths.location order by coviddeaths.location,
coviddeaths.date) as TotalVaccinations 
from coviddeaths
join covidvaccinations
on coviddeaths.location = covidvaccinations.location
and coviddeaths.date = covidvaccinations.date
where coviddeaths.continent is not null
order by 1,2,3



--Using CTE 

with popvsvac (continent, location, date , population,new_vaccinations, TotalVaccinated)
as
(
select coviddeaths.continent, coviddeaths.location,coviddeaths.date,coviddeaths.population, covidvaccinations.new_vaccinations
, sum(convert(bigint, covidvaccinations.new_vaccinations)) over (partition by coviddeaths.location order by coviddeaths.location,
coviddeaths.date) as TotalVaccinated
from coviddeaths
join covidvaccinations
on coviddeaths.location = covidvaccinations.location
and coviddeaths.date = covidvaccinations.date
where coviddeaths.continent is not null
--order by 1,2,3
)
select *,(TotalVaccinated/population)*100 as VaccinationPercentage from popvsvac
order by 1,2,3


--Temp Table
drop table #PercentPopVaccinated
create table #PercentPopVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
TotalVaccinated numeric
)
insert into #PercentPopVaccinated
select coviddeaths.continent, coviddeaths.location,coviddeaths.date,coviddeaths.population, covidvaccinations.new_vaccinations
, sum(convert(bigint, covidvaccinations.new_vaccinations)) over (partition by coviddeaths.location order by coviddeaths.location,
coviddeaths.date) as TotalVaccinated
from coviddeaths
join covidvaccinations
on coviddeaths.location = covidvaccinations.location
and coviddeaths.date = covidvaccinations.date
where coviddeaths.continent is not null

select *,(TotalVaccinated/population)*100 as VaccinationPercentage from #PercentPopVaccinated
order by 1,2,3 


-- Creating View to store data for later visualization

create view PercentPopVaccinated as
select coviddeaths.continent, coviddeaths.location,coviddeaths.date,coviddeaths.population, covidvaccinations.new_vaccinations
, sum(convert(bigint, covidvaccinations.new_vaccinations)) over (partition by coviddeaths.location order by coviddeaths.location,
coviddeaths.date) as TotalVaccinated
from coviddeaths
join covidvaccinations
on coviddeaths.location = covidvaccinations.location
and coviddeaths.date = covidvaccinations.date
where coviddeaths.continent is not null

select * from PercentPopVaccinated
