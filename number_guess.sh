#!/bin/bash

# Variabili globali
username=""
games_played=0
best_game=0
secret_number=0
current_guesses=0
PSQL="psql --username=freecodecamp --dbname=number_guessing_game --no-align --tuples-only -c"

# Carica dati utente dal file
init_database() {
    
    # Crea tabella utenti se non esiste
    $PSQL "
        CREATE TABLE IF NOT EXISTS users (
            username VARCHAR(22) PRIMARY KEY,
            games_played INTEGER DEFAULT 0,
            best_game INTEGER DEFAULT 0
        );
    " > /dev/null
}

# Carica dati utente dal database
load_user_data() {
    local result
    result=$($PSQL "SELECT games_played, best_game FROM users WHERE username = '$username';")
    
    if [[ -z "$result" ]]; then
        games_played=0
        best_game=0
    else
        games_played=$(echo "$result" | cut -d'|' -f1)
        best_game=$(echo "$result" | cut -d'|' -f2)
    fi
}

# Salva dati utente nel database
save_user_data() {
    # Verifica se l'utente esiste già
    local exists
    exists=$($PSQL "SELECT username FROM users WHERE username = '$username';")
    
    if [[ -z "$exists" ]]; then
        # Inserisce nuovo utente
        $PSQL "INSERT INTO users(username, games_played, best_game) VALUES ('$username', $games_played, $best_game);" > /dev/null
    else
        # Aggiorna utente esistente
        $PSQL "UPDATE users SET games_played = $games_played, best_game = $best_game WHERE username = '$username';" > /dev/null
    fi
}


# Stampa messaggio di benvenuto appropriato
print_welcome_message() {
    if [[ "$games_played" -eq 0 ]]; then
        echo "Welcome, $username! It looks like this is your first time here."
    else
        echo "Welcome back, $username! You have played $games_played games, and your best game took $best_game guesses."
    fi
}

# Genera numero segreto casuale tra 1 e 1000
generate_secret_number() {
    secret_number=$((RANDOM % 1000 + 1))
}

# Verifica se l'input è un numero intero valido
is_integer() {
    [[ "$1" =~ ^[0-9]+$ ]]
}

# Loop principale del gioco
play_game() {
    current_guesses=0
    local guess=0
    
    echo "Guess the secret number between 1 and 1000:"
    
    while true; do
        read -r guess
        
        # Valida che l'input sia un intero
        if ! is_integer "$guess"; then
            echo "That is not an integer, guess again:"
            continue
        fi
        
        current_guesses=$((current_guesses + 1))
        
        # Confronta il tentativo con il numero segreto
        if [[ "$guess" -eq "$secret_number" ]]; then
            break
        elif [[ "$guess" -gt "$secret_number" ]]; then
            echo "It's lower than that, guess again:"
        else
            echo "It's higher than that, guess again:"
        fi
    done
    
    echo "You guessed it in $current_guesses tries. The secret number was $secret_number. Nice job!"
}

# Aggiorna le statistiche del giocatore
update_stats() {
    games_played=$((games_played + 1))
    
    # Aggiorna il miglior punteggio se necessario
    if [[ "$best_game" -eq 0 ]] || [[ "$current_guesses" -lt "$best_game" ]]; then
        best_game="$current_guesses"
    fi
}

# Funzione principale
main() {
    init_database
    
    # Richiedi username
    echo "Enter your username:"
    read -r username
    
    # Validazione lunghezza username (max 22 caratteri)
    if [[ ${#username} -gt 22 ]]; then
        echo "Error: Username must be 22 characters or less."
        exit 1
    fi
    
    # Carica i dati dell'utente
    load_user_data
    
    # Mostra messaggio di benvenuto
    print_welcome_message
    
    # Inizia il gioco
    generate_secret_number
    play_game
    
    # Aggiorna e salva le statistiche
    update_stats
    save_user_data
}

# Avvia il programma
main