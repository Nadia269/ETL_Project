create database insurance;


/*by city */
CREATE TABLE GlobalLandTemperatures (
    SKTemperature int Primary Key Identity(1,1),
    dt DATE,
    AverageTemperature FLOAT,
    AverageTemperatureUncertainty FLOAT,
    City VARCHAR(100),
    Country VARCHAR(100),
    Latitude DECIMAL(10, 6),
    Longitude DECIMAL(10, 6)
);



/*CREATE TABLE GlobalLandTemperatures (
    dt DATE PRIMARY KEY,
    AverageTemperature FLOAT,
    AverageTemperatureUncertainty FLOAT,
    City VARCHAR(100),
    Country VARCHAR(100),
    Latitude DECIMAL(10, 6),
    Longitude DECIMAL(10, 6)
); */

select * from GlobalLandTemperatures;
 drop table GlobalLandTemperatures;


 CREATE TABLE GlobalLandTemperaturesByCountry (
    SKTemperatureCountry int Primary Key Identity(1,1),
    dt DATE,
    AverageTemperature DECIMAL(10,2), -- Adjust data type and precision as needed
	AverageTemperatureUncertainty DECIMAL (10,2),
    Country VARCHAR(100), -- Adjust data type and length as needed
);
select* from GlobalLandTemperaturesByCountry;
drop table GlobalLandTemperaturesByCountry;




 CREATE TABLE GlobalLandTemperaturesByState (

    SKTemperatureState int Primary Key Identity(1,1),
    dt DATE,
    AverageTemperature DECIMAL(10,2), -- Adjust data type and precision as needed
	AverageTemperatureUncertainty DECIMAL (10,2),
	State VARCHAR(500),
    Country VARCHAR(500) -- Adjust data type and length as needed
);

DBCC CHECKIDENT ('GlobalLandTemperaturesByState', NORESEED);
DBCC CHECKIDENT ('GlobalLandTemperaturesByState', RESEED, 0);



select * from GlobalLandTemperaturesByState;
drop table GlobalLandTemperaturesByState;





CREATE TABLE GlobalTemperaturesFact (
   SKGlobalTemperaturesFact int Primary Key Identity(1,1),
    dt DATE,  -- Date of temperature record
    LandAverageTemperature DECIMAL(10, 2),
    LandAverageTemperatureUncertainty DECIMAL(10, 2),
    LandMaxTemperature DECIMAL(10, 2),
    LandMaxTemperatureUncertainty DECIMAL(10, 2),
    LandMinTemperature DECIMAL(10, 2),
    LandMinTemperatureUncertainty DECIMAL(10, 2),
    LandAndOceanAverageTemperature DECIMAL(10, 2),
    LandAndOceanAverageTemperatureUncertainty DECIMAL(10, 2),  
	
    -- Foreign Key Columns
    SKTemperature INT,
    SKTemperatureCountry INT ,
    SKTemperatureState INT ,  
    -- Define Foreign Key Constraints
    CONSTRAINT FK_GlobalLandTemperatures FOREIGN KEY (SKTemperature) 
        REFERENCES GlobalLandTemperatures(SKTemperature),
    CONSTRAINT FK_GlobalLandTemperaturesByCountry FOREIGN KEY (SKTemperatureCountry) 
        REFERENCES GlobalLandTemperaturesByCountry(SKTemperatureCountry),
    CONSTRAINT FK_GlobalLandTemperaturesByState FOREIGN KEY (SKTemperatureState) 
        REFERENCES GlobalLandTemperaturesByState(SKTemperatureState)     
); 


/*	City VARCHAR(100) DEFAULT 'Unknown',  
    Country VARCHAR(100) DEFAULT 'Unknown', 
    State VARCHAR(500) DEFAULT 'Unknown', -- Optional
    Latitude DECIMAL(10, 6) DEFAULT 0.000000, 
    Longitude DECIMAL(10, 6) DEFAULT 0.000000, */  
   
);



select * from GlobalTemperaturesFact ;

drop table GlobalTemperaturesFact;



/* Aggregations on Each Table */

/* Daily Temperature Trends */

SELECT dt, AVG(LandAverageTemperature) AS AvgDailyTemp
FROM GlobalTemperaturesFact
GROUP BY dt;

/* Monthly Temperature Trends*/
SELECT YEAR(dt) AS Year, MONTH(dt) AS Month, AVG(LandAverageTemperature) AS AvgMonthlyTemp
FROM GlobalTemperaturesFact
GROUP BY YEAR(dt), MONTH(dt);

