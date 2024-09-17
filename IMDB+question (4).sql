USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/


-- Segment 1:


			## Getting the table names:
				SELECT TABLE_NAME
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_SCHEMA = 'imdb';

-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:

			##Solution:
			SELECT   
				(SELECT COUNT(*) FROM director_mapping) AS director_mapping_count,   
				(SELECT COUNT(*) FROM genre) AS genre_count,
				(SELECT COUNT(*) FROM movie) AS movie_count,
				(SELECT COUNT(*) FROM names) AS names_count,
				(SELECT COUNT(*) FROM ratings) AS ratings_count,
				(SELECT COUNT(*) FROM role_mapping) AS role_mapping_count;

-- Q2. Which columns in the movie table have null values?
-- Type your code below:

			## Solution:
			## Getting the column names:
				SELECT COLUMN_NAME
				FROM INFORMATION_SCHEMA.COLUMNS  
				WHERE  TABLE_SCHEMA = 'imdb' AND TABLE_NAME = 'movie';

			## Now, fetching the columns with count of null values:
                SELECT   
					(SELECT COUNT(*) FROM movie WHERE id IS NULL) AS id_count,   
					(SELECT COUNT(*) FROM movie WHERE title IS NULL) AS title_count,   
					(SELECT COUNT(*) FROM movie WHERE year IS NULL) AS year_count,   
					(SELECT COUNT(*) FROM movie WHERE date_published IS NULL) AS date_published_count,   
					(SELECT COUNT(*) FROM movie WHERE duration IS NULL) AS duration_count,   
					(SELECT COUNT(*) FROM movie WHERE country IS NULL) AS country_count,
					(SELECT COUNT(*) FROM movie WHERE worlwide_gross_income IS NULL) AS worlwide_gross_income_count,
					(SELECT COUNT(*) FROM movie WHERE languages IS NULL) AS languages_count,
					(SELECT COUNT(*) FROM movie WHERE production_company IS NULL) AS production_company_count;

			## Country, Worldwide Gross Income, Languages & Production Company are the columns with missing values

-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 

-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

			## Solution:
            ## We are taking DISTINCT movie counts ensuring that duplicates are not being considered
				SELECT year AS Year, COUNT(DISTINCT title) AS number_of_movies
				FROM movie
				GROUP BY Year
				ORDER BY Year;

			## The year 2017 has the highest number of movie titles released and the year 2019 has the lowest  
			
            ## Now converting dates into months & getting the month wise trend:
				SELECT MONTH(date_published) AS month_num, COUNT(DISTINCT title) AS number_of_movies
				FROM movie
				GROUP BY month_num
				ORDER BY month_num;

/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:

			## Solution:
            ## Checking all India & USA related counts:
				SELECT country AS Country, year AS Year, COUNT(DISTINCT title) AS number_of_movies
				FROM movie
				WHERE year = 2019 AND country LIKE '%India%' OR year = 2019 AND country LIKE '%USA%'  
				GROUP BY country, year
				ORDER BY number_of_movies DESC;
			
            ## Getting the final output:
				SELECT SUM(number_of_movies)
				FROM (
					SELECT country AS Country, year AS Year, COUNT(DISTINCT title) AS number_of_movies
					FROM movie
					WHERE year = 2019 AND country LIKE '%India%' OR year = 2019 AND country LIKE '%USA%'  
					GROUP BY country, year
					ORDER BY number_of_movies DESC) india_usa_movies;
    
			## Total number of movies produced by India & USA in 2019 is 1056

/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:

			## Solution:
				SELECT DISTINCT genre
				FROM genre;

/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:

			## Solution:
				SELECT genre, COUNT(DISTINCT title) AS number_of_movies
				FROM genre
				INNER JOIN movie ON genre.movie_id = movie.id
				GROUP BY genre
				ORDER BY number_of_movies DESC;

/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:

			## Solution:
				SELECT SUM(movie_one_genre_only)
				FROM (	
					SELECT COUNT(DISTINCT title) AS movie_one_genre_only
					FROM genre
					INNER JOIN movie ON genre.movie_id = movie.id
					GROUP BY title
					HAVING COUNT(genre) = 1) movie_one_genre;

/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)

