create database music_database;
USE music_database;
#Q1: . who is senior most employee base on job tittle?
select * from employee
 ORDER By levels desc
 Limit 1;
 
 #Q2. Which country has most invoices
 select COUNT(*)  as c, billing_country
 from invoice
 group by billing_country
 order by c desc
 
 #Q3. what are the top 3 value of total invoice
 select total FROM invoice
 order by total desc
 limit 3;
 
 #Q4. Which city has the best customer? We would like to throw a promotinal festival in a city we made the most money. 
 # write a query that returns one city that has highest sum of invocie total
 # Return both the city name & sum of invoic Total.
 
 select SUM(total) as invoice_total, billing_city
 from invoice
 group by billing_city
 order by invoice_total desc;
 
 #Q5: who is the best customer? The customer who has the spent most money will declared the best customer.
 # write a query that return the customer who has spent the most money.
 
 select * from customer;
 
 select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as total
 from customer
 JOIN invoice ON customer.customer_id = invoice.customer_id
 Group by customer.customer_id
 order by total desc
 limit 1;
 
 # Q6. write rhe query to return the email,  first name, last name, genre of all rock music listeners.
 #Returns your list alphabetically email starting by A.alter
 
 Select distinct email,first_name, last_name
 from customer
 JOIN invoice on customer.customer_id = invoice.customer_id
 JOIN invoice_line on invoice.invoice_id = invoice_line.invoice_id
 WHERE track_id IN(
		select track_id from track
        JOIN genre ON track.genre_id = genre.genre_id
        WHERE genre.name LIKE "ROCK"
)
ORDER by email;
 
 #Q.7 let's invite the artrist who have written the most rock music in our dataset. 
 #write a query that return the artist name and total track count of the top 10 rock bands.
 Select artist.artist_id, artist.name , count(artist.artist_id) as number_of_songs
 from track
 JOIN album1 ON album1.album_id = track.album_id
 JOIN artist ON artist.artist_id = album1.artist_id
 JOIN genre ON genre.genre_id = track.genre_id
 where genre.name LIKE 'ROCK'
 Group by artist.artist_id
 ORDER by number_of_songs DESC
 LIMIT 15;
 
 #Q8. Return all the track names that have a song length longer than the average song length.
 # Returns all names and milliseconds for each track. Order by the song length with the longest songs listed first.
 Select name, milliseconds
 FROM track
 where milliseconds > (
		Select AVG (milliseconds) AS avg_track_length
        FROM track)
 Order by milliseconds DESC;       
 
 Select AVG (milliseconds) AS avg_track_length
        FROM track;
 
 # Q.9 find how much spent on artist by each customer? Write a Query to return customer name , artist name and total spent.alter
 
 With best_selling_artist As (
	Select artist.artist_id AS artist_id, artist.name AS artist_name,
	SUM(invoice_line.unit_price*invoice_line.quantity) As total_sales
    FROM invoice_line
    JOIN track on track.track_id = invoice_line.track_id
    JOIN album1 on album1.album_id = track.album_id
    JOIN artist on artist.artist_id = album1.artist_id
    GROUP by 1
    ORDER BY 3 DESC
    LIMIT 1
  )
  
  Select c.customer_id, c.first_name, c.last_name, bsa.artist_name, 
  SUM(il.unit_price*il.quantity)AS amount_spent
  FROM invoice i
  JOIN customer c on c.customer_id = i.customer_id
  JOIN invoice_line il ON il.invoice_id = i.invoice_id
  JOIN track t ON t.track_id = il.track_id
  JOIN album1 alb ON alb.album_id = t.album_id
  JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
  GROUP BY 1,2,3,4
  ORDER BY 5 DESC;
  
  #Q2.We want to find out the most popular music Genre for each country.
  #We determine the most genre as the genre with highest amount.
  
  With popular_genre As
  (
	Select COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id,
    ROW_NUMBER() over(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS Rowno
    FROM invoice_line
    JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
    JOIN customer ON customer.customer_id = invoice.customer_id
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN genre ON genre.genre_id = track.genre_id
    Group by 2,3,4
    Order by 2 Asc, 1 DESC
  )
  Select * from Popular_genre where Rowno <= 1
  
  #Q10. Write a query that determines customers that has spent on music for each country.
  #Write a query that returns the country along with the top customers and how much they spent.
  #for countries where the top amount spent is shared, Provide all customers who spent this amount
  
With customer_with_country As (
		Select customer.customer_id,first_name, last_name, billing_country, SUM(total) AS total_spending,
        ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total)DESC) AS Rowno
        FROM invoice
        JOIN customer ON customer.customer_id = invoice.customer_id
        GROUP BY 1,2,3,4
        ORDER BY 4 ASC,5 DESC)
SELECT * FROM customer_with_country WHERE Rowno <= 1      