DROP TABLE IF EXISTS products;

CREATE TABLE products (
    Product_id INT,
    Product TEXT,
    Category TEXT,
    Sub_category TEXT,
    Brand TEXT,
    Sale_price NUMERIC,
    Market_price NUMERIC,
    Product_type TEXT,
    Product_rating NUMERIC(2,1),
    Description TEXT
);


-- Load Csv 
COPY products (Product_Id,Product,Category,Sub_category,Brand,Sale_price,Market_price,Product_type,Product_rating,Description)
FROM 'H:\DataAnalytics\BigBasket Sql Project\BigBasket Products.csv' 
CSV HEADER;

SELECT COUNT(*) FROM products
SELECT * FROM products LIMIT 5;

--Missing prices
SELECT * FROM products
WHERE sale_price IS NULL OR market_price IS NULL;

--Remove invalid ratings
DELETE FROM products
WHERE Product_rating < 0 OR Product_rating > 5;

--Discount column (Derived)
ALTER TABLE products ADD COLUMN Discount NUMERIC;

UPDATE products
SET Discount = Market_price - Sale_price;

--Category-wise product count
SELECT category, COUNT(*) 
FROM products
GROUP BY category;

--Average rating per category
SELECT Category, ROUND(AVG(Product_rating),2)
FROM products
GROUP BY Category;

--Brand-wise average sale price
SELECT Brand, ROUND(Avg(Sale_price),2)
FROM products
GROUP BY Brand
ORDER BY AVG(Sale_price)DESC;

--Discounted products
SELECT Product, Discount
FROM products
WHERE Discount > 0
ORDER BY Discount DESC;

--Top expensive products per category
SELECT *
FROM (
    SELECT Product, Category, Sale_price,
    RANK() OVER(PARTITION BY Category ORDER BY Sale_price DESC) rnk
    FROM products
) t
WHERE rnk <= 3;

 --Top 3 rated products per category
 SELECT *
FROM (
    SELECT Product, Category, Product_rating,
    RANK() OVER(PARTITION BY Category ORDER BY Product_rating DESC) rnk
    FROM products
) t
WHERE rnk <= 3;

--Products priced above category average
SELECT Product, Category, Sale_price
FROM products p
WHERE Sale_price >
    (SELECT AVG(sale_price)
     FROM products
     WHERE Category = p.Category);

--Price Segmentation (CASE WHEN)
SELECT Product,
CASE
    WHEN Sale_price < 100 THEN 'Low'
    WHEN Sale_price BETWEEN 100 AND 300 THEN 'Mid'
    ELSE 'Premium'
END AS price_segment
FROM products;

--Rating vs Discount Insight
SELECT
CASE
    WHEN Product_rating >= 4 THEN 'High Rated'
    ELSE 'Low Rated'
END AS rating_group,
ROUND(AVG(Discount),2) AS avg_discount
FROM products
GROUP BY rating_group;

--Category Profitability Proxy
SELECT Category,
ROUND(AVG(Sale_price),2) avg_price,
ROUND(AVG(Product_rating),2) avg_rating
FROM products
GROUP BY Category;

--PERFORMANCE OPTIMIZATION
CREATE INDEX idx_category ON products(Category);
CREATE INDEX idx_brand ON products(Brand);




