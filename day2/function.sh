#!/bin/bash

is_loyal() {
  echo "$1, jalal is loyal"    # adjust message as you want

  # using arithmetic (( ... )) with <= and variables without $
  if (( $2 <= 100 )); then
    echo "love percentage is less than or equal to 100, not loyal"
  else
    echo "loyal"
  fi
}

is_loyal jetha 90
