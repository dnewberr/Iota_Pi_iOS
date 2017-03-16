# Iota_Pi_iOS
The Iota Pi chapter of Kappa Kappa Psi's official member app. It was a Senior Project for Cal Poly SLO's Computer Science department.
CREDIT:
Tabbar icons were free from http://www.iconbeast.com/.

## Administrative Summary

| Item          | Pres. | Recording Secretary | VP    | Webmaster | Parliamentarian | Committee Chairs |
| ------------- | :---: | :-----------------: | :---: | :-------: | :-------------: | :--------------: |
| User Accounts | x     |                     |       | X         |                 |                  |
| Announcements | x     | X                   | X     | X         | X               | X - All          |
| HIRLy         | x     |                     |       |           |                 | X - Brotherhood  |
| Current       | x     | X                   | X     |           | X               |                  |
| Attendance    | x     | X                   | X     |           |                 |                  |
| Roster        | x     | X                   |       |           |                 |                  |

## Screens
In order to ease our process with parliamentary and organizational procedures, the app consists of six main screens:
### Login
In order to automatically be able to only login members of Iota Pi, the login feature uses the <firstname>.<lastname>@iotapi.com email address that is automatically created by the chapter Webmaster. 
#### Forgot Password
Before logging in, users can reset their password if forgotten. An automatically generated email will then be sent to their iotapi.com account (which is automatically forwarded to their @calpoly.edu email) and will include a link to reset it.
#### Account Creation
Users can create an account by filling out a form. Six fields are required: first and last name (in order to generate @iotapi.com email), their Nationals roster number (found via the official Kappa Kappa Psi site), their administrator privilege (by default “None”, but can be changed by another admin later), their education class, and their current membership status (for example, Active or Conditional, among many other official statuses Nationals deems valid). These are necessary for the app to function correctly for a user. Optional fields for roster purposes include birthday, local address, phone number, and many more.
Their original password is given via a randomly generated 6-character screen in an alert, and then they are responsible for changing their password once they have access to their account.

**Admin:**
Once created, the President or Webmaster must validate their account on the “More” options screen. Until then, the user will receive a “needs validation” error when attempting to log in, and they will not appear on the roster or any other portion of the app.
### Announcements
This section serves as a general information view for all members, and is the first visible screen upon starting the application (if logged in). It lists announcements made by administrators in order from most to least recent. Each announcement made expires after seven days, and is then transferred to the archived announcement section. After one year, the announcement is automatically removed from the database.

**General:**
Brothers can read and search through announcements by committee tags (Band Social, Brotherhood, Fundraising, etc) and an optional text phrase. They can search through the list of archived announcements ordered by date by a text phrase (but no committee filters).

**Admin:**
All administrators can create new announcements by writing a short title, a description, and optional committee tags. These are set to expire automatically in seven days, and when submitted they send out notifications to all members’ phones. Additionally, all administrators have to option of swiping left on active announcements to either permanently delete or force archive them, and swiping left on archived announcements to permanently delete them.
### Calendar
This section includes a web view of the Google Calendar already set up by the chapter. There are no plans to make an add event feature as it seems out of scope for the project, but brothers will be able to see all events and their details.
### Voting
The voting section is the most important part of the application. An important note to make is that by National’s rules, only Active and Associate members are able to vote on any topics. Therefore, any other membership status will not be able to see either type of vote. There are two different votes that are simplified through the addition of the app, both of which are automatically deleted from the database after a full year has passed:
#### HIRLy Nominations
These are used to reward brothers that have gone beyond the call of duty and represented a trait that is picked by the Brotherhood committee. 

**General:**
Brothers are presented the trait and its definition. They select a brother’s name from an alphabetical list of all brothers that have not already won HIRLy in the past school year and write a quick reason as to why they believe that brother deserves to win. The nominations themselves are kept anonymous, but each user will be marked as having submitted a vote as to prevent multiple submissions.
All brothers can also opt to look at a list of archived HIRLy votes. These list the date and trait of the vote, as well as a list of winners. Clicking on these winners leads the brother to view all of the reasons submitted for why they deserved to win.

**Admin:**
The Brotherhood committee chair and President are able to create new HIRLy votes and archive or permanently delete current open ones. If a new vote is created while one is already open, it automatically archives the current open vote. They can also swipe left to permanently delete archived HIRLy votes.
#### Anonymous/Current Votes
These are votes that are decided anonymously during the meeting. They only survive for about an hour before the results are automatically archived.

**General:**
Brothers can vote “Yes”, “No”, or “Abstain” on all anonymous votes. They must enter the correct randomly generated code to be able to vote on the topic. The brother is then marked as having submitted a vote, and the “Yes”, “No”, or “Abstain” counter is incremented based on their selection.

**Admin:**
The President and Parliamentarian have the ability to create votes and forcibly archive them. They open a vote by creating a summary and description (similar to HIRLy), and are then shown a randomly generated string of six characters that the brothers need to submit their vote. They are also the only ones capable of viewing the list of archived current votes (and swiping left to permanently delete them if desired).
### Attendance
This section allows brothers two actions: checking into meetings and viewing the roster.
#### Check-In
Brothers use this screen to make sure they are marked as “present” during a current session. An important note to make is that by National’s rules, only Active and Associate members are able to check into a meeting. Therefore, any other membership status will not be able to see the check-in screen.

**General:**
Brothers enter the session code for the current meeting to check-in.

**Admin:**
The President, Recording Secretary, or Vice President can start the meeting. When created, a randomly generated session code is shown. This code allows everyone to check-in. After the meeting, an administrator can then end the meeting. They can then look at all of the archived meetings ordered by date to see the start and end times of the meeting, as well as the list and total number of brothers present.
#### Roster
Brothers can search through the database for a particular person by first and last name or nickname. This information is currently stored on a spreadsheet on the chapter’s Google Drive and is available to all members.

**General:**
Tapping a brother’s name gives the current user their full name, nickname, roster number, status, phone number, education class, SLO address, birthday, instrument, and expected graduating quarter. If they click on their own info, they have the ability to change all but their roster number and status.

**Admin:**
The President and Recording Secretary have the ability to change any of the above listed fields for any brother except for roster number. The Webmaster and President will also have the ability to change that brother’s admin privileges and delete the user if desired.
##More
This section includes items that don’t fit into any of the above categories. Any user has the ability to go directly to their info (which is the same as their roster screen details). They can log out of the app, and they can follow a link to the iotapi.com webpage. They also are able to change their password here, which is especially important for those who don’t want to remember the randomly generated one they received on account creation.

**Admin:**
The President and Webmaster will have the additional option of validating any users pending validation. They can validate one or more users at once, or swipe left to delete any pending user if they do not wish to validate them.
