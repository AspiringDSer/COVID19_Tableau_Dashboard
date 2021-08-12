# COVID-19 Queries for Tableau Dashboard Portfolio Piece  
# Dataset: https://ourworldindata.org/covid-deaths
# Data pulled on July 6th 2021

# Tableau Public Dashboard Link: https://public.tableau.com/views/COVID-19Dashboard_16269278155240/COVIDDashboard?:language=en-US&publish=yes&:display_count=n&:origin=viz_share_link

# This portfolio piece is to demonstrate some of my Tableau skills.
# Skills used: Animations, Race Charts, Calculated Fields, Map Analysis, and Creating Dashboards
# Note: Due to Tableau Public, you cannot see the animations properly. I suggest to download my provided databases and Tableau workbook to see the full animations. 

# This portfolio piece also demonstrates some of my SQL skills.
# Skills used: Creating Tables, CTE's, Window Functions, and Aggregate Functions



# Creating Database 
CREATE SCHEMA portfolioproject_COVID19_TableauDashboard;

# import the following tables 
# CovidDeaths.csv
# CovidVaccinations.csv 

#############   
## Query 1 ##   The first query will be used to get:
#############   Total Cases Per Day, Total Deaths Per Day, and Death Percentage

 # Total Global Numbers - Use to verify query results below 
SELECT SUM(new_cases) AS TotalCases,
	   SUM(new_deaths) AS TotalDeaths,
	   SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE continent != '' 
ORDER BY TotalCases;

# Global Numbers Per Day with Cumulation 
DROP TABLE IF EXISTS TotalGlobalNumbers;
CREATE TABLE TotalGlobalNumbers 
(date date,
 cumulative_new_cases double,
 cumulative_new_deaths double);

INSERT INTO TotalGlobalNumbers
SELECT CAST(date AS DATE) AS date1,
       SUM(new_cases) OVER w AS cumulative_new_cases,
       SUM(new_deaths) OVER w AS cumulative_new_deaths
FROM coviddeaths
WHERE continent != ''
GROUP BY date, new_cases, new_deaths
WINDOW w AS (ORDER BY date 
			  RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW);

# Global Numbers Per Day with Cumulation - Final Version
# We need to use GROUP BY date on the TotalGlobalNumbers Table
DROP TABLE IF EXISTS TotalGlobalCumulative;
CREATE TABLE TotalGlobalCumulative 
(date date,
 cumulative_new_cases double,
 cumulative_new_deaths double);

INSERT INTO TotalGlobalCumulative
SELECT * 
FROM TotalGlobalNumbers
GROUP BY date;

#############
## Query 2 ##   The second query will be used to get:
#############   Total Death Per Continent

DROP TABLE IF EXISTS TotalDeathPerContinent;
CREATE TABLE TotalDeathPerContinent 
(date date,
 location varchar(255),
 new_deaths numeric,
 cumulative_deaths numeric);
 
INSERT INTO TotalDeathPerContinent
SELECT date, 
	   location,
       new_deaths,
       SUM(new_deaths) OVER w AS cumulative_deaths 
FROM coviddeaths
WHERE continent = ''
WINDOW w AS (PARTITION BY location ORDER BY date);

#############
## Query 3 ##   The third query will be used to get:
#############   Map Analysis - % Population Infected Per Country, % Population Infected Forecast 

# Looking at Countries with Highest Infection Rate compared to Population
DROP TABLE IF EXISTS IRvPopulation;
CREATE TABLE IRvPopulation 
(date date,
 location varchar(255),
 population numeric,
 new_cases numeric,
 cumulative_infection_count numeric,
 pct_population_infected float);

INSERT INTO IRvPopulation
WITH IRvPopulation (date, location, population, new_cases, cumulative_infection_count)
AS 
(
SELECT date, 
	   location, 
       population, 
       new_cases,
       SUM(new_cases) OVER w AS cumulative_infection_count
FROM coviddeaths
WHERE continent != ''
WINDOW w AS (PARTITION BY location ORDER BY date)
)
SELECT *, (cumulative_infection_count / population) * 100 AS pct_population_infected  
FROM IRvPopulation;

