# S3-Filer-Mailer V0.1
Simple bash script checks when new files have been uploaded to an S3 bucket and emails those files as a compressed attachment. Useful for keeping tabs on S3-backed web forms.

By [Josh Wieder](http://joshwieder.net)
[@jwieder](https://github.com/jwieder)

### Prerequisities
* [AWS Command Line Interface](https://docs.aws.amazon.com/cli/latest/userguide/installing.html)
* [Python](https://www.python.org/downloads/) version 2 above 2.6.5 or version above 3.3
* [Mailx](http://linux.die.net/man/1/mailx)
* Functioning email (you don't need your own mail server, but mailx needs to be able to send messages)

### Instructions
This program contains two files: an executable bash file, `S3-Filter-Mailer.sh`, and a configuration file `S3-Filter-Mailer.conf`. The configuration file contains four variables:

1. **BUCKETURL**
  * `BUCKETURL` is the URL of your S3 bucket. MUST include the `s3://` prefix and must OMMIT a trailing slash (`/`). This is the only configuration option that **must** be changed in order to successfully execute the script.
    * Ex. `BUCKETURL=s3://bucket.example.com`
2. **FOLDER**
  * `FOLDER` can be used to specify a directory within your S3 bucket for notifications. If you want this script to send you notifications about new files uploaded to the root directory of your bucket, assign this variable a single `/` character. Tracks the root directory of your bucket and all subdirectories by default.
    * Ex. Tracks files in a directory named messages: `FOLDER=/messages/`
	* Ex. Tracks files in the root directory of your S3 bucket: `FOLDER=/` *(default)*
3. **EMAILADDY**
  * `EMAILADDY` is the email address you want to send notifications and file attachments to. Sends to local root account mailbox by default. Currently multiple email addresses are not supported. Until this is updated, I would suggest sending notifications to a mailing list or similar if multiple simultaneous email notifications are required.
    * Ex. The easiest option is to add a single email address: `EMAILADDY=email@example.com`
	* Ex. Email addresses that are also local accounts, or local accounts that are aliases to email addresses, can be referenced like this: `EMAILADDY=root` *(default)*
4. **LOG**
  * `LOG` must include the filename and path to a where error logs can be written.  The directory should be writable to whatever user you choose to run the mailer script as. By default, the script writes to `/var/log/s3contacts.log`.
    * Ex. `LOG=/var/log/s3contacts.log` *(default)*

### Updates
There are a few things that need to be done to tidy this up. Pull requests that address these or other issues I haven't thought of are welcome. Here are the major issues:

* Accept command line arguments, ex. bucket, log file, help menu, reassign configuration and log file paths, etc.
* Implement error-handling.
* Accept regex pattern identification for file notifications in addition to or as an alternative to file dates.
* Support for multiple email addresses.
* Local indexing to relieve charges associated with S3 bucket file listing requests (see below)

### Note about AWS charges
In what is either an over-sight or an incredibly shrewd form of penny-pinching, AWS both charges for file listing requests on S3 buckets thta contain over 1,000 files *and* has not implemented basic functionality to filter such file listings by date, size or other properties. While this script can help with limiting charges associated with SNS, this script can result in charges for S3 file listings if configured to track directories containing over 1,000 files. I have some ideas about how to limit these charges by introducing a local index, but introducing such functionality without integration into the application(s) creating the files in a users S3 bucket is problematic, to say the least.
