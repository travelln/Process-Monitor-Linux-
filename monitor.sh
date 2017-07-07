#!/bin/bash
#Author: Sunny Pritpal Singh
#Student ID 100206047
#Purpose: This program outputs various statistics about the cpu usage, memory usage
#and process activity. CPU and memory usage appear as percentage values as well can
#be displayed graphically using an array of dots which represent no activity or 
#"*" which show the usage from zero to one hundred percent broken down in to five
#five segments with five being the highest and zero means no usage. The graphs for
#memory and cpu usage can be toggled on or off as desired by the user.

#Initializes the CPU usage graph array with dots
function initCPUGraphArray(){
	cpuArray1=( . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . )
	cpuArray2=( . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . )
	cpuArray3=( . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . )
	cpuArray4=( . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . )
	cpuArray5=( . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . )
}

#Initializes the variables and flags used in the program
function initVariables(){
	cpuUsageValue=0	   #total cpu usage percentage
	memoryUsageValue=0 #total memory usage percentage	
	cpuGraphFlag=1     #flag that toggles the cpu graph
	memGraphFlag=1	   #flag that toggles the memory graph
}

#Initializes the Memory usage graph
function initMemGraphArray(){
	memArray1=( . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . )
	memArray2=( . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . )
	memArray3=( . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . )
	memArray4=( . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . )
	memArray5=( . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . )
}

#Calculates how cpu is used by getting values from the proc/stat file
#an then translates them as a percentage
function cpuUsage(){

	#reads the info from the proc/stat file info
	#other value discards the rest of the line from the stat file 
	#that we do not need
	read cpuN userCPU niceUser systemCPU idleCPU other < /proc/stat
	
	total1=$((userCPU+niceUser+systemCPU+idleCPU)) #total value of cpu used
	userCPU1=$((userCPU)) #sets the cpu used by the user

	sleep 0.5 #sleep so we can get out second set of values for the cpu usage stats

	#reads it again after a defined sleep period
	#this is necessary since the cpu stats in the stat file are 
	#aggregates from when the cpu is first booted - so we have to 
	#get the values over a time slice to find the cpu usage stats
	#we need
	read cpuN2 userCPU2 niceUser2 systemCPU2 idleCPU2 other2 < /proc/stat
	
	total2=$((userCPU2+niceUser2+systemCPU2+idleCPU2))
	userCPU2=$((userCPU2))

	totalCPU=$((total2-total1)) #subtracts the two cpu usage values which gives as a usable
				    #value for cpu usage
	totalIdleCPU=$((idleCPU2-idleCPU)) #subtracts tjhe two idle cpu values which gives us a 
					   #usable idle cpu value

	#calculates the total user cpu usage as a percentage
	totalUserCPU=$((userCPU2-userCPU))
	totalUserCPU=$(echo - | awk "{print ($totalUserCPU/$totalCPU)}")
	totalUserCPU=$(echo - | awk "{print $totalUserCPU*100}")

	#calculates the total cpu usage - by everything as a percentage
	cpuUsageValue=$((totalCPU-totalIdleCPU))
	cpuUsageValue=$(echo - | awk "{print ($cpuUsageValue/$totalCPU)}")
	cpuUsageValue=$(echo - | awk "{print $cpuUsageValue*100}")

	#calculates the total idle cpu as a percentage
	idle=$(echo - | awk "{print ($totalIdleCPU/$totalCPU)}")
	idle=$(echo - | awk "{print $idle*100}")

	#calculates the total cpu usage by the system as a percentage
	systemTotal=$((systemCPU2-systemCPU))
	systemTotal=$(echo - | awk "{print ($systemTotal/$totalCPU)}")
	systemTotal=$(echo - | awk "{print $systemTotal*100}")
	
	#discards any decimal places from the number
        totalUserCPU=${totalUserCPU/.*}
	systemTotal=${systemTotal/.*}
	idle=${idle/.*}
	cpuUsageValue=${cpuUsageValue/.*}

	#outputs the the user, system and idle cpu usage values as a percentage
	echo -n "CPU: "$totalUserCPU"% usr," $systemTotal"% sys," $idle"% idle"
}

#Calculates the usage of memory by the computer from the /proc/meminfo file
#and converts this information into a percentage value which is used later on
#by the memory graphing function. It also outputs the raw memory usage and 
#free memory values
function memoryUsage(){

	#gets values from the /proc/meminfo file
	totalMemory=$(cat /proc/meminfo | grep MemTotal | awk '{print $2}')
	freeMemory=$(cat /proc/meminfo | grep MemFree | awk '{print $2}')

	#outputs the values
	echo " MEM:" $totalMemory "total," $freeMemory "free     "

	#calculates the percentage of memory used by the computer
	memoryUsageValue=$((totalMemory-freeMemory))
	memoryUsageValue=$(echo - | awk "{print ($memoryUsageValue/$totalMemory)}")
	memoryUsageValue=$(echo - | awk "{print $memoryUsageValue*100}")
	memoryUsageValue=${memoryUsageValue/.*}
}

