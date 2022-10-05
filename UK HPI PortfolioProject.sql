
/*
UK House Price Index Data Exploration

Skills Used: Joins, CTE's, Temp Tables, Converting Data Types
*/


select *
from PortfolioProject..[UK-HPI-2022-07]
order by 2

/* 

Area Codes To Distinguish Country, Region, County and Local Authority
Country: 'E92%' OR 'K02%' OR 'K03%' OR 'K04%' OR 'L93%' OR 'M83%' OR 'N92%' OR 'S92%' OR 'W92%'
Region: 'E12%'
County: 'E10%'
Local Authority (Loc.A): 'E06%' OR 'E07%' OR 'E08%' OR 'E09%' OR 'N09%' OR 'S12%' OR 'W06%'

*/

-- Rank The Loc.A's Most Recent Index (1/07/2022)

SELECT [Date], RegionName, [Index]
FROM PortfolioProject..[UK-HPI-2022-07]
WHERE [Date] = {d '2022-07-01'}
AND (AreaCode LIKE 'E06%' OR AreaCode LIKE 'E07%' OR AreaCode LIKE 'E08%' OR AreaCode LIKE 'E09%' OR AreaCode LIKE 'N09%' OR AreaCode LIKE 'S12%' OR  AreaCode LIKE'W06%')
ORDER BY [Index]
DESC

-- Rank The Loc.A's Most Recent Sales Volume (1/05/2022)

SELECT [Date], RegionName, SalesVolume
FROM PortfolioProject..[UK-HPI-2022-07]
WHERE [Date] = {d '2022-05-01'}
AND (AreaCode LIKE 'E06%' OR AreaCode LIKE 'E07%' OR AreaCode LIKE 'E08%' OR AreaCode LIKE 'E09%' OR AreaCode LIKE 'N09%' OR AreaCode LIKE 'S12%' OR  AreaCode LIKE'W06%')
ORDER BY SalesVolume
DESC

-- Rank The Loc.A's Sales Volume Growth In The Past 5 Years (01/02/2017 - 01/02/2022)

-- Temp Table

DROP TABLE IF EXISTS OSV
Create Table OSV
(
Date datetime,
RegionName nvarchar (255),
SalesVolume numeric
)
Insert Into OSV
Select Date, RegionName, SalesVolume
From PortfolioProject..[UK-HPI-2022-07]
Where [Date] = {d '2017-02-01'}

SELECT a.[Date], a.RegionName, b.SalesVolume as [2017SalesVolume], a.SalesVolume as [2022SalesVolume], ((a.SalesVolume/b.SalesVolume)*100) as SalesVolumeGrowth
FROM PortfolioProject..[UK-HPI-2022-07] a 
INNER JOIN OSV b
ON a.RegionName = b.RegionName
WHERE a.[Date] = {d '2022-02-01'}
AND (a.AreaCode LIKE 'E06%' OR a.AreaCode LIKE 'E07%' OR a.AreaCode LIKE 'E08%' OR a.AreaCode LIKE 'E09%' OR a.AreaCode LIKE 'N09%' OR a.AreaCode LIKE 'S12%' OR  a.AreaCode LIKE'W06%')
ORDER BY SalesVolumeGrowth
DESC


-- Type Of Property With Most Recent Highest Index In Each LocA (01/07/2022)

SELECT [Date], RegionName, DetachedIndex, SemiDetachedIndex, TerracedIndex, FlatIndex, 
CASE 
	WHEN DetachedIndex > SemiDetachedIndex and DetachedIndex > TerracedIndex and DetachedIndex > FlatIndex  THEN 'Detached'
	WHEN SemiDetachedIndex> DetachedIndex and SemiDetachedIndex> TerracedIndex and SemiDetachedIndex> FlatIndex THEN 'SemiDetached'
	WHEN TerracedIndex> DetachedIndex and TerracedIndex> SemiDetachedIndex and TerracedIndex> FlatIndex THEN 'Terraced'
	WHEN FlatIndex> DetachedIndex and FlatIndex> SemiDetachedIndex and FlatIndex> TerracedIndex THEN 'Flat'
ELSE 'N/A'
END AS HighestPropertyIndexType
FROM PortfolioProject..[UK-HPI-2022-07]
WHERE [Date] = {d '2022-07-01'}
AND (AreaCode LIKE 'E06%' OR AreaCode LIKE 'E07%' OR AreaCode LIKE 'E08%' OR AreaCode LIKE 'E09%' OR AreaCode LIKE 'N09%' OR AreaCode LIKE 'S12%' OR  AreaCode LIKE'W06%')
ORDER BY RegionName



-- Most Recent Cash Index vs Mortgage Index (01/07/2022)

