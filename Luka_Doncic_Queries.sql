USE NBAProject

SELECT * FROM dbo.LUKA_DONCIC_STATS$

------------------------------------------------------------------------------------------------
-- Luka's Individual Stats

--Points
SELECT ROUND(AVG(PTS),2) AS AveragePoints FROM dbo.LUKA_DONCIC_STATS$

--Rebounds
SELECT ROUND(AVG(REB),2) AS AverageRebounds FROM dbo.LUKA_DONCIC_STATS$

--Assists
SELECT ROUND(AVG(AST),2) AS AverageAssists FROM dbo.LUKA_DONCIC_STATS$

-- 3 Point Percentage
SELECT ROUND(AVG(FG3_PCT),2) AS Three_point_percentage FROM dbo.LUKA_DONCIC_STATS$

-- FG percentage
SELECT ROUND(AVG(FG_PCT),2) AS Field_Goal_percentage FROM dbo.LUKA_DONCIC_STATS$

-- FT Percentage
SELECT ROUND(AVG(FT_PCT),2) AS Free_Throw_percentage FROM dbo.LUKA_DONCIC_STATS$
---------------------------------------------------------------------------------------------------
--Luka Doncic Average Points for Wins and Losses

DROP TABLE IF EXISTS #NumberOfWinsAndLosses
CREATE TABLE #NumberOfWinsAndLosses
(
WL varchar(255),
Amount float,
TotalGames float
)

DROP TABLE IF EXISTS #AveragePoints
CREATE TABLE #AveragePoints
(
WL varchar(255),
AveragePoints float
)

INSERT INTO #NumberOfWinsAndLosses
SELECT WL, COUNT(*), (SELECT COUNT(*) FROM dbo.LUKA_DONCIC_STATS$ AS TotalGames) FROM dbo.LUKA_DONCIC_STATS$	
	GROUP BY WL


INSERT INTO #AveragePoints
SELECT WL, ROUND(AVG(PTS),1) FROM dbo.LUKA_DONCIC_STATS$
	GROUP BY WL

SELECT #NumberOfWinsAndLosses.WL, #NumberOfWinsAndLosses.Amount, #AveragePoints.AveragePoints FROM #NumberOfWinsAndLosses 
	JOIN #AveragePoints
	ON #NumberOfWinsAndLosses.WL = #AveragePoints.WL
	ORDER BY 2 DESC
---------------------------------------------------------------------------------------------------

--Win Percentage Based off of Luka's scoring

DROP TABLE IF EXISTS #GreaterThanThirty
CREATE TABLE #GreaterThanThirty
(
NumberofWins FLOAT,
TotalGames FLOAT,
)
INSERT INTO #GreaterThanThirty
SELECT COUNT(*) AS NumberofWins, (SELECT COUNT(*) FROM dbo.LUKA_DONCIC_STATS$ AS TotalGames) AS TotalGames FROM dbo.LUKA_DONCIC_STATS$
	WHERE PTS <= 30 AND WL = 'W'
	GROUP BY WL

SELECT 30 AS MaximumPointsScored, *, NumberofWins/TotalGames AS WinPercentage FROM #GreaterThanThirty



DROP TABLE IF EXISTS #GreaterThanThirtyFive
CREATE TABLE #GreaterThanThirtyFive
(
NumberofWins FLOAT,
TotalGames FLOAT,
)
INSERT INTO #GreaterThanThirtyFive
SELECT COUNT(*) AS NumberofWins, (SELECT COUNT(*) FROM dbo.LUKA_DONCIC_STATS$ AS TotalGames) AS TotalGames FROM dbo.LUKA_DONCIC_STATS$
	WHERE PTS <= 35 AND WL = 'W'
	GROUP BY WL

SELECT 35 AS MaximumPointsScored, *, NumberofWins/TotalGames AS WinPercentage FROM #GreaterThanThirtyFive



