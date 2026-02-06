#!/bin/bash
if [ $# -eq 0 ]; then
    echo "Please provide an element as an argument."
    exit 0
fi
input=$1
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"
result=$($PSQL "SELECT 
                    e.atomic_number,
                    e.name,
                    e.symbol,
                    t.type,
                    p.atomic_mass,
                    p.melting_point_celsius,
                    p.boiling_point_celsius
                FROM elements e
                JOIN properties p ON e.atomic_number = p.atomic_number
                JOIN types t ON p.type_id = t.type_id
                WHERE 
                    e.atomic_number::text = '$input' OR
                    LOWER(e.symbol) = LOWER('$input') OR
                    LOWER(e.name) = LOWER('$input')
                LIMIT 1;")
if [ -z "$result" ]; then
    echo "I could not find that element in the database."
    exit 0
fi
IFS='|' read -r atomic_number name symbol type atomic_mass melting_point_celsius boiling_point_celsius <<< "$result"
echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point_celsius celsius and a boiling point of $boiling_point_celsius celsius."