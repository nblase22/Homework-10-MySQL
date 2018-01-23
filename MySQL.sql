USE sakila;

-- 1a, display first and last name of actors
SELECT first_name, last_name FROM actor;

-- 1b display first and last name in single column with upper case letters
SELECT CONCAT(first_name ," ", last_name) AS Full_Name from actor;

-- 2a find ID number, first name, last name of actor with name Joe
SELECT actor_id, first_name, last_name FROM actor
WHERE first_name = "Joe";


-- 2b find all actors whose last name contains GEN
SELECT first_name, last_name FROM actor
WHERE last_name LIKE '%gen%';

-- 2c find actors whose last names contain LI, order by last name/first name
SELECT last_name, first_name FROM actor
WHERE last_name LIKE '%LI%';

-- 2d using IN, display Country_id and country columns for Afghanistan, Bangladesh, CHina
SELECT country_id, country FROM country
WHERE country IN ("Afghanistan", "Bangladesh", "China");

-- 3a add a middle name column to the actor table, between first_name and last_name
ALTER TABLE actor
ADD COLUMN middle_name varchar(30) AFTER first_name;

-- SELECT * FROM actor;

-- 3b change the data type of middle_name to blobs
ALTER TABLE actor MODIFY middle_name BLOB;

-- 3c delete mittle_name column
ALTER TABLE actor
DROP COLUMN middle_name;

-- SELECT * FROM actor;

-- 4a list the names of actors and the number of actors who have that last naem
SELECT last_name, COUNT(*) AS Same_Last_Name FROM actor
GROUP BY last_name;

-- 4b same as a, but only for names shared by > 2 actors
SELECT last_name, COUNT(*) AS Same_Last_Name FROM actor
GROUP BY last_name HAVING Same_Last_Name > 1;

-- 4c change Groucho Williams to Harpo Williams
UPDATE actor
SET first_name = "HARPO"
WHERE first_name = "Groucho" AND last_name = "Williams";

-- Select * FROM actor;

-- 4d if first name is harpo, change to groucho, otherwise change first name to mucho groucho
-- don't change very actor to mucho groucho, update using unique identifier
UPDATE actor
SET first_name = "GROUCHO"
WHERE actor_id = 172;

-- SELECT * from actor;

-- 5a cannot locate schema, write query to re-create it

-- SHOW CREATE TABLE address;
DESCRIBE address;

-- 6a use Join to display first and last names, as well as address of each staff member using
-- staff and address tables
SELECT first_name, last_name, address
FROM staff
JOIN address ON staff.address_id = address.address_id;

-- 6b use JOIN to display total amount rung up by each staff member in august 2005
-- use staff and payment table
SELECT first_name, last_name, SUM(amount) AS Total
FROM staff
JOIN payment ON staff.staff_id = payment.staff_id
WHERE payment_date LIKE '%2005-08%'
GROUP BY staff.staff_id;

-- 6c list each film and number of actors listed for that film
-- use tables film_actor and film, inner join
SELECT title, COUNT(actor_id) AS Total_Actors
FROM film
JOIN film_actor ON film.film_id = film_actor.film_id
GROUP BY film.title;

-- 6d how many copies of the film hunchback impossible exist in the inventory system
SELECT COUNT(inventory_id) AS Num_Copies FROM inventory
WHERE film_id IN (
	SELECT film_id
	FROM film
	WHERE title = 'Hunchback Impossible'
);

-- 6e using tables payment and customer an join, list total paid by each customer, list customers
-- alphabetically by last name
SELECT first_name, last_name, SUM(amount) AS `Total Amount Paid`
FROM customer
JOIN payment ON customer.customer_id = payment.payment_id
GROUP BY customer.customer_id
ORDER By last_name;

-- 7a display titles of movies starting with letters K and Q whose langaguage is English
SELECT title from FILM
WHERE language_id IN (
	
    SELECT language_id FROM language
    WHERE name = "English"
    
)
AND title LIKE 'K%' OR title LIKE 'Q%';

-- 7b display all actors who appear in the film Alone Trip
SELECT first_name, last_name FROM actor
WHERE actor_id IN (
	SELECT actor_id FROM film_actor
    WHERE film_id IN (
		SELECT film_id FROM film
        WHERE title = "Alone Trip"
        )
	);

-- 7c get names and email addresses of all canadian customers using joins
SELECT first_name, last_name, email FROM customer
WHERE address_id IN (
	SELECT address_id
    FROM address
    JOIN city on address.city_id = city.city_id
    JOIN country on city.country_id = country.country_id
    WHERE country = "Canada"
    );

-- 7d identify all movies categorized as family films
SELECT title FROM film_list WHERE category = "family";

-- 7e display most frequently rented movies in descending order
SELECT title, COUNT(rental_id) AS Num_Rentals FROM rental
JOIN inventory ON rental.inventory_id = inventory.inventory_id
JOIN film ON inventory.film_id = film.film_id
GROUP By title
ORDER BY Num_Rentals DESC;

-- 7f display how much business, in dollars, each store brought in
SELECT store, total_sales FROM sales_by_store;

-- 7g display for each store: store ID, city, country
SELECT store_id, city, country
FROM store
JOIN address ON store.address_id = address.address_id
JOIN city ON address.city_id = city.city_id
JOIN country ON city.country_id = country.country_id;

-- 7h list top 5 generes in gross revenue in descending order
-- may need to use tables: category, film_category, inventory, payment, rental
SELECT name AS Category, SUM(amount) AS Gross_Revenue
FROM category
JOIN film_category ON category.category_id = film_category.category_id
JOIN inventory ON film_category.film_id = inventory.film_id
JOIN rental ON inventory.inventory_id = rental.inventory_id
JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY name
ORDER BY Gross_Revenue DESC limit 5;

-- 8a use 7h results to create a view (top_five_genres)
DROP VIEW IF EXISTS top_five_genres;

CREATE VIEW top_five_genres AS
SELECT name AS Category, SUM(amount) AS Gross_Revenue
FROM category
JOIN film_category ON category.category_id = film_category.category_id
JOIN inventory ON film_category.film_id = inventory.film_id
JOIN rental ON inventory.inventory_id = rental.inventory_id
JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY name
ORDER BY Gross_Revenue DESC limit 5;

-- 8b how would you display the view created in 8a
-- SHOW CREATE VIEW top_five_genres;
SELECT * FROM top_five_genres;

-- 8c delete the view top_five_generes
DROP VIEW top_five_genres;