DROP TABLE IF EXISTS #GreaterThanForty
CREATE TABLE #GreaterThanForty
(
NumberofWins FLOAT,
TotalGames FLOAT,
)
INSERT INTO #GreaterThanForty
SELECT COUNT(*) AS NumberofWins, (SELECT COUNT(*) FROM dbo.LUKA_DONCIC_STATS$ AS TotalGames) AS TotalGames FROM dbo.LUKA_DONCIC_STATS$
	WHERE PTS <= 40 AND WL = 'W'
	GROUP BY WL

SELECT 40 AS MaximumPointsScored, *, NumberofWins/TotalGames AS WinPercentage FROM #GreaterThanForty



DROP TABLE IF EXISTS #GreaterThanFortyFive
CREATE TABLE #GreaterThanFortyFive
(
NumberofWins FLOAT,
TotalGames FLOAT,
)
INSERT INTO #GreaterThanFortyFive
SELECT COUNT(*) AS NumberofWins, (SELECT COUNT(*) FROM dbo.LUKA_DONCIC_STATS$ AS TotalGames) AS TotalGames FROM dbo.LUKA_DONCIC_STATS$
	WHERE PTS <= 45 AND WL = 'W'
	GROUP BY WL

SELECT 45 AS MaximumPointsScored, *, NumberofWins/TotalGames AS WinPercentage FROM #GreaterThanFortyFive



DROP TABLE IF EXISTS #GreaterThanFifty
CREATE TABLE #GreaterThanFifty
(
NumberofWins FLOAT,
TotalGames FLOAT,
)
INSERT INTO #GreaterThanFifty
SELECT COUNT(*) AS NumberofWins, (SELECT COUNT(*) FROM dbo.LUKA_DONCIC_STATS$ AS TotalGames) AS TotalGames FROM dbo.LUKA_DONCIC_STATS$
	WHERE PTS <= 50 AND WL = 'W'
	GROUP BY WL

SELECT 50 AS MaximumPointsScored, *, NumberofWins/TotalGames AS WinPercentage FROM #GreaterThanFifty

--combining

SELECT 30 AS MaximumPointsScored, *, ROUND(NumberofWins/TotalGames,3)*100 AS WinPercentage FROM #GreaterThanThirty
UNION
SELECT 35 AS MaximumPointsScored, *, ROUND(NumberofWins/TotalGames,3)*100 AS WinPercentage FROM #GreaterThanThirtyFive
UNION
SELECT 40 AS MaximumPointsScored, *, ROUND(NumberofWins/TotalGames,3)*100 AS WinPercentage FROM #GreaterThanForty
UNION
SELECT 45 AS MaximumPointsScored, *, ROUND(NumberofWins/TotalGames,3)*100 AS WinPercentage FROM #GreaterThanFortyFive
UNION
SELECT 50 AS MaximumPointsScored, *, ROUND(NumberofWins/TotalGames,3)*100 AS WinPercentage FROM #GreaterThanFifty

---------------------------------------------------------------------------------------------------
--Luka's Rolling Sum for Points

SELECT GAME_DATE, PTS, SUM(PTS) OVER (ORDER BY GAME_DATE) AS RollingSum FROM dbo.LUKA_DONCIC_STATS$

---------------------------------------------------------------------------------------------------
--Luka's 3 game rolling average for points

SELECT GAME_DATE, PTS, ROUND(AVG(PTS) OVER (ORDER BY GAME_DATE ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING),2) AS ThreeDayRollingAverage FROM dbo.LUKA_DONCIC_STATS$

----------------------------------------------------------------------------------------------------
--Luka's Percent Change for Points

WITH CTE AS
(
SELECT GAME_DATE, PTS, LAG(PTS,1) OVER (ORDER BY GAME_DATE) AS previous FROM dbo.LUKA_DONCIC_STATS$
	WHERE PTS!= 0
)

SELECT GAME_DATE, PTS, ROUND(((PTS-previous)/previous)*100,2) AS Percent_Change FROM CTE
	
