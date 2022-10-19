USE Covid_Project
GO

					/* Covid Project - Final */

/* The data came from Our World in Data website as a CSV file, which converted to Excel. */

-- First, imported the data from the Excel file to this database.

SELECT *
FROM OWID_CovidData

/*  I was having trouble with quiry execution time, probably because of the size of data. 
	Also, the date format, some non-valuable locations, and the datatype of some columns were bothering me. 
	So, I decided to create simplified tables.*/

SELECT CONVERT(date, date) 
FROM OWID_CovidData

SELECT iso_code, continent, location, CONVERT(date, date) AS date, population, new_cases, total_cases, CAST(new_deaths AS int) AS new_deaths, CAST(total_deaths AS int) AS total_deaths 
FROM OWID_CovidData

SELECT DISTINCT iso_code, continent, location
FROM OWID_CovidData
WHERE location LIKE '%INCOME%' 
OR location = 'European Union'
OR location = 'International'

SELECT iso_code, continent, location, CONVERT(date, date) AS date, population, new_cases, total_cases, CAST(new_deaths AS int) AS new_deaths, CAST(total_deaths AS int) AS total_deaths 
FROM OWID_CovidData
WHERE location NOT LIKE '%INCOME%' 
AND location <> 'European Union'
AND location <> 'International'
;
CREATE VIEW OWID_CovidData2 AS
SELECT iso_code, continent, location, CONVERT(date, date) AS date, population, new_cases, total_cases, CAST(new_deaths AS int) AS new_deaths, CAST(total_deaths AS int) AS total_deaths 
FROM OWID_CovidData
WHERE location NOT LIKE '%INCOME%' 
AND location <> 'European Union'
AND location <> 'International'

SELECT *
FROM OWID_CovidData2

-- Now lets do the analysis.

-- Cases vs popuplation.	Percentage of cases over Population. 
	-- Note: This doesn't show the probability of getting infected, because it doesn't show the affected people at a certain time, but all the people affected at some point.

SELECT location, date, population, total_cases, ROUND( total_cases/population *100 , 2) AS Cases_Percentage
FROM OWID_CovidData2
ORDER BY 1, 2

SELECT location, date, population, total_cases, ROUND( total_cases/population *100 , 2) AS Cases_Percentage
FROM OWID_CovidData2
WHERE location = 'QATAR'
ORDER BY 1, 2

	-- By countries

SELECT location, population, MAX(total_cases) AS Max_Cases
FROM OWID_CovidData2
GROUP BY location, population
ORDER BY 1

SELECT location, population, MAX(total_cases) AS Max_Cases, ROUND( MAX(total_cases)/population *100 , 2) AS Cases_Percentage
FROM OWID_CovidData2
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC

	-- By continents

SELECT location, MAX(total_cases) AS Max_Cases
FROM OWID_CovidData2
WHERE continent IS NULL
GROUP BY location
ORDER BY 2 DESC

-- Deaths vs cases. 	Percentage of death over affected cases. 

SELECT location, date, total_cases, total_deaths, ROUND( total_deaths/total_cases *100 , 2) AS Death_Percentage
FROM OWID_CovidData2
ORDER BY 1, 2

SELECT location, date, total_cases, total_deaths, ROUND( total_deaths/total_cases *100 , 2) AS Death_Percentage
FROM OWID_CovidData2
WHERE location = 'QATAR'
ORDER BY 1, 2
		-- Intersing fact: The death percentage never reached 1%
		SELECT location, date, total_cases, total_deaths, ROUND( total_deaths/total_cases *100 , 2) AS Death_Percentage
		FROM OWID_CovidData2
		WHERE location = 'QATAR'
		ORDER BY 5 DESC

SELECT location, date, total_cases, total_deaths, ROUND( total_deaths/total_cases *100 , 2) AS Death_Percentage
FROM OWID_CovidData2
WHERE location = 'INDIA'
ORDER BY 1, 2

	-- By countries

SELECT location, MAX(total_deaths) AS Max_Deaths
FROM OWID_CovidData2
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

SELECT location, MAX(total_deaths) AS Max_Deaths, MAX(total_cases) AS Max_Cases
FROM OWID_CovidData2
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 1 

SELECT location, MAX(total_deaths) AS Max_Deaths, MAX(total_cases) AS Max_Cases, ROUND( MAX(total_deaths)/MAX(total_cases) *100 , 2) AS Deaths_Percentage
FROM OWID_CovidData2
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 4 DESC
	-- Interesting result for North Korea 

-- Deaths vs population.	Percentage of Death over the population

SELECT location, population, MAX(total_deaths) AS Max_Deaths, ROUND( MAX(total_deaths)/population *100 , 2) AS Deaths_Percentage_pop
FROM OWID_CovidData2
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC
	
	-- By continent

SELECT location, MAX(total_deaths) AS Max_Deaths
FROM OWID_CovidData2
WHERE continent IS NULL
GROUP BY location
ORDER BY 2 DESC

-- World Wide analysis

SELECT date, SUM(new_cases) AS Total_Cases, SUM(new_deaths) AS Total_Deaths, ROUND( SUM(new_deaths)/SUM(new_cases) *100 , 2) AS Deaths_Percentage
FROM OWID_CovidData2
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1

SELECT SUM(new_cases) AS Total_Cases, SUM(new_deaths) AS Total_Deaths, ROUND( SUM(new_deaths)/SUM(new_cases) *100 , 2) AS Deaths_Percentage
FROM OWID_CovidData2
WHERE continent IS NOT NULL



							/* Covid Project Queries for Tableau */


-- 1. Deaths vs Cases - World Wide
SELECT SUM(new_cases) AS Total_Cases, SUM(new_deaths) AS Total_Deaths, SUM(new_deaths)/SUM(new_cases) *100 AS Deaths_Percentage
FROM OWID_CovidData2
WHERE continent IS NOT NULL

-- 2. Deaths by continents
SELECT location, SUM(new_deaths) AS Total_Deaths
FROM OWID_CovidData2
WHERE continent IS NULL
AND location <> 'World'
GROUP BY location
ORDER BY 2 DESC

-- 3. Cases vs population - by countries
SELECT location, population, MAX(total_cases) AS Max_Cases, MAX(total_cases)/population *100 AS Cases_Percentage
FROM OWID_CovidData2
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC

-- 4. Cases vs population - by countries over dates /**/
Select Location, Population,date, MAX(total_cases) as Max_Cases,  Max((total_cases/population))*100 as Cases_Percentage
From OWID_CovidData2
Group by Location, Population, date
order by Cases_Percentage desc

-- 5. Overall data
SELECT location, date, population, new_cases, total_cases, new_deaths, total_deaths
FROM OWID_CovidData2
ORDER BY 1, 2
