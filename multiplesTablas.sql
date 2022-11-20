-- DESAFIO MULTIPLES TABLAS 

-- 1. Crea y agrega al entregable las consultas para completar el setup de acuerdo a lo
-- pedido. (1 Punto)

CREATE DATABASE desafio_oscar_acevedo_609;

\c desafio_oscar_acevedo_609

CREATE TABLE users(
  id SERIAL,
  email VARCHAR(50) NOT NULL,
  name VARCHAR NOT NULL,
  last_name VARCHAR NOT NULL,
  rol VARCHAR
);

INSERT INTO users(email, name, last_name, rol) VALUES 
('juan@mail.com', 'Juan', 'Gonzalez', 'administrador'),
('super@mail.com', 'Seba', 'Roman', 'usuario'),
('oscar@mail.com', 'Oscar', 'Acevedo', 'usuario'),
('vale@mail.com','Valeria', 'Cortes', 'usuario'),
('yare@mail.com', 'Yarenla', 'Cordero', 'usuario');

CREATE TABLE posts(
  id SERIAL,
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  outstanding BOOLEAN NOT NULL DEFAULT FALSE,
  user_id BIGINT
);

INSERT INTO posts (title, content, created_at, updated_at, outstanding, user_id)
VALUES ('prueba', 'contenido prueba', '01/01/2021', '01/02/2021', true, 1),
('prueba2', 'contenido prueba2', '01/03/2021', '01/03/2021', true, 1),
('ejercicios', 'contenido ejercicios', '02/05/2021', '03/04/2021', true, 2),
('ejercicios2', 'contenido ejercicios2', '03/05/2021', '04/04/2021', false, 2),
('random', 'contenido random', '03/06/2021', '04/05/2021', false, null);

CREATE TABLE comments(
  id SERIAL,
  content TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  user_id BIGINT,
  post_id BIGINT
);

INSERT INTO comments (content, created_at, user_id,
post_id) VALUES 
('comentario 1', '03/06/2021', 1, 1),
('comentario 2', '03/06/2021', 2, 1),
('comentario 3', '04/06/2021', 3, 1),
('comentario 4', '04/06/2021', 1, 2);

-- 2. Cruza los datos de la tabla usuarios y posts mostrando las siguientes columnas.
-- nombre e email del usuario junto al título y contenido del post. (1 Punto)

SELECT users.name, users.email, posts.title, posts.content FROM users INNER JOIN posts ON users.id = posts.user_id;
  name |     email      |    title    |        content
  ------+----------------+-------------+-----------------------
  Juan | juan@mail.com  | prueba2     | contenido prueba2
  Juan | juan@mail.com  | prueba      | contenido prueba
  Seba | super@mail.com | ejercicios2 | contenido ejercicios2
  Seba | super@mail.com | ejercicios  | contenido ejercicios


-- 3. Muestra el id, título y contenido de los posts de los administradores. El
-- administrador puede ser cualquier id y debe ser seleccionado dinámicamente.
-- (1 Punto).

SELECT posts.id, posts.title, posts, content FROM posts INNER JOIN users ON posts.user_id = users.id WHERE users.rol = 'administrador';
  id |  title  |                                      posts                                      |      content
  ----+---------+---------------------------------------------------------------------------------+-------------------
    1 | prueba  | (1,prueba,"contenido prueba","2021-01-01 00:00:00","2021-02-01 00:00:00",t,1)   | contenido prueba
    2 | prueba2 | (2,prueba2,"contenido prueba2","2021-03-01 00:00:00","2021-03-01 00:00:00",t,1) | contenido prueba2

-- 4. Cuenta la cantidad de posts de cada usuario. La tabla resultante debe mostrar el id
-- e email del usuario junto con la cantidad de posts de cada usuario. (1 Punto)
-- Hint importante: Aquí hay diferencia entre utilizar inner join, left join o right join,
-- prueba con todas y con eso determina cual es la correcta. No da lo mismo desde
-- cual tabla partes.

SELECT COUNT(posts), users.id, users.id, users.email FROM posts RIGHT JOIN users ON posts.user_id = users.id GROUP BY users.id, users.email ORDER BY users.id ASC;
  count | id | id |     email
  -------+----+----+----------------
      2 |  1 |  1 | juan@mail.com
      2 |  2 |  2 | super@mail.com
      0 |  3 |  3 | oscar@mail.com
      0 |  4 |  4 | vale@mail.com
      0 |  5 |  5 | yare@mail.com

-- 5. Muestra el email del usuario que ha creado más posts. Aquí la tabla resultante tiene
-- un único registro y muestra solo el email. (1 Punto)

SELECT users.email FROM posts JOIN users ON posts.user_id = users.id GROUP BY users.id, users.email ORDER BY COUNT(posts.id) DESC LIMIT 1;

      email
  ---------------
  juan@mail.com

-- 6. Muestra la fecha del último post de cada usuario. (1 Punto)
-- Hint: Utiliza la función de agregado MAX sobre la fecha de creación.

SELECT users.name, MAX(posts.created_at) FROM users INNER JOIN posts ON users.id = posts.user_id GROUP BY users.name;
  name |         max
  ------+---------------------
  Seba | 2021-05-03 00:00:00
  Juan | 2021-03-01 00:00:00

-- 7. Muestra el título y contenido del post (artículo) con más comentarios. (1 Punto)

SELECT posts.title, posts.content, COUNT(*) FROM posts INNER JOIN comments 
ON posts.id = comments.post_id GROUP BY posts.title, posts.content ORDER BY COUNT(*) DESC LIMIT 1;
  title  |     content      | count
  --------+------------------+-------
  prueba | contenido prueba |     3

-- 8. Muestra en una tabla el título de cada post, el contenido de cada post y el contenido
-- de cada comentario asociado a los posts mostrados, junto con el email del usuario
-- que lo escribió. (1 Punto)

SELECT posts.title AS Title_post, posts.content AS content_post, comments.content AS content_comments, users.email
FROM posts LEFT JOIN comments ON posts.id = comments.post_id LEFT JOIN users ON comments.user_id = users.id;
  title_post  |     content_post      | content_comments |     email
  -------------+-----------------------+------------------+----------------
  prueba      | contenido prueba      | comentario 1     | juan@mail.com
  prueba      | contenido prueba      | comentario 2     | super@mail.com
  prueba      | contenido prueba      | comentario 3     | oscar@mail.com
  prueba2     | contenido prueba2     | comentario 4     | juan@mail.com
  random      | contenido random      |                  |
  ejercicios2 | contenido ejercicios2 |                  |
  ejercicios  | contenido ejercicios  |                  |

-- 9. Muestra el contenido del último comentario de cada usuario. (1 Punto)

SELECT comments.user_id, comments.content FROM comments
INNER JOIN (SELECT max(comments.id) AS last_id FROM comments GROUP BY user_id) AS dt_last_reg
ON comments.id = dt_last_reg.last_id ORDER BY comments.user_id;
  user_id |   content
  ---------+--------------
        1 | comentario 4
        2 | comentario 2
        3 | comentario 3

-- 10. Muestra los emails de los usuarios que no han escrito ningún comentario. (1 Punto)
-- Hint: Recuerda el Having

SELECT users.email FROM users LEFT JOIN comments ON users.id = comments.user_id WHERE comments.content IS NULL;
      email
  ---------------
  yare@mail.com
  vale@mail.com

-- Opción 2
SELECT users.email FROM users LEFT JOIN comments ON users.id = comments.user_id GROUP BY users.email, comments.content HAVING comments.content IS NULL;
      email
  ---------------
  vale@mail.com
  yare@mail.com