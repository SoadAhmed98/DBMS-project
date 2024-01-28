#!/bin/bash
shopt -s extglob
#/********************************(variables)******************************/
dbpath=""
#/*******************************(create Database Folder)*******************/
function main_dbs_folder {
db=`ls -F|grep DBs`
if [ -n "$db" ]
then	
  dbpath+="./${db}"
else
 mkdir -p ./DBs
 dbpath+="./DBs/"

fi

}
#/*******************************(Database functions)************************/
function Create_Database() 
{

  read -p "Please Enter your database name :" db_name
  check=$(ls -F "${dbpath}" | grep -w "${db_name}")
  
  if [[  $db_name  =~ \  || ! $db_name =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]
  then 
  echo "Invalid database name."
  echo " Database names must start with a letter or underscore and only contain letters, numbers, and underscores."	  
  elif [ ${#check} -eq 0 ]
  then    
   mkdir "${dbpath}${db_name}"
   echo "$db_name created successfully"  
 else
  while [ ${#check} -gt 0 ]
  do 
    read -p "this database is already exist,Please Enter another database name :" dbName
    check=$(ls -F "${dbpath}" | grep -w "${dbName}")
    if [[  $dbName  =~ \  || ! $dbName =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]
  then
  echo "Invalid database name."
  echo " Database names must start with a letter or underscore and only contain letters,numbers, and underscores."       
    elif [ ${#check} -eq 0 ]
    then    
    mkdir "${dbpath}${dbName}"
    echo "$dbName created successfully"  
    else
	    continue
    fi	 
  done
  fi
}
function List_Database()
{
        
	allDb=$(ls -F "${dbpath}" | grep /)
	allDb_cleaned=""
        # Remove trailing slash from all elements
	for element in $allDb;
       	do
	    allDb_cleaned+="${element%/} "
	done

	# Remove the trailing space at the end
	allDb_cleaned=${allDb_cleaned% }

	
	if [ -z  "$allDb" ]
	then 	
	echo "No Database Found"
        else
	    echo "$allDb_cleaned"
	
	fi	
}
function Connect_to_Database()
{
        Dbs=$(List_Database)
	
	if [ "$Dbs" != "No Database Found" ]
	then	
        if [ -n "$Dbs" ]
        then	       
        echo "All Databases Found"
        echo -n "$Dbs" | tr '\n' ' '  # Replace newlines with spaces
        echo   
        read -p  "Write name of database you want to connect to it : " name
        if [[  $name  =~ \  || ! $name =~ ^[a-zA-Z_][a-zA-Z0-9_]*$  ]]
        then
          echo "invalid database name "
        elif [ -d "${dbpath}${name}" ]
         then
         echo "Connected to ${name} database successfully"
	 dbpath+="${name}/"
	 echo
	 submenu
        else
         echo "Invalid database name"
        fi
        fi
        else
	 echo "No Database Found"	
        fi	
}
function Drop_Database()
{
	

	Dbs=$(List_Database)
        if [ "$Dbs" != "No Database Found" ]
        then
	echo "All Databases Found"
	echo -n "$Dbs" | tr '\n' ' '  # Replace newlines with spaces
	echo   
	read -p  "Write name of database you want to drop : " name
	if [[  $name =~ ^[[:blank:]] || ! $name =~ ^[a-zA-Z_][a-zA-Z0-9_]*$  ]]
	then
	  echo "invalid database name "
        elif [ -d "${dbpath}${name}" ] 
         then		
	 rm -r "${dbpath}${name}"
	 echo "${name} Dropped successfully"
        else
         echo "Invalid database name"
        fi
        else 
	echo "No Database Found"
	fi
}
#/*********************************(Table Functions)***********************************/
function Create_Table
{
   read -p "Please Enter table name: " tableName
   #validate table name
  
   if [[ ! $tableName =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]
   then
   echo "Table name must start with a letter or underscore and only contain letters, numbers, and underscores."
   else
    table_name=$(ls -F ${dbpath} | grep / | grep -w "${tableName}")
    if [ ${#table_name} -eq 0 ]
    then
    tabledir="${dbpath}${tableName}/"
    
    mkdir "$tabledir"    
    touch "${tabledir}metadata"
    touch "${tabledir}data"
    #Input number of columns
    read -p "Enter number of columns: " columns
    #loop through columns
    columnNames=()
   for ((i = 1; i <= columns; i++))
   do
     # Input column name
     read -p "Enter Column $i Name: " colName
     if [[ $colName =~ ^[A-Za-z_]{1}[A-Za-z0-9]*$ ]]
     then
      columnNames+=("$colName")

      # Input data type
       while true;
       do
       read -p "Select Data Type for $colName (int/string/boolean): " datatype
      # Check if the entered data type is valid
      case $datatype in "int" | "string" | "boolean")
      break # Break out of the loop if the input is valid
       ;;
      *)
      echo "Invalid data type. Please enter 'int', 'string', or 'boolean'."
       ;;
      esac
      done
      # Input if column is primary key
      while true;
      do
      read -p "Is $colName a primary key? (yes/no): " isPrimary
      # Check if the entered answer for primary key is valid
      case $isPrimary in  "yes" | "no")
      break # Break out of the loop if the input is valid
       ;;
      *)
      echo "Invalid input for primary key. Please enter 'yes' or 'no'."
       ;;
      esac
      done
      # Append column info to metadata file
      echo "$colName|$datatype|$isPrimary" >> "${tabledir}metadata"
      else
        echo "column name must start with a letter or underscore and only contain letters, numbers, and underscores."
      fi
   done		
    # Store column names in the first row of the data file with ":"
   echo "${columnNames[*]}" | tr ' ' '|' >>"${tabledir}data"
   echo "$tableName table created successfully"  
   else
   echo "$tableName already exist, Please try again"
   fi 
   fi	  
}
function List_Tables
{
    alltables=$(ls -F ${dbpath} | grep /)
        alltables_cleaned=""
        # Remove trailing slash from all elements
        for element in $alltables;
        do
            alltables_cleaned+="${element%/} "
        done

        # Remove the trailing space at the end
        alltables_cleaned=${alltables_cleaned% }
  
   # Check if the database is empty
    if [ -z "$alltables" ]; then
        echo "No tables found in the ${name} database."
        return
    fi

     echo "Tables in ${name} database:"
     echo "${alltables_cleaned}"

}
function Drop_Table
{
          
        tables=$(List_Tables)
	if [ "$tables" != "No tables found in the ${name} database." ]
	then	
          
         echo "${tables}"
        read -p  "Write name of table you want to drop : " Tname
        if [[ ! "$Tname" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$  ]]
        then
          echo "invalid table name "
        elif [ -d "${dbpath}${Tname}" ]
         then
         rm -r "${dbpath}${Tname}"
         echo "${Tname} Dropped successfully"
        else
         echo "Invalid Table name ${dbpath}${Tname}"
        fi
       else
	 echo "No tables found in the ${name} database."
       fi	 

}
function Insert_into_Table
{
	
	#list all tables
        tables=$(List_Tables)
        if [ "$tables" != "No tables found in the ${name} database." ]
        then

        echo "${tables}"
        read -p  "Write name of table you want to insert into : " Tabname
        if [[   ! $Tabname =~ ^[a-zA-Z_][a-zA-Z0-9_]*$  ]]
        then
          echo "invalid table name"
        else
	
	        # Read metadata from the metadata file
                metadata=$(<"${dbpath}${Tabname}/metadata")
                IFS=$'\n' read -rd '' -a metadataArray <<<"$metadata"
                # Ask user for the values for each column
                declare -a values=()
                declare -A uniqueColumns  #array to store unique IDs
                for meta in "${metadataArray[@]}"; do
                    IFS='|' read -ra metaArray <<<"$meta"
                    column="${metaArray[0]}"
                    columnType="${metaArray[1]}"
		    

                    while true; do
                        echo -n "Enter value for $column: "
                        read value

                        case $columnType in
                        "int")
                            if [[ ! $value =~ ^[0-9]+$ ]]; then
                                echo "Invalid input. Please enter an integer."
                                continue
                            fi
                            ;;
                        "string")
                            if [[ ! "$value" =~ ^[a-zA-Z]+$ ]]; then
                                echo "Invalid input. Please enter letters only."
                                continue
                            fi
                            ;;

                        "boolean")
                            if [[ $value != "0" && $value != "1" ]]; then
                                echo "Invalid input. Please enter 0 or 1."
                                continue
                            fi
                            ;;
                        esac
                     
                        values+=("$value")
                        break
                    done
                done

                # Combine values into a '|' separated string
                valuesString=$(
                    IFS='|'
                    echo "${values[*]}"
                )

                # Append values to the data file
                echo "$valuesString" >>"${dbpath}${Tabname}/data"

                echo "Values inserted successfully into table '$Tabname'."
	
        fi
	 else
         echo "No tables found in the ${name} database,create table first"
        fi
}
function Select_From_Table
{
  # List all tables
tables=$(List_Tables)
if [ "$tables" != "No tables found in the ${name} database." ]; then
    echo "${tables}"
    read -p "Write name of table you want to select from: " tab_name

    if [[ ! $tab_name =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "Invalid table name."
    else
        tablePath="${dbpath}/${tab_name}/data"

        if [ -e "$tablePath" ]; then
            # Display all data from the table
            awk -F, 'NR>1 {OFS=","} {print $0}' "$tablePath"
            echo "All data from table '$tab_name' displayed."
        else
            echo "Table '$tab_name' not found in the current database."
        fi
    fi
fi
}
function Delete_From_Table
{
   echo "I apologize for not being able to complete the project due to time constraints."
}
function Update_Table
{
   echo "I apologize for not being able to complete the project due to time constraints."
}
function Back_to_Main_menu
{
   dbpath="./DBs/"	
   main_menu
}

#/*************************************(Sub Menu)**************************************/
function submenu 
{
PS3="${name} >"	
select choice in "Create Table" "List Tables" "Drop Table" "Insert into Table" "Select From Table" "Delete From Table" "Update Table" "Back to Main menu" "Exit" 
do
case $REPLY in
1)Create_Table
        ;;
2)List_Tables
        ;;
3)Drop_Table
        ;;
4)Insert_into_Table
        ;;
5)Select_From_Table
        ;;
6)Delete_From_Table
	;;
7)Update_Table
	;;
8)Back_to_Main_menu
	;;
9)exit
	;;	
*)echo "$REPLY is Not valid choice,Your choice must be a number"        
esac
done
}
#/*******************************(main menue)********************************/
main_dbs_folder
function main_menu {
PS3="Enter your choice Number :"
echo 
echo  "<<=============================DBMS Project=================================>>"
echo 
select choice in "Create Database" "List Database" "Connect To Database" "Drop Database" "Exit"
do		
case $REPLY in 
1)Create_Database
	;;
2)List_Database
	;;
3)Connect_to_Database	
	;;
4)Drop_Database
	;;
5)exit
	;;	
*)echo "$REPLY is Not valid choice,Your choice must be a number"	
esac
done	
}
main_menu
