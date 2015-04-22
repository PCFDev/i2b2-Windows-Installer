//TODO: Can we not include this entire file?

// this file contains a list of all files that need to be loaded dynamically for this i2b2 Cell
// every file in this list will be loaded after the cell's Init function is called
{
	files: [
		"SHRINE_ctrl.js",
		"i2b2_msgs.js"
	],
	css: [],
	config: {
		// additional configuration variables that are set by the system
		name: "SHRINE Cell",
		description: "SHRINE Cell",
		category: ["core","cell","shrine"],
		newTopicURL: "https://shrine.catalyst.harvard.edu/sheriff/logon",
		readApprovedURL:"https://SHRINE_IP:SHRINE_SSL_PORT/shrine/rest/i2b2/"
	}
}
