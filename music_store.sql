-- ----- After uploading tables into MySQL, ALTER TABLE
 
SELECT * FROM invoice;
-- 1. Ensure primary keys exist

ALTER TABLE artist
ADD PRIMARY KEY (artist_id);

ALTER TABLE album2
ADD PRIMARY KEY (album_id);

ALTER TABLE employee
ADD PRIMARY KEY (employee_id);

ALTER TABLE customer
ADD PRIMARY KEY (customer_id);

ALTER TABLE genre
ADD PRIMARY KEY (genre_id);

ALTER TABLE media_type
ADD PRIMARY KEY (media_type_id);

ALTER TABLE track
ADD PRIMARY KEY (track_id);

ALTER TABLE invoice
ADD PRIMARY KEY (invoice_id);

ALTER TABLE invoice_line
ADD PRIMARY KEY (invoice_line_id);

ALTER TABLE playlist
ADD PRIMARY KEY (playlist_id);

-- For playlist_track, composite PK
ALTER TABLE playlist_track
ADD PRIMARY KEY (playlist_id, track_id);


-- 2. Add foreign key constraints

ALTER TABLE album2
ADD CONSTRAINT fk_album_artist
FOREIGN KEY (artist_id) REFERENCES artist(artist_id);

ALTER TABLE employee
ADD CONSTRAINT fk_employee_reports_to
FOREIGN KEY (reports_to) REFERENCES employee(employee_id);

ALTER TABLE customer
ADD CONSTRAINT fk_customer_support_rep
FOREIGN KEY (support_rep_id) REFERENCES employee(employee_id);

ALTER TABLE track
ADD CONSTRAINT fk_track_album
FOREIGN KEY (album_id) REFERENCES album2(album_id);

ALTER TABLE track
ADD CONSTRAINT fk_track_media_type
FOREIGN KEY (media_type_id) REFERENCES media_type(media_type_id);

ALTER TABLE track
ADD CONSTRAINT fk_track_genre
FOREIGN KEY (genre_id) REFERENCES genre(genre_id);

ALTER TABLE invoice
ADD CONSTRAINT fk_invoice_customer
FOREIGN KEY (customer_id) REFERENCES customer(customer_id);

ALTER TABLE invoice_line
ADD CONSTRAINT fk_invoice_line_invoice
FOREIGN KEY (invoice_id) REFERENCES invoice(invoice_id);

ALTER TABLE invoice_line
ADD CONSTRAINT fk_invoice_line_track

FOREIGN KEY (track_id) REFERENCES track(track_id);

ALTER TABLE playlist_track
ADD CONSTRAINT fk_playlist_track_playlist
FOREIGN KEY (playlist_id) REFERENCES playlist(playlist_id);

ALTER TABLE playlist_track
ADD CONSTRAINT fk_playlist_track_track
FOREIGN KEY (track_id) REFERENCES track(track_id);

-- ------------------ Analysis 
-- Revenue by genre
-- Identify which genres are most profitable.
SELECT genre.name, COUNT(genre.name) AS Popularity
FROM invoice_line
INNER JOIN track 
	ON invoice_line.track_id = track.track_id
INNER JOIN genre
	ON track.genre_id = genre.genre_id
GROUP BY genre.name
ORDER BY popularity DESC;

-- Churn Analysis 
-- Calculate monthly frequency

CREATE VIEW ann_frequency AS
with ann_count AS (
	SELECT
		customer_id,
		YEAR(invoice_date) AS invoice_year,
		COUNT(*) AS yearly_frequency
	FROM invoice
	GROUP BY
		customer_id,
		invoice_year
	ORDER BY
		customer_id,
		invoice_year
) SELECT
	customer_id, 
    invoice_year,
    yearly_frequency,
    ROUND(LAG(yearly_frequency, 1, 0) OVER (
		PARTITION BY customer_id
        ORDER BY  invoice_year) , 2
	) AS percentage_change
FROM ann_count;

SELECT *
FROM ann_frequency
WHERE percentage_change <= 0;

-- Total spent by each customers over time (CLV)
--  For each customers, who are their top 3 artists?
WITH customer_artist_totals AS (
    SELECT
        customer.customer_id,
        customer.first_name,
        customer.last_name,
        artist.artist_id,
        artist.name AS artist_name,
        ROUND(SUM(invoice_line.unit_price * invoice_line.quantity), 2) AS total_spent
    FROM invoice_line
    JOIN invoice ON invoice_line.invoice_id = invoice.invoice_id
    JOIN customer ON invoice.customer_id = customer.customer_id
    JOIN track ON invoice_line.track_id = track.track_id
    JOIN album2 ON track.album_id = album2.album_id
    JOIN artist ON album2.artist_id = artist.artist_id
    GROUP BY customer.customer_id, artist.artist_id, customer.first_name, customer.last_name, artist.name
)
SELECT *
FROM (
    SELECT
        customer_id,
        first_name,
        last_name,
        artist_id,
        artist_name,
        total_spent,
        RANK() OVER (
            PARTITION BY customer_id
            ORDER BY total_spent DESC, artist_name ASC
        ) AS rank_per_customer
    FROM customer_artist_totals
) AS ranked
WHERE rank_per_customer <= 3
ORDER BY customer_id, rank_per_customer;

-- monthly revenue
WITH monthly_trend AS (
	SELECT 
		MONTH(invoice_date) as invoice_month,
		YEAR(invoice_date) as invoice_year,
		ROUND(SUM(total), 2) AS monthly_revenue
	FROM invoice
	GROUP BY invoice_year, invoice_month
) SELECT 
	invoice_month,
    invoice_year,
    monthly_revenue,
	ROUND(
		monthly_revenue / LAG(monthly_revenue, 1, 0) OVER (ORDER BY invoice_year, invoice_month) * 100,
        2
	) AS previous_month_revenue
FROM monthly_trend;

-- Customers who only buy one genre
-- Identifying "genre-loyal" customers for personalised marketing and upselling. 
WITH compare_genre AS (
    SELECT 
        invoice_line.invoice_line_id, 
        invoice_line.invoice_id, 
        invoice_line.track_id,
        invoice.customer_id,
        invoice.invoice_date,
        track.genre_id,
        LAG(track.genre_id) OVER (
            PARTITION BY invoice.customer_id
            ORDER BY invoice.invoice_date, invoice_line.invoice_line_id
        ) AS last_sale_genre
    FROM invoice_line
    LEFT JOIN invoice
        ON invoice_line.invoice_id = invoice.invoice_id
    LEFT JOIN track
        ON invoice_line.track_id = track.track_id
)
SELECT
    invoice.customer_id,
    SUM(CASE WHEN compare_genre.genre_id = compare_genre.last_sale_genre THEN 1 ELSE 0 END) AS repeated_genre_count
FROM compare_genre
GROUP BY invoice.customer_id
HAVING repeated_genre_count = 0;

