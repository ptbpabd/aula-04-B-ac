/*
Questão 1. 
Gere uma lista de todos os instrutores, mostrando sua ID, nome e número de seções que eles ministraram. 
Não se esqueça de mostrar o número de seções como 0 para os instrutores que não ministraram qualquer seção. 
Sua consulta deverá utilizar outer join e não deverá utilizar subconsultas escalares.
*/

SELECT instructor.ID, instructor.name, count(teaches.sec_id) as "Number of sections"
FROM instructor left outer join teaches ON instructor.ID = teaches.ID 
GROUP BY instructor.ID, instructor.name 
ORDER BY instructor.ID, instructor.name;

/*
Questão 2. 
Escreva a mesma consulta do item anterior, mas usando uma subconsulta escalar, sem outer join.
 */

SELECT ID, name,
(SELECT count(*) AS "Number of sections"
FROM teaches T WHERE T.id = I.id) AS "Number of sections"
FROM instructor I

/*
Questão 3. 
Gere a lista de todas as seções de curso oferecidas na primavera de 2010, junto com o nome dos instrutores ministrando a seção. 
Se uma seção tiver mais de 1 instrutor, ela deverá aparecer uma vez no resultado para cada instrutor. 
Se não tiver instrutor algum, ela ainda deverá aparecer no resultado, com o nome do instrutor definido como “-”. 
 */

SELECT course_id, sec_id, i.ID, semester, [year], IIF(name IS NULL, '-', name) AS name FROM
-- left outer join de section com teaches: section_teaches
(SELECT s.course_id, s.sec_id, s.semester, s.[year], t.ID
FROM (
section s 
LEFT OUTER JOIN 
teaches t 
ON s.course_id = t.course_id AND s.sec_id  = t.sec_id AND s.semester = t.semester AND s.[year] = t.[year])) section_teaches
-- left outer join de section_teaches com instructor
LEFT OUTER JOIN instructor i ON i.ID = section_teaches.ID WHERE semester = 'Spring' AND year = 2010


/*
Questão 4. 
Suponha que você tenha recebido uma relação grade_points (grade, points), que oferece uma conversão de conceitos (letras) na relação takes para notas numéricas; por exemplo, uma nota “A+” poderia ser especificada para corresponder a 4 pontos, um “A” para 3,7 pontos, e “A-” para 3,4, e “B+” para 3,1 pontos, e assim por diante. 
Os Pontos totais obtidos por um aluno para uma oferta de curso (section) são definidos como o número de créditos para o curso multiplicado pelos pontos numéricos para a nota que o aluno recebeu.
Dada essa relação e o nosso esquema university, escreva: 
Ache os pontos totais recebidos por aluno, para todos os cursos realizados por ele.
 */

CREATE VIEW grade_points AS (SELECT grade, 
IIF(grade = 'A+', 4.0, 
IIF(grade = 'A ', 3.7, 
IIF(grade = 'A-', 3.3, 
IIF(grade = 'B+', 3.0, 
IIF(grade = 'B ', 2.7, 
IIF(grade = 'B-', 2.3, 
IIF(grade = 'C+', 2.0, 
IIF(grade = 'C ', 1.7, 
IIF(grade = 'C-', 1.3, 0))))))))) as points
FROM takes
group by grade);

SELECT * FROM grade_points;

SELECT t.ID, s2.name, c.title, c.dept_name, t.grade, points, credits, (credits * points) AS 'Pontos totais'
FROM (((takes t JOIN [section] s ON t.course_id = s.course_id AND 
                                  t.sec_id  = s.sec_id AND 
                                  t.semester = s.semester AND 
                                  t.[year]  = s.[year]) 
JOIN course c ON t.course_id = c.course_id) 
JOIN grade_points g ON t.grade = g.grade) JOIN student s2 ON s2.ID = t.ID AND s2.dept_name = c.dept_name 
order by t.ID, s2.name, c.title;

/*
Questão 5. Crie uma view a partir do resultado da Questão 4 com o nome “Coeficiente de rendimento”.
*/ 
CREATE VIEW coeficiente_rendimento AS (SELECT t.ID, s2.name, c.title, c.dept_name, t.grade, points, credits, (credits * points) AS 'Pontos totais'
FROM (((takes t JOIN [section] s ON t.course_id = s.course_id AND 
                                  t.sec_id  = s.sec_id AND 
                                  t.semester = s.semester AND 
                                  t.[year]  = s.[year]) 
JOIN course c ON t.course_id = c.course_id) 
JOIN grade_points g ON t.grade = g.grade) JOIN student s2 ON s2.ID = t.ID AND s2.dept_name = c.dept_name);

SELECT * FROM coeficiente_rendimento order by ID, name, title;




