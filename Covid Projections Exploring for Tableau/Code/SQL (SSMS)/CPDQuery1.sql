--to fetch & display all results from table CovidDeaths in dbo CDRProject ordering the data by column 3 & 4
select * from CPDProject..CovidDeaths
where continent is not null
order by 3,4

--to fetch & display all results from table CovidVaccinations in dbo CDRProject ordering the data by column 3 & 4
select * from CPDProject..CovidVaccinations
where continent is not null
order by 3,4

--selecting required data & exploring said dataset
select location, date, new_cases, total_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by 1,2

--to find case fatality rate (in %)
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as CaseFatalityRate
from CovidDeaths 
where --location like '%India%' and --> uncomment to see of specific location(s)
continent is not null
order by 1,2

--to find % of population infected
select location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
from CovidDeaths 
where --location like '%India%' and <-- uncomment to see for India only
continent is not null
order by 1,2

--TABLEAU TABLE QUERY 3
--to find countries with highest % of population infected
select location, population, MAX(total_cases) as HighestCasesCount, MAX(total_cases/population)*100 as PercentagePopulationInfected
from CovidDeaths 
where --location like '%India%' and <-- uncomment to see for India only
continent is not null
group by location, population
order by PercentagePopulationInfected desc

--TABLEAU TABLE QUERY 4
--to find countries with highest % of population infected date-wise
select location, population, date, MAX(total_cases) as HighestCasesCount, MAX(total_cases/population)*100 as PercentagePopulationInfected
from CovidDeaths 
where --location like '%India%' and <-- uncomment to see for India only
continent is not null
group by location, population, date
order by PercentagePopulationInfected desc

--to find countries with highest deaths by population
select location, population, MAX(CAST(total_deaths as int)) as TotalDeathCount
from CovidDeaths 
where --location like '%India%' and <-- uncomment to see for India only
continent is not null
group by location, population
order by TotalDeathCount desc

----TABLEAU TABLE QUERY 2
--to find CONTINENTS with highest deaths by population
select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
from CovidDeaths 
where location not in ('World','European Union', 'International') and 
continent is null
group by location
order by TotalDeathCount desc

--TABLEAU TABLE QUERY 1
--exploring global numbers/data
select SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null

--to see how many people got at least 1 vaccine shot
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.location Order by d.location, d.date) VaccinatedPopulationCoverage
from CovidDeaths d
join CovidVaccinations v
	on d.date = v.date 
	and d.location = v.location
where d.continent is not null
order by 2,3

--using CTE (common table expression) to perform calculations and give meaning to the partition by part
with PopVac (continent, location, date, population, new_vaccinations, VaccinatedPopulationCoverage)
as 
(
	Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.location Order by d.location, d.date) VaccinatedPopulationCoverage
from CovidDeaths d
join CovidVaccinations v
	on d.date = v.date 
	and d.location = v.location
where d.continent is not null
)
select *, (VaccinatedPopulationCoverage/population)*100 as PopulationPercentageVaccinated
from PopVac

--performing the same query above using TEMP TABLE
Drop table if exists #PercentagePopulationVacinated
create table #PercentagePopulationVacinated
(
	Continent nvarchar(150),
	Location nvarchar(150),
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	VaccinatedPopulationCoverage numeric
)

insert into #PercentagePopulationVacinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.location Order by d.location, d.date) VaccinatedPopulationCoverage
from CovidDeaths d
join CovidVaccinations v
	on d.date = v.date 
	and d.location = v.location
where d.continent is not null
select *, (VaccinatedPopulationCoverage/population)*100 
from #PercentagePopulationVacinated

--creating a view 
create view PercentagePopulationVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.location Order by d.location, d.date) VaccinatedPopulationCoverage
from CovidDeaths d
join CovidVaccinations v
	on d.date = v.date 
	and d.location = v.location
where d.continent is not null

