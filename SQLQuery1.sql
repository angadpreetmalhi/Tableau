/*
cleaning data in Sql queries
*/
select *
From portfolio_project..['covid death$']
order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
From portfolio_project..['covid death$']
order by 1,2

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercantage
From portfolio_project..['covid death$']
where location like '%states%'
order by 1,2

select location,date,total_cases,population,(total_cases/population)*100 as PercentagePopulationInfected
From portfolio_project..['covid death$']
order by 1,2

select location,population,max(total_cases) as HighestInfectionCount , max((total_cases/population))*100 as PercentagePopulationInfected
From portfolio_project..['covid death$']
group by location, population
order by PercentagePopulationInfected desc

select location,max(total_cases) as TotalDeathCount
From portfolio_project..['covid death$']
where continent is not null
group by location
order by TotalDeathCount desc

select continent,max(total_cases) as TotalDeathCount
From portfolio_project..['covid death$']
where continent is not null
group by continent
order by TotalDeathCount desc

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_death, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercantage
From portfolio_project..['covid death$']
where continent is not null

order by 1,2




select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From portfolio_project..['covid death$'] dea
join portfolio_project..covidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portfolio_project..['covid death$'] dea
Join portfolio_project..covidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portfolio_project..['covid death$'] dea
Join portfolio_project..covidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portfolio_project..['covid death$'] dea
Join portfolio_project..covidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

Drop Table if exists #PercentPopulationVaccinated
Create table #PercentpopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentpopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portfolio_project..['covid death$'] dea
Join portfolio_project..covidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentpopulationVaccinated

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portfolio_project..['covid death$'] dea
Join portfolio_project..covidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
