SELECT *
FROM [amazondsb].[dbo].[final_book_dataset_kaggle2$]


  -- 1. Average Price of Books
SELECT ROUND (AVG(CAST(price AS FLOAT)), 2) AS average_price
FROM [amazondsb].[dbo].[final_book_dataset_kaggle2$];

-- 2. Highest Rated Authors
SELECT author, AVG(CAST(avg_reviews AS FLOAT)) AS avg_review_rating
FROM [amazondsb].[dbo].[final_book_dataset_kaggle2$]
WHERE author IS NOT NULL
GROUP BY author
ORDER BY avg_review_rating DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

-- 3. Most Common Publishers
SELECT publisher, COUNT(*) AS count
FROM [amazondsb].[dbo].[final_book_dataset_kaggle2$]
GROUP BY publisher
ORDER BY count DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

-- 4. Correlation Between Number of Pages and Average Review Rating
-- (Extracting relevant data for further analysis)
SELECT pages, avg_reviews
FROM [amazondsb].[dbo].[final_book_dataset_kaggle2$]
WHERE pages IS NOT NULL AND avg_reviews IS NOT NULL;

-- 5. Compare New and Used Book Prices
-- First, ensure new_price and used_price columns are created and populated
-- Add new_price and used_price columns if they do not exist
IF NOT EXISTS (SELECT * FROM sys.columns 
               WHERE object_id = OBJECT_ID('[amazondsb].[dbo].[final_book_dataset_kaggle2$]') 
               AND name = 'new_price')
BEGIN
    ALTER TABLE [amazondsb].[dbo].[final_book_dataset_kaggle2$]
    ADD new_price FLOAT;
END;

IF NOT EXISTS (SELECT * FROM sys.columns 
               WHERE object_id = OBJECT_ID('[amazondsb].[dbo].[final_book_dataset_kaggle2$]') 
               AND name = 'used_price')
BEGIN
    ALTER TABLE [amazondsb].[dbo].[final_book_dataset_kaggle2$]
    ADD used_price FLOAT;
END;

-- Update the table to set new_price and used_price based on the price (including used books) column
UPDATE [amazondsb].[dbo].[final_book_dataset_kaggle2$]
SET new_price = TRY_CAST(SUBSTRING(CAST([price (including used books)] AS NVARCHAR(MAX)), 1, CHARINDEX('-', CAST([price (including used books)] AS NVARCHAR(MAX))) - 1) AS FLOAT),
    used_price = TRY_CAST(SUBSTRING(CAST([price (including used books)] AS NVARCHAR(MAX)), CHARINDEX('-', CAST([price (including used books)] AS NVARCHAR(MAX))) + 1, LEN(CAST([price (including used books)] AS NVARCHAR(MAX))) - CHARINDEX('-', CAST([price (including used books)] AS NVARCHAR(MAX)))) AS FLOAT)
WHERE CHARINDEX('-', CAST([price (including used books)] AS NVARCHAR(MAX))) > 0;

-- For rows where there is no '-' in the price (including used books) column, set both new_price and used_price to the same value
UPDATE [amazondsb].[dbo].[final_book_dataset_kaggle2$]
SET new_price = TRY_CAST([price (including used books)] AS FLOAT),
    used_price = TRY_CAST([price (including used books)] AS FLOAT)
WHERE CHARINDEX('-', CAST([price (including used books)] AS NVARCHAR(MAX))) = 0;

-- Select the average of new_price and used_price
SELECT AVG(new_price) AS average_new_price, AVG(used_price) AS average_used_price
FROM [amazondsb].[dbo].[final_book_dataset_kaggle2$];

-- 6. Top 10 Highest-Rated Books
SELECT title, author, avg_reviews
FROM [amazondsb].[dbo].[final_book_dataset_kaggle2$]
ORDER BY CAST(avg_reviews AS FLOAT) DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

-- 7. Distribution of Book Lengths (in Pages)
SELECT pages
FROM [amazondsb].[dbo].[final_book_dataset_kaggle2$]
WHERE pages IS NOT NULL;

-- 8. Distribution of Books by Language
SELECT language, COUNT(*) AS count
FROM [amazondsb].[dbo].[final_book_dataset_kaggle2$]
GROUP BY language
ORDER BY count DESC;

-- 9. Books with the Highest Number of Reviews
SELECT title, author, n_reviews
FROM [amazondsb].[dbo].[final_book_dataset_kaggle2$]
ORDER BY TRY_CAST(REPLACE(n_reviews, ',', '') AS INT) DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

-- 10. Highest-Rated Books' Price Ranges
SELECT title, author, price, [price (including used books)], avg_reviews
FROM [amazondsb].[dbo].[final_book_dataset_kaggle2$]
WHERE avg_reviews = '5.0';
