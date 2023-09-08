/*Q1. Write a query to display customer_id, customer full name with their title (Mr/Ms), 
 both first name and last name are in upper case, customer_email,  customer_creation_year 
 and display customer’s category after applying below categorization rules:
 i. if CUSTOMER_CREATION_DATE year <2005 then category A
 ii. if CUSTOMER_CREATION_DATE year >=2005 and <2011 then category B 
 iii. if CUSTOMER_CREATION_DATE year>= 2011 then category C
 Expected 52 rows in final output.
 [Note: TABLE to be used - ONLINE_CUSTOMER TABLE] 
Hint:Use CASE statement. create customer_creation_year column with the help of customer_creation_date,
 no permanent change in the table is required. (Here don’t UPDATE or DELETE the columns in the table nor CREATE new tables
 for your representation. A new column name can be used as an alias for your manipulation in case if you are going to use a CASE statement.) 
*/

SELECT CUSTOMER_ID,
       CASE
           WHEN CUSTOMER_GENDER = 'M' THEN
               'Mr'
           ELSE
               'Ms'
       END AS title,
       CONCAT(CUSTOMER_FNAME, ' ', CUSTOMER_LNAME) AS customer_full_name,
       UPPER(CUSTOMER_FNAME) AS first_name,
       UPPER(CUSTOMER_LNAME) AS last_name,
       CUSTOMER_EMAIL,
       YEAR(CUSTOMER_CREATION_DATE) AS customer_creation_year,
       CASE
           WHEN YEAR(CUSTOMER_CREATION_DATE) < 2005 THEN
               'Category A'
           WHEN YEAR(CUSTOMER_CREATION_DATE)
                BETWEEN 2005 AND 2011 THEN
               'Category B'
           WHEN YEAR(CUSTOMER_CREATION_DATE) >= 2011 THEN
               'Category C'
       END AS customer_category
FROM online_customer;

----------------------------------------------------------------------------------------------------------------------------------------

/* Q2. Write a query to display the following information for the products which
 have not been sold: product_id, product_desc, product_quantity_avail, product_price,
 inventory values (product_quantity_avail * product_price), New_Price after applying discount
 as per below criteria. Sort the output with respect to decreasing value of Inventory_Value. 
i) If Product Price > 20,000 then apply 20% discount 
ii) If Product Price > 10,000 then apply 15% discount 
iii) if Product Price =< 10,000 then apply 10% discount 
Expected 13 rows in final output.
[NOTE: TABLES to be used - PRODUCT, ORDER_ITEMS TABLE]
Hint: Use CASE statement, no permanent change in table required. 
(Here don’t UPDATE or DELETE the columns in the table nor CREATE new tables for your representation.
 A new column name can be used as an alias for your manipulation in case if you are going to use a CASE statement.)
*/

SELECT p.PRODUCT_ID,
       p.PRODUCT_DESC,
       p.PRODUCT_QUANTITY_AVAIL,
       p.PRODUCT_PRICE,
       p.PRODUCT_QUANTITY_AVAIL * PRODUCT_PRICE AS INVENTORY_VALUES,
       CASE
           WHEN PRODUCT_PRICE > 20000 THEN
               PRODUCT_PRICE * 20 / 100
           WHEN PRODUCT_PRICE > 10000 THEN
               PRODUCT_PRICE * 15 / 100
           WHEN PRODUCT_PRICE > 10000 THEN
               PRODUCT_PRICE * 10 / 100
       END AS NEW_PRICE
FROM product p
WHERE p.PRODUCT_ID NOT IN (
                              SELECT DISTINCT o.PRODUCT_ID FROM order_items o
                          )
ORDER BY 5 DESC;

----------------------------------------------------------------------------------------------------------------------------------------

