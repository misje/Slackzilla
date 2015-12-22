# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# This Source Code Form is "Incompatible With Secondary Licenses", as
# defined by the Mozilla Public License, v. 2.0.

# Simple Bugzilla⟷Slack/Mattermost integration, posting messages whenever a
# bug is changed by a user.
#
# Copyright © 2015 Andreas Misje

package Bugzilla::Extension::Slackzilla;
use strict;
use utf8;
use base qw(Bugzilla::Extension);
use HTTP::Request::Common;
use JSON;
use LWP::UserAgent;

our $VERSION = '0.01';

# TODO: Inject a form in the admin panel where these can be set:
my %CONFIG = (
	#slackURI => 'https://mattermost.example.org/hooks/somewhatLongH4sh',
	username => 'bugzilla',
	# Channel is optional when using Mattermost, in which case the 
	#channel => 'devchat',
	#iconURI => 'http://my.fancy/icon.png/',
	#bugzillaURI => 'http://bugs.example.org/',
);

my $userAgent = LWP::UserAgent->new();

# Since bug_end_of_update is called also when bugs are created (and since I
# have found no good way to detect whether bug_end_of_update is called on a
# new bug object), keep the following message simple. All the details of the
# new bug will be posted in the following bug_end_of_update event.
sub bug_end_of_create {
	my (undef, ($args)) = @_;
	my $bug = $$args{'bug'};
	my $user = Bugzilla->user->name;
	my $id = $bug->id;
	my $product = $bug->product;
	my $component = $bug->component;
	my $link = "$CONFIG{'bugzillaURI'}/show_bug.cgi?id=$id";

	my %jsonObj = (
		icon_emoji => ':bug:',
		# The Slack link syntax does not work in Mattermost. Use Markdown
		# instead:
		#text => "New <$link|bug $id> in $product/$component",
		text => "New [bug $id]($link) in $product/$component",
	);
	sendData(%jsonObj);
}

sub bug_end_of_update {
	my (undef, $args) = @_;
	my $user = Bugzilla->user->name;
	my ($bug, $oldBug, $changes) = @$args{qw(bug old_bug changes)};
	my $id = $bug->id;
	my $summary = $bug->short_desc;
	my $status = $bug->status->name;
	my $assignedTo = $bug->assigned_to->name;
	my $assignedToEMail = $bug->assigned_to->email;
	my $severity = $bug->bug_severity;
	my $product = $bug->product;
	my $component = $bug->component;
	# First comment is the bug description, and the remaining comments are in a
	# reverse order:
	my $description = ${$bug->comments}[0]->body;
	my $lastComment = ($#{$bug->comments} ? ${$bug->comments}[1]->body : $description);
	my $link = "$CONFIG{'bugzillaURI'}/show_bug.cgi?id=$id";

	my %attachment = (
		# The Slack link syntax does not work in Mattermost. Use Markdown
		# instead:
		#fallback => "<$link|Bug $id> ($summary) in $product/$component changed",
		#pretext => "<$link|Bug $id> in $product/$component changed",
		fallback => "[Bug $id]($link) ($summary) in $product/$component changed",
		pretext => "[Bug $id]($link) in $product/$component changed",
		title => $summary,
		title_link => $link,
		# %$changes may be empty (when a comment is added, for instance). Not
		# sure what to write … so let's just be honest and write just that:
		text => "$user changed " . (%$changes ? join(', ', keys %$changes) : 
			'… something') . "\n\n$lastComment",
		fields => [
			{
				title => 'Assigned to',
				# The Slack link syntax does not work in Mattermost. Use Markdown
				# instead:
				#value => "<mailto:$assignedToEMail|$assignedTo>",
				value => "[$assignedTo](mailto:$assignedToEMail)",
				short => 'true',
			},
			{ title => 'Status', value => $status, short => 'true' },
			{ title => 'Severity', value => $severity, short => 'true' },
			{ title => 'Version', value => $bug->version, short => 'true' },
			{ title => 'Depends on', value => join(', ', @{$bug->dependson}), short => 'true' },
		],
	);

	my %jsonObj = (
		icon_emoji => ':bug:',
		attachments => [ \%attachment ],
	);
	sendData(%jsonObj);
}

sub sendData {
	my (%jsonObj) = @_;
	$jsonObj{'username'} = $CONFIG{'username'};
	$jsonObj{'icon_url'} = $CONFIG{'iconURI'} if exists $CONFIG{'iconURI'};
	$jsonObj{'channel'} = $CONFIG{'channel'} if exists $CONFIG{'channel'};

	my $jsonText = encode_json \%jsonObj;
	$userAgent->post($CONFIG{'slackURI'}, [ 'payload' => $jsonText ]);
}

__PACKAGE__->NAME;
