# OmniFocus to Reminders 

## Overview 

Three Applescripts to help send OmniFocus tasks to Reminders app

- **of2reminders** - Send OmniFocus task to Reminders by selection (supports multiple selections)
- **of2reminders-batch** - Send OmniFocus task to Reminders in batch. 
- **of2reminders-sync** - Sync task completion status when task is completed in Reminders App

## Use Case

I like to keep my errand tasks in OmniFocus, but I also want the convenience of shared family shopping lists
via Reminders.

## Script Configuration

of2reminders and of2reminders-batch can be configured as such:

### Property: cleanUp ### 

- If you want to keep the OmniFocus task active after sending it to Reminders, set cleanUp to "link"- If you want to complete the OmniFocus task after sending it to Reminders app, set cleanUp to "complete"
- Default is "link"

### property listMode ###

- If you want to send the OmniFocus task to one of multiple Reminders lists, set listMode to "multi"- If you want to send the OmniFocus task to a single Reminders list, set listMode to "single"
- Default is "multi"

### property contextList ###

A list of whichever OmniFocus context names you want to send to Reminders in Batch. NB: The context names must match the names of the Reminders lists. 

### property defaultList ###

The name of your default Reminders List

- Used by listMode multi if the OmniFocus task does not have a context
- Is the list all tasks are sent to if listMode is single.

## Requirements ##

When using of2reminders-Batch:

- In order to send tasks to multiple Reminders lists, the names of the Reminders lists **MUST MATCH** the OmniFocus context name.
- To use of2reminders-sync script, the notes added to both the OmniFocus and Reminders tasks MUST exist. 

## Notes ##

 You can run the script in the background by either creating a launchd item or by using Keyboard Maestro.