/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

			## Solution:
			## Using a genre_and_movie CTE (Common Table Expression):
				WITH genre_and_movie AS
					(SELECT *
					FROM genre
					INNER JOIN movie ON genre.movie_id = movie.id)
				SELECT genre, AVG(duration) AS avg_duration
				FROM genre_and_movie
				GROUP BY genre
				ORDER BY avg_duration DESC;

			## Creating a temporary table for repeated use:
				CREATE TEMPORARY TABLE genre_and_movie 
				SELECT * 
				FROM genre
				INNER JOIN movie ON genre.movie_id = movie.id;

/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

			## Solution:
				SELECT genre, COUNT(DISTINCT title) AS movie_count, RANK() OVER(ORDER BY COUNT(title) DESC) as genre_rank
				FROM genre_and_movie
				GROUP BY genre;

/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/


-- Segment 2:


			## Getting the column names:
				SELECT COLUMN_NAME
				FROM INFORMATION_SCHEMA.COLUMNS  
				WHERE  TABLE_SCHEMA = 'imdb' AND TABLE_NAME = 'ratings';

-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:
			## Solution:
				SELECT 
					MIN(avg_rating) AS min_avg_rating, MAX(avg_rating) AS max_avg_rating, 
					MIN(total_votes) AS min_total_votes, MAX(total_votes) AS max_total_votes,
					MIN(median_rating) AS min_median_rating, MAX(median_rating) AS max_median_rating
				FROM ratings;

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too

			## Solution:
			## Creating a temporary table for repeated use:
				CREATE TEMPORARY TABLE ratings_and_movie 
				SELECT * 
				FROM ratings
				INNER JOIN movie ON ratings.movie_id = movie.id;

			## Using CTE to get only top 10 ranks
				WITH ratings_and_movie_0 AS
					(SELECT title, avg_rating, DENSE_RANK() OVER(ORDER BY avg_rating DESC) AS movie_rank
					FROM ratings_and_movie)
				SELECT *
				FROM ratings_and_movie_0
				WHERE movie_rank <= 10;

/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have

			## Solution:
				SELECT median_rating, COUNT(DISTINCT title) AS movie_count
				FROM  ratings_and_movie
				GROUP BY median_rating
				ORDER BY median_rating;

/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:
			## Solution:
			## Trying it with CTE & nested to get 1st ranked production companies:
				WITH ratings_and_movie_avg8 AS
					(SELECT *
					FROM  ratings_and_movie
					WHERE avg_rating > 8 AND production_company IS NOT NULL)
				SELECT *
				FROM(
					SELECT production_company, COUNT(DISTINCT title) AS movie_count, DENSE_RANK() OVER(ORDER BY COUNT(DISTINCT title) DESC) AS movie_rank
					FROM ratings_and_movie_avg8
					GROUP BY production_company) with_and_nested
				WHERE movie_rank = 1;

-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

			## Solution:
			## Creating a temporary table for repeated use:
				CREATE TEMPORARY TABLE genre_ratings_movie 
                WITH copy_genre AS
                (SELECT movie_id AS m_id, genre 
				FROM genre)
                SELECT *
                FROM copy_genre
				INNER JOIN ratings ON copy_genre.m_id = ratings.movie_id
                INNER JOIN movie ON copy_genre.m_id = movie.id;
			
            ## Getting the final output:
				SELECT genre, COUNT(DISTINCT title) AS movie_count
                FROM genre_ratings_movie
                WHERE total_votes > 1000 AND year = 2017 AND MONTH(date_published) = 3 AND country LIKE '%USA%'
                GROUP BY genre
                ORDER BY movie_count DESC;
                
-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
			
            ## Solution:
				SELECT DISTINCT title, avg_rating, genre
                FROM genre_ratings_movie
                WHERE title LIKE 'The%' AND avg_rating > 8;

-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:

			## Solution:
				SELECT DISTINCT title, median_rating, date_published
                FROM genre_ratings_movie
                WHERE date_published BETWEEN '2018-04-01' AND '2019-04-01' AND median_rating = 8
                ORDER BY date_published;

-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:

			## Solution:
				SELECT 
					CASE 
					WHEN languages LIKE '%Italian%' THEN 'Italian'
					WHEN languages LIKE '%German%' THEN 'German'
					END AS language, SUM(total_votes)
                FROM(
					SELECT DISTINCT title, languages, total_votes
					FROM genre_ratings_movie
					WHERE languages LIKE '%German%' OR languages LIKE '%Italian%') language_distinct_titles
				GROUP BY language;
			
			##Answer is 'YES' German movies get more votes than Italian

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/


