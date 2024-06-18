#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=guessing_game -t --no-align -c"

echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."

  NEW_USER_RESULT=$($PSQL "INSERT INTO users (username) VALUES ('$USERNAME');")
else
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUM=$(($RANDOM % 1000 + 1))

NUM_GUESSES=1

echo "Guess the secret number between 1 and 1000:"
read USER_GUESS
while [[ $USER_GUESS != $SECRET_NUM ]]
do
  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    NUM_GUESSES=$((NUM_GUESSES + 1))

    if [[ $USER_GUESS > $SECRET_NUM ]]
    then
      echo "It's lower than that, guess again:"
    elif [[ $USER_GUESS < $SECRET_NUM ]]
    then
      echo "It's higher than that, guess again:"
    fi
  fi
  read USER_GUESS
done

if [[ -z $BEST_GAME || $NUM_GUESSES < $BEST_GAME ]]
then
  UPDATE_BEST_RESULT=$($PSQL "UPDATE users SET best_game=$NUM_GUESSES WHERE username='$USERNAME';")
fi

UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=games_played + 1 WHERE username='$USERNAME';")

echo "You guessed it in $NUM_GUESSES tries. The secret number was $SECRET_NUM. Nice job!"