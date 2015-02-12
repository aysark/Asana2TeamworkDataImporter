# Asana To Teamwork Data Importer/Transfer

# about
Switching from Asana to Teamwork?

Have a ton of existing data on Asana that you want to import to TW?

Data such as projects and tasks?

Look no further, this script has you covered! (but makes no gaurantees! use at own risk)

# how to run
Be sure to have ruby 2.0.0, may work on 1.9.3

Also install the rest-client gem

And add your api keys and asana workspace id

From cmd line, navigate to location of file and call ruby a2tw.rb

# other notes
Sometimes might glitch out with a 4XX error, usually due to rate limiting on TW.

This does not support overwriting/fixing existing projects in a TW account in such a case, it'll just skip it (but tell you that it did)

If running on windows and get SSL cert error, download cacert.pem first and cmd:
set SSL_CERT_FILE=C:\Ruby200\cacert.pem