SELECT [Date], RegionName, CashPrice, MortgagePrice, (CONVERT (float,MortgagePrice)- CAST(CashPrice as float)) AS CashVsMortgageDiff
FROM PortfolioProject..[UK-HPI-2022-07]
WHERE [Date] = {d '2022-07-01'}
AND (AreaCode LIKE 'E06%' OR AreaCode LIKE 'E07%' OR AreaCode LIKE 'E08%' OR AreaCode LIKE 'E09%' OR AreaCode LIKE 'N09%' OR AreaCode LIKE 'S12%' OR  AreaCode LIKE'W06%')
ORDER BY RegionName


-- Most Recent New vs Old Property Index (01/01/2022)

SELECT [Date], RegionName, NewIndex, OldIndex, 
CASE
	WHEN NewIndex> OldIndex THEN 'New'
	WHEN OldIndex> NewIndex THEN 'Old'
	ELSE 'N/A'
END AS HighestPropertyIndexStatus
FROM PortfolioProject..[UK-HPI-2022-07]
WHERE [Date] = {d '2022-05-01'}
AND (AreaCode LIKE 'E06%' OR AreaCode LIKE 'E07%' OR AreaCode LIKE 'E08%' OR AreaCode LIKE 'E09%' OR AreaCode LIKE 'N09%' OR AreaCode LIKE 'S12%' OR  AreaCode LIKE'W06%')
ORDER BY RegionName

-- Areas With Highest Average 12m%Change.

--Use of CTE

With Average12Month  ([Date], RegionName, [12m%Change], [AVG12m%Change])
AS(
SELECT [Date], RegionName, [12m%Change], 
AVG(CONVERT(float, [12m%Change])) OVER (PARTITION BY RegionName ORDER BY RegionName, [Date]) AS [AVG12m%Change]
FROM PortfolioProject..[UK-HPI-2022-07]
WHERE (AreaCode LIKE 'E06%' OR AreaCode LIKE 'E07%' OR AreaCode LIKE 'E08%' OR AreaCode LIKE 'E09%' OR AreaCode LIKE 'N09%' OR AreaCode LIKE 'S12%' OR  AreaCode LIKE'W06%')

)
SELECT * 
FROM Average12Month
WHERE [Date]= {d '2022-07-01'}
ORDER BY [AVG12m%Change]
DESC

-- Property Types With Highest Average 12m%Change

-- Use of CTE

With AVGProp12mChange ([Date], RegionName, [Detached12m%Change], DetAVG12m, [SemiDetached12m%Change], SemiDetAVG12m, 
[Terraced12m%Change], TerrAVG12m, [Flat12m%Change], FlatAVG12m)
AS(
SELECT [Date], RegionName, 
[Detached12m%Change], AVG(Convert(float,[Detached12m%Change])) OVER (PARTITION BY RegionName ORDER BY RegionName, [Date]) AS DetAVG12m, 
[SemiDetached12m%Change], AVG(Convert(float,[SemiDetached12m%Change])) OVER (PARTITION BY RegionName ORDER BY RegionName, [Date]) AS SemiDetAVG12m, 
[Terraced12m%Change], AVG(Convert(float,[Terraced12m%Change])) OVER (PARTITION BY RegionName ORDER BY RegionName, [Date]) AS TerrAVG12m, 
[Flat12m%Change], AVG(Convert(float,[Flat12m%Change])) OVER (PARTITION BY RegionName ORDER BY RegionName, [Date]) AS FlatAVG12m
FROM PortfolioProject..[UK-HPI-2022-07]
WHERE (AreaCode LIKE 'E06%' OR AreaCode LIKE 'E07%' OR AreaCode LIKE 'E08%' OR AreaCode LIKE 'E09%' OR AreaCode LIKE 'N09%' OR AreaCode LIKE 'S12%' OR  AreaCode LIKE'W06%')

)
SELECT *, 
CASE 
	WHEN DetAVG12m > SemiDetAVG12m and DetAVG12m > TerrAVG12m and DetAVG12m > FlatAVG12m  THEN 'Detached'
	WHEN SemiDetAVG12m> DetAVG12m and SemiDetAVG12m> TerrAVG12m and SemiDetAVG12m> FlatAVG12m THEN 'SemiDetached'
	WHEN TerrAVG12m> DetAVG12m and TerrAVG12m> SemiDetAVG12m and TerrAVG12m> FlatAVG12m THEN 'Terraced'
	WHEN FlatAVG12m> DetAVG12m and FlatAVG12m> SemiDetAVG12m and FlatAVG12m> TerrAVG12m THEN 'Flat'
ELSE 'N/A'
END AS HighestPropertyAVG
FROM AVGProp12mChange
WHERE [Date] = {d '2022-05-01'}
