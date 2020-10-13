a.

Number of new customers every month :

SELECT 
    strftime('%Y', period_start_date)|| '-' ||strftime('%m', period_start_date) As Year_Month, count(id) As Count_Active_Customers
FROM 
    subscription_histories
WHERE
    status = 'ACTIVE'
GROUP BY
    strftime('%Y', period_start_date),strftime('%m', period_start_date)
	
===============================================================================
Churn rate ( No of customer cancelled in current month/Total of number
active customers in previous month)

SELECT 
    main.YM AS Year_Month,round((((main.Can*100.0)/main.Ac)),2) AS Churn_Rate
FROM   
(SELECT
   cast(strftime('%Y', period_start_date) ||strftime('%m', period_start_date) as integer)  AS YM,
   (select count(*) from subscription_histories sh1 where sh1.period_start_date<sh.period_start_date AND sh1.status = 'ACTIVE') AS 'Ac',
   count(*) AS 'Can'
FROM 
    subscription_histories sh
where
    sh.status = 'CANCELLED'
GROUP BY
    strftime('%Y', period_start_date),strftime('%m', period_start_date) )main

==============================================================================
No of Upgrades and Upgrade value in every month (revenue amount
increase in a month compared to the same subscription in previous
month)

SELECT 
    main.YM Year_Month, main.subscription_id Subscription, count(*) Upgrades,(sum(main.Am) - sum(misc.Am)) Upgrade_Amount
FROM
(
SELECT
   strftime('%Y', period_start_date)||strftime('%m', period_start_date) YM,
   strftime('%Y', date(period_start_date,'-1 month'))||strftime('%m', date(period_start_date,'-1 month')) YM_1,
   subscription_id,sum(amount) Am
FROM 
    subscription_histories sh
where
    sh.status = 'ACTIVE'
GROUP BY
    strftime('%Y', period_start_date),strftime('%m', period_start_date),subscription_id
)main   

INNER JOIN
(SELECT
   strftime('%Y', date(period_start_date,'-1 month'))||strftime('%m', date(period_start_date,'-1 month')) YM_P,
   subscription_id,sum(amount) Am
FROM 
    subscription_histories sh
where
    sh.status = 'ACTIVE'
GROUP BY
    strftime('%Y', date(period_start_date,'-1 month')),strftime('%m', date(period_start_date,'-1 month')),subscription_id
)misc
ON main.YM_1 = misc.YM_P and main.subscription_id=main.subscription_id
WHERE 
    main.Am > misc.Am
GROUP BY
    main.YM,main.subscription_id

=========================================================================================

b
(i)
SELECT
    strftime('%Y', date(substr(invoice_date,1,11))) || strftime('%m', date(substr(invoice_date,1,11))) YM,
    SUM(CASE WHEN status = 'POSTED' THEN total ELSE 0 END) Invoice_Raise_Amount_Before_Month_End,
    SUM(CASE WHEN status = 'PAID' THEN total ELSE 0 END) Payments_Done_Amount_Before_Month_End, 
    SUM(CASE WHEN status = 'PAID' THEN 1 ELSE 0 END) Payments_Done_Count_Before_Month_End, 
    SUM(CASE WHEN status = 'POSTED' THEN 1 ELSE 0 END) Invoices_Raise_Count_Before_Month_End
FROM
    invoices i
WHERE
    date(substr(invoice_date,1,11)) != date(date(substr(invoice_date,1,11)),'start of month','+1 month','-1 day')
GROUP BY
    strftime('%Y', date(substr(invoice_date,1,11))), strftime('%m', date(substr(invoice_date,1,11)))



(ii)
SELECT 
    main.Year_Month, round(((IFNULL(Voided,0))*100.0/Paid),2) Invoice_Voided_Perecentage
FROM
(select 
    strftime('%Y', paid_at_date) || strftime('%m', paid_at_date) Year_Month,
    count(i.invoice_id) Paid
from 
    invoices i
WHERE
    i.status = 'PAID'
GROUP BY
    strftime('%Y', paid_at_date), strftime('%m', paid_at_date)) main
    
LEFT JOIN

(select 
    strftime('%Y', voided_at_date) || strftime('%m', voided_at_date) Year_Month,
    count(i.invoice_id) Voided
from 
    invoices i
WHERE
    i.status = 'VOIDED'
GROUP BY
    strftime('%Y', voided_at_date), strftime('%m', voided_at_date)) misc

ON main.Year_Month = misc.Year_Month

    



(iii)

select 
    strftime('%Y', paid_at_date)||strftime('%m', paid_at_date) Year_Month,plan AS PLan, count(i.invoice_id) Invoice_Paid
from 
    invoices i
    INNER JOIN subscription_plan sp ON i.subscription_id = sp.subscription_id
WHERE
    i.status = 'PAID'
GROUP BY
    strftime('%Y', paid_at_date), strftime('%m', paid_at_date),plan
    
    