/* Yearly Temperature Trends*/

SELECT YEAR(dt) AS Year, AVG(LandAverageTemperature) AS AvgYearlyTemp
FROM GlobalTemperaturesFact
GROUP BY YEAR(dt);


/* City-Level Temperature Trends */
SELECT City, AVG(AverageTemperature) AS AvgCityTemp
FROM GlobalLandTemperatures
GROUP BY City;

/*Country-Level Temperature Trends   */ 

SELECT Country, AVG(AverageTemperature) AS AvgCountryTemp
FROM GlobalLandTemperaturesByCountry
GROUP BY Country;

/* State-Level Temperature Trends */
SELECT State, AVG(AverageTemperature) AS AvgStateTemp
FROM GlobalLandTemperaturesByState
GROUP BY State;

/*Global Maximum and Minimum Temperatures*/
SELECT MAX(LandMaxTemperature) AS MaxTemperature, MIN(LandMinTemperature) AS MinTemperature
FROM GlobalTemperaturesFact;

/*Global Average Temperature with Uncertainty */

SELECT AVG(LandAverageTemperature) AS AvgTemperature, AVG(LandAverageTemperatureUncertainty) AS AvgUncertainty
FROM GlobalTemperaturesFact;


/* Average Land and Ocean Temperature*/

SELECT AVG(LandAndOceanAverageTemperature) AS AvgLandOceanTemp, AVG(LandAndOceanAverageTemperatureUncertainty) AS AvgLandOceanUncertainty
FROM GlobalTemperaturesFact;

/*  Aggregations Combining Time and Geography
     Yearly Temperature Trends by Country  */

SELECT YEAR(dt) AS Year, Country, AVG(AverageTemperature) AS AvgYearlyTemp
FROM GlobalLandTemperaturesByCountry
GROUP BY YEAR(dt), Country;

/* Monthly Temperature Trends by State*/

SELECT YEAR(dt) AS Year, MONTH(dt) AS Month, State, AVG(AverageTemperature) AS AvgMonthlyTemp
FROM GlobalLandTemperaturesByState
GROUP BY YEAR(dt), MONTH(dt), State;


/*  Aggregations for Global Trends
    Global Average Temperature over Time */

SELECT YEAR(dt) AS Year, AVG(LandAverageTemperature) AS GlobalAvgTemp
FROM GlobalTemperaturesFact
GROUP BY YEAR(dt);


/* Global Temperature Range by Year */

SELECT YEAR(dt) AS Year, MAX(LandMaxTemperature) AS MaxTemp, MIN(LandMinTemperature) AS MinTemp
FROM GlobalTemperaturesFact
GROUP BY YEAR(dt) order by YEAR(dt);




UPDATE GTF
SET GTF.SKTemperatureState = GLTS.SKTemperatureState
FROM GlobalTemperaturesFact GTF
JOIN GlobalLandTemperaturesByState GLTS
    ON GTF.dt = GLTS.dt
WHERE GTF.SKTemperatureState IS NULL;


UPDATE GTF
SET GTF.SKTemperature = GLT.SKTemperature
FROM GlobalTemperaturesFact GTF
JOIN GlobalLandTemperatures GLT
    ON GTF.dt = GLT.dt
WHERE GTF.SKTemperature IS NULL;


UPDATE GTF
SET GTF.SKTemperatureCountry = GLTC.SKTemperatureCountry
FROM GlobalTemperaturesFact GTF
JOIN GlobalLandTemperaturesByCountry GLTC
    ON GTF.dt = GLTC.dt
WHERE GTF.SKTemperatureCountry IS NULL;


/* Aggregations Betwwn diemtions and Fact
   These aggregations help uncover meaningful trends, 
    correlations, and insights from the global temperature
    data across different geographical levels and time periods.

*/ 


/*Global Average Temperature by City
 
 Analyze the average temperature for each city based on data from the fact table.
*/

SELECT 
    GLT.City,
    AVG(GTF.LandAverageTemperature) AS AvgCityTemp
FROM GlobalTemperaturesFact GTF
JOIN GlobalLandTemperatures GLT
    ON GTF.SKTemperature = GLT.SKTemperature
GROUP BY GLT.City;

/*
Average Temperature by Country

This gives a summary of average temperatures for each country*/ 

