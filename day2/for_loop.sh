#!/bin/bash


<<comment
  this is for loop example shell file
comment


# create 10 directory


for (( num = 1; num <= 10; num++))
do 
	mkdir "demo$num"
done

echo "10 directory are created"
