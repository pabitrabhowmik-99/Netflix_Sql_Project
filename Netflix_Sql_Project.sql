use sql_project1;
--NETFLIX TV SHOWS AND MOVIES DATA ANALYSIS USING SQL SERVER--
--Here I have solved the following business queries
-----
-----------
--Query1:Total Numbers Of TV Shows and Movies in the dataset.

select [type],count(*) as total from netflix group by [type];
--TV SHOW-2676
--MOVIES-6131

--Query2:TOP 5 TV Shows by duration.

select top 5 title,[type],duration from netflix where [type]='tv show' 
order by CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS numeric) desc;
--Grey's Anatomy is Longest tv show 17 seasons

--Query3:Top 5 Shortest Movies Name and Duration

select top 5 title,duration from netflix where [type]='Movie' 
order by CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS numeric) asc;
--Silent  is the shortest movie 3 min only

--Query4:Top 5 Longest Movies Name and Duration

select top 5 title,duration from netflix where [type]='Movie' 
order by CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS numeric) desc;
--Black Mirror:Bandersnatch longest movie 312 min

--Query5:The number of movies or TV shows in each genre.

 select indivisual_listed_in,count(*) as total from (select value as indivisual_listed_in from netflix
 cross apply string_split(listed_in,',')) as genres
 group by indivisual_listed_in order by total desc;
--International Movies:2624
--Dramas:1600

--Query6:The average duration of movies or TV shows in each genre.

select genres.indivisual_listed_in,   avg(cast(left(duration, charindex(' ', duration) - 1) as numeric)) as avg_duration
from (select [type], duration, trim(value) as indivisual_listed_in from netflix cross apply string_split(listed_in,',')) as genres 
where [type]='movie' group by indivisual_listed_in order by avg_duration desc ;
--Avg duration of Classic movies 118.65 min

--Query7:Numbers of movies or TV shows were released in each year.

select netflix.release_year,count(*) as Total_movies from netflix
where [type]='movie' group by netflix.release_year order by netflix.release_year desc, Total_movies desc;
--2021:277 movies was released
--2018:767 movies was released

--Query8:Director who has the most movies or TV shows in the dataset.

select  indivisual_director,count(*) as Total_movies from (select trim(value) as indivisual_director from netflix 
cross apply string_split(director,',') where director is not null) as Indivisual_Director_tb
group by indivisual_director order by Total_movies desc;
--Rajiv Chilaka:22 movies

--Query9:The most frequently cast actors and actresses.

select  indivisual_cast,count(*) as Appearence from (select trim(value) as indivisual_cast from netflix 
cross apply string_split([cast],',')) as Indivisual_actor_tb
group by indivisual_cast order by Appearence desc;
--Anupam kher:Appearence 43 Movies
--SRK:Appearence 35 Movies

--Query10:The country that produced the most movies or TV shows.

select indivisual_country,count(*) as total_movie_tvshow from (select trim(value) as indivisual_country from netflix cross apply
string_split(country, ',')) as  normalized_country group by indivisual_country order by total_movie_tvshow desc;
--USA:3690
--INDIA:1046

--Query11: The average rating for each director's productions.

--step 1:
create function mapRating(@rating nvarchar(max))
returns int as
begin
declare @numericRating int
set @numericRating=case
		when @rating='G' then 1
		when @rating='TV-Y' then 2
		when @rating='R' then 3
		when @rating='TV-Y7' then 4
		when @rating='TV-G' then 5
		when @rating='TV-MA' then 6
		when @rating='NC-17' then 7
		when @rating='NR' then 8
		when @rating='TV-PG' then 9
		when @rating='UR' then 10
		when @rating='PG-13' then 11
		when @rating='YV-14' then 12
		when @rating='PG' then 13
		when @rating='TV-Y7-FV' then 14
		else null
end 
return @numericRating
end
--step 2:
select indivisual_director,avg(dbo.mapRating(rating)) as avg_rating from
(select trim(value) as indivisual_director,rating from netflix cross apply string_split(director,',')) as 
tb_director_rating where dbo.mapRating(rating) is not null group by indivisual_director order by avg_rating desc;
--Mario Cambi:avg rating TV-Y7-FV
--Holger Tappe:avg rating PG

--Query12:Total number of movies or tv shows in each rating.

select rating,count(*) as total_movie_tvshow from netflix group by rating order by total_movie_tvshow desc;
--TV-MA:3207
--TV-14:2160

--Query13:Oldest and newst title of the dataset.

select title from netflix where date_added =(select max(convert(date, date_added, 107)) as NewestDate from netflix);
select title,release_year from netflix where date_added =(select min(convert(date, date_added, 107)) as NewestDate from netflix);
--Newest movie:Dick johnson is dead
--Oldest movie:To and from new york