/*Q3. Write a query to display Product_class_code, Product_class_desc, Count of Product type in each product class, 
Inventory Value (p.product_quantity_avail*p.product_price). Information should be displayed for only those
 product_class_code which have more than 1,00,000 Inventory Value. Sort the output with respect to decreasing value of Inventory_Value. 
Expected 9 rows in final output.
[NOTE: TABLES to be used - PRODUCT, PRODUCT_CLASS]
Hint: 'count of product type in each product class' is the count of product_id based on product_class_code.
*/

SELECT pc.PRODUCT_CLASS_CODE,
       pc.PRODUCT_CLASS_DESC,
       COUNT(p.PRODUCT_ID) AS PRODUCT_TYPE_COUNT,
       SUM(p.PRODUCT_QUANTITY_AVAIL * p.PRODUCT_PRICE) AS INVENTORY_VALUE
FROM product_class pc
    JOIN product p
        ON pc.PRODUCT_CLASS_CODE = p.PRODUCT_CLASS_CODE
GROUP BY 1,
         2
HAVING INVENTORY_VALUE > 100000
ORDER BY 4 DESC;

----------------------------------------------------------------------------------------------------------------------------------------

/* Q4. Write a query to display customer_id, full name, customer_email, customer_phone and
 country of customers who have cancelled all the orders placed by them.
Expected 1 row in the final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ADDRESSS, OREDER_HEADER]
Hint: USE SUBQUERY
*/

SELECT OC.customer_id,
       CONCAT(OC.CUSTOMER_FNAME, ' ', OC.CUSTOMER_LNAME) AS full_name,
       OC.CUSTOMER_EMAIL,
       OC.CUSTOMER_PHONE,
       A.COUNTRY
FROM ONLINE_CUSTOMER OC
    JOIN ADDRESS A
        ON OC.address_id = A.address_id
WHERE OC.customer_id IN (
                            SELECT customer_id
                            FROM ORDER_HEADER
                            GROUP BY customer_id
                            HAVING COUNT(DISTINCT order_status) = 1
                                   AND MAX(order_status) = 'Cancelled'
                        );

----------------------------------------------------------------------------------------------------------------------------------------

/*Q5. Write a query to display Shipper name, City to which it is catering, num of customer catered by the shipper in the city ,
 number of consignment delivered to that city for Shipper DHL 
Expected 9 rows in the final output
[NOTE: TABLES to be used - SHIPPER, ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]
Hint: The answer should only be based on Shipper_Name -- DHL. The main intent is to find the number
 of customers and the consignments catered by DHL in each city.
 */

SELECT s.SHIPPER_NAME,
       a.CITY,
       COUNT(oh.CUSTOMER_ID) AS CUSTOMER_CATERED_COUNT, /* both customer_id and address_id can be used here as the customer_id and order_id are unique to every customer */
       COUNT(oh.ORDER_ID) AS CONSINMENT_DELIVERED_COUNT
FROM online_customer oc
    JOIN address a
        ON oc.ADDRESS_ID = a.ADDRESS_ID
    JOIN order_header oh
        ON oc.customer_id = oh.CUSTOMER_ID
    JOIN shipper s
        ON oh.SHIPPER_ID = s.SHIPPER_ID
WHERE SHIPPER_NAME = 'DHL'
GROUP BY 1,
         2;

----------------------------------------------------------------------------------------------------------------------------------------

/*Q6. Write a query to display product_id, product_desc, product_quantity_avail, quantity sold and 
show inventory Status of products as per below condition: 

a. For Electronics and Computer categories, 
if sales till date is Zero then show  'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 10% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 50% of quantity sold, show 'Medium inventory, need to add some inventory',
if inventory quantity is more or equal to 50% of quantity sold, show 'Sufficient inventory' 

b. For Mobiles and Watches categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 20% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 60% of quantity sold, show 'Medium inventory, need to add some inventory', 
if inventory quantity is more or equal to 60% of quantity sold, show 'Sufficient inventory' 

c. Rest of the categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 30% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 70% of quantity sold, show 'Medium inventory, need to add some inventory',
if inventory quantity is more or equal to 70% of quantity sold, show 'Sufficient inventory'
Expected 60 rows in final output
[NOTE: (USE CASE statement) ; TABLES to be used - PRODUCT, PRODUCT_CLASS, ORDER_ITEMS]
Hint:  quantity sold here is product_quantity in order_items table. 
You may use multiple case statements to show inventory status (Low stock, In stock, and Enough stock)
 that meets both the conditions i.e. on products as well as on quantity.
The meaning of the rest of the categories, means products apart from electronics, computers, mobiles, and watches.
*/


