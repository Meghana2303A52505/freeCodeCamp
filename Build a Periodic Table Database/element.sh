#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z "$1" ]]; then
  echo "Please provide an element as an argument."
  exit 0
fi

INPUT="$1"

# Find the element by atomic number, symbol, or name.
RESULT=$($PSQL "
  SELECT
    e.atomic_number,
    e.name,
    e.symbol,
    p.atomic_mass,
    t.type,
    p.melting_point_celsius,
    p.boiling_point_celsius
  FROM elements e
  JOIN properties p USING (atomic_number)
  JOIN types t USING (type_id)
  WHERE e.atomic_number::TEXT = '$INPUT'
     OR e.symbol = '$INPUT'
     OR e.name = '$INPUT';
")

if [[ -z "$RESULT" ]]; then
  echo "I could not find that element in the database."
  exit 0
fi

IFS='|' read -r ATOMIC_NUMBER NAME SYMBOL MASS TYPE MELTING BOILING <<< "$RESULT"

# Remove unnecessary trailing zeros from the atomic mass.
MASS=$(printf '%s\n' "$MASS" | sed -E 's/(\.[0-9]*[1-9])0+$/\1/; s/\.0+$//')

echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
