-- Homework Assignment
use sakila;

-- 1a. Display the first and last names of all actors from the table actor.
select first_name, last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. 
--  Name the column Actor Name.
select (concat(upper(first_name),' ',upper(last_name))) as `Actor Name` from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the
--  first name, "Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name from actor where first_name = "JOE";

-- 2b. Find all actors whose last name contain the letters GEN:
select * from actor where last_name like "%GEN%";

-- 2c. Find all actors whose last names contain the letters LI. 
-- This time, order the rows by last name and first name, in that order:
select * from actor where last_name like "%LI%" order by last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: 
-- Afghanistan, Bangladesh, and China:
select country_id, country from country where country in ("AFGHANISTAN", "BANGLADESH", "CHINA");

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. 
-- Hint: you will need to specify the data type.
alter table actor add column Middle_Name VARCHAR(30) after first_name;

-- 3b. You realize that some of these actors have tremendously long last names. 
-- Change the data type of the middle_name column to blobs.
alter table actor modify column Middle_Name blob;

-- 3c. Now delete the middle_name column.
alter table actor drop column Middle_Name;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(*) from actor group by last_name;
 
-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
select last_name, count(*) from actor group by last_name having count(*) > 1 ;

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS,
--  the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
update actor set first_name ="HARPO" where first_name = "GROUCHO" and last_name =  "WILLIAMS";

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. 
-- It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO,
-- change it to GROUCHO. 
-- Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor 
-- will be with the grievous error. 
-- BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, 
-- HOWEVER! (Hint: update the record using a unique identifier.)
update actor set first_name = case 
   when first_name = "HARPO" then "GROUCHO"
   when first_name = "GROUCHO" then "MUCHO GROUCHO"
   else first_name
   end   where last_name = "WILLIAMS";

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
show create table address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
-- Use the tables staff and address:
select staff.first_name, staff.last_name, address.address from staff inner join address on staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select staff.first_name, staff.last_name, sum(payment.amount) from staff inner join payment on staff.staff_id = payment.staff_id
where payment.payment_date like '2005-08-%' group by staff.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. 
-- Use tables film_actor and film. Use inner join.
select film.title, count(film_actor.actor_id) `number of actors` from film inner join film_actor on film.film_id = film_actor.film_id
group by film.film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select film.title, count(*) `number of copies` from film inner join inventory on film.film_id = inventory.film_id
where film.title = "HUNCHBACK IMPOSSIBLE";

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer.
--  List the customers alphabetically by last name:
select customer.first_name, customer.last_name, sum(payment.amount) as `Total Amount Paid` from payment 
inner join customer on customer.customer_id = payment.customer_id 
group by customer.customer_id order by customer.last_name;  

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence.
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select film.title from film where 
  film.language_id = (select language.language_id from language where language.name = 'English') 
  and (title like 'Q%' or title like 'K%');
  
-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select A.first_name, A.last_name from actor A where
    A.actor_id in (select FA.actor_id from film_actor FA where
                              FA.film_id = (select F.film_id from film F where
                                          F.title = 'Alone Trip'));
-- 7b alternative using joins
select Actor_Name from actor 
    inner join film_actor on film_actor.actor_id = actor.actor_id
	inner join film on film.film_id = film_actor.film_id 
	where film.title = "Alone Trip";


-- 7c. You want to run an email marketing campaign in Canada, 
-- for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
select customer.first_name `First Name`, customer.last_name `Last Name`, customer.email from customer
    inner join address on customer.address_id = address.address_id
	inner join city on city.city_id = address.city_id
    inner join country on country.country_id = city.country_id
    where country.country = "CANADA";

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as famiy films.
select F.title, C.name from film F
    inner join film_category FC on F.film_id = FC.film_id
	inner join category C on C.category_id = FC.category_id
    where C.name = "FAMILY";

-- 7e. Display the most frequently rented movies in descending order.
select F.title, count(R.rental_id) `Times Rented` from rental R
	inner join inventory I on R.inventory_id = I.inventory_id 
    inner join film F on I.film_id = F.film_id
	group by F.title order by count(R.rental_id) desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select store.store_id, concat('$',format(sum(payment.amount),"currency","en_us")) as Dollars from payment  
	 inner join customer on customer.customer_id = payment.customer_id 
     inner join store on store.store_id = customer.store_id
     group by store.store_id;
	

-- 7g. Write a query to display for each store its store ID, city, and country.
select store.store_id, city.city, country.country from store 
     inner join address on store.address_id = address.address_id
     inner join city on city.city_id = address.city_id
     inner join country on city.country_id = country.country_id;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
    select category.name `Genre Category`, concat('$',format(sum(payment.amount),"currency","en_us")) as `Revenue` from category
     inner join film_category on category.category_id = film_category.category_id
	 inner join inventory on inventory.film_id = film_category.film_id 
	 inner join rental on rental.inventory_id = inventory.inventory_id
     inner join payment on payment.rental_id = rental.rental_id
	group by category.category_id
    order by sum(payment.amount) desc limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres
-- by gross revenue. Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.
create view top_5_genre_view as select category.name, sum(payment.amount) from category
     inner join film_category on category.category_id = film_category.category_id
	 inner join inventory on inventory.film_id = film_category.film_id 
	 inner join rental on rental.inventory_id = inventory.inventory_id
     inner join payment on payment.rental_id = rental.rental_id
	group by category.category_id
    order by sum(payment.amount) desc limit 5;

-- 8b. How would you display the view that you created in 8a?
select * from top_5_genre_view;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view top_5_genre_view;
