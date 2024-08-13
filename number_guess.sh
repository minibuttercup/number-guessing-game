#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess --tuples-only -c"

echo "Enter your username:"
read USERNAME

# Check if user exists
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
if [[ -z $USER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
else
  USER_DATA=$($PSQL "SELECT COUNT(*), MIN(guesses) FROM games WHERE user_id=$USER_ID")
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
GUESSES=0
echo "Guess the secret number between 1 and 1000:"

while read GUESS
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi
  
  GUESSES=$((GUESSES + 1))

  if [[ $GUESS -eq $SECRET_NUMBER ]]
  then
    echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $GUESSES)")
    BEST_GAME_UPDATE=$($PSQL "UPDATE games SET best_game=TRUE WHERE user_id=$USER_ID AND guesses=$GUESSES")
    break
  elif [[ $GUESS -lt $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  else
    echo "It's lower than that, guess again:"
  fi
done
