select * from walmart;

------------------ Business Problems ---------------------
-- Q.1) Find different payment methods and for each payment method find no. of transactions and no. of qty sold

select payment_method,  
count(*) as no_of_payments,
sum(quantity) as total_sold_qty
from walmart
group by payment_method

--Q.2) Indentify highest rated category in each branch, displaying the branch, category AVG rating
select * from
(
select
  branch,
  category,
  avg(rating) as avg_rating,
  rank () over(partition by branch, order by avg(rating) desc) as rank
from walmart
group by 1,2
)
where rank =1;

--Q3) Indentify the busiest day for each branch based on the no. of transactions 

select * from
(select branch,
to_char(to_date(date,'DD/MM/YY'),'day') as day,
count(*) as no_of_transactions,
rank() over(partition by branch order by count(*) desc ) as rank
from walmart
group by 1,2
)
where rank =1;

--Q4) Calculate the total quantity of items sold per payment method. list payment_method and total_qty

select payment_method, 
sum(quantity) as total_qty
from walmart
group by 1

--Q5) Determine the average, minimum, maximum rating of products of each city. list the city, avg_rating, min_rating, max_rating

select city,
avg(rating) as avg_rating,
min(rating) as min_rating,
max(rating) as max_rating
from walmart
group by 1

--Q6) calculate the total_profit for each category by considering total_profit as 
-- (unit_price * quantity * profit_margin). list category and total_profit, ordered from highest to lowest profit.

select distinct category,
sum(total* profit_margin) as total_profit
from walmart
group by 1
order by 1,2 desc

select distinct category from walmart

--Q7) Determine the most common payment method for each branch. Display branch and preferend_pay_method
with cte
as
(SELECT 
    branch, 
    payment_method, 
    COUNT(*) AS total_transaction, 
    RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank 
FROM walmart 
GROUP BY branch, payment_method)
select * from cte where rank =1

--Q8) categorize the sales into Morning, Afternoon and Evening. Find out each of the shift and no. of invoices

select branch,
case
 when extract (hour from(time::time)) < 12 then 'morning'
 when extract (hour from(time::time)) between 12 and 17 then 'afternoon'
 else 'evening'
end day_time,
count(*)
from walmart
group by 1,2

--Q9) Indentify 5 branches with highest degree ratio in revenu compared to last year (current yr : 2023)--IMP 

select *,
extract(year from to_date(date,'DD/MM/YY')) as formated_date
from walmart
----

WITH revenue_2022 AS ( 
    SELECT "branch", SUM(total) AS revenue 
    FROM walmart 
    WHERE EXTRACT(YEAR FROM TO_DATE("date", 'DD/MM/YY')) = 2022 
    GROUP BY "branch" 
), 
revenue_2023 AS ( 
    SELECT "branch", SUM(total) AS revenue 
    FROM walmart 
    WHERE EXTRACT(YEAR FROM TO_DATE("date", 'DD/MM/YY')) = 2023 
    GROUP BY "branch" 
) 
SELECT 
    ls.branch, 
    ls.revenue AS last_year_revenue, 
    cs.revenue AS current_year_revenue, 
    round((ls.revenue - cs.revenue)::numeric / ls.revenue::numeric * 100,2) AS revenue_decrease_percentage 
FROM revenue_2022 AS ls 
JOIN revenue_2023 AS cs ON ls.branch = cs.branch 
WHERE ls.revenue > cs.revenue
order by 4 desc 
limit 5
