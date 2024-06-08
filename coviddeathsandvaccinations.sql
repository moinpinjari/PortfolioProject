-- Checking the Data

select * from coviddeaths limit 100;

select * from covidvaccinations limit 100;


-- select the data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
order by 1, 2

-- Looking at Total cases vs Total deaths

select location, date, total_cases, total_deaths, round((total_deaths/total_cases)* 100,2) as DeathPercentage 
from coviddeaths
order by 1, 2;

-- Looking at Total cases vs Total deaths in India

select location, date, total_cases, total_deaths, round((total_deaths/total_cases)* 100,2) as DeathPercentage 
from coviddeaths
where location like '%India%'
order by 1, 2;


-- Looking at Total Cases vs Population

select location, date,  population, total_cases, round((total_cases/population)* 100,2) as casespercent
from coviddeaths
WHERE location like '%India%'
order by 1, 2;


-- Looking at countries with highest infection compare to population

select location,   population, max(total_cases) as HighestInfectionCount, max((total_cases/population))* 100 as casespercentpopulation
from coviddeaths
--WHERE location like '%India%'
group by location,   population
order by casespercentpopulation desc ;


-- Showing Countries with Highest Death Count per Population

select location, max(total_deaths) as HighestDeathCount
from coviddeaths
where continent is not null and total_deaths is not null
group by location
order by HighestDeathCount desc ;


-- Lets break down by the continent

select continent, max(total_deaths) as HighestDeathCount
from coviddeaths
where continent is not null and total_deaths is not null
group by continent
order by HighestDeathCount desc ;

--Global Numbers

select date, sum(new_cases) as Total_New_Cases, sum(new_deaths) as Total_New_Deaths, sum(new_cases)/sum(new_deaths)*0.1 as Death_Percentage
from coviddeaths
where continent is not null 
group by date
order by 1, 2 ;



-- Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as Rolling_People_vaccinated
--(Rolling_people_vaccinated/population)
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Using CTE

with PopVAc (Continent, Location, Date, Population, New_Vaccination, Rolling_people_Vaccination)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as Rolling_People_vaccinated
--(Rolling_people_vaccinated/population)
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,
from Popvac


--Using Temp Table

DROP TABLE IF EXISTS percetnpopulationvaccinated;
create temp table percetnpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as Rolling_People_vaccinated
--(Rolling_people_vaccinated/population)
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select * , (Rolling_People_vaccinated:: numeric/population :: numeric)*100 as Rolling_percent
from percetnpopulationvaccinated

-- creating VIEW

create view percetnpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as Rolling_People_vaccinated
--(Rolling_people_vaccinated/population)
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from percetnpopulationvaccinated
	
--Analyze the data based on different regions or countries.

select  dea.location,sum(dea.population)as population, sum(dea.total_deaths)as Total_Deaths, sum(vac.new_vaccinations) as Total_Vaccination,(sum(vac.total_vaccinations)/sum(dea.population))*100 as Vaccination_rate
--sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as Rolling_People_vaccinated
--(Rolling_people_vaccinated/population)
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
group by dea.location
order by 3 desc


--Case Fatality Rate (CFR) and Vaccination Coverage

SELECT 
    dea.location as country,
    SUM(dea.total_cases) AS total_cases,
    SUM(dea.total_deaths) AS total_deaths,
    (SUM(dea.total_deaths)/ SUM(dea.total_cases)) * 100 AS case_fatality_rate,
    SUM(vac.total_vaccinations) AS total_vaccinations,
    (SUM(vac.total_vaccinations)/ SUM(dea.population)) * 100 AS vaccination_coverage
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
group by dea.location
order by 4 desc
















