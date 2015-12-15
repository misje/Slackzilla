# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# This Source Code Form is "Incompatible With Secondary Licenses", as
# defined by the Mozilla Public License, v. 2.0.

# Copyright © 2015 Andreas Misje

package Bugzilla::Extension::Slackzilla;
use strict;

use constant NAME => 'Slackzilla';

# TODO: Not tested (run check_requirements to check?):
use constant REQUIRED_MODULES => [
	{
		package => 'libwww-perl',
		module => 'LWP::UserAgent',
		version => 0,
	},
	{
		package => 'HTTP-Message',
		module => 'HTTP::Request::Common',
		version => 0,
	},
	{
		package => 'JSON',
		module => 'JSON',
		version => 0,
	},
];

use constant OPTIONAL_MODULES => [
];

__PACKAGE__->NAME;
