CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  parent_reply_id INTEGER,
  user_id INTEGER NOT NULL,
  body TEXT NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_reply_id) REFERENCES replies(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
  users(fname, lname)
VALUES
  ('Kartik', 'Parihar'),
  ('Ryan', 'Meyer'),
  ('Nick', 'Brown Beard');

INSERT INTO
  questions(title, body, user_id)
VALUES
  ('SQL?', 'What does sql stand for?', (SELECT id FROM users WHERE fname = 'Nick')),
  ('SQLite3?', 'What is SQLite3?', (SELECT id FROM users WHERE fname = 'Ryan')),
  ('PostgreSQL', 'What is PostgreSQL?', (SELECT id FROM users WHERE fname = 'Kartik'));

INSERT INTO
  question_follows(user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Nick'), (SELECT id FROM questions WHERE title = 'PostgreSQL')),
  ((SELECT id FROM users WHERE fname = 'Ryan'), (SELECT id FROM questions WHERE title = 'SQL?')),
  ((SELECT id FROM users WHERE fname = 'Kartik'), (SELECT id FROM questions WHERE title = 'SQLite3?')),
  ((SELECT id FROM users WHERE fname = 'Kartik'), (SELECT id FROM questions WHERE title = 'PostgreSQL')),
  ((SELECT id FROM users WHERE fname = 'Ryan'), (SELECT id FROM questions WHERE title = 'PostgreSQL')),
  ((SELECT id FROM users WHERE fname = 'Nick'), (SELECT id FROM questions WHERE title = 'SQL?'));

INSERT INTO
  replies(question_id, parent_reply_id, user_id, body)
VALUES
  (1, NULL, 1, 'body'),
  (2, NULL, 2, 'head'),
  (1, 1, 3, 'shoulders');

INSERT INTO
  question_likes(user_id, question_id)
VALUES
  (1,2),
  (2,3),
  (2,2),
  (3,2),
  (3,3),
  (3,1);