SELECT P.PRODUCT_ID,
       P.PRODUCT_DESC,
       P.PRODUCT_QUANTITY_AVAIL,
       SUM(OI.PRODUCT_QUANTITY) AS quantity_sold,
       CASE
           WHEN P.PRODUCT_CLASS_CODE IN ( 'Electronics', 'Computer' ) THEN
               CASE
                   WHEN SUM(OI.product_quantity) = 0 THEN
                       'No Sales in past, give discount to reduce inventory'
                   WHEN P.product_quantity_avail < 0.1 * SUM(OI.product_quantity) THEN
                       'Low inventory, need to add inventory'
                   WHEN P.product_quantity_avail < 0.5 * SUM(OI.product_quantity) THEN
                       'Medium inventory, need to add some inventory'
                   ELSE
                       'Sufficient inventory'
               END
           WHEN P.PRODUCT_CLASS_CODE IN ( 'Mobiles', 'Watches' ) THEN
               CASE
                   WHEN SUM(OI.product_quantity) = 0 THEN
                       'No Sales in past, give discount to reduce inventory'
                   WHEN P.product_quantity_avail < 0.2 * SUM(OI.product_quantity) THEN
                       'Low inventory, need to add inventory'
                   WHEN P.product_quantity_avail < 0.6 * SUM(OI.product_quantity) THEN
                       'Medium inventory, need to add some inventory'
                   ELSE
                       'Sufficient inventory'
               END
           ELSE
               CASE
                   WHEN SUM(OI.product_quantity) = 0 THEN
                       'No Sales in past, give discount to reduce inventory'
                   WHEN P.product_quantity_avail < 0.3 * SUM(OI.product_quantity) THEN
                       'Low inventory, need to add inventory'
                   WHEN P.product_quantity_avail < 0.7 * SUM(OI.product_quantity) THEN
                       'Medium inventory, need to add some inventory'
                   ELSE
                       'Sufficient inventory'
               END
       END AS inventory_status
FROM PRODUCT P
    JOIN PRODUCT_CLASS PC
        ON P.PRODUCT_CLASS_CODE = PC.PRODUCT_CLASS_CODE
    LEFT JOIN ORDER_ITEMS OI
        ON OI.product_id = P.product_id
GROUP BY 1,
         2,
         3,
         P.PRODUCT_CLASS_CODE;


----------------------------------------------------------------------------------------------------------------------------------------


/* Q7. Write a query to display order_id and volume of the biggest order (in terms of volume) that can fit in carton id 10 .
Expected 1 row in final output
[NOTE: TABLES to be used - CARTON, ORDER_ITEMS, PRODUCT]
Hint: First find the volume of carton id 10 and then find the order id with products having total volume less than the volume of carton id 10
 */

SELECT 
    oi.ORDER_ID,
    SUM(oi.PRODUCT_QUANTITY * (p.LEN * p.WIDTH * p.HEIGHT)) AS BIGGEST_ORDER_VOLUME
FROM
    order_items oi
        JOIN
    product p ON oi.PRODUCT_ID = p.PRODUCT_ID
GROUP BY 1
HAVING SUM(oi.PRODUCT_QUANTITY * (p.LEN * p.WIDTH * p.HEIGHT)) <= (SELECT 
        (c.LEN * c.WIDTH * c.HEIGHT) AS CARTON_VOLUME
    FROM
        carton c
    WHERE
        c.CARTON_ID = 10)
ORDER BY 2 DESC
LIMIT 1

