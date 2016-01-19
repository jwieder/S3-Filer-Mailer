# S3-Filer-Mailer V0.1
Simple bash script checks when new files have been uploaded to an S3 bucket and emails those files as a compressed attachment. Useful for keeping tabs on S3-backed web forms.

By @jwieder

### Prerequisities
	- [AWS Command Line Interface](https://docs.aws.amazon.com/cli/latest/userguide/installing.html)
	- [Python](https://www.python.org/downloads/) version 2 above 2.6.5 or version above 3.3
	- [mailx](http://linux.die.net/man/1/mailx)
	- functioning email (you don't need a mail server, but mailx needs somewhere to send to)

### Instructions
This program contains two files: an executable bash file, S3-Filter-Mailer.sh, and a configuration file S3-Filter-Mailer.conf. The configuration file contains four variables:

1. BUCKETURL
  * BUCKETURL is the URL of your S3 bucket. MUST include the s3:// prefix and must OMMIT a trailing slash. This is the only configuration option that **must** be changed in order to successfully execute the script.
    * Ex. BUCKETURL=s3://bucket.example.com
2. FOLDER
  * FOLDER can be used to specify a directory within your S3 bucket for notifications. If you want this script to send you notifications about new files uploaded to the root directory of your bucket, assign this variable a single / character. Tracks the root directory of your bucket and all subdirectories by default.
    * Ex. FOLDER=/messages/	##### Tracks files in a directory named messages
	* Ex. FOLDER=/			##### Tracks files in the root directory of your S3 bucket (default)
3. EMAILADDY
  * EMAILADDY is the email address you want to send notifications and file attachments to. Sends to local root account mailbox by default.
    * Ex. EMAILADDY=email@example.com  
	* Ex. root				##### Email addresses that are also local accounts, or local accounts that are aliases to email addresses, can be referenced like this. (default)
4. LOG
  * LOG must include the filename and path to a where error logs can be written.  The directory should be writable to whatever user you choose to run the mailer script as. By default, the script writes to /var/log/s3contacts.log.
    * Ex. LOG=/var/log/s3contacts.log (default).   

### Updates
There are a few things that need to be done to tidy this up. I'm happy to confirm pull requests that address these or other issues I haven't thought of. Here are the major issues:

* Accept command line arguments, ex. bucket, log file, help menu, reassign configuration and log file paths, etc.
* Implement error-handling.
* Accept regex pattern identification for file notifications in addition to or as an alternative to file dates.