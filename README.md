# Slackzilla

This Bugzilla extension does one very simple thing: Posts messages to
Slack/Mattermost whenever a user changes a bug.

## Instructions

1. Clone this project into your bugzilla extensions directory. Don't worry, the
	_disabled_ file will prevent the extension from being loaded (which is wise,
	since you need to configure it first).
1. Get an incoming webhook token (copy the full URL) and put it in
	_$CONFIG{'slackURI'}_ in _Extension.pm_. (Yes, this is ugly. Hopefully one
	day this can be configured directly from a template in the bugzilla
	administration panel.)
1. Change the remaining settings (_channel_, _username_, _bugzillaURI_).
1. Adjust the message format to your liking (optional). The Bugzilla API
	documents can be very limited. If you know Perl you might also want to take
	a peak at the Bugzilla source code or other extension implementations.
1. Remove the disabled file.
1. Create a new bug or edit a bug and watch the extension fail miserably with a
	Perl error message.
1. Fix your or my mistake
1. Enjoy

## Limitations

Yes, most certainly! Contributions are welcome!
