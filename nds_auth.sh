#!/bin/sh

# Get the current Date/Time for the log
date=$(date)

#
# Get the action method from NDS ie the first command line argument.
#
# Possible values are:
# "auth_client" - NDS requests validation of the client
# "client_auth" - NDS has authorised the client
# "client_deauth" - NDS has deauthorised the client
# "idle_deauth" - NDS has deauthorised the client because the idle timeout duration has been exceeded
# "timeout_deauth" - NDS has deauthorised the client because the session length duration has been exceeded
# "ndsctl_auth" - NDS has authorised the client because of an ndsctl command
# "ndsctl_deauth" - NDS has deauthorised the client because of an ndsctl command
# "shutdown_deauth" - NDS has deauthorised the client because it received a shutdown command
#
action=$1

if [ $action == "auth_client" ]; then
       #
       # The redir parameter is sent to this script as the fifth command line argument in url-encoded form.
       #
       # In the case of a simple splash.html login, redir is the URL originally requested by the client CPD.
       #
       # In the case of PreAuth or FAS it MAY contain not only the originally requested URL
       # but also a payload of custom variables defined by Preauth or FAS.
       #
       # It may just be simply url-encoded (fas_secure_enabled 0 and 1), or
       # aes encrypted (fas_secure_enabled 2)
       #
       # The username and password variables may be passed from splash.html, FAS or PreAuth and can be used
       # not just as "username" and "password" but also as general purpose string variables to pass information to BinAuth.
       #
       # The client User Agent string is sent as the sixth command line argument.
       # This can be used to determine much information about the capabilities of the client.
       # In this case it will be added to the log.
       #
       # Both redir and useragent are url-encoded, so decode:
       redir_enc=$5
       redir=$(printf "${redir_enc//%/\\x}")
       useragent_enc=$6
       useragent=$(printf "${useragent_enc//%/\\x}")

       # Append to the log.
       printf "$date\n method=$1\n clientmac=$2\n clientip=$7\n username=$3\n password=$4\n redir=$redir\n useragent=$useragent" >> /tmp/binauth.log
else
       printf "$date\n method=$1\n clientmac=$2\n bytes_incoming=$3, bytes_outgoing=$4\n session_start=$5, session_end=$6\n---" >> /tmp/binauth.log
fi


# Set length of session in seconds (eg 24 hours is 86400 seconds - if set to 0 then defaults to global sessiontimeout value):
session_length=0
# The session length could be determined by FAS or PreAuth, on a per client basis, and embedded in the redir variable payload.

# Finally before exiting, output the session length, followed by two integers (reserved for future use in traffic shaping)

echo $session_length 0 0

# exit 0 tells NDS is is ok to allow the client to have access.
# exit 1 would tell NDS to deny access.

exit 0