SELECT *
FROM PortFolioProject ..covidD

SELECT *
FROM PortFolioProject ..covidD$
order by 3,4

--looking at the total_deaths and total_cases

SELECT Location, date, total_cases, total_deaths,(cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
FROM PortFolioProject..covidD
Where Location like '%nigeria%'

--loking at countries with the Highest Infection Rate compared to population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount,Max((cast(total_cases as float)/population ))*100 as DeathPercentage
FROM PortFolioProject..covidD
Group by location, population
order by DeathPercentage desc

--GLOBAL NUMBERS
Select date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)
FROM PortFolioProject..covidD
where continent is not null
group by date
order by 1,2

Select date, location, new_cases, new_deaths 
FROM PortFolioProject..covidD
where continent is not null
order by 1,2

--looking at the amount of people vaccinated in the world



select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
,sum(cast(vacc.new_vaccinations as float)) over (partition by death.location order by death.location, death.date)
as rollingPeopleVaccinated

from PortfolioProject..covidD Death
join PortfolioProject..covidD$ vacc
on death.location = vacc.location
and death.date = vacc.date
where death.continent is not null
order by 2,3

--now i want to get the percentage of peopple vaccinated by dividing the rolling  by population using a CTE

with popVSvacc  (continent, location, date, population, New_Vaccinations, rollingpeoplevaccinated)
as
(
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
,sum(cast(vacc.new_vaccinations as float)) over (partition by death.location order by death.location, death.date)
as rollingPeopleVaccinated
from PortfolioProject..covidD Death
join PortfolioProject..covidD$ vacc
on death.location = vacc.location
and death.date = vacc.date
where death.continent is not null
)
select *, (rollingpeoplevaccinated/population)*100
from popvsvacc


--creating view to store data for later visualizations
 Create View PercentPopulationVaccination as
 select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
,sum(cast(vacc.new_vaccinations as float)) over (partition by death.location order by death.location, death.date)
as rollingPeopleVaccinated
from PortfolioProject..covidD Death
join PortfolioProject..covidD$ vacc
on death.location = vacc.location
and death.date = vacc.date
where death.continent is not null