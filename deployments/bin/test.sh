#!/bin/bash

match='fields'
insert='New/Inserted Line'
file='file.txt'

sed -i "s|$match|$match\n$insert|" $file