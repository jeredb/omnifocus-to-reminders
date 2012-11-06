(*
OmniFocus2Reminders - Batch
Created by: Sean KorzdorferCreated on: 10/23/12 08:53:07Version: 1.0

## Overview

Send all tasks found for the contexts listed in the property contextList to Reminders.app

## Use Case

I like to keep my errand tasks in OmniFocus, but I also want the convenience of shared family shopping lists
via Reminders.

## Notes

You can configure the script to:

- Send OmniFocus tasks to multiple Reminders lists or a single list
- Complete OmniFocus task after sent to the Reminders app. (cleanUp:"complete")
- Keep OmniFocus task active and note it with date/time sent to Reminders (cleanUp:"link")

NB: The default cleanUp is link. Note you can use this script with OF2Reminders-Sync to complete the tasks in 
 OmniFocus once they have been completed in Reminders. 
 
 You can run the script in the background by either creating a launchd item or by using Keyboard Maestro

Requirements:

- In order to send tasks to multiple Reminders lists, the Reminders app list name MUST MATCH the OmniFocus context name.
- To use OF2Reminders-sync script, the notes added to both the OmniFocus and Reminders tasks MUST exist.*)(* ################################ CONFIGURATION ################################ *)-- Propery cleanup can be link, complete or deleteproperty cleanUp : "link"-- A Reminders List For Each OmniFocus Context OR all tasks go to a single Reminders list-- listType can be multi or single-- IF YOU MAKE listMode SINGLE, ALL TASKS WILL BE SENT TO THE LIST NAME SET BY THE PROPERTY defaultListproperty listMode : "multi"-- contextList is a of OmniFocus context names which MUST match a Reminders list name--		Example: I have a context named CVS. I need to have a Reminders list named CVSproperty contextList : {"trader joe's", "CVS", "Price Chopper"}-- defaultList is the name of the Reminders list you want any task without a context to go.property defaultList : "Reminders"(* ################################ Script ################################ *)tell first document of application "OmniFocus"		repeat with iContext from 1 to count of contextList		-- Catch error here		set theContext to item iContext of contextList		-- Create a list of tasks which belong to a context in contextList, are active, and do not contain an OF2Reminder note		if the (count of the tasks of flattened context theContext) > 0 then set theTasks to (tasks of flattened context theContext whose note does not contain "OF2Reminders" and completed is false)		repeat with theTask in theTasks			set taskProps to {taskList:theContext as string, taskName:the name of theTask, taskStart:start date of theTask, taskDue:the due date of theTask, taskID:"omnifocus:///task/" & the id of theTask as rich text}			if cleanUp is "link" then my noteTask(theTask)			my prepTask(taskProps)			-- Test cleanUp Property			if cleanUp is "complete" then set completed of theTask to true		end repeat	end repeat			end tell(* 
################################ Note Task ################################ 

Input: OmniFocus Task 
Output: Nothing

Modifies the OmniFocus Task object's note field to 

	OF2Reminder: <date>

*)on noteTask(theTask)	try		using terms from application "OmniFocus"			if note of theTask is not "" then				set note of theTask to "OF2Reminders: " & (current date) & return & note of theTask			else				set note of theTask to "OF2Reminders: " & (current date)			end if		end using terms from	on error		display dialog		"There was an error setting the note for task: " & theTask	end tryend noteTask(* 
################################ Prepare Task ################################ 

Input: a list of properties regarding an OmniFocus task object
Output: Creates a Reminder task

*)on prepTask(theTask)	using terms from application "OmniFocus"		-- Test listMode property		if listMode is "multi" then			set thelist to taskList of theTask		else if listMode is "single" then			set thelist to defaultList		end if		-- Test if date is missing value		if taskStart of theTask is not missing value and taskStart of theTask is greater than (current date) then			tell application "Reminders" to tell list thelist of default account to make new reminder with properties {name:taskName of theTask, remind me date:taskStart of theTask, body:taskID of theTask}			-- Second Test: No valid start date, but future due date found		else if taskDue of theTask is not missing value and the taskDue of theTask is greater than (current date) then			tell application "Reminders" to tell list thelist of default account to make new reminder with properties {name:taskName of theTask, remind me date:taskDue of theTask, body:taskID of theTask}			-- No valid start date or due date found. I could test for start date > due date, but that's on the user.		else			tell application "Reminders" to tell list thelist of default account to make new reminder with properties {name:taskName of theTask, body:taskID of theTask}		end if	end using terms fromend prepTask