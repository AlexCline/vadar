VADAR - Vigilant Active Directory AuditoR
=========================================

Vadar will keep AD and BP in sync and generate useful reports.

When an account in AD is created, it will need either an IBM Serial Number (in the serialNumber field), or a valid internet address (in the mail field).  The script will then try to synchronize the following information based off those two items:

- Serial Number
- Internet Address
- Manager's Serial Number
- Manager's Internet Address
- Job Title
- Phone number
- Description field (FULLNAME;SERIAL;INTERNETID)

Examples
--------

	# Run the default task to sync AD and BP and print the results to the console
    ./vadar.rb

    # Run the default task and print it in a format for emailing
    ./vadar.rb --format=email

    # Run the quarterly employment verification and format for emailing
    ./vadar.rb quarterly_report --format=email

    # Check for expired passwords
    ./vadar.rb check_expired

    # Check for expiring passwords and send emails to users
    ./vadar.rb notify_expiring

To Dos
------

- Implement expiring/expired passwords check
- Sync job title
- Sync phone number

Note
----

_The file 'config/env_vars.rb' contains the required AD bind credentials and is not tracked in git._
