<!---
	Invocation of the CF-Alexa Framework
--->

<cfcomponent extends="Alexa">

	<!--- 
	Define your intents here 
	
	The framework will automatically call the associated function
	and pass slot values as arguments. This functions as a mapping, so 
	you can use a different function name than in your intent_schema.json.
	I advise against for clarity, but the option is available.
	
	--->

	<cfset this.intents = {
		"getParkDescription"  = "getParkDescription",
		"getParkAlerts"  = "getParkAlerts",
		"getParkNews"  = "getParkNews",
		"getParksByState"  = "getParksByState",
		"getDYKFact"  = "getDYKFact",
		"AMAZON.HelpIntent" = "onHelp",
		"AMAZON.CancelIntent" = "onStop",
		"AMAZON.StopIntent" = "onStop",
		"AMAZON.NoIntent" = "onStop",
		"AMAZON.YesIntent" = "onContinue"
	}>
	
	<cfset this.api_base="http://developer.nps.gov/api/v0/" />
	<cfset this.api_headers = { "Authorization":"XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX" } />




	<!---
	
		INTENT Handlers
	
	--->

	<cffunction name="onContinue" access="public" returntype="void">

		<cfset local.lastIntent = getLastIntent()>

		<cfif structkeyexists(local.lastintent,"intent")>
			<!--- Special handling for particular intents --->
			<cfswitch expression="#local.lastintent.intent#">
				<!--- Holdover from Steve Drucker's original code
				<cfcase value="eventCalendarSearchIntent">
					<cfset say("Ok. I'm Listening...")>
				</cfcase>
				--->
				<cfdefaultcase>
					<cfset onHelp()>
				</cfdefaultcase>
			</cfswitch>
		<cfelse>
			<cfset onHelp()>
		</cfif>

	</cffunction>
	
	<cffunction name="getParkDescription" access="public" returntype="void">
		<cfargument name="Park" type="string" required="no" default="">

		<cfset local.park_name = trim(arguments.Park) />
		
		<!--- Parse park_name --->
		<cfset local.park_code = getParkCode(local.park_name) />
				
		<cfif local.park_code neq "none">
			<!--- Call NPS API to get park description --->
			<cftry>
				<cfhttp url="#this.api_base#index.cfm?endpoint=%2Fparks&parkCode=#local.park_code#" method="get" result="local.parkData" timeout="5">
					<cfloop collection="#this.api_headers#" item="local.header_name">
						<cfhttpparam name="#local.header_name#" type="header" value="#this.api_headers[local.header_name]#" />
					</cfloop>
				</cfhttp>
				<cfcatch>
					<!--- Timeout or other HTTP error --->
					<cflog text="#SerializeJSON(cfcatch)#" type="information" file="alexa_debug" />
				</cfcatch>
			</cftry>
			
			<cfset local.returnJSON = DeserializeJSON(local.parkData.filecontent) />
			
			<!--- say(ParkDescription) --->			
			<cfif local.returnJSON.total gt 0>
				<cfset say(local.returnJSON.data[1].description) />
			<cfelse>
				<!--- No corresponding record --->
				<cfset say("I did not find #local.park_name#") />
			</cfif>

		<cfelse>
			<!--- parse of site_name failed to find a result --->
			<cfset say("I did not find #local.park_name#") />
		</cfif>

	</cffunction>


	<cffunction name="onStop" access="public" returntype="void">

		<cfset say("Goodbye.")>
		<cfset endSession()>

	</cffunction>

	<cffunction name="onHelp" access="public" returntype="void">

		<cfset say("To get information about a park, say tell me about a park")>
		<cfset say("To hear about active alerts for a park, say give me the alerts for a park")>
		<cfset say("To hear about recent news from a park, say give me the news for a park")>
		<cfset say("To get a list of national parks in a state, say what are the parks in a state")>


	</cffunction>
	
	<cffunction name="getParkAlerts" access="public" returntype="void">
		<cfargument name="Park" type="string" required="no">
		
		<cfset local.park_name = trim(arguments.Park) />
		
		<!--- Parse park_name --->
		<cfset local.park_code = getParkCode(local.park_name) />
		
		<cfif local.park_code neq "none">
			<!--- Call NPS API to get park description --->
			<cftry>
				<cfhttp url="#this.api_base#index.cfm?endpoint=%2Falerts&parkCode=#local.park_code#" method="get" result="local.alertData" timeout="5">
					<cfloop collection="#this.api_headers#" item="local.header_name">
						<cfhttpparam name="#local.header_name#" type="header" value="#this.api_headers[local.header_name]#" />
					</cfloop>
				</cfhttp>
				<cfcatch>
					<!--- Timeout or other HTTP error --->
					<cflog text="#SerializeJSON(cfcatch)#" type="information" file="alexa_debug" /> 
				</cfcatch>
			</cftry>
			
			<cfset local.returnJSON = DeserializeJSON(local.alertData.filecontent) />
			<!--- Read off alerts --->			
			<cfif local.returnJSON.total gt 0>
				<cfset local.alert_output = "I found #local.returnJSON.total# alerts. " />
				<cfloop array="#local.returnJSON.data#" index="local.thisAlert">
					<!---<cfset local.alert_output &= "#local.thisAlert.category#: #local.thisAlert.title#. " /> --->
					<!---  ---><cfset local.alert_output &= "#local.thisAlert.category#: #local.thisAlert.title#. #local.thisAlert.description# " />
				</cfloop>

				<cfset say(local.alert_output) />
			<cfelse>
				<!--- No alerts --->
				<cfset say("There are no active alerts for #local.park_name#") />
			</cfif>

		<cfelse>
			<!--- parse of site_name failed to find a result --->
			<cfset say("I did not find #local.park_name#") />
		</cfif>

	</cffunction>
	
	<cffunction name="getParkNews" access="public" returntype="void">
	
		<cfargument name="Park" type="string" required="no">
		
		<cfset local.park_name = trim(arguments.Park) />

		<!--- Parse park_name --->
		<cfset local.park_code = getParkCode(local.park_name) />
		
		<cfif local.park_code neq "none">
			<!--- Call NPS API to get park description --->
			<cftry>
				<cfhttp url="#this.api_base#index.cfm?endpoint=%2Fnews&parkCode=#local.park_code#&limit=5" method="get" result="local.newsData" timeout="5">
					<cfloop collection="#this.api_headers#" item="local.header_name">
						<cfhttpparam name="#local.header_name#" type="header" value="#this.api_headers[local.header_name]#" />
					</cfloop>
				</cfhttp>
				<cfcatch>
					<!--- Timeout or other HTTP error --->
					<cflog text="#SerializeJSON(cfcatch)#" type="information" file="alexa_debug" /> 
				</cfcatch>
			</cftry>
			
			<cfset local.returnJSON = DeserializeJSON(local.newsData.filecontent) />
			<!--- Read off alerts --->			
			<cfif local.returnJSON.total gt 0>
				<cfset say("Here are the most current news items for #local.park_name#. ")>
				<cfloop array="#local.returnJSON.data#" index="local.thisNews">
					<cfset news_output = "News release: #local.thisNews.title#. #local.thisNews.abstract# " />
					<cfset say(news_output) />
				</cfloop>
			<cfelse>
				<!--- No alerts --->
				<cfset say("I did not find any news for #local.park_name#") />
			</cfif>

		<cfelse>
			<!--- parse of site_name failed to find a result --->
			<cfset say("I did not find #local.park_name#") />
		</cfif>

	</cffunction>
	
	<cffunction name="getParksByState" access="public" returntype="void">
		<cfargument name="State" type="string" required="no">

		<cfset local.state_name = trim(arguments.State) />

		<!--- Parse state_name --->
		<cfset local.state_code = getStateCodeFromStateName(local.state_name) />

		<cfif local.state_code neq "none">
			<!--- Call NPS API to get parks --->
			<cftry>
				<cfhttp url="#this.api_base#index.cfm?endpoint=%2Fparks&stateCode=#local.state_code#" method="get" result="local.parkData" timeout="5">
					<cfloop collection="#this.api_headers#" item="local.header_name">
						<cfhttpparam name="#local.header_name#" type="header" value="#this.api_headers[local.header_name]#" />
					</cfloop>
				</cfhttp>
				<cfcatch>
					<!--- Timeout or other HTTP error --->
					<cflog text="#SerializeJSON(cfcatch)#" type="information" file="alexa_debug" /> 
				</cfcatch>
			</cftry>
			
			<cfset local.returnJSON = DeserializeJSON(local.parkData.filecontent) />
			<!--- Read off alerts --->			
			<cfif local.returnJSON.total gt 0>
				<cfset say("Here are the parks in #local.state_name#. ")>
				<cfloop array="#local.returnJSON.data#" index="local.thisPark">
					<cfset park_output = "#local.thisPark.fullName#. " />
					<cfset say(park_output) />
				</cfloop>
			<cfelse>
				<!--- No alerts --->
				<cfset say("I did not find any parks in #local.state_name#") />
			</cfif>

		<cfelse>
			<!--- parse of state_name failed to find a result --->
			<cfset say("I did not find #local.state_name#") />
		</cfif>

	</cffunction>
		
	<cffunction name="getDYKFact" access="public" returntype="void">
		<cfargument name="Park" type="string" required="no" default="">

		<cfset local.park_name = trim(arguments.Park) />
		
		<!--- Parse park_name --->
		<cfset local.park_code = getParkCode(local.park_name) />
				
		<cfif local.park_code neq "none">
			<!--- Pull in DYK.json --->
			<cftry>
				<cfhttp url="DYK.json" method="get" result="local.dykData" timeout="5"></cfhttp>
				<cfcatch>
					<!--- Timeout or other HTTP error --->
					<cflog text="#SerializeJSON(cfcatch)#" type="information" file="alexa_debug" />
				</cfcatch>
			</cftry>
			<cfset local.returnJSON = DeserializeJSON(local.dykData.filecontent) />
			<cfset local.factArray = ArrayNew(1) />
			<cfloop array="#local.returnJSON#" index="thisFact">
				<cfif thisFact.alphacode eq '#local.park_code#'>
					<cfset ArrayAppend(local.factArray, thisFact) />
				</cfif>
			</cfloop>
			<cflog text="#SerializeJSON(local.factArray)#" type="information" file="alexa_debug" />
			<cfif ArrayLen(local.returnJSON)>
				<cfset theFactIndex = RandRange(1, ArrayLen(local.returnJSON)) />
				<cfset say(local.returnJSON[theFactIndex].fact) />
			<cfelse>
				<!--- No corresponding record --->
				<cfset say("I can't find a fact for #local.park_name#. ") />
			</cfif>

		<cfelse>
			<!--- parse of site_name failed to find a result --->
			<cfset say("I did not find #local.park_name#") />
		</cfif>
		
	</cffunction>
	
	<cffunction name="onLaunch" access="public" returntype="void">
		<cfargument name="sessionInfo" required="yes">


		<cfset super.onLaunch(arguments.sessionInfo)>
		
		<cfset say("Welcome to the Alexa NPS Ranger skill. You can ask me for descriptions, alerts, or news for any national park service site.")>
	</cffunction>
	
	<!---
	
		Helper Functions
		
	--->
	
	<cffunction name="getParkCode" access="private" hint="Returns park code from a full or partial park name." returntype="string">
		<cfargument name="park_name" type="string" required="yes" />
		
		<cfset local.park_name = trim(arguments.park_name) />
		
		<!--- Eventually want this to be outside this script --->
		<cfset local.park_struct = { 
				"acadia" = "acad", 
				"acadia national park": "acad", 
				"cuyahoga valley": "cuva", 
				"cuyahoga valley national park": "cuva", 
				"denali": "dena", 
				"denali national park": "dena", 
				"denali national park and preserve": "dena", 
				"great sand dunes": "grsa", 
				"great sand dunes national park": "grsa", 
				"great sand dunes national park and preserve": "grsa", 
				"joshua tree": "jotr", 
				"joshua tree national park": "jotr", 
				"yellowstone": "yell", 
				"yellowstone national park": "yell"
			} />

		<cfset local.park_code_struct = StructFindKey( local.park_struct, local.park_name ) />
		
		<cfif ArrayLen(local.park_code_struct)>
			<cfset local.park_code = local.park_code_struct[1].value />
		<cfelse>
			<cfset local.park_code = 'none' />
		</cfif>

		<cfreturn local.park_code />
	
	</cffunction>
	
	<cffunction name="getStateCodeFromStateName" access="private" returntype="string">
		<cfargument name="state_name" type="string" required="yes">
		
		<cfset local.state_name = trim(arguments.state_name) />
		<cfset local.state_struct = { "Alabama":"AL","Alaska":"AK","Arizona":"AZ","Arkansas":"AR","California":"CA","Colorado":"CO","Connecticut":"CT","Delaware":"DE","District of Columbia":"DC","Florida":"FL","Georgia":"GA","Hawaii":"HI","Idaho":"ID","Illinois":"IL","Indiana":"IN","Iowa":"IA","Kansas":"KS","Kentucky":"KY","Louisiana":"LA","Maine":"ME","Maryland":"MD","Massachusetts":"MA","Michigan":"MI","Minnesota":"MN","Mississippi":"MS","Missouri":"MO","Montana":"MT","Nebraska":"NE","Nevada":"NV","New Hampshire":"NH","New Jersey":"NJ","New Mexico":"NM","New York":"NY","North Carolina":"NC","North Dakota":"ND","Ohio":"OH","Oklahoma":"OK","Oregon":"OR","Pennsylvania":"PA","Puerto Rico":"PR","Rhode Island":"RI","South Carolina":"SC","South Dakota":"SD","Tennessee":"TN","Texas":"TX","Utah":"UT","Vermont":"VT","Virginia":"VA","Washington":"WA","West Virginia":"WV","Wisconsin":"WI","Wyoming":"WY","American Samoa":"AS","Federated States of Micronesia":"FM","Guam":"GU","Marshall Islands":"MH","Northern Mariana Islands":"MP","Palau":"PW","Virgin Islands":"VI" } />

		<cfif len(local.state_name) eq 2>
			<!--- IL --->
			<cfset local.state_code = local.state_name />
		<cfelseif len(local.state_name eq 4) and local.state_name contains '.'>
			<!--- I.L. --->
			<cfset local.state_code = replace(local.state_name, '.', '', "ALL") />
		<cfelse>
			<!--- Illinois --->
			<cfset local.state_code_struct = StructFindKey( local.state_struct, local.state_name ) />
			
			<cfif ArrayLen(local.state_code_struct)>
				<cfset local.state_code = local.state_code_struct[1].value />
			<cfelse>
				<cfset local.state_code = 'none' />
			</cfif>
		</cfif>
		
		<cfreturn local.state_code />
	</cffunction>




</cfcomponent>