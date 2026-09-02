return {
	s({
		trig = "uuid",
		filetype = "all",
		desc = "Generate a UUIDv4",
	}, {
		f(require("rbar/helpers").generate_uuid, {}),
	}),
}
