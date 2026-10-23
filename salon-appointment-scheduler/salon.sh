#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo "Welcome to My Salon, how can I help you?"

# Display available services
echo "$($PSQL "SELECT service_id || ') ' || name FROM services ORDER BY service_id")"

# Ask the customer to select a service
while true
do
    read SERVICE_ID_SELECTED

    # Check whether the selected service exists
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

    if [[ -n $SERVICE_NAME ]]
    then
        break
    else
        echo -e "\nI could not find that service. What would you like today?"
        echo "$($PSQL "SELECT service_id || ') ' || name FROM services ORDER BY service_id")"
    fi
done

# Ask for the customer's phone number
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

# Check whether the customer already exists
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

if [[ -z $CUSTOMER_ID ]]
then
    # New customer: ask for their name and save their details
    echo -e "\nWhat's your name?"
    read CUSTOMER_NAME

    $PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')"

    # Retrieve the new customer's ID
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
else
    # Existing customer: retrieve their name
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
fi

# Ask for the appointment time
echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

# Save the appointment
$PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')"

# Confirm the appointment
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