Select GLC.Country,
       AVG(GTF.LandAverageTemperature)AS AvgCItyTemp
	   from GlobalTemperaturesFact GTF
	   join GlobalLandTemperaturesbyCountry GlC
	   ON  GTF.SKTemperatureCountry = GLC.SKTemperatureCountry
	   Group BY GLC.Country;


/* Yearly Temperature Trends by State  
    Shows how the temperature changes over time for each state  */

select Year(GTF.dt) as Year ,
      GLTS.State,
	  Avg(GTF.LandAverageTemperature) As AvgStateTemp
	  from  GlobalTemperaturesFact GTF
	  Join GlobalLandTemperaturesByState  GLTS
	  ON GTF.SKTemperatureState=GLTS.SKTemperatureState

	  Group By Year(GTF.dt),GLTS.State;

/*  Monthly Temperature Trends by Country  
   Analyze temperature fluctuations for each country on a monthly basis  */

SELECT 
    YEAR(GTF.dt) AS Year,
    MONTH(GTF.dt) AS Month,
    GLTC.Country,
    AVG(GTF.LandAverageTemperature) AS AvgMonthlyTemp
FROM GlobalTemperaturesFact GTF
JOIN GlobalLandTemperaturesByCountry GLTC
    ON GTF.SKTemperatureCountry = GLTC.SKTemperatureCountry
GROUP BY YEAR(GTF.dt), MONTH(GTF.dt), GLTC.Country;


/* Global Maximum and Minimum Temperatures by City
   Find the cities with the highest and lowest temperatures. */

SELECT 
    GLT.City,
    MAX(GTF.LandMaxTemperature) AS MaxCityTemp,
    MIN(GTF.LandMinTemperature) AS MinCityTemp
FROM GlobalTemperaturesFact GTF
JOIN GlobalLandTemperatures GLT
    ON GTF.SKTemperature = GLT.SKTemperature
GROUP BY GLT.City;


/* Temperature Uncertainty by State
             Provides insight into the reliability 
            of the temperature data for each state.
*/

SELECT 
    GLTS.State,
    AVG(GTF.LandAverageTemperatureUncertainty) AS AvgTempUncertainty
FROM GlobalTemperaturesFact GTF
JOIN GlobalLandTemperaturesByState GLTS
    ON GTF.SKTemperatureState = GLTS.SKTemperatureState
GROUP BY GLTS.State;

/*
      Yearly Average Land and Ocean Temperature by Country
      Understand how combined land and ocean temperatures change
         for different countries year over year. */

SELECT 
    YEAR(GTF.dt) AS Year,
    GLTC.Country,
    AVG(GTF.LandAndOceanAverageTemperature) AS AvgLandOceanTemp
FROM GlobalTemperaturesFact GTF
JOIN GlobalLandTemperaturesByCountry GLTC
    ON GTF.SKTemperatureCountry = GLTC.SKTemperatureCountry
GROUP BY YEAR(GTF.dt), GLTC.Country;


/* Global Average Temperature and Uncertainty by Year 
    Measure the global average temperature and the uncertainty 
    in the temperature readings by year for different countries.
*/
SELECT 
    YEAR(GTF.dt) AS Year,
    GLTC.Country,
    AVG(GTF.LandAverageTemperature) AS AvgTemp,
    AVG(GTF.LandAverageTemperatureUncertainty) AS AvgUncertainty
FROM GlobalTemperaturesFact GTF
JOIN GlobalLandTemperaturesByCountry GLTC
    ON GTF.SKTemperatureCountry = GLTC.SKTemperatureCountry
GROUP BY YEAR(GTF.dt), GLTC.Country;
























/*
CREATE TABLE GlobalLandTemperaturesFact (
    dt DATE,
    AverageTemperature DECIMAL(10,2),
    AverageTemperatureUncertainty DECIMAL(10,2),
    City VARCHAR(100),
    Latitude DECIMAL(10, 6),
    Longitude DECIMAL(10, 6),
    Country VARCHAR(100),
    State VARCHAR(500),
    PRIMARY KEY (dt, City, Country, Latitude, Longitude),
    FOREIGN KEY (dt, City, Country, Latitude, Longitude)
        REFERENCES GlobalLandTemperatures(dt, City, Country, Latitude, Longitude),
    FOREIGN KEY (dt, Country)
        REFERENCES GlobalLandTemperaturesByCountry(dt, Country),
    FOREIGN KEY (dt, State)
        REFERENCES GlobalLandTemperaturesByState(dt, State)
);

drop table  GlobalLandTemperaturesFact;
*/