-- Segment 3:


-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

			## Solution:
				SELECT   
					(SELECT COUNT(*) FROM names WHERE id IS NULL) AS id_nulls,   
					(SELECT COUNT(*) FROM names WHERE name IS NULL) AS name_nulls,   
					(SELECT COUNT(*) FROM names WHERE height IS NULL) AS height_nulls,   
					(SELECT COUNT(*) FROM names WHERE date_of_birth IS NULL) AS date_of_birth_nulls,   
					(SELECT COUNT(*) FROM names WHERE known_for_movies IS NULL) AS known_for_movies_nulls;
				
/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

			## Solution:
			## Creating temporary table for repeated use:
				CREATE TEMPORARY TABLE all_merged_table 
				WITH copy_genre AS
				(SELECT movie_id AS m_id, genre 
				FROM genre),
				copy_director_mapping AS
				(SELECT movie_id AS m_id1, name_id AS n_id
				FROM director_mapping),
				copy_names AS 
				(SELECT id AS id_0, name, height, date_of_birth, known_for_movies
				FROM names),
				copy_role_mapping AS
				(SELECT movie_id AS m_id2, name_id AS n_id1, category
				FROM role_mapping)
				SELECT *
				FROM movie
				INNER JOIN ratings ON movie.id = ratings.movie_id
				INNER JOIN copy_role_mapping ON movie.id = copy_role_mapping.m_id2
				INNER JOIN copy_director_mapping ON movie.id = copy_director_mapping.m_id1
				INNER JOIN copy_genre ON movie.id = copy_genre.m_id
				INNER JOIN copy_names ON copy_role_mapping.n_id1 = copy_names.id_0;
				
                CREATE TEMPORARY TABLE merged_for_directors_table 
				WITH copy_genre AS
				(SELECT movie_id AS m_id, genre 
				FROM genre),
				copy_director_mapping AS
				(SELECT movie_id AS m_id1, name_id AS n_id
				FROM director_mapping),
				copy_names AS 
				(SELECT id AS id_0, name, height, date_of_birth, known_for_movies
				FROM names)
				SELECT *
				FROM movie
				INNER JOIN ratings ON movie.id = ratings.movie_id
				INNER JOIN copy_director_mapping ON movie.id = copy_director_mapping.m_id1
				INNER JOIN copy_genre ON movie.id = copy_genre.m_id
				INNER JOIN copy_names ON copy_director_mapping.n_id = copy_names.id_0;
                
			## Getting the top 3 genres:
				SELECT genre, COUNT(DISTINCT title) AS movie_count, RANK() OVER(ORDER BY COUNT(DISTINCT title) DESC) AS genre_rank
				FROM merged_for_directors_table
				WHERE avg_rating > 8
				GROUP BY genre;
				
			## The top 3 genres are Drama, Action & Comedy
			## Top 3 directors for drama:
				SELECT name as director_name, movie_count
                FROM(
					SELECT name, COUNT(DISTINCT title) AS movie_count, RANK() OVER(ORDER BY COUNT(DISTINCT title) DESC) AS genre_rank
					FROM merged_for_directors_table
					WHERE avg_rating > 8 AND genre = 'Drama'
					GROUP BY name) genre_ranked
				WHERE genre_rank < 4;
                
			## Top 3 directors for action:
                SELECT name as director_name, movie_count
                FROM(
					SELECT name, COUNT(DISTINCT title) AS movie_count, RANK() OVER(ORDER BY COUNT(DISTINCT title) DESC) AS genre_rank
					FROM merged_for_directors_table
					WHERE avg_rating > 8 AND genre = 'Action'
					GROUP BY name) genre_ranked
				WHERE genre_rank < 4;
                
			## Top 3 directors for comedy:
                SELECT name as director_name, movie_count
                FROM(
					SELECT name, COUNT(DISTINCT title) AS movie_count, RANK() OVER(ORDER BY COUNT(DISTINCT title) DESC) AS genre_rank
					FROM merged_for_directors_table
					WHERE avg_rating > 8 AND genre = 'Comedy'
					GROUP BY name) genre_ranked
				WHERE genre_rank < 4;
			
            ## James Manigold with 4 movies across drama & action is the top director
                
/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

			## Solution:
				SELECT actor_name, movie_count
				FROM(
					SELECT name AS actor_name, COUNT(DISTINCT title) AS movie_count, RANK() OVER(ORDER BY COUNT(DISTINCT title) DESC) AS actor_rank
					FROM all_merged_table
					WHERE median_rating >= 8
					GROUP BY name) actor_ranked
				WHERE actor_rank < 3;
		
/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

			## Solution:
				SELECT *
                FROM(
					SELECT DISTINCT production_company, SUM(total_votes) AS vote_count, 
					DENSE_RANK() OVER(ORDER BY SUM(total_votes) DESC) AS prod_comp_rank
					FROM(
						SELECT DISTINCT production_company, total_votes 
						FROM all_merged_table) production_company_ranked
					GROUP BY production_company) prod_table
				WHERE prod_comp_rank < 4;

/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

			## Solution:
				SELECT name AS actor_name, COUNT(movie) AS movie_count, SUM(total_votes) AS total_votes, ROUND(SUM(avg_rating*total_votes)/SUM(total_votes),2) AS actor_avg_rating, DENSE_RANK() OVER(ORDER BY ROUND(SUM(avg_rating*total_votes)/SUM(total_votes),2) DESC) AS actor_rank
                FROM(
					SELECT DISTINCT title as movie, name, total_votes, avg_rating
					FROM all_merged_table
                    WHERE country LIKE '%INDIA%' AND category = 'actor') actor_ranked
				GROUP BY name
				HAVING COUNT(movie) >= 5;
			
			## Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
				
			## Solution:
				SELECT name AS actress_name, COUNT(movie) AS movie_count, SUM(total_votes) AS total_votes, ROUND(SUM(avg_rating*total_votes)/SUM(total_votes),2) AS actress_avg_rating, DENSE_RANK() OVER(ORDER BY ROUND(SUM(avg_rating*total_votes)/SUM(total_votes),2) DESC) AS actress_rank
                FROM(
					SELECT DISTINCT title as movie, name, total_votes, avg_rating
					FROM all_merged_table
                    WHERE country LIKE '%INDIA%' AND category != 'actor' AND languages = 'Hindi') actress_ranked
				GROUP BY name
				HAVING COUNT(movie) >= 3;
			
			## Top actress is Tapsee Pannu

/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/

/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:

			## Solution:
				SELECT DISTINCT title, genre, avg_rating, 
				CASE 
				WHEN avg_rating >= 8 THEN 'Superhit movie'
				WHEN avg_rating >= 7 AND avg_rating < 8 THEN 'Hit movie'
				WHEN avg_rating >= 5 AND avg_rating < 7 THEN 'One-time-watch movie'
				WHEN avg_rating < 5 THEN 'Flop movie'
				ELSE 'Extremely Flop'
				END as classification_of_movies
				FROM all_merged_table
                ORDER BY avg_rating DESC;

/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/


-- Segment 4:


-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

			### Solution:
				SELECT genre, 
				ROUND(AVG(duration),2) AS avg_duration,
                AVG(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS UNBOUNDED PRECEDING) AS moving_avg_duration,
                ROUND(SUM(duration),2) AS total_duration,
				SUM(ROUND(SUM(duration),2)) OVER(ORDER BY genre ROWS UNBOUNDED PRECEDING) AS running_total_duration
				FROM all_merged_table
				GROUP BY genre
				ORDER BY avg_duration;
				