#Gets the top five processes that are using the cpu and outputs various statistics
#about these processes; including PID, user, cpu%, mem%, state and name of command
function topProcesses(){

	format="%-10s%-10s%-10s%-10s%-10s%-15s" #format for printing the chart
	
	echo -e "\nMost active Processes\n"
	
	#outputs the headers for the chart
	printf "%-10s%-10s%-10s%-10s%-10s%-15s\n" "PID" "USER" "State" "%CPU" "%MEM" "COMMAND"
	
	#outputs the info for the top five processes. These series of commands uses the ps command 
	#to get all the process which is then sorted with the sort command using the cpu% column and the result
	#is piped into the head command which gives ud the top five results then awk makes it look nice	
	ps auxc --no-headers | sort -k3 -r | head -5 | awk '{printf("'$format'\n", $2, $1, $8, $3, $4, $11)}'

}

#Outputs the current time using the date command with arguments for hour,minute and AM/PM values
function outputTime(){

	date +%I:%M%p 
}

#Outputs the CPU Graph that has its values stored in five arrays each containg
#thirty two elements with each element represnting one second of cpu usage as either
#a dot for no usage or a star for usage.
function outputCPUGraph(){

	if [ "$cpuGraphFlag" -eq "1" ] #this flag gets checked just in case the user does not want 
	        then		       #the graph to be outputed 
			echo -e "\nCPU usage\n"
			echo "${cpuArray1[*]}"
			echo "${cpuArray2[*]}"
			echo "${cpuArray3[*]}"
			echo "${cpuArray4[*]}"
			echo "${cpuArray5[*]}"	
	fi
}

#Outputs thee memory usage graoh that has its values stored in five arrays each containg
#thirty two elements with each element represnting a single capture of memory usage by the system
#as either a dot for no usage or a star for usage
function outputMemGraph(){

	if [ "$memGraphFlag" -eq "1" ] #this flag gets checked just in case the user does not want 
	        then		       #the graph to be outputed
	        	echo -e "\nMemory usage\n"
	       	        echo "${memArray1[*]}"
	        	echo "${memArray2[*]}"
	       	        echo "${memArray3[*]}"
	        	echo "${memArray4[*]}"
	        	echo "${memArray5[*]}"	
	fi
}

#Updates the usage of the cpu by modifying one column of the five arrays that together represent
#one second of cpu usage. The degree to which the cpu is being used will determine if the 
#individual elemnt of the column is either a star or a dot
function updateCPUGraph(){


	if [ "$cpuUsageValue" -lt "21" ]   #twenty percent or less usage
		then
			cpuArray5[31]="*";
	elif [ "$cpuUsageValue" -lt "41" ] #forty percent or less usage	
		then 			   #else if statements ensure only one value is represented	
			cpuArray5[31]="*"; #and not performed twice depending on the criteria
			cpuArray4[31]="*";
	elif [ "$cpuUsageValue" -lt "61" ] #sixty percent or less usage
		then
			cpuArray5[31]="*";
			cpuArray4[31]="*";
			cpuArray3[31]="*";
	elif [ "$cpuUsageValue" -lt "81" ] #eighty percent or less usage
		then
			cpuArray5[31]="*";
			cpuArray4[31]="*";
			cpuArray3[31]="*";
			cpuArray2[31]="*";
	elif [ "$cpuUsageValue" -lt "101" ] #one hundred percent or less usage
		then
			cpuArray5[31]="*";
			cpuArray4[31]="*";
			cpuArray3[31]="*";
			cpuArray2[31]="*";
			cpuArray1[31]="*";	
	fi
}

#Updates the usage of the memory by the computer processes as represented by the five arrays
#The degree to which the meory is being used will determine if the #individual element of 
#the column is either a star or a dot
function updateMemGraph(){


	if [ "$memoryUsageValue" -lt "21" ]    #twenty percent usage or less
	        then
	                memArray5[31]="*";
	elif [ "$memoryUsageValue" -lt "41" ]  #forty percent usage or less
	        then
	                memArray5[31]="*";
	                memArray4[31]="*";
	elif [ "$memoryUsageValue" -lt "61" ]  #sixty percent usage or less
	        then
	                memArray5[31]="*";
	                memArray4[31]="*";
	                memArray3[31]="*";
	elif [ "$memoryUsageValue" -lt "81" ]  #eighty percent usage or less
	        then
	                memArray5[31]="*";
	                memArray4[31]="*";
	                memArray3[31]="*";
	                memArray2[31]="*";
	elif [ "$memoryUsageValue" -lt "101" ] #one hundred percent usage or less
	        then
	                memArray5[31]="*";
	                memArray4[31]="*";
	                memArray3[31]="*";
	                memArray2[31]="*";
	                memArray1[31]="*";
	fi
}

