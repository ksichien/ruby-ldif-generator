# ruby-ldif-generator

This is a script I wrote for generating LDIF files to create new users on an OpenLDAP server.

The LDIF files are created based from template files included in this project and the result of running the script will be written into the result.ldif file.

It can be executed from a terminal with:
```
$ ruby ruby-ldif-generator john smith groups.txt
```
Where the first argument is the new user's first name, the second argument their last name and the third (optional) argument a text file with all groups the new user needs to be added to.
