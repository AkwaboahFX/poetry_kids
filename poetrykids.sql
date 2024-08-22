--- 1.a
SELECT g.name AS grade, 
	COUNT(a.name) AS num_of_poets
FROM author a
JOIN grade g
ON a.grade_id = g.id
GROUP BY grade
ORDER BY grade ASC;


--- 1.b
SELECT g.name AS grade, 
	gd.name AS gender_name, 
	COUNT(a.id) AS poet_count
FROM author AS a
JOIN gender AS gd ON a.gender_id = gd.id 
JOIN grade AS g ON a.grade_id = g.id
WHERE gd.name IN ('Male', 'Female')
GROUP BY g.name, gd.name
ORDER BY g.name, gd.name;


--- 2.a 
SELECT 
	SUM(CASE WHEN (text) LIKE '%Pizza%' OR (title) LIKE '%Pizza%' THEN 1 ELSE 0 END) AS pizza_count,
	SUM(CASE WHEN (text) LIKE '%Hamburger%' OR (title) LIKE '%Hamburger%' THEN 1 ELSE 0 END) AS ham_count,
	AVG(CASE WHEN (text) LIKE '%Pizza%' OR (title) LIKE '%Hamburger%' THEN LENGTH(text) + LENGTH(title) ELSE 0 END) AS avg_pizza_count,
	AVG(CASE WHEN (text) LIKE '%Pizza%' OR (title) LIKE '%Hamburger%' THEN LENGTH(text) + LENGTH(title) ELSE 0 END) AS avg_ham_count
FROM poem;


--- 3.a
SELECT e.name, 
	AVG(pe.intensity_percent) AS avg_intensity, 
	AVG(p.char_count) AS avg_char_count
FROM emotion AS e
JOIN poem_emotion AS pe ON e.id = pe.emotion_id
JOIN poem AS p ON pe.poem_id = p.id
GROUP BY e.name
ORDER BY avg_char_count DESC;


--- 3.b
WITH emotional_poem AS
(SELECT e.name AS emotion, 
	AVG(pe.intensity_percent) AS avg_intensity, 
	AVG(p.char_count) AS avg_char_count
FROM emotion AS e
JOIN poem_emotion AS pe ON e.id = pe.emotion_id
JOIN poem AS p ON pe.poem_id = p.id
GROUP BY e.name),
Angry_Poem AS
(SELECT 
	p.title, 
	p.text, 
	p.char_count, 
	pe.intensity_percent AS avg_angry_count
FROM poem AS p 
JOIN poem_emotion AS pe ON p.id = pe.poem_id
JOIN emotion e ON pe.emotion_id = e.id
JOIN emotional_poem AS ep ON e.name = ep.emotion
WHERE e.name = 'Anger'
ORDER BY pe.intensity_percent
LIMIT 5)
SELECT
    title,
    text,
    char_count,
    avg_angry_count,
    CASE
        WHEN char_count > avg_angry_count THEN 'Longer'
        WHEN char_count < avg_angry_count THEN 'Shorter'
        ELSE 'Equal'
    END AS length_comparison
FROM Angry_Poem;


--- 4
WITH TopJoyfulPoems AS 
(
SELECT
      p.title,
      pe.intensity_percent,
      gd.name AS gender,  
      g.name AS grade_name,
   	 ROW_NUMBER() OVER (PARTITION BY g.name ORDER BY pe.intensity_percent DESC) AS rn
FROM poem AS p
JOIN poem_emotion AS pe ON p.id = pe.poem_id
JOIN emotion AS e ON pe.emotion_id = e.id
JOIN author AS a ON p.author_id = a.id
JOIN grade AS g ON a.grade_id = g.id
JOIN gender AS gd ON gd.id = a.gender_id 
WHERE e.name = 'Joy'
)
SELECT
    grade_name,
    ROUND(AVG(intensity_percent), 2) AS avg_intensity,
    SUM(CASE WHEN gender = 'Male' THEN 1 ELSE 0 END) AS male_count,
    SUM(CASE WHEN gender = 'Female' THEN 1 ELSE 0 END) AS female_count
FROM TopJoyfulPoems
WHERE rn <= 5
GROUP BY grade_name;


--- 5
SELECT
    a.name AS poet_name,
    g.name AS grade,
    e.name AS emotion,
    COUNT(*) AS poem_count
FROM author AS a
JOIN poem AS p ON a.id = p.author_id
JOIN poem_emotion AS pe ON p.id = pe.poem_id
JOIN emotion AS e ON pe.emotion_id = e.id
JOIN grade AS g ON a.grade_id = g.id
WHERE
    LOWER(a.name) = 'robert'
GROUP BY
    a.name,
    g.name,
    e.name
ORDER BY
    g.name,
    poet_name,
    poem_count DESC;





























