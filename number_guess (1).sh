#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "Enter your username:"
read USERNAME_INPUT

USERNAME_QUERY=$($PSQL "SELECT username, games_played, best_game FROM players WHERE username='$USERNAME_INPUT'")

if [[ -z $USERNAME_QUERY ]]
then
  echo -e "Welcome, $USERNAME_INPUT! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO players(username) VALUES('$USERNAME_INPUT')")
else
  USERNAME=$(echo $USERNAME_QUERY | cut -d '|' -f 1)
  GAMES_PLAYED=$(echo $USERNAME_QUERY | cut -d '|' -f 2)
  BEST_GAME=$(echo $USERNAME_QUERY | cut -d '|' -f 3)
  echo -e "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$(( ( RANDOM % 1000 ) + 1 ))
GUESS_COUNT=0

echo -e "Guess the secret number between 1 and 1000:"
read GUESS

while [[ $GUESS != $SECRET_NUMBER ]]
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo -e "That is not an integer, guess again:"
  else
    GUESS_COUNT=$((GUESS_COUNT + 1))
    if [[ $GUESS -gt $SECRET_NUMBER ]]
    then
      echo -e "It's lower than that, guess again:"
    elif [[ $GUESS -lt $SECRET_NUMBER ]]
    then
      echo -e "It's higher than that, guess again:"
    fi
  fi

  read GUESS
done

GUESS_COUNT=$((GUESS_COUNT + 1))
echo -e "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"

UPDATE_RESULT=$($PSQL "UPDATE players SET games_played = games_played + 1, best_game = CASE WHEN best_game IS NULL OR best_game > $GUESS_COUNT THEN $GUESS_COUNT ELSE best_game END WHERE username='$USERNAME_INPUT'")
