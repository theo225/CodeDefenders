DROP TABLE IF EXISTS `ratings`;
CREATE TABLE ratings
(
  User_ID INT DEFAULT -1 NOT NULL,
  Game_ID INT DEFAULT -1 NOT NULL,
  type    VARCHAR (128),
  value INT DEFAULT 0 NOT NULL,
  CONSTRAINT fk_ratings_userID_users FOREIGN KEY (User_ID) REFERENCES users (User_ID)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fk_ratings_gameID_games FOREIGN KEY (Game_ID) REFERENCES games (ID)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT game_user_type_unique UNIQUE (User_ID, Game_ID, type)
);