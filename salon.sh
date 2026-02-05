#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

MAIN_MENU() {
    if [[ $1 ]]
    then
        echo -e "\n$1"
    fi

    echo -e "\n~~~~~ MY SALON ~~~~~\n"
    echo -e "Welcome to My Salon, how can I help you?\n"
    
    # Get services
    SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
    
    # Display services
    echo "$SERVICES" | while IFS="|" read SERVICE_ID NAME
    do
        echo "$SERVICE_ID) $NAME"
    done

    read SERVICE_ID_SELECTED
    
    # Check if service exists
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    
    if [[ -z $SERVICE_NAME ]]
    then
        MAIN_MENU "I could not find that service. What would you like today?"
    else
        # Get customer phone
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE
        
        # Check if customer exists
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        
        # If customer doesn't exist
        if [[ -z $CUSTOMER_NAME ]]
        then
            # Get customer name
            echo -e "\nI don't have a record for that phone number, what's your name?"
            read CUSTOMER_NAME
            
            # Insert new customer
            INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
        fi
        
        # Get service time
        echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
        read SERVICE_TIME
        
        # Get customer_id
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        
        # Insert appointment
        INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
        
        # Output confirmation
        echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
}

MAIN_MENU