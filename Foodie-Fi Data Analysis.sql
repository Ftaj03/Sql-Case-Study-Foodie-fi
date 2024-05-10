 # Question 1 How many customers has Foodie-Fi ever had?
SELECT
    COUNT(DISTINCT customer_id) AS total_customers
FROM subscriptions;

# Question 2 What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
SELECT
    YEAR(start_date) AS year_,
    MONTH(start_date) AS m_,
    MONTHNAME(start_date) AS month_,
    COUNT(plan_name) AS trial_plans
FROM plans p
    LEFT JOIN subscriptions s
        ON p.plan_id = s.plan_id
WHERE plan_name = "trial"
GROUP BY 1,2,3
ORDER BY 1,2;

# Question 3: What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
SELECT
        p.plan_name,
        COUNT(s.customer_id)
    FROM plans p
        LEFT JOIN subscriptions s
            ON p.plan_id = s.plan_id
    WHERE start_date > "2020-12-31"
    GROUP BY 1;
    
# question 4: What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
    SELECT
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(CASE WHEN plan_id = 4 THEN 1 ELSE NULL END) AS churned_customers,
    ROUND(COUNT(CASE WHEN plan_id = 4 THEN 1 ELSE NULL END) /
        COUNT(DISTINCT customer_id) * 100,1) AS pct_churn
FROM subscriptions;

#Question 5:How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

SELECT -- 3 count the number of total customers, and the churned customers (plan_id = 4)
    COUNT(customer_id) AS total_customers,
    COUNT(CASE WHEN plan_id = 4 THEN 1 ELSE NULL END) AS church_after_trial,
    CEILING(COUNT(CASE WHEN plan_id = 4 THEN 1 ELSE NULL END) / COUNT(customer_id) * 100) AS pct_of_church_after_trial
FROM
(
SELECT -- 2 we join the list(1) with the subscriptions table so that we can see their status
    a.customer_id,
    a.after_1_week,
    s.plan_id
FROM
(
SELECT -- 1 generate a list with all customers after 1 week 
    customer_id AS customer_id,
    DATE_ADD(MIN(start_date), INTERVAL 7 DAY) AS after_1_week
FROM subscriptions s
    LEFT JOIN plans p
        ON s.plan_id = s.plan_id
GROUP BY 1
ORDER BY 1
) AS a
    LEFT JOIN subscriptions s
        ON a.customer_id = s.customer_id AND
            a.after_1_week = s.start_date) AS b;
            
# Question 6: What is the number and percentage of customer plans after their initial free trial?
SELECT
    COUNT(CASE WHEN plan_id = 1 THEN 1 ELSE NULL END) AS basic_monthly,
    ROUND((COUNT(CASE WHEN plan_id = 1 THEN 1 ELSE NULL END) / COUNT(customer_id)) * 100,2) AS pct_basic_monthly,
    COUNT(CASE WHEN plan_id = 2 THEN 1 ELSE NULL END) AS pro_monthly,
    ROUND((COUNT(CASE WHEN plan_id = 2 THEN 1 ELSE NULL END) / COUNT(customer_id)) * 100,2) AS pct_pro_monthly,
    COUNT(CASE WHEN plan_id = 3 THEN 1 ELSE NULL END) AS pro_annual,
    ROUND((COUNT(CASE WHEN plan_id = 3 THEN 1 ELSE NULL END) / COUNT(customer_id)) * 100,2) AS pct_pro_annual,
    COUNT(CASE WHEN plan_id = 4 THEN 1 ELSE NULL END) AS churn,
    ROUND((COUNT(CASE WHEN plan_id = 4 THEN 1 ELSE NULL END) / COUNT(customer_id)) * 100,2) AS pct_churn
FROM
(
SELECT
    a.customer_id,
    a.after_1_week,
    s.plan_id
FROM
(
SELECT
    customer_id AS customer_id,
    DATE_ADD(MIN(start_date), INTERVAL 7 DAY) AS after_1_week
FROM subscriptions s
    LEFT JOIN plans p
        ON s.plan_id = s.plan_id
GROUP BY 1
ORDER BY 1
) AS a
    LEFT JOIN subscriptions s
        ON a.customer_id = s.customer_id AND
            a.after_1_week = s.start_date) AS b; 

