(*
OmniFocus2Reminders - Selection
Created by: Sean Korzdorfer
Created on: 10/23/12 08:53:07
Version: 1.0

## Overview

Send selected tasks in OmniFocus to Reminders.app

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
 
*)


(* ################################ CONFIGURATION ################################ *)

-- if you want to keep the OmniFocus tasks active, set cleanUp to "link"
-- if yoy want to complete the OmniFocus tasks after sending them to Reminders app
-- set cleanUp to "complete"

property cleanUp : "link"

-- If you want to send OmniFocus tasks to multiple Reminders lists, set listMode to "multi"
-- If you want to sent OmniFocus tasks to a single lise, set listMode to "single"

property listMode : "multi"

-- If you have, say multiple shared shopping lists in the Reminders App whose 
-- name match an OmniFocus context name, add them the the contextList property:

property contextList : {"costco", "trader joe's", "petsmart", "target", "price chopper", "cvs", "amazon"}

-- defaultList is the name of the Reminders list you want any task without a context to go.

property defaultList : "Reminders"

(* ################################ Script ################################ *)


tell application "OmniFocus"
	activate
	-- This first bit is from a RobTrew example from a few years back É Lost the source url.
	tell front window of application "OmniFocus"
		set oTrees to selected trees of content
		set lngTrees to count of oTrees
		if lngTrees < 1 then
			set oTrees to selected trees of sidebar
		end if
		
		if lngTrees < 1 then
			return
		end if
		if (lngTrees > 0) then
			repeat with iTree from 1 to lngTrees
				set SelectedItemInMainView to selected trees of content
				set theSelection to value of (item iTree of oTrees)
				try
					-- get a list of tasks who are not missing a context, and whose context name can be found in contextList
					if listMode is "multi" and context of theSelection is not missing value and contextList contains the name of the context of theSelection then
						set thelist to the name of the context of theSelection
					else
						set thelist to defaultList
					end if
				on error
					display dialog
					"There was an error getting the context for the task" & name of theSelection
				end try
				-- First Test: Future Start Date found
				if start date of theSelection is not missing value and start date of theSelection is greater than (current date) then
					my createReminder(thelist, name of theSelection, start date of theSelection, "omnifocus:///task/" & id of theSelection as rich text)
					-- Second Test: No valid start date, but future due date found
				else if due date of theSelection is not missing value and the due date of theSelection is greater than (current date) then
					my createReminder(thelist, name of theSelection, due date of theSelection, "omnifocus:///task/" & id of theSelection as rich text)
					-- No valid start date or due date found. I could test for start date > due date, but that's on the user.
				else
					my createReminder(thelist, name of theSelection, missing value, "omnifocus:///task/" & id of theSelection as rich text)
				end if
				if note of theSelection is not "" then
					set note of theSelection to "OF2Reminders: " & (current date) & return & note of theSelection
				else
					set note of theSelection to "OF2Reminders: " & (current date)
				end if
				-- test CleanUp
				if cleanUp is "complete" then set completed of theSelection to true
			end repeat
		end if
	end tell
end tell

(* 
################################ Create Reminder Task ################################ 

Input: 
- The Reminders list to send the task to
- The name of the OmniFocus task
- The date object of the OmniFocus task
- The note of the OmniFocus task
Output: A Reminders Task

Modifies the OmniFocus Task object's note field to 

	OF2Reminder: <date>

*)

on createReminder(thelist, theTask, theDate, theNote)
	try
		-- test cleanUp property
		if cleanUp is not "link" then set theNote to ""
		if theDate is not missing value then
			tell application "Reminders" to tell list thelist of default account to make new reminder with properties {name:theTask, remind me date:theDate, body:theNote}
		else
			tell application "Reminders" to tell list thelist of default account to make new reminder with properties {name:theTask, body:theNote}
		end if
	on error
		display dialog
		"There was an error creating a reminder for the task" & theTask
	end try
end createReminder


