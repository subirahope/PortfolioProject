SELECT *
FROM amazonbooks

/*Separating the publisher, edition, and the publication date on the table*/
SELECT 
    CASE
        WHEN CHARINDEX('(', publisher) > 0 THEN LEFT(publisher, CHARINDEX('(', publisher) - 2)
        ELSE publisher
    END AS publisher_name,
    CASE
        WHEN CHARINDEX('(', publisher) > 0 THEN SUBSTRING(publisher, CHARINDEX('(', publisher) + 1, LEN(publisher) - CHARINDEX('(', publisher) - 1)
        ELSE ''
    END AS publication_date
FROM 
    amazonbooks;

ALTER TABLE amazonbooks
ADD publication_date date

UPDATE amazonbooks
SET publication_date = CASE
        WHEN CHARINDEX('(', publisher) > 0 THEN TRY_CONVERT(DATE, SUBSTRING(publisher, CHARINDEX('(', publisher) + 1, LEN(publisher) - CHARINDEX('(', publisher) - 1))
        ELSE NULL
    END;

-- Add a new column for the publisher
ALTER TABLE amazonbooks
ADD publisher_name NVARCHAR(255);

-- Update the values in the new column
UPDATE amazonbooks
SET publisher_name = CASE
        WHEN CHARINDEX('(', publisher) > 0 THEN LEFT(publisher, CHARINDEX('(', publisher) - 2)
        ELSE publisher
    END;

-- Remove the publication date from the publisher column
UPDATE amazonbooks
SET publisher = CASE
        WHEN CHARINDEX('(', publisher) > 0 THEN SUBSTRING(publisher, CHARINDEX('(', publisher) + 1, LEN(publisher) - CHARINDEX('(', publisher) - 1)
        ELSE publisher
    END;

/*removing the publisher column*/
ALTER TABLE amazonbooks
DROP COLUMN publisher

-- Add a new column for the edition
ALTER TABLE amazonbooks
ADD edition NVARCHAR(255);

-- Update the values in the new edition column
UPDATE amazonbooks
SET edition = CASE
        WHEN CHARINDEX(';', publisher_name) > 0 THEN SUBSTRING(publisher_name, CHARINDEX(';', publisher_name) + 1, LEN(publisher_name) - CHARINDEX(';', publisher_name))
        ELSE ''
    END
WHERE CHARINDEX(';', publisher_name) > 0;

-- Remove the edition from the publisher column
UPDATE amazonbooks
SET publisher_name = CASE
        WHEN CHARINDEX(';', publisher_name) > 0 THEN LEFT(publisher_name, CHARINDEX(';', publisher_name) - 1)
        ELSE publisher_name
    END
WHERE CHARINDEX(';', publisher_name) > 0;


/*Price Analysis*/
--distribution of book prices
SELECT title, price
FROM amazonbooks

SELECT MIN(price) AS min_price, MAX(price) AS max_price
FROM amazonbooks
--GROUP BY title


SELECT
  b.title,
  b.price,
  b.pages
FROM
  amazonbooks AS b
WHERE
  b.price = (SELECT MIN(price) FROM amazonbooks)
  OR b.price = (SELECT MAX(price) FROM amazonbooks);


SELECT
  b.title,
  b.price,
  b.pages
FROM
  amazonbooks AS b
WHERE
  b.price = (SELECT MIN(price) FROM amazonbooks)
  OR b.price = (SELECT MAX(price) FROM amazonbooks)
  OR b.pages = (SELECT MIN(pages) FROM amazonbooks)
  OR b.pages = (SELECT MAX(pages) FROM amazonbooks);

SELECT
  title,
  price,
  pages,
  price / pages AS cost_per_page
FROM
  amazonbooks
ORDER BY cost_per_page DESC

--determining the price and language comparison
SELECT title,language,price 
FROM amazonbooks
WHERE language <> 'English'
GROUP BY
  title,language,price;

SELECT language,MAX(price) AS highest_price
FROM
  amazonbooks
GROUP BY language
ORDER BY highest_price DESC

/*Review analysis*/
--relationship between the average review and the star ratings
SELECT AVG(avg_reviews) AS average_reviews, 
       AVG(star5) AS average_5_star,
       AVG(star4) AS average_4_star,
       AVG(star3) AS average_3_star,
       AVG(star2) AS average_2_star,
       AVG(star1) AS average_1_star
FROM amazonbooks;

--determining if the books with higher average reviews tend to have a higher % of a 5 star rating
SELECT title,AVG(avg_reviews) AS average_reviews,(SUM(star5) * 100) / (SUM(star1 + star2 + star3 + star4 + star5)) AS percentage_5_star
FROM amazonbooks
GROUP BY title
ORDER BY average_reviews DESC;

SELECT title,AVG(avg_reviews) AS average_reviews,(SUM(star5) * 100) / (SUM(star1 + star2 + star3 + star4 + star5)) AS percentage_5_star
FROM amazonbooks
GROUP BY title
HAVING (SUM(star5) * 100) / (SUM(star1 + star2 + star3 + star4 + star5)) IS NOT NULL
ORDER BY percentage_5_star--,average_reviews DESC;

--Language comparison
--comparing the popularity and average reviews of books written in different languages
SELECT language, COUNT(*) AS book_count, AVG(avg_reviews) AS average_reviews
FROM amazonbooks
GROUP BY language
ORDER BY book_count DESC

--Analyzing whether books written in a particular language receive higher ratings or have more reviews
SELECT language,
       AVG(avg_reviews) AS average_reviews,
       SUM(n_reviews) AS total_reviews
FROM amazonbooks
GROUP BY language
ORDER BY total_reviews DESC

--Identifying the most common languages in the dataset, exporing variations in attributes like price and number of pages
SELECT language,
       COUNT(*) AS book_count,
       AVG(price) AS average_price,
       MIN(price) AS min_price,
       MAX(price) AS max_price,
       AVG(pages) AS average_pages,
       MIN(pages) AS min_pages,
       MAX(pages) AS max_pages
FROM amazonbooks
GROUP BY language
ORDER BY book_count DESC;














