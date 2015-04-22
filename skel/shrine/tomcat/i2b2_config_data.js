{
  urlProxy: "/shrine-proxy/request",	
	urlFramework: "js-i2b2/",
	loginTimeout: 15, // in seconds
	//JIRA|SHRINE-519:Charles McGow
	username_label:"test username:", //Username Label
	password_label:"test password:", //Password Label
	//JIRA|SHRINE-519:Charles McGow
	// -------------------------------------------------------------------------------------------
	// THESE ARE ALL THE DOMAINS A USER CAN LOGIN TO
	lstDomains: [
		{
		    domain: "I2B2_DOMAIN_ID",
		    name: "SHRINE_NODE_NAME",
		    debug: true,
		    allowAnalysis: true,
		    urlCellPM: "http://I2B2_PM_IP/i2b2/services/PMService/"
		}
	]
	// -------------------------------------------------------------------------------------------
}