-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies
			
            ## Solution:
            
			## Creating temporary table for repeated use:
				CREATE TEMPORARY TABLE all_merged_table_02 
				WITH copy_genre AS
				(SELECT movie_id AS m_id, genre 
				FROM genre),
				copy_director_mapping AS
				(SELECT movie_id AS m_id1, name_id AS n_id
				FROM director_mapping),
				copy_names AS 
				(SELECT id AS id_0, name, height, date_of_birth, known_for_movies
				FROM names),
				copy_role_mapping AS
				(SELECT movie_id AS m_id2, name_id AS n_id1, category
				FROM role_mapping)
				SELECT *
				FROM movie
				INNER JOIN ratings ON movie.id = ratings.movie_id
				INNER JOIN copy_role_mapping ON movie.id = copy_role_mapping.m_id2
				INNER JOIN copy_director_mapping ON movie.id = copy_director_mapping.m_id1
				INNER JOIN copy_genre ON movie.id = copy_genre.m_id
				INNER JOIN copy_names ON copy_role_mapping.n_id1 = copy_names.id_0;
            
			## Getting the top 3 genres & then gettingthe top 5 movies within these genres:
				WITH top_3_genre AS
                (SELECT genre, COUNT(DISTINCT title) AS number_of_movies
				FROM all_merged_table
				GROUP BY genre
				ORDER BY COUNT(DISTINCT title) DESC
                LIMIT 3)
				SELECT *
                FROM(
					SELECT DISTINCT genre, year, title AS movie_name, worlwide_gross_income,
					DENSE_RANK() OVER(PARTITION BY genre ORDER BY worlwide_gross_income DESC) AS movie_rank
					FROM all_merged_table_02
					WHERE genre IN (SELECT genre FROM top_3_genre)
					) genre_split
				WHERE movie_rank < 6;

-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

			## Solution:
				SELECT *
                FROM(
                    SELECT DISTINCT production_company, COUNT(DISTINCT title) AS movie_count,
					DENSE_RANK() OVER(ORDER BY COUNT(DISTINCT title) DESC) AS prod_comp_rank
					FROM all_merged_table_02
					WHERE median_rating >= 8 AND production_company IS NOT NULL AND POSITION(',' IN languages) > 0
					GROUP BY production_company) production_table
				WHERE prod_comp_rank <= 2;

-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

			## Solution:
				SELECT *
                FROM(
					SELECT name AS actress_name, SUM(total_votes) AS total_votes, COUNT(title) AS movie_count, 
					AVG(avg_rating) AS actress_avg_rating, DENSE_RANK() OVER(ORDER BY AVG(avg_rating) DESC) AS actress_rank
					FROM(
						SELECT DISTINCT name, total_votes, title, avg_rating
						FROM all_merged_table_02
						WHERE category = 'actress' AND avg_rating > 8 AND genre = 'drama') actress_rank
					GROUP BY actress_name) actress_nested
				WHERE actress_rank < 4;

/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:

			## Solution:
			## Creating temporary table for repeated use: 	
                CREATE TEMPORARY TABLE merged_for_directors_table_02 
				WITH copy_genre AS
				(SELECT movie_id AS m_id, genre 
				FROM genre),
				copy_director_mapping AS
				(SELECT movie_id AS m_id1, name_id AS n_id
				FROM director_mapping),
				copy_names AS 
				(SELECT id AS id_0, name, height, date_of_birth, known_for_movies
				FROM names)
				SELECT *
				FROM movie
				INNER JOIN ratings ON movie.id = ratings.movie_id
				INNER JOIN copy_director_mapping ON movie.id = copy_director_mapping.m_id1
				INNER JOIN copy_genre ON movie.id = copy_genre.m_id
				INNER JOIN copy_names ON copy_director_mapping.n_id = copy_names.id_0;
                
                
                WITH inter_movie_average AS
				(SELECT id_0 AS id_00, AVG(inter_movie_days) AS avg_inter_movie_days
				FROM(
					SELECT *, DATEDIFF(next_movie_date, date_published) AS inter_movie_days
					FROM(
						SELECT DISTINCT id_0, name, m_id, date_published, 
						LEAD(date_published, 1) OVER(PARTITION BY id_0 ORDER BY date_published, m_id) AS next_movie_date
						FROM merged_for_directors_table) date_diff) inter_movie_tables
				GROUP BY id_0),
                other_headers AS
				(SELECT id_0 AS director_id, name AS director_name, COUNT(title) AS number_of_movies,
				AVG(avg_rating) AS avg_rating, SUM(total_votes) AS total_votes,
                MIN(avg_rating) AS min_rating, MAX(avg_rating) AS max_rating, SUM(duration) AS total_duration
                FROM(
					SELECT DISTINCT id_0, name, title, avg_rating, total_votes, duration 
					FROM merged_for_directors_table_02) directors_table
				GROUP BY id_0, name
                ORDER BY COUNT(title) DESC
                LIMIT 9)
                
                SELECT * 
                FROM other_headers
                INNER JOIN inter_movie_average ON other_headers.director_id = inter_movie_average.id_00;

## FIN
		