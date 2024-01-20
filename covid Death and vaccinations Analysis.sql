--Datasets we will be using 

select *
from dbo.covidDeaths

select *
from dbo.CovidVaccinations

--Total Cases vs Total Death
--show the likely hood of dying if you got covid in a country as of 2021

select date,location,total_Cases,total_deaths,(total_deaths/total_cases)*100 as DeathPrecentage
from dbo.covidDeaths
where location like '%state%'
order by 1 desc

--Total cases vs Total Popluation
--shows what precentage of population got covid
select date,location,population,total_Cases,(total_cases/population)*100 as CasesPrecentage
from dbo.covidDeaths
where location like '%state%' and continent is not null
order by 1 desc

--Looking At Countries With Highest Infection Rate Compared To Population

select location,max(population) as maxpopulation,max(total_cases) as HighestInfectionCases,(max(total_cases)/max(population))*100 as infection_rate 
from dbo.CovidDeaths
where continent is not null
group by location
order by infection_rate desc


--Showing Countries With Highest Deathcount Per Population
select location,max(cast(total_deaths as int)) as DeathCount
from dbo.CovidDeaths
where continent is not null
group by location
order by 2 desc

--Showing Contient with highest DeathCount per Population
select location,max(population) as population,max(cast(total_deaths as int)) as DeathCount
from dbo.covidDeaths
where continent is null
group by location
order by DeathCount desc

--Showing death_rate of each country
select location,max(population) as dPopulation,max(cast(total_deaths as int)) as HighestDeathCases,
(max(cast(total_deaths as int)/population))*100 as Deathcount
from dbo.CovidDeaths
group by location
order by 4 desc

--Global Numbers

select date,sum(new_cases) Total_cases,sum(cast(new_deaths as int)) Total_Deaths,
sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPrecentage
from dbo.covidDeaths
where continent is not null
group by date
order by 1,2

--Looking at Total_populations vs Vaccinations

--CTE
with PopvsVac (Continent,Location,Date,Population,New_vaccinations,RollingPepoleVaccinated)
as
(
select dea.continent,Dea.location,dea.date,dea.population,vacc.new_vaccinations
,sum(convert(int,vacc.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPepoleVaccinated 
from dbo.covidDeaths dea
join dbo.CovidVaccinations$ vacc
	on dea.date = vacc.date
	and dea.location = vacc.location
	where dea.continent is not null
--order by 1,2,3
)
select * from popvsvac


--Temp Table

Drop table if exists #PrecentPopulationVaccinated --to drop the table if you want to edit something in the table

create table #PrecentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPepoleVaccinated numeric)

insert into #PrecentPopulationVaccinated
select dea.continent,Dea.location,dea.date,dea.population,vacc.new_vaccinations
,sum(convert(int,vacc.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPepoleVaccinated 
from dbo.covidDeaths dea
join dbo.CovidVaccinations$ vacc
	on dea.date = vacc.date
	and dea.location = vacc.location
	where dea.continent is not null
--order by 1,2,3

select *,(RollingPepoleVaccinated/Population)*100 
from #PrecentPopulationVaccinated