----------------------------------------------------------------------------------------------------------------------------------------

/*Q8. Write a query to display customer id, customer full name, total quantity and total value (quantity*price) 
shipped where mode of payment is Cash and customer last name starts with 'G'
Expected 2 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER]
*/

SELECT
    oc.CUSTOMER_ID,
    CONCAT(oc.CUSTOMER_FNAME, ' ', oc.CUSTOMER_LNAME) AS customer_full_name,
    SUM(oi.PRODUCT_QUANTITY)                          AS total_quantity,
    SUM(oi.PRODUCT_QUANTITY * p.PRODUCT_PRICE)        AS total_value_shipped
FROM
    online_customer  oc
    JOIN
        order_header oh
            ON oc.CUSTOMER_ID = oh.CUSTOMER_ID
    JOIN
        order_items  oi
            ON oh.ORDER_ID = oi.ORDER_ID
    JOIN
        product      p
            ON oi.PRODUCT_ID = p.PRODUCT_ID
WHERE
    oh.PAYMENT_MODE = 'cash'
    AND oc.CUSTOMER_LNAME LIKE 'G%'
GROUP BY
    1,
    2;

----------------------------------------------------------------------------------------------------------------------------------------

/*Q9. Write a query to display product_id, product_desc and total quantity of products which are sold together 
with product id 201 and are not shipped to city Bangalore and New Delhi. 
[NOTE: TABLES to be used - ORDER_ITEMS, PRODUCT, ORDER_HEADER, ONLINE_CUSTOMER, ADDRESS]
Hint: Display the output in descending order with respect to the sum of product_quantity. 
(USE SUB-QUERY) In final output show only those products , 
 product_id’s which are sold with 201 product_id (201 should not be there in output) and are shipped except Bangalore and New Delhi
 */

SELECT 
    P.product_id,
    P.product_desc,
    SUM(OI.product_quantity) AS total_quantity
FROM
    ORDER_ITEMS OI
        JOIN
    PRODUCT P ON OI.product_id = P.product_id
        JOIN
    ORDER_HEADER OH ON OI.order_id = OH.order_id
        JOIN
    ONLINE_CUSTOMER OC ON OH.customer_id = OC.customer_id
        JOIN
    ADDRESS A ON OC.address_id = A.address_id
WHERE
    OI.order_id IN (SELECT 
            order_id
        FROM
            ORDER_ITEMS
        WHERE
            product_id = 201)
        AND A.city NOT IN ('Bangalore' , 'New Delhi')
        AND p.PRODUCT_ID != 201
        AND oh.ORDER_STATUS = 'Shipped'
GROUP BY 1 , 
		 2
ORDER BY 3 DESC;

----------------------------------------------------------------------------------------------------------------------------------------

/* Q10. Write a query to display the order_id, customer_id and customer fullname, 
total quantity of products shipped for order ids which are even and shipped to address where pincode is not starting with "5" 
Expected 15 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_HEADER, ORDER_ITEMS, ADDRESS]	
 */

SELECT 
    oi.order_id,
    OC.customer_id,
    CONCAT(oc.CUSTOMER_FNAME,
            ' ',
            oc.CUSTOMER_LNAME) AS customer_full_name,
    SUM(oi.PRODUCT_QUANTITY) AS products_shipped_quantity
FROM
    order_header oh
        JOIN
    order_items oi ON oh.order_id = oi.ORDER_ID
        JOIN
    online_customer oc ON oh.CUSTOMER_ID = oc.CUSTOMER_ID
        JOIN
    address a ON oc.ADDRESS_ID = a.ADDRESS_ID
WHERE
    oi.ORDER_ID % 2 = 0
        AND oi.order_id IN (SELECT 
            oi.order_id
        FROM
            order_items oi
        GROUP BY 1
        HAVING COUNT(oi.order_id) > 1)
        AND a.PINCODE NOT LIKE '5%'
GROUP BY 1, 
		 2, 
		 3;

