#!/bin/bash

<< comment
 this file is for if else statements
comment

echo "is your are is greater then 18?"

read -p "enter your age" age

if [[ $age -ge 18 ]];
then
	echo "you are adult"
elif [[ $age -le 12 ]];
then      
	echo "you are child right now"
else
        echo "you are teneager"
fi