#Shifts the values contained in the five cpu usage arrays to allow for another 
#second of usage to be displayed when the main loop reiterates and polls more
#data from the /proc/stat file. The array elements shift to the left
function shiftCPUGraph()
{
	unset cpuArray5[0]                #deletes the first element in the array
	cpuArray5=("${cpuArray5[@]}" ".") #reinitalizes the array minus the first element
	cpuArray5[31]="."                 #sets the last element to a dot

	unset cpuArray4[0]
	cpuArray4=("${cpuArray4[@]}" ".")
	cpuArray4[31]="."

        unset cpuArray3[0]
        cpuArray3=("${cpuArray3[@]}" ".")
        cpuArray3[31]="."

        unset cpuArray2[0]
        cpuArray2=("${cpuArray2[@]}" ".")
        cpuArray2[31]="."

        unset cpuArray1[0]
        cpuArray1=("${cpuArray1[@]}" ".")
        cpuArray1[31]="."
}

#Shifts the vlues contained in the five memory usage arrays to allow for another
#set of data elements from the polling of the /proc/meminfo file to be represented 
#in the array once the main loop reiterates
function shiftMemGraph()
{
        unset memArray5[0]		  #deletes the first element in the array
        memArray5=("${memArray5[@]}" ".") #reinitializes the array minus the first element
        memArray5[31]="."		  #sets the last element to a dot

        unset memArray4[0]
        memArray4=("${memArray4[@]}" ".")
        memArray4[31]="."

        unset memArray3[0]
        memArray3=("${memArray3[@]}" ".")
        memArray3[31]="."

        unset memArray2[0]
        memArray2=("${memArray2[@]}" ".")
        memArray2[31]="."

        unset memArray1[0]
        memArray1=("${memArray1[@]}" ".")
        memArray1[31]="."
}

#Toggles the flag which reprsents if the user would like the cpu Graph to be displayed
#or not to the screen
function toggleCPUGraph(){

	if [ "$cpuGraphFlag" -eq "0" ]
		then
			cpuGraphFlag=1
	else
		cpuGraphFlag=0
	fi
}

#Toggles the flag which represents if the user would like the cup graph to be displayed
#or not to the screen
function toggleMemGraph(){

	if [ "$memGraphFlag" -eq "0" ]
	        then
	                memGraphFlag=1
	else
	        memGraphFlag=0
	fi
}

#Outputs the values of cpu and memory usage and the graphs of the cpu and
#memory usage (if the user wants it to be). Also, updates the values of 
#the arrays for cpu and memory usage. Outputs the top processes being used
#by the cpu. This function calls various functions defined earlier
function outputUpdateAll(){

	tput cup 0 0     #sets the cursor to the first position
	outputTime	 #displays the time

	tput cup 0 9     #sets the cursor after the output of time
	cpuUsage	 #outputs cpu usage stats	
	memoryUsage      #outputs memory usage stats
	
	updateCPUGraph   #updates the cpu graph with a new set of values
	outputCPUGraph   #outputs the cpu graph
	shiftCPUGraph    #shifts the contents of the cpu usage arrays
	
	updateMemGraph   #updates the memory usage graph
	outputMemGraph   #outputs the memory usage graph
	shiftMemGraph    #shifts the contents of the memory usage arrays

	topProcesses     #outputs the top five processes being used
}

#main function of the program which uses a while loop which cycles every second to 
#update cpu, memory usage and process activity stats. It also gets input from the user 
#to check see if they want the output of the cpu and memory graphs to be displayed. If the 
#user wishes to exit they can do so by typing in q.
function main(){

	clear               #clears the terminal screen
 	tput civis	    #hides the cursor
	initCPUGraphArray   #initializes the cpu graph
	initMemGraphArray   #initializes the mem graph
	initVariables       #initializes the varibles used (flags and usage values)
	
	while :
		do
			outputUpdateAll #outputs all the stats

			#gives the user some options for different view preferences
			echo -e "\nPress c to toggle CPU, m to toggle Memory, q to Quit.\n"

			#reads input from the user or cycles through output if no command
			#is recieved within one second
			read -n 1 -s -t 1 command 
				
			case $command in
			
				c) #to toggle cpu graph output
					clear		
					toggleCPUGraph
					;;
		
				m) #to toggle mem graph output
					clear
					toggleMemGraph
					;;
				q) #to quit from the program
					tput clear #clears the screen before exiting
					tput cnorm #makes the cursor reappear
					exit 0     #exits the program
					;;
				*) #this is our catch all case for invalid input
					outputUpdateAll
					;;
			esac #end case 
	done

        #this point should never be reached but just in case:   
	tput clear #clear the screen
	tput cnorm #make the cursor visible
	exit 0     #exit the program nicely
}

main
exit 0
