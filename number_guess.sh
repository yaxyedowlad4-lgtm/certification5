#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

if [[ -z $USER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  USER_ID=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME') RETURNING user_id")
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id=$USER_ID")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
SECRET_NUMBER=$((1 + RANDOM % 1000))
GUESS_COUNT=0
read GUESS

while [[ $GUESS != $SECRET_NUMBER ]]
do
  ((GUESS_COUNT++))

  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  elif [[ $GUESS -lt $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  fi

  read GUESS
done

((GUESS_COUNT++))

echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"

GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id=$USER_ID")
GAMES_PLAYED=$((GAMES_PLAYED + 1))

$PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE user_id=$USER_ID" > /dev/null

BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id=$USER_ID")

if [[ -z $BEST_GAME || $GUESS_COUNT -lt $BEST_GAME ]]
then
  $PSQL "UPDATE users SET best_game=$GUESS_COUNT WHERE user_id=$USER_ID" > /dev/null
fi
