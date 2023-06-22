select *
from CovidDeaths
where continent IS NOT NULL
order by 3,4

--Select relevant data that I want to work with

Select Location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2


-- Looking at total cases vs total deaths
-- Chance of dying if you contract covid in the United States 
Select Location, date, total_cases, total_deaths, CAST(total_deaths AS float) / total_cases *100 as Death_Percentage
from CovidDeaths
where Location = 'United States'
order by 1,2

-- Looking at total cases vs population
-- Show what percent of population got Covid
Select Location, date, population, total_cases, CAST(total_cases AS float) / population *100 as Percent_of_Infected
from CovidDeaths
where Location = 'United States'
order by 1,2

-- Looking at countries with highest infection rate
Select Location, Population, MAX(total_cases) as Total_cases_Per_Country, (CAST(MAX(total_cases) As Float) / Population) *100 as Percent_of_Population_Infected
from CovidDeaths
group by Location, Population
order by Percent_of_Population_Infected desc

-- Show countries with highest death count per population
Select Location, MAX(total_deaths) as Total_Deaths_Per_Country
from CovidDeaths
where continent IS NOT NULL
group by Location
order by Total_Deaths_Per_Country desc

-- Breakdown of deaths by continent
Select continent, Sum(Max_Deaths) as Total_Deaths_Per_Continent
from (
	Select Continent, Max(total_deaths) as Max_Deaths
	from CovidDeaths
	group by Continent, location
) as Max_Deaths_Per_Country
where continent is not null
group by continent
order by Total_Deaths_Per_Continent desc

-- Global death percentage
Select sum(new_cases) total_cases, sum(new_deaths) total_deaths, sum(new_deaths) / sum(new_cases) * 100  as Death_Percentage
from CovidDeaths
where continent is not null


SELECT date,
	   SUM(new_cases) AS cases_per_day,
       SUM(new_deaths) AS deaths_per_day,
       CASE WHEN SUM(new_cases) <> 0
            THEN (SUM(new_deaths) / NULLIF(SUM(new_cases), 0)) * 100
            ELSE NULL
       END AS Death_Percentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2


-- Total population vs Vaccinations

Select deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations,
	sum(convert(bigint,vax.new_vaccinations)) OVER (Partition by deaths.location order by deaths.location, deaths.date) as rolling_count_of_vaccinated
from CovidDeaths deaths
join CovidVaccinations vax
on deaths.location = vax.location
and deaths.date = vax.date
where deaths.continent is not null
order by 2,3


-- USE CTE

With PopVsVac (Continent, location, date, population, new_vaccinations, rolling_vaccination)
AS
(
Select deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations,
	sum(convert(bigint,vax.new_vaccinations)) OVER (Partition by deaths.location order by deaths.location, deaths.date) as rolling_count_of_vaccinated
from CovidDeaths deaths
join CovidVaccinations vax
on deaths.location = vax.location
and deaths.date = vax.date
where deaths.continent is not null
--order by 2,3
)
Select *, (rolling_vaccination/population)*100
from PopVsVac

-- Temp Table
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population bigint,
New_vaccinations bigint,
Rolling_people_vaccinated bigint
)


Insert into #PercentPopulationVaccinated 
Select deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations,
	sum(convert(bigint,vax.new_vaccinations)) OVER (Partition by deaths.location order by deaths.location, deaths.date) as rolling_count_of_vaccinated
from CovidDeaths deaths
join CovidVaccinations vax
on deaths.location = vax.location
and deaths.date = vax.date
where deaths.continent is not null

Select *, (rolling_people_vaccinated/population)*100
from #PercentPopulationVaccinated

--Creating View to store data for later visualization
Create View PercentPopulationVaccinated as
Select deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations,
	sum(convert(bigint,vax.new_vaccinations)) OVER (Partition by deaths.location order by deaths.location, deaths.date) as rolling_count_of_vaccinated
from CovidDeaths deaths
join CovidVaccinations vax
on deaths.location = vax.location
and deaths.date = vax.date
where deaths.continent is not null


Select *
from PercentPopulationVaccinated