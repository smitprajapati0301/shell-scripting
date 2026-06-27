#!/bin/bash

#basic code for usinf if then for error handling

#this code will work for first time without any error, but second time it will generate error

create_directory(){
      mkdir demo

}

if ! create_directory; then
	echo "The code is being exited as the directory already existed"
	exit 1
fi

echo "this is the last line code of this script "


