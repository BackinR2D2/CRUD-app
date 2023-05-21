# CRUD application (Users management in Bash)

The management menu displays the following options:

1. Create user by entering a set of information (name, email, grade, height)
2. Delete user by specifying an ID
3. Display the situation of a student by specifying an ID (If the student is eligible for entering the basketball team, the conditions would be: height >= 185cm and grade > 5)
4. Edit user by specifying an ID
5. Display sorted users by grade

The data is stored in the ./db.csv file. If the file doesn't exist, it's being initialized once the script is executed.
Check the ./db.csv.example file for seeing the structure of the CSV file
You may need to execute: `chmod +x ./script.sh` for being able to run the script
