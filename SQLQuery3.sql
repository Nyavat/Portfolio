-- select data to work with 

SELECT  location, date, total_cases, new_cases, total_deaths,population  FROM [dbo].[CovidDeaths]
ORDER BY 1,2

--- TOTAL CASES VS TOTAL DEATHS
SELECT location,date ,total_cases, total_deaths  ,(total_cases/total_deaths)*100 as PercentofpopulationInfected from  [dbo].[CovidDeaths]
ORDER BY 1,2

--Shows Population with Covid
---Total Cases Vs Population 
SELECT location, population ,MAX(( total_cases/population))*100 as PercentofpopulationInfected from [dbo].[CovidDeaths]
GROUP BY location, population 
ORDER BY 1,2

--- Countries with Highest Infection rate to Country 
SELECT location,population ,MAX(total_cases)as  Highest_Infection_Count, ( total_cases/population)*100 as PercentofpopulationInfected from  [dbo].[CovidDeaths]
GROUP BY location, population 
ORDER BY PercentofpopulationInfected

--- Highest Death Count In Per Poulation 
SELECT location, MAX(cast(total_deaths as int)) as Total_Death_Count from  [dbo].[CovidDeaths]
Where continent is not null
GROUP BY location
ORDER BY Total_Death_Count desc


--- By Continent
SELECT continent, MAX(cast(total_deaths as int)) as Total_Death_Count from  [dbo].[CovidDeaths]
Where continent is not null
GROUP BY continent
ORDER BY Total_Death_Count desc


--- Showing continets with the highest death count per population 
SELECT continent, MAX(cast(total_deaths as int)) as Total_Death_Count from  [dbo].[CovidDeaths]
Where continent is not null
GROUP BY continent
ORDER BY Total_Death_Count desc


--- GLOBAL NUMBERS 
SELECT date,SUM(new_cases), SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage from  [dbo].[CovidDeaths]
--Where location like '%states%'
Where continent is not null
group by date
order by 1,2


---Total Population Vs Vaccination 
Select dea.continent, dea.location,dea.date , dea.population, lac.new_vaccinations,
SUM(Convert(int, lac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date ) as Rollingpeoplevaccinated
from 
[dbo].[CovidDeaths] dea
Join
[dbo].[CovidVaccination] lac 
on lac.location = dea.location
and lac.date = dea.date
where dea.continent is not null
order by 1,2,3


----use cte 
With  Popvac (continent,location, date, population,Rollingpeoplevaccinated,new_vaccinations)
as (
Select dea.continent, dea.location,dea.date , dea.population, lac.new_vaccinations,
SUM(Convert(int, lac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date ) as Rollingpeoplevaccinated
from 
[dbo].[CovidDeaths] dea
Join
[dbo].[CovidVaccination] lac 
on lac.location = dea.location
and lac.date = dea.date
where dea.continent is not null
)
Select* ,(Rollingpeoplevaccinated/population)*100
 from  Popvac



 ---Temp Table
 Drop table if exists #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated
 (Continent nvarchar(225),
 Location nvarchar(225),
 Date datetime,
 Population numeric, 
 New_vaccination numeric, 
 Rollingpeoplevaccinated numeric
 )


 Insert into 
 Select dea.continent, dea.location,dea.date , dea.population, lac.new_vaccinations,
SUM(Convert(int, lac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date ) as Rollingpeoplevaccinated
from 
[dbo].[CovidDeaths] dea
Join
[dbo].[CovidVaccination] lac 
on lac.location = dea.location
and lac.date = dea.date
where dea.continent is not null

Select* ,(Rollingpeoplevaccinated/population)*100
 from  PercentPopulationVaccinated

