-- Look at all information in the DB
select 
	*
from 
	CovidDeaths

--Filter out irrelevant data
select 
	*
from 
	CovidDeaths c
where 
	continent IS NOT NULL
order by 
	c.location
  , c.date

--Select relevant data that I want to work with
select 
	  c.location
	, c.date
	, c.total_cases
	, c.new_cases
	, c.total_deaths
	, c.population
from 
	CovidDeaths c
order by 
	  c.location
	, c.date

-- Looking at total cases vs total deaths
-- Chance of dying if you contract covid in the United States 
select 
	c.location
  , c.date
  , c.total_cases
  , c.total_deaths
  , CAST(c.total_deaths AS float) / c.total_cases *100 as Death_Percentage
from 
	CovidDeaths c
where 
	c.Location = 'United States'
order by
	c.location
  , c.date

-- Looking at total cases vs population
-- Show what percent of population got Covid
select 
	c.Location
  , c.date
  , c.population
  , c.total_cases
  , CAST(c.total_cases AS float) / c.population *100 as Percent_of_Infected
from CovidDeaths c
where 
	c.Location = 'United States'
order by
	c.location
  , c.date

-- Looking at countries with highest infection rate
select 
	c.location
  , c.population
  , MAX(c.total_cases) as Total_cases_Per_Country
  , (CAST(MAX(c.total_cases) As Float) / c.population) *100 as Percent_of_Population_Infected
from CovidDeaths c
group by 
	c.location
  , c.population
order by 
	Percent_of_Population_Infected desc

-- Show countries with highest death count per population
select 
	c.location
  , MAX(c.total_deaths) as Total_Deaths_Per_Country
from 
	CovidDeaths c
where 
	c.continent IS NOT NULL
group by 
	c.location
order by 
	Total_Deaths_Per_Country desc

-- Breakdown of deaths by continent
select 
	continent
  , Sum(Max_Deaths) as Total_Deaths_Per_Continent
from (
	Select 
		c.continent
	 ,  Max(total_deaths) as Max_Deaths
	from 
		CovidDeaths c
	group by 
		c.continent
	 ,  c.location
) as Max_Deaths_Per_Country
where 
	continent is not null
group by 
	continent
order by 
	Total_Deaths_Per_Continent desc

-- Global death percentage
select 
	Sum(c.new_cases) as total_cases
  , Sum(c.new_deaths) as total_deaths
  , Sum(c.new_deaths) / Sum(c.new_cases) * 100  as Death_Percentage
from 
	CovidDeaths c
where 
	c.continent is not null


-- Number of deaths vs cases daily
SELECT
	c.date
  , SUM(new_cases) AS cases_per_day
  , SUM(new_deaths) AS deaths_per_day
  , CASE WHEN SUM(c.new_cases) <> 0
		 THEN (SUM(c.new_deaths) / NULLIF(SUM(new_cases), 0)) * 100
         ELSE NULL
	END AS Death_Percentage
FROM 
	CovidDeaths c
WHERE 
	c.continent is not null
GROUP BY 
	c.date
ORDER BY
	c.date


-- Total population, Newly Vaccinated Daily, Total Vaccinated Count 
select 
	d.continent
  , d.location
  , d.date
  , d.population
  , v.new_vaccinations
  , SUM(convert(bigint,v.new_vaccinations)) OVER (Partition by d.location order by d.location, d.date) as rolling_count_of_vaccinated
from 
	CovidDeaths d
join 
	CovidVaccinations v
on 
	d.location = v.location
and 
	d.date = v.date
where 
	d.continent is not null
order by
	d.location
  , d.date


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
select 
	d.continent
  , d.location
  , d.date
  , d.population
  , v.new_vaccinations
  , SUM(convert(bigint,v.new_vaccinations)) OVER (Partition by d.location order by d.location, d.date) as rolling_count_of_vaccinated
from 
	CovidDeaths d
join 
	CovidVaccinations v
on 
	d.location = v.location
and 
	d.date = v.date
where 
	d.continent is not null

Select 
	*
from 
	#PercentPopulationVaccinated
order by
	continent
  , location

--Creating View to store data for later visualization
GO
CREATE VIEW PercentPopulationVaccinated AS
SELECT
    d.continent
  , d.location
  , d.date
  , d.population
  , v.new_vaccinations
  , SUM(CONVERT(BIGINT, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_count_of_vaccinated
FROM
    CovidDeaths d
JOIN
    CovidVaccinations v
ON
    d.location = v.location
AND 
	d.date = v.date
WHERE
    d.continent IS NOT NULL;
GO


select
	*
from 
	PercentPopulationVaccinated