# Question 7:What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
SELECT
    COUNT(CASE WHEN plan_id = 0 THEN 1 ELSE NULL END) AS trial,
    ROUND((COUNT(CASE WHEN plan_id = 0 THEN 1 ELSE NULL END) / COUNT(customer_id)) * 100,2) AS pct_trial,
    COUNT(CASE WHEN plan_id = 1 THEN 1 ELSE NULL END) AS basic_monthly,
    ROUND((COUNT(CASE WHEN plan_id = 1 THEN 1 ELSE NULL END) / COUNT(customer_id)) * 100,2) AS pct_basic_monthly,
    COUNT(CASE WHEN plan_id = 2 THEN 1 ELSE NULL END) AS pro_monthly,
    ROUND((COUNT(CASE WHEN plan_id = 2 THEN 1 ELSE NULL END) / COUNT(customer_id)) * 100,2) AS pct_pro_monthly,
    COUNT(CASE WHEN plan_id = 3 THEN 1 ELSE NULL END) AS pro_annual,
    ROUND((COUNT(CASE WHEN plan_id = 3 THEN 1 ELSE NULL END) / COUNT(customer_id)) * 100,2) AS pct_pro_annual,
    COUNT(CASE WHEN plan_id = 4 THEN 1 ELSE NULL END) AS churn,
    ROUND((COUNT(CASE WHEN plan_id = 4 THEN 1 ELSE NULL END) / COUNT(customer_id)) * 100,2) AS pct_churn
FROM(
 
SELECT -- 2 we join the list(1) with the subscriptions table so that we can see their status
    a.customer_id,
    a.after_1_week,
    s.plan_id
FROM (
SELECT -- 1 generate a list with all customers after 1 week and before the 2020-12-31
    customer_id AS customer_id,
    MAX(start_date) AS after_1_week
FROM subscriptions s
    LEFT JOIN plans p
        ON s.plan_id = s.plan_id
WHERE start_date < "2020-12-31"
GROUP BY 1
ORDER BY 1)
AS a
    LEFT JOIN subscriptions s
        ON a.customer_id = s.customer_id AND
            a.after_1_week = s.start_date) AS b;
            
# Question 8 How many customers have upgraded to an annual plan in 2020?

SELECT
    COUNT(plan_id) AS total_pro_annual_2020
FROM subscriptions
WHERE plan_id = 3
    AND start_date <= "2020-12-31";
    
# Question 9: How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
   
   WITH trial_users AS (
SELECT
    s.customer_id,
    s.plan_id,
    s.start_date,
    p.plan_name
FROM subscriptions s
    LEFT JOIN plans p
        ON s.plan_id = p.plan_id
WHERE plan_name = "trial"
ORDER BY 1),
pro_users AS (
SELECT
    customer_id,
    plan_id,
    start_date,
    plan_name
FROM (
SELECT
    s.customer_id,
    s.plan_id,
    s.start_date,
    p.plan_name
FROM subscriptions s
    LEFT JOIN plans p
        ON s.plan_id = p.plan_id
ORDER BY 1) AS a
WHERE plan_name = "pro annual"
)
SELECT
    CEILING(AVG(days_to_became_pro)) AS average_days_to_pro
FROM (
    SELECT
        pu.customer_id,
        DATEDIFF(pu.start_date, tu.start_date) AS days_to_became_pro
    FROM pro_users pu
        LEFT JOIN trial_users tu
            ON pu.customer_id = tu.customer_id) AS f; 

# Question 10: Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

WITH trial_plan AS 
  (SELECT 
    customer_id, 
    start_date AS trial_date
  FROM foodie_fi.subscriptions
  WHERE plan_id = 0
),
-- Filter results to customers at pro annual plan = 3
annual_plan AS
  (SELECT 
    customer_id, 
    start_date AS annual_date
  FROM foodie_fi.subscriptions
  WHERE plan_id = 3
),
-- Sort values above in buckets of 12 with range of 30 days each
bins AS 
  (SELECT 
    WIDTH_BUCKET(ap.annual_date - tp.trial_date, 0, 360, 12) AS     avg_days_to_upgrade
  FROM trial_plan tp
  JOIN annual_plan ap
    ON tp.customer_id = ap.customer_id)
  
SELECT 
  ((avg_days_to_upgrade - 1) * 30 || ' - ' ||   (avg_days_to_upgrade) * 30) || ' days' AS breakdown, 
  COUNT(*) AS customers
FROM bins
GROUP BY avg_days_to_upgrade
ORDER BY avg_days_to_upgrade; 

# Question 11: How many customers downgraded from a pro monthly to a basic monthly plan in 2020? 

WITH next_plan_cte AS (
  SELECT 
    customer_id, 
    plan_id, 
    start_date,
    LEAD(plan_id, 1) OVER(
      PARTITION BY customer_id 
      ORDER BY plan_id) as next_plan
  FROM foodie_fi.subscriptions)

SELECT 
  COUNT(*) AS downgraded
FROM next_plan_cte
WHERE start_date <= '2020-12-31'
  AND plan_id = 2 
  AND next_plan = 1;