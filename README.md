# Ruby LDIF Generator

This is a Ruby script for generating LDIF files to create new users on an OpenLDAP server.

It was part of a gradual process to simplify OpenLDAP user creation, the next step can be found in my ruby-ldap-script project.

## Overview

The available arguments are listed below:
- the user's first name
- the user's last name
- (optional) a text file containing all groups the user will be added to after creation

When the script is executed, it will write all operations to result.ldif and print the username and password to the terminal.

## Usage

It can be executed from a terminal with:
```
$ ruby ruby-ldif-generator john smith groups.txt
```
