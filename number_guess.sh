#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\nEnter your username:"
read user
user_id=$($PSQL "SELECT user_id FROM users WHERE name='$user';")

# check if the user is already in the database
if [[ $user_id ]]
then
    # if it's there calculate the number of games they've played and their best game
    num_games=$($PSQL "SELECT COUNT(game_id) FROM games WHERE user_id = $user_id;")
    best_game=$($PSQL "SELECT MIN(num_guess) FROM games WHERE user_id = $user_id;")
    echo "Welcome back, $user! You have played $num_games games, and your best game took $best_game guesses."
else
    echo "Welcome, $user! It looks like this is your first time here."
    # insert the customer
    insert_user=$($PSQL "INSERT INTO users(name) VALUES('$user') RETURNING user_id;")
    user_id=$($PSQL "SELECT user_id FROM users WHERE name='$user';")
fi

# Play the game
# Generate a random number between 1 and 1000
secret_number=$((RANDOM % 1000 + 1))
num_guess=0
while true; do
    echo -e "\nGuess the secret number between 1 and 1000: "
    read guess
    # Check if the input is an integer
    if ! [[ $guess =~ ^[0-9]+$ ]]; then
        echo "That is not an integer, guess again:"
        continue
    fi
    ((num_guess++))

    if [[ $guess -eq $secret_number ]]; then
        echo "You guessed it in $num_guess tries. The secret number was $secret_number. Nice job!"
        # Insert the game into the games table
        insert_game=$($PSQL "INSERT INTO games(user_id, num_guess) VALUES($user_id, $num_guess);")
        break
    elif [[ $guess -gt $secret_number ]]; then
        echo "It's lower than that, guess again:"
    else
        echo "It's higher than that, guess again:"
    fi
done
