return {
	s({
		trig = "usage-script",
		filetype = "all",
		desc = "Create a script with usage information in comments",
	}, {
		t({
			"#!/usr/bin/env -S usage bash",
			'#USAGE flag "-f --force" help="Overwrite existing <file>"',
			'#USAGE flag "-u --user <user>" help="User to run as"',
			'#USAGE arg "<file>" help="The file to write" default="file.txt"',
		}),
	}),
}
