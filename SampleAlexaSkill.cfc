<!---
Sample invocation of the CF-Alexa Framework
--->

<cfcomponent extends="Alexa">

	<!--- 
	Define your intents here 
	
	The framework will automatically call the associated function
	and pass slot values as arguments.
	
	--->

	<cfset this.intents = {
		"getParkDescription"  = "getParkDescription",
		"getRandomParkDescription" = "getRandomParkDescription",
		"getParkAlerts"  = "getParkAlerts",
		"getParkContacts"  = "getParkContacts",
		"getParkDirections"  = "getParkDirections",
		"getParkEvents"  = "getParkEvents",
		"getParkNews"  = "getParkNews",
		"getParksByState"  = "getParksByState",
		"getRandomDYK"  = "getRandomDYK",
		"getParkDYK"  = "getParkDYK",
		"AMAZON.HelpIntent" = "onHelp",
		"AMAZON.CancelIntent" = "onStop",
		"AMAZON.StopIntent" = "onStop",
		"AMAZON.NoIntent" = "onStop",
		"AMAZON.YesIntent" = "onContinue"
	}>
	
	<cfset this.api_base="http://developer.nps.gov/api/v1/" />
	<!--- Update the dyk_base URI to point at wherever you host this JSON --->
	<cfset this.dyk_base = "http://developer.nps.gov/assets/components/alexa/DYK.json" />
	<cfset this.api_headers = { "Authorization":"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" } />




	<!---
	
	INTENT Handlers
	
	--->

	<cffunction name="onContinue" access="public" returntype="void">

		<cfset local.lastIntent = getLastIntent()>

		<cfif structkeyexists(local.lastintent,"intent")>
			<!--- Special handling for particular intents --->
			<cfswitch expression="#local.lastintent.intent#">
				<!---<cfcase value="onContinue">
					<cfset say("Ok. I'm Listening...")>
				</cfcase>--->
				<cfdefaultcase>
					<cfset onHelp()>
				</cfdefaultcase>
			</cfswitch>
		<cfelse>
			<cfset onHelp()>
		</cfif>

	</cffunction>
	
	<cffunction name="getParkCode" access="private" hint="Returns park code from a full or partial park name." returntype="string">
		<cfargument name="park_name" type="string" required="yes" />
		
		<cfset local.park_name = trim(arguments.park_name) />
		<cflog text="#local.park_name#" type="information" file="alexa_debug" />
		<!--- Eventually want this to be outside this script --->
		<cfset local.park_struct = { 
				"abraham lincoln birthplace": "abli",
				"abraham lincoln birthplace national historical park": "abli",
				"acadia": "acad",
				"acadia national park": "acad",
				"adams": "adam",
				"adams national historical park": "adam",
				"African-American civil war memorial": "afam",
				"african burial ground": "afbg",
				"african burial ground national monument": "afbg",
				"agate fossil beds": "agfo",
				"agate fossil beds national monument": "agfo",
				"ala kahakai": "alka",
				"ala kahakai national historic trail": "alka",
				"alagnak": "alag",
				"alagnak wild river": "alag",
				"alaska public lands": "anch",
				"alcatraz": "alca",
				"alcatraz island": "alca",
				"Aleutian world war 2": "aleu",
				"aleutian world war ii": "aleu",
				"aleutian world war ii national historic area": "aleu",
				"alibates flint quarries": "alfl",
				"alibates flint quarries national monument": "alfl",
				"allegheny portage railroad": "alpo",
				"allegheny portage railroad national historic site": "alpo",
				"american memorial": "amme",
				"american memorial park": "amme",
				"amistad": "amis",
				"amistad national recreation area": "amis",
				"anacostia": "anac",
				"anacostia park": "anac",
				"andersonville": "ande",
				"andersonville national historic site": "ande",
				"andrew johnson": "anjo",
				"andrew johnson national historic site": "anjo",
				"aniakchak": "ania",
				"aniakchak national monument and preserve": "ania",
				"NEX shack": "ania",
				"Annie it check": "ania",
				"Annie at check": "ania",
				"any at chuck": "ania",
				"antietam": "anti",
				"antietam national battlefield": "anti",
				"apostle islands": "apis",
				"apostle islands national lakeshore": "apis",
				"appalachian": "appa",
				"appalachian national scenic trail": "appa",
				"appomattox court house": "apco",
				"appomattox court house national historical park": "apco",
				"arabia mountain": "armo",
				"arabia mountain national heritage area": "armo",
				"arches": "arch",
				"arches national park": "arch",
				"arkansas post": "arpo",
				"arkansas post national memorial": "arpo",
				"arlington house": "arho",
				"Robert evilly memorial": "arho",
				"Arlington house the Robert E lee memorial": "arho",
				"Robert E lee memorial": "arho",
				"assateague island": "asis",
				"assateague": "asis",
				"asset Teague": "asis",
				"asset Teague sea shore": "asis",
				"assateague island national seashore": "asis",
				"atchafalaya": "attr",
				"atchafalaya national heritage area": "attr",
				"augusta canal": "auca",
				"augusta canal national heritage area": "auca",
				"aztec ruins": "azru",
				"aztec ruins national monument": "azru",
				"badlands": "badl",
				"badlands national park": "badl",
				"baltimore": "balt",
				"baltimore national heritage area": "balt",
				"baltimore washington": "bawa",
				"baltimore washington parkway": "bawa",
				"bandelier": "band",
				"bandelier national monument": "band",
				"belmont paul women's equality": "bepa",
				"belmont paul women's equality national monument": "bepa",
				"bent's old fort": "beol",
				"bent's old fort national historic site": "beol",
				"bering land bridge": "bela",
				"bering land bridge national preserve": "bela",
				"big bend": "bibe",
				"big bend national park": "bibe",
				"big cypress": "bicy",
				"big cypress national preserve": "bicy",
				"big hole": "biho",
				"big hole national battlefield": "biho",
				"big south fork": "biso",
				"big south fork national river and recreation area": "biso",
				"big thicket": "bith",
				"big thicket national preserve": "bith",
				"bighorn canyon": "bica",
				"bighorn canyon national recreation area": "bica",
				"birmingham civil rights": "bicr",
				"birmingham civil rights national monument": "bicr",
				"biscayne": "bisc",
				"biscayne national park": "bisc",
				"black canyon of the gunnison": "blca",
				"black canyon of the gunnison national park": "blca",
				"blackstone river valley": "blrv",
				"blackstone river valley national historical park": "blrv",
				"blue ridge national heritage area": "blrn",
				"blue ridge": "blri",
				"blue ridge parkway": "blri",
				"bluestone": "blue",
				"bluestone national scenic river": "blue",
				"booker t washington": "bowa",
				"booker t washington national monument": "bowa",
				"boston african american": "boaf",
				"boston african american national historic site": "boaf",
				"boston harbor islands": "boha",
				"boston harbor islands national recreation area": "boha",
				"boston": "bost",
				"boston national historical park": "bost",
				"brices cross roads": "brcr",
				"brices cross roads national battlefield site": "brcr",
				"brown v. board of education": "brvb",
				"brown v. board of education national historic site": "brvb",
				"bryce canyon": "brca",
				"bryce canyon national park": "brca",
				"buck island reef": "buis",
				"buck island reef national monument": "buis",
				"buffalo": "buff",
				"buffalo river": "buff",
				"buffalo national river": "buff",
				"cabrillo": "cabr",
				"cabrillo national monument": "cabr",
				"cache la poudre river": "cala",
				"cache la poudre river national heritage area": "cala",
				"california": "cali",
				"california national historic trail": "cali",
				"canaveral": "cana",
				"canaveral national seashore": "cana",
				"cane river creole": "cari",
				"cane river creole national historical park": "cari",
				"cane river": "crha",
				"cane river national heritage area": "crha",
				"canyon de chelly": "cach",
				"canyon de chelly national monument": "cach",
				"canyonlands": "cany",
				"canyonlands national park": "cany",
				"cape cod": "caco",
				"cape cod national seashore": "caco",
				"cape hatteras": "caha",
				"cape hatteras national seashore": "caha",
				"cape henry memorial": "came",
				"cape henry memorial part of colonial national historical park": "came",
				"cape krusenstern": "cakr",
				"cape krusenstern national monument": "cakr",
				"cape lookout": "calo",
				"cape lookout national seashore": "calo",
				"capitol hill": "cahi",
				"capitol hill parks": "cahi",
				"capitol reef": "care",
				"capitol reef national park": "care",
				"captain john smith chesapeake": "cajo",
				"captain john smith chesapeake national historic trail": "cajo",
				"capulin volcano": "cavo",
				"capulin volcano national monument": "cavo",
				"carl sandburg home": "carl",
				"carl sandburg home national historic site": "carl",
				"carlsbad caverns": "cave",
				"carlsbad caverns national park": "cave",
				"carter g. woodson home": "cawo",
				"carter g. woodson home national historic site": "cawo",
				"casa grande ruins": "cagr",
				"casa grande ruins national monument": "cagr",
				"castillo de san marcos": "casa",
				"castillo de san marcos national monument": "casa",
				"castle clinton": "cacl",
				"castle clinton national monument": "cacl",
				"castle mountains": "camo",
				"castle mountains national monument": "camo",
				"catoctin mountain": "cato",
				"catoctin mountain park": "cato",
				"cedar breaks": "cebr",
				"cedar breaks national monument": "cebr",
				"cedar creek and belle grove": "cebe",
				"cedar creek and belle grove national historical park": "cebe",
				"cesar e. chavez": "cech",
				"Cesar E Chavez": "cech",
				"cesar e. chavez national monument": "cech",
				"chaco culture": "chcu",
				"chaco culture national historical park": "chcu",
				"chamizal": "cham",
				"chamizal national memorial": "cham",
				"champlain valley": "chva",
				"champlain valley national heritage partnership": "chva",
				"channel islands": "chis",
				"channel islands national park": "chis",
				"charles pinckney": "chpi",
				"charles pinckney national historic site": "chpi",
				"charles young": "chyo",
				"charles young buffalo soldiers": "chyo",
				"charles young buffalo soldiers national monument": "chyo",
				"chattahoochee river": "chat",
				"chattahoochee river national recreation area": "chat",
				"chesapeake and ohio canal": "choh",
				"chesapeake and ohio canal national historical park": "choh",
				"chesapeake bay": "cbpo",
				"chesapeake bay gateways and watertrails": "cbgn",
				"chesapeake bay gateways and watertrails network": "cbgn",
				"chickamauga and chattanooga": "chch",
				"chickamauga and chattanooga national military park": "chch",
				"chickasaw": "chic",
				"chickasaw national recreation area": "chic",
				"chiricahua": "chir",
				"chiricahua national monument": "chir",
				"christiansted": "chri",
				"christiansted national historic site": "chri",
				"city of rocks": "ciro",
				"city of rocks national reserve": "ciro",
				"civil war defenses": "cwdw",
				"civil war defenses of washington": "cwdw",
				"clara barton": "clba",
				"clara barton national historic site": "clba",
				"claude moore": "clmo",
				"claude moore colonial farm": "clmo",
				"coal": "coal",
				"coal national heritage area": "coal",
				"colonial": "colo",
				"colonial national historical park": "colo",
				"colorado": "colm",
				"colorado national monument": "colm",
				"coltsville": "colt",
				"coltsville national historical park": "colt",
				"congaree": "cong",
				"congaree national park": "cong",
				"constitution gardens": "coga",
				"coronado": "coro",
				"coronado national memorial": "coro",
				"cowpens": "cowp",
				"cowpens national battlefield": "cowp",
				"crater lake": "crla",
				"crater lake national park": "crla",
				"craters of the moon": "crmo",
				"craters of the moon national monument": "crmo",
				"craters of the moon national monument and preserve": "crmo",
				"crossroads of the american revolution": "xrds",
				"crossroads of the american revolution national heritage area": "xrds",
				"cumberland gap": "cuga",
				"cumberland gap national historical park": "cuga",
				"cumberland island": "cuis",
				"cumberland island national seashore": "cuis",
				"curecanti": "cure",
				"curecanti national recreation area": "cure",
				"cuyahoga": "cuva",
				"cuyahoga valley": "cuva",
				"cuyahoga valley national park": "cuva",
				"david berger": "dabe",
				"david berger national memorial": "dabe",
				"dayton aviation heritage": "daav",
				"dayton aviation heritage national historical park": "daav",
				"de soto": "deso",
				"de soto national memorial": "deso",
				"death valley": "deva",
				"death valley national park": "deva",
				"delaware and lehigh": "dele",
				"delaware and lehigh national heritage corridor": "dele",
				"delaware": "dela",
				"delaware national scenic river": "dela",
				"delaware water gap": "dewa",
				"delaware water gap national recreation area": "dewa",
				"denali": "dena",
				"denali national park": "dena",
				"denali national park and preserve": "dena",
				"devils postpile": "depo",
				"devils postpile national monument": "depo",
				"devils tower": "deto",
				"devils tower national monument": "deto",
				"dinosaur": "dino",
				"dinosaur national monument": "dino",
				"dry tortugas": "drto",
				"dry tortugas national park": "drto",
				"ebey's landing": "ebla",
				"ebey's landing national historical reserve": "ebla",
				"edgar allan poe": "edal",
				"edgar allan poe national historic site": "edal",
				"effigy mounds": "efmo",
				"effigy mounds national monument": "efmo",
				"eisenhower": "eise",
				"eisenhower national historic site": "eise",
				"el camino real de los tejas": "elte",
				"el camino real de los tejas national historic trail": "elte",
				"el camino real de tierra adentro": "elca",
				"el camino real de tierra adentro national historic trail": "elca",
				"el malpais": "elma",
				"el malpais national monument": "elma",
				"el morro": "elmo",
				"el morro national monument": "elmo",
				"eleanor roosevelt": "elro",
				"eleanor roosevelt national historic site": "elro",
				"ellis island": "elis",
				"ellis island national monument": "elis",
				"ellis island statue of liberty national monument": "elis",
				"ellis island part of statue of liberty national monument": "elis",
				"erie canalway": "erie",
				"erie canalway national heritage corridor": "erie",
				"essex": "esse",
				"essex national heritage area": "esse",
				"eugene o'neill": "euon",
				"eugene o'neill national historic site": "euon",
				"everglades": "ever",
				"everglades national park": "ever",
				"fallen timbers battlefield": "fati",
				"fallen timbers battlefield national historic site": "fati",
				"fallen timbers battlefield and fort miamis": "fati",
				"fallen timbers battlefield and fort miamis national historic site": "fati",
				"federal hall": "feha",
				"federal hall national memorial": "feha",
				"fire island": "fiis",
				"fire island national seashore": "fiis",
				"first ladies": "fila",
				"1st ladies": "fila",
				"first ladies national historic site": "fila",
				"first state": "frst",
				"1st state": "frst",
				"first state national historical park": "frst",
				"flight ninety three": "flni",
				"flight 93": "flni",
				"flight ninety three national memorial": "flni",
				"florissant fossil beds": "flfo",
				"florissant fossil beds national monument": "flfo",
				"ford's theatre": "foth",
				"ford's theater": "foth",
				"fort bowie": "fobo",
				"fort bowie national historic site": "fobo",
				"fort davis": "foda",
				"fort davis national historic site": "foda",
				"fort donelson": "fodo",
				"fort donelson national battlefield": "fodo",
				"fort dupont park": "fodu",
				"fort foote": "fofo",
				"fort foote park": "fofo",
				"fort frederica": "fofr",
				"fort frederica national monument": "fofr",
				"fort laramie": "fola",
				"fort laramie national historic site": "fola",
				"fort larned": "fols",
				"fort lar ned": "fols",
				"fort larned national historic site": "fols",
				"fort matanzas": "foma",
				"fort matanzas national monument": "foma",
				"fort mchenry": "fomc",
				"fort mchenry national monument": "fomc",
				"fort mchenry national monument and historic shrine": "fomc",
				"fort monroe": "fomr",
				"fort monroe national monument": "fomr",
				"fort necessity": "fone",
				"fort necessity national battlefield": "fone",
				"fort point": "fopo",
				"fort point national historic site": "fopo",
				"fort pulaski": "fopu",
				"fort pulaski national monument": "fopu",
				"fort raleigh": "fora",
				"fort raleigh national historic site": "fora",
				"fort scott": "fosc",
				"fort scott national historic site": "fosc",
				"fort smith": "fosm",
				"fort smith national historic site": "fosm",
				"fort stanwix": "fost",
				"fort stanwix national monument": "fost",
				"fort sumter": "fosu",
				"fort sumter national monument": "fosu",
				"fort union": "foun",
				"fort union national monument": "foun",
				"fort union trading post": "fous",
				"fort union trading post national historic site": "fous",
				"fort vancouver": "fova",
				"fort vancouver national historic site": "fova",
				"fort washington": "fowa",
				"fort washington park": "fowa",
				"fossil butte": "fobu",
				"fossil butte national monument": "fobu",
				"franklin delano roosevelt": "frde",
				"Franklin Roosevelt": "frde",
				"FDR": "frde",
				"franklin delano roosevelt memorial": "frde",
				"frederick douglass": "frdo",
				"frederick douglass national historic site": "frdo",
				"frederick law olmsted": "frla",
				"frederick law olmsted national historic site": "frla",
				"fredericksburg and spotsylvania": "frsp",
				"Fredericksburg": "frsp",
				"Spotsylvania": "frsp",
				"fredericksburg and spotsylvania national military park": "frsp",
				"freedom riders": "frri",
				"freedom riders national monument": "frri",
				"friendship hill": "frhi",
				"friendship hill national historic site": "frhi",
				"gates of the arctic": "gaar",
				"gates of the arctic national park": "gaar",
				"gates of the arctic national park and preserve": "gaar",
				"gateway": "gate",
				"gateway national recreation area": "gate",
				"gauley river": "gari",
				"gauley river national recreation area": "gari",
				"general grant": "gegr",
				"general grant national memorial": "gegr",
				"george mason": "gemm",
				"george mason memorial": "gemm",
				"george rogers clark": "gero",
				"george rogers clark national historical park": "gero",
				"george washington birthplace": "gewa",
				"george washington birthplace national monument": "gewa",
				"george washington carver": "gwca",
				"george washington carver national monument": "gwca",
				"george washington": "gwmp",
				"George Washington memorial parkway": "gwmp",
				"GW memorial parkway": "gwmp",
				"GW parkway": "gwmp",
				"george washington memorial parkway": "gwmp",
				"gettysburg": "gett",
				"gettysburg national military park": "gett",
				"gila cliff dwellings": "gicl",
				"gila cliff dwellings national monument": "gicl",
				"glacier bay": "glba",
				"glacier bay national park": "glba",
				"glacier bay national park and preserve": "glba",
				"glacier": "glac",
				"glacier national park": "glac",
				"glen canyon": "glca",
				"glen canyon national recreation area": "glca",
				"glen echo": "glec",
				"glen echo park": "glec",
				"gloria dei church": "glde",
				"gloria dei church national historic site": "glde",
				"golden gate": "goga",
				"golden gate national recreation area": "goga",
				"golden spike": "gosp",
				"golden spike national historic site": "gosp",
				"governors island": "gois",
				"governors island national monument": "gois",
				"grand canyon": "grca",
				"grand canyon national park": "grca",
				"grand portage": "grpo",
				"grand portage national monument": "grpo",
				"grand teton": "grte",
				"grand teton national park": "grte",
				"grant kohrs ranch": "grko",
				"grant kohrs ranch national historic site": "grko",
				"great basin": "grba",
				"great basin national park": "grba",
				"great egg harbor": "greg",
				"great egg harbor river": "greg",
				"great falls": "grfa",
				"great falls park": "grfa",
				"great sand dunes": "grsa",
				"great sand dunes national park": "grsa",
				"great sand dunes national park and preserve": "grsa",
				"great smokies": "grsm",
				"great smoky mountains": "grsm",
				"great smoky mountains national park": "grsm",
				"green springs": "grsp",
				"greenbelt": "gree",
				"greenbelt park": "gree",
				"guadalupe mountains": "gumo",
				"guadalupe mountains national park": "gumo",
				"guilford courthouse": "guco",
				"guilford courthouse national military park": "guco",
				"gulf islands": "guis",
				"gulf islands national seashore": "guis",
				"gullah geechee": "guge",
				"gullah geechee cultural heritage corridor": "guge",
				"hagerman fossil beds": "hafo",
				"hagerman fossil beds national monument": "hafo",
				"haleakala": "hale",
				"haleakala national park": "hale",
				"hamilton grange": "hagr",
				"hamilton grange national memorial": "hagr",
				"hampton": "hamp",
				"hampton national historic site": "hamp",
				"harmony hall": "haha",
				"harpers ferry": "hafe",
				"harpers ferry national historical park": "hafe",
				"harriet tubman": "hart",
				"harriet tubman national historical park": "hart",
				"harriet tubman underground railroad": "hatu",
				"harriet tubman underground railroad national historical park": "hatu",
				"harry s. truman": "hstr",
				"harry s. truman national historic site": "hstr",
				"hawaii volcanoes": "havo",
				"hawaii volcanoes national park": "havo",
				"herbert hoover": "heho",
				"herbert hoover national historic site": "heho",
				"historic jamestowne": "jame",
				"historic jamestowne national historical park": "jame",
				"historic jamestowne part of colonial national historical park": "jame",
				"hohokam pima": "pima",
				"hohokam pima national monument": "pima",
				"home of franklin d roosevelt": "hofr",
				"home of franklin d roosevelt national historic site": "hofr",
				"homestead": "home",
				"homestead national monument of america": "home",
				"honouliuli": "hono",
				"honouliuli national monument": "hono",
				"hopewell culture": "hocu",
				"hopewell culture national historical park": "hocu",
				"hopewell furnace": "hofu",
				"hopewell furnace national historic site": "hofu",
				"horseshoe bend": "hobe",
				"horseshoe bend national military park": "hobe",
				"hot springs": "hosp",
				"hot springs national park": "hosp",
				"hovenweep": "hove",
				"hovenweep national monument": "hove",
				"hubbell trading post": "hutr",
				"hubbell trading post national historic site": "hutr",
				"hudson river valley": "hurv",
				"hudson river valley national heritage area": "hurv",
				"inupiat": "inup",
				"inupiat heritage center": "inup",
				"ice age floods": "iafl",
				"ice age floods national geologic trail": "iafl",
				"ice age": "iatr",
				"ice age national scenic trail": "iatr",
				"independence": "inde",
				"independence national historical park": "inde",
				"indiana dunes": "indu",
				"indiana dunes national lakeshore": "indu",
				"isle royale": "isro",
				"isle royale national park": "isro",
				"james a garfield": "jaga",
				"james a garfield national historic site": "jaga",
				"jean lafitte": "jela",
				"jean lafitte national historical park": "jela",
				"jean lafitte national historical park and preserve": "jela",
				"jefferson": "jeff",
				"jefferson national expansion memorial": "jeff",
				"jewel cave": "jeca",
				"jewel cave national monument": "jeca",
				"jimmy carter": "jica",
				"jimmy carter national historic site": "jica",
				"john day fossil beds": "joda",
				"john day fossil beds national monument": "joda",
				"john ericsson": "joer",
				"john ericsson national memorial": "joer",
				"john fitzgerald kennedy": "jofi",
				"john fitzgerald kennedy national historic site": "jofi",
				"john h. chafee blackstone river valley": "blac",
				"blackstone river valley national heritage corridor": "blac",
				"john h. chafee blackstone river valley national heritage corridor": "blac",
				"John H chafee Blackstone river valley": "blac",
				"john muir": "jomu",
				"john muir national historic site": "jomu",
				"johnstown flood": "jofl",
				"johnstown flood national memorial": "jofl",
				"joshua tree": "jotr",
				"joshua tree national park": "jotr",
				"journey through hallowed ground": "jthg",
				"journey through hallowed ground national heritage area": "jthg",
				"juan bautista de anza": "juba",
				"juan bautista de anza national historic trail": "juba",
				"kalaupapa": "kala",
				"kalaupapa national historical park": "kala",
				"kaloko honokohau": "kaho",
				"kaloko honokohau national historical park": "kaho",
				"katahdin": "kaww",
				"katahdin woods and waters": "kaww",
				"katahdin woods and waters national monument": "kaww",
				"katmai": "katm",
				"katmai national park and preserve": "katm",
				"kenai fjords": "kefj",
				"kenai fjords national park": "kefj",
				"kenilworth park and aquatic gardens": "keaq",
				"kennesaw mountain": "kemo",
				"kennesaw mountain national battlefield park": "kemo",
				"keweenaw": "kewe",
				"keweenaw national historical park": "kewe",
				"kings mountain": "kimo",
				"kings mountain national military park": "kimo",
				"klondike gold rush seattle": "klse",
				"klondike gold rush seattle unit": "klse",
				"klondike gold rush seattle unit national historical park": "klse",
				"klondike gold rush": "klgo",
				"klondike gold rush national historical park": "klgo",
				"knife river": "knri",
				"knife river indian villages": "knri",
				"knife river indian villages national historic site": "knri",
				"kobuk valley": "kova",
				"kobuk valley national park": "kova",
				"korean war memorial": "kowa",
				"korean war veterans memorial": "kowa",
				"lake clark": "lacl",
				"lake clark national park and preserve": "lacl",
				"lake mead": "lake",
				"lake mead national recreation area": "lake",
				"lake meredith": "lamr",
				"lake meredith national recreation area": "lamr",
				"lake roosevelt": "laro",
				"lake roosevelt national recreation area": "laro",
				"lassen volcanic": "lavo",
				"lassen volcanic national park": "lavo",
				"lava beds": "labe",
				"lava beds national monument": "labe",
				"lyndon baines johnson memorial grove on the potomac": "lyba",
				"lyndon baines johnson memorial": "lyba",
				"lyndon baines johnson memorial grove": "lyba",
				"l.b.j. memorial": "lyba",
				"LBJ memorial": "lyba",
				"l.b.j. memorial grove": "lyba",
				"l.b.j. memorial grove on the potomac": "lyba",
				"lewis and clark trail": "lecl",
				"lewis and clark national historic trail": "lecl",
				"lewis and clark": "lewi",
				"lewis and clark national historical park": "lewi",
				"lincoln boyhood": "libo",
				"lincoln boyhood national memorial": "libo",
				"lincoln home": "liho",
				"lincoln home national historic site": "liho",
				"lincoln memorial": "linc",
				"little bighorn battlefield": "libi",
				"little bighorn battlefield national monument": "libi",
				"little river canyon": "liri",
				"little river canyon national preserve": "liri",
				"Little Rock high school": "chsc",
				"little rock central high school": "chsc",
				"little rock central high school national historic site": "chsc",
				"longfellow house": "long",
				"longfellow house washington's headquarters": "long",
				"longfellow house national historic site": "long",
				"longfellow house washington's headquarters national historic site": "long",
				"lowell": "lowe",
				"lowell national historical park": "lowe",
				"lower delaware": "lode",
				"lower delaware national wild and scenic river": "lode",
				"lower east side tenement museum": "loea",
				"lower east side tenement museum national historic site": "loea",
				"lyndon b johnson": "lyjo",
				"Lyndon B. Johnson": "lyjo",
				"lyndon baines johnson": "lyjo",
				"lyndon b johnson national historical park": "lyjo",
				"Lyndon B. Johnson national historical park": "lyjo",
				"maggie walker": "mawa",
				"maggie l walker": "mawa",
				"maggie walker national historic site": "mawa",
				"maggie l walker national historic site": "mawa",
				"maine acadian culture": "maac",
				"mammoth cave": "maca",
				"mammoth cave national park": "maca",
				"manassas": "mana",
				"manassas national battlefield park": "mana",
				"manhattan project": "mapr",
				"manhattan project national historical park": "mapr",
				"manhattan sites": "npnr",
				"Manhattan sites": "npnr",
				"manzanar": "manz",
				"manzanar national historic site": "manz",
				"marsh billings rockefeller": "mabi",
				"marsh billings rockefeller national historical park": "mabi",
				"martin luther king junior": "malu",
				"martin luther king junior national historic site": "malu",
				"martin luther king junior memorial": "mlkm",
				"martin van buren": "mava",
				"martin van buren national historic site": "mava",
				"mary mcleod bethune council house": "mamc",
				"mary mcleod bethune council house national historic site": "mamc",
				"mesa verde": "meve",
				"mesa Verde": "meve",
				"mesa Ver de": "meve",
				"mesa verde national park": "meve",
				"minidoka": "miin",
				"minidoka national historic site": "miin",
				"minute man": "mima",
				"minute man national historical park": "mima",
				"minuteman missile": "mimi",
				"minuteman missile national historic site": "mimi",
				"mississippi delta": "mide",
				"mississippi delta national heritage area": "mide",
				"mississippi gulf": "migu",
				"mississippi gulf national heritage area": "migu",
				"mississippi hills": "mihi",
				"mississippi hills national heritage area": "mihi",
				"mississippi": "miss",
				"mississippi river": "miss",
				"mississippi national river": "miss",
				"mississippi national river and recreation area": "miss",
				"missouri": "mnrr",
				"missouri river": "mnrr",
				"missouri national river": "mnrr",
				"missouri national recreational river": "mnrr",
				"mojave": "moja",
				"mojave national preserve": "moja",
				"monocacy": "mono",
				"monocacy national battlefield": "mono",
				"montezuma castle": "moca",
				"montezuma castle national monument": "moca",
				"moores creek": "mocr",
				"moores creek national battlefield": "mocr",
				"mormon pioneer": "mopi",
				"mormon pioneer national historic trail": "mopi",
				"morristown": "morr",
				"morristown national historical park": "morr",
				"motor cities": "auto",
				"motor cities national heritage area": "auto",
				"mount rainier": "mora",
				"mount rainier national park": "mora",
				"mount rushmore": "moru",
				"mount rushmore national memorial": "moru",
				"muir woods": "muwo",
				"muir woods national monument": "muwo",
				"muscle shoals": "mush",
				"muscle shoals national heritage area": "mush",
				"natchez": "natc",
				"natchez national historical park": "natc",
				"natchez trace trail": "natt",
				"natchez trace national scenic trail": "natt",
				"natchez trace": "natr",
				"natchez trace parkway": "natr",
				"national aviation": "avia",
				"national aviation heritage area": "avia",
				"national capital parks east": "nace",
				"national mall": "nama",
				"national mall and memorial parks": "nama",
				"american samoa": "npsa",
				"national park of american samoa": "npsa",
				"new york harbor": "npnh",
				"national parks of new york harbor": "npnh",
				"natural bridges": "nabr",
				"natural bridges national monument": "nabr",
				"navajo": "nava",
				"navajo national monument": "nava",
				"new bedford": "nebe",
				"new bedford whaling": "nebe",
				"new bedford whaling national historical park": "nebe",
				"new england": "neen",
				"new england national scenic trail": "neen",
				"new jersey coastal heritage trail": "neje",
				"new jersey coastal heritage trail route": "neje",
				"new jersey pinelands": "pine",
				"new jersey pinelands national reserve": "pine",
				"new orleans jazz": "jazz",
				"new orleans jazz national historical park": "jazz",
				"new river gorge": "neri",
				"new river gorge national river": "neri",
				"nez perce": "nepe",
				"nez perce national historical park": "nepe",
				"niagara falls": "nifa",
				"niagara falls national heritage area": "nifa",
				"nicodemus": "nico",
				"nicodemus national historic site": "nico",
				"ninety six": "nisi",
				"96": "nisi",
				"ninety six national historic site": "nisi",
				"niobrara": "niob",
				"niobrara national scenic river": "niob",
				"noatak": "noat",
				"noatak national preserve": "noat",
				"north cascades": "noca",
				"north cascades national park": "noca",
				"north country": "noco",
				"north country national scenic trail": "noco",
				"northern rio grande": "norg",
				"northern rio grande national heritage area": "norg",
				"obed": "obed",
				"obed wild and scenic river": "obed",
				"ocmulgee": "ocmu",
				"ocmulgee national monument": "ocmu",
				"oil region": "oire",
				"oil region national heritage area": "oire",
				"oklahoma city": "okci",
				"oklahoma city national memorial": "okci",
				"old spanish": "olsp",
				"old spanish national historic trail": "olsp",
				"olympic": "olym",
				"olympic national park": "olym",
				"oregon caves": "orca",
				"oregon caves national monument and preserve": "orca",
				"oregon": "oreg",
				"oregon national historic trail": "oreg",
				"organ pipe": "orpi",
				"organ pipe cactus": "orpi",
				"organ pipe cactus national monument": "orpi",
				"overmountain victory": "ovvi",
				"overmountain victory national historic trail": "ovvi",
				"oxon cove park": "oxhi",
				"oxon hill farm": "oxhi",
				"oxon cove park and oxon hill farm": "oxhi",
				"ozark": "ozar",
				"ozark national scenic riverways": "ozar",
				"padre island": "pais",
				"padre island national seashore": "pais",
				"palo alto battlefield": "paal",
				"palo alto battlefield national historical park": "paal",
				"parashant": "para",
				"grand canyon parashant": "para",
				"grand canyon parashant national monument": "para",
				"parashant grand canyon parashant national monument": "para",
				"paterson great falls": "pagr",
				"paterson great falls national historical park": "pagr",
				"pea ridge": "peri",
				"pea ridge national military park": "peri",
				"pecos": "peco",
				"pecos national historical park": "peco",
				"peirce mill": "pimi",
				"pennsylvania avenue": "paav",
				"perry's victory": "pevi",
				"perry's victory memorial": "pevi",
				"perry's victory and international peace memorial": "pevi",
				"petersburg": "pete",
				"petersburg national battlefield": "pete",
				"petrified forest": "pefo",
				"petrified forest national park": "pefo",
				"petroglyph": "petr",
				"petroglyph national monument": "petr",
				"pictured rocks": "piro",
				"pictured rocks national lakeshore": "piro",
				"pinnacles": "pinn",
				"pinnacles national park": "pinn",
				"pipe spring": "pisp",
				"pipe spring national monument": "pisp",
				"pipestone": "pipe",
				"pipestone national monument": "pipe",
				"piscataway": "pisc",
				"piscataway park": "pisc",
				"point reyes": "pore",
				"point reyes national seashore": "pore",
				"pony express": "poex",
				"pony express national historic trail": "poex",
				"port chicago": "poch",
				"port chicago naval magazine": "poch",
				"port chicago naval magazine national memorial": "poch",
				"potomac heritage": "pohe",
				"potomac heritage national scenic trail": "pohe",
				"poverty point": "popo",
				"poverty point national monument": "popo",
				"william jefferson clinton": "wicl",
				"william jefferson clinton birthplace": "wicl",
				"william jefferson clinton home": "wicl",
				"william jefferson clinton birthplace home": "wicl",
				"president william jefferson clinton": "wicl",
				"president william jefferson clinton birthplace": "wicl",
				"president william jefferson clinton home": "wicl",
				"president william jefferson clinton birthplace home": "wicl",
				"president william jefferson clinton birthplace home national historic site": "wicl",
				"president's park": "whho",
				"white house": "whho",
				"presidio": "prsf",
				"presidio of san francisco": "prsf",
				"prince william": "prwi",
				"prince william forest": "prwi",
				"prince william forest park": "prwi",
				"pu uhonua o honaunau": "puho",
				"pu uhonua o honaunau national historical park": "puho",
				"pu ukohola heiau": "puhe",
				"pu ukohola heiau national historic site": "puhe",
				"pullman": "pull",
				"pullman national monument": "pull",
				"rainbow bridge": "rabr",
				"rainbow bridge national monument": "rabr",
				"reconstruction era": "reer",
				"reconstruction era national monument": "reer",
				"redwood": "redw",
				"redwood national and state parks": "redw",
				"richmond": "rich",
				"richmond national battlefield park": "rich",
				"rio grande": "rigr",
				"rio grande wild and scenic river": "rigr",
				"river raisin": "rira",
				"river raisin national battlefield park": "rira",
				"rivers of steel": "rist",
				"rivers of steel national heritage area": "rist",
				"rock creek": "rocr",
				"rock creek park": "rocr",
				"rocky mountain": "romo",
				"rocky mountain national park": "romo",
				"roger williams": "rowi",
				"roger williams national memorial": "rowi",
				"roosevelt campobello": "roca",
				"roosevelt campobello international park": "roca",
				"rosie the riveter": "rori",
				"rosie the riveter wwii home front": "rori",
				"rosie the riveter wwii home front national historical park": "rori",
				"russell cave": "ruca",
				"russell cave national monument": "ruca",
				"sagamore hill": "sahi",
				"sagamore hill national historic site": "sahi",
				"saguaro": "sagu",
				"saguaro national park": "sagu",
				"saint croix island": "sacr",
				"saint croix island international historic site": "sacr",
				"saint croix": "sacn",
				"saint croix national scenic riverway": "sacn",
				"saint paul's church": "sapa",
				"saint paul's church national historic site": "sapa",
				"saint gaudens": "saga",
				"saint gaudens national historic site": "saga",
				"Saint-Gaudens": "saga",
				"salem maritime": "sama",
				"salem maritime national historic site": "sama",
				"salinas pueblo missions": "sapu",
				"salinas pueblo missions national monument": "sapu",
				"salt river": "sari",
				"salt river bay": "sari",
				"salt river bay national historical park": "sari",
				"salt river bay national historical park and ecological preserve": "sari",
				"san antonio missions": "saan",
				"san antonio missions national historical park": "saan",
				"san francisco maritime": "safr",
				"san francisco maritime national historical park": "safr",
				"san juan island": "sajh",
				"san juan island national historical park": "sajh",
				"san juan": "saju",
				"san juan national historic site": "saju",
				"sand creek": "sand",
				"sand creek massacre": "sand",
				"sand creek massacre national historic site": "sand",
				"santa fe": "safe",
				"santa fe national historic trail": "safe",
				"santa monica mountains": "samo",
				"santa monica mountains national recreation area": "samo",
				"saratoga": "sara",
				"saratoga national historical park": "sara",
				"saugus iron works": "sair",
				"saugus iron works national historic site": "sair",
				"schuylkill river valley": "scrv",
				"schuylkill river valley national heritage area": "scrv",
				"scotts bluff": "scbl",
				"scotts bluff national monument": "scbl",
				"selma to montgomery": "semo",
				"selma to montgomery national historic trail": "semo",
				"sequoia": "seki",
				"kings canyon": "seki",
				"sequoia and kings canyon": "seki",
				"sequoia and kings canyon national parks": "seki",
				"shenandoah": "shen",
				"shenandoah national park": "shen",
				"shenandoah valley battlefields": "shvb",
				"shenandoah valley battlefields national historic district": "shvb",
				"shiloh": "shil",
				"shiloh national military park": "shil",
				"silos and smokestacks": "silo",
				"silos and smokestacks national heritage area": "silo",
				"sitka": "sitk",
				"sitka national historical park": "sitk",
				"sleeping bear": "slbe",
				"sleeping bear dunes": "slbe",
				"sleeping bear dunes national lakeshore": "slbe",
				"south carolina": "soca",
				"south carolina national heritage corridor": "soca",
				"springfield armory": "spar",
				"springfield armory national historic site": "spar",
				"star spangled banner": "stsp",
				"star spangled banner national historic trail": "stsp",
				"statue of liberty": "stli",
				"statue of liberty national monument": "stli",
				"steamtown": "stea",
				"steamtown national historic site": "stea",
				"stones river": "stri",
				"stones river national battlefield": "stri",
				"stonewall": "ston",
				"stonewall national monument": "ston",
				"suitland": "suit",
				"suitland parkway": "suit",
				"sunset crater": "sucr",
				"sunset crater volcano": "sucr",
				"sunset crater volcano national monument": "sucr",
				"tallgrass prairie": "tapr",
				"tallgrass prairie national preserve": "tapr",
				"tennessee civil war": "tecw",
				"tennessee civil war national heritage area": "tecw",
				"thaddeus kosciuszko": "thko",
				"thaddeus kosciuszko national memorial": "thko",
				"the last green valley": "qush",
				"the last green valley national heritage corridor": "qush",
				"old stone house": "olst",
				"the old stone house": "olst",
				"theodore roosevelt birthplace": "thrb",
				"theodore roosevelt birthplace national historic site": "thrb",
				"theodore roosevelt inaugural": "thri",
				"theodore roosevelt inaugural national historic site": "thri",
				"theodore roosevelt island": "this",
				"theodore roosevelt": "thro",
				"theodore roosevelt national park": "thro",
				"thomas cole": "thco",
				"thomas cole national historic site": "thco",
				"thomas edison": "edis",
				"thomas edison national historical park": "edis",
				"edison": "edis",
				"thomas jefferson": "thje",
				"thomas jefferson memorial": "thje",
				"thomas stone": "thst",
				"thomas stone national historic site": "thst",
				"timpanogos cave": "tica",
				"timpanogos cave national monument": "tica",
				"timucuan": "timu",
				"timucuan ecological and historic preserve": "timu",
				"tonto": "tont",
				"tonto national monument": "tont",
				"touro synagogue": "tosy",
				"touro synagogue national historic site": "tosy",
				"trail of tears": "trte",
				"trail of tears national historic trail": "trte",
				"tule lake": "tule",
				"tule lake unit": "tule",
				"tule springs": "tusk",
				"tule springs fossil beds": "tusk",
				"tule springs fossil beds national monument": "tusk",
				"tumacacori": "tuma",
				"tumacacori national historical park": "tuma",
				"tupelo": "tupe",
				"tupelo national battlefield": "tupe",
				"tuskegee airmen": "tuai",
				"tuskegee airmen national historic site": "tuai",
				"tuskegee institute": "tuin",
				"tuskegee institute national historic site": "tuin",
				"tuzigoot": "tuzi",
				"tuzigoot national monument": "tuzi",
				"ulysses s. grant": "ulsg",
				"ulysses s. grant national historic site": "ulsg",
				"Ulysses S grant": "ulsg",
				"upper delaware": "upde",
				"upper delaware scenic and recreational river": "upde",
				"valles caldera": "vall",
				"valles caldera national preserve": "vall",
				"valley forge": "vafo",
				"valley forge national historical park": "vafo",
				"vanderbilt mansion": "vama",
				"vanderbilt mansion national historic site": "vama",
				"vicksburg": "vick",
				"vicksburg national military park": "vick",
				"vietnam veterans": "vive",
				"vietnam veterans memorial": "vive",
				"virgin islands coral reef": "vicr",
				"virgin islands coral reef national monument": "vicr",
				"virgin islands": "viis",
				"virgin islands national park": "viis",
				"voyageurs": "voya",
				"voyageurs national park": "voya",
				"waco mammoth": "waco",
				"waco mammoth national monument": "waco",
				"walnut canyon": "waca",
				"walnut canyon national monument": "waca",
				"war in the pacific": "wapa",
				"war in the pacific national historical park": "wapa",
				"washington monument": "wamo",
				"washington rochambeau": "waro",
				"washington rochambeau national historic trail": "waro",
				"washita battlefield": "waba",
				"washita battlefield national historic site": "waba",
				"weir farm": "wefa",
				"weir farm national historic site": "wefa",
				"wheeling": "whee",
				"wheeling national heritage area": "whee",
				"whiskeytown": "whis",
				"whiskeytown national recreation area": "whis",
				"white sands": "whsa",
				"white sands national monument": "whsa",
				"whitman mission": "whmi",
				"whitman mission national historic site": "whmi",
				"william howard taft": "wiho",
				"william howard taft national historic site": "wiho",
				"wilson's creek": "wicr",
				"wilson's creek national battlefield": "wicr",
				"wind cave": "wica",
				"wind cave national park": "wica",
				"wing luke museum": "wing",
				"wing luke museum affiliated area": "wing",
				"wolf trap": "wotr",
				"wolf trap national park": "wotr",
				"wolf trap national park for the performing arts": "wotr",
				"women's rights": "wori",
				"women's rights national historical park": "wori",
				"world war two": "wwii",
				"world war 2 valor in the pacific": "valr",
				"world war 2": "wwii",
				"world war 2 memorial": "wwii",
				"world war two memorial": "wwii",
				"world war two valor in the pacific": "valr",
				"world war two valor in the pacific national monument": "valr",
				"world war 2 valor in the pacific national monument": "valr",
				"wrangell saint elias": "wrst",
				"wrangell saint elias national park": "wrst",
				"wrangell saint elias national park and preserve": "wrst",
				"wright brothers": "wrbr",
				"wright brothers national memorial": "wrbr",
				"wupatki": "wupa",
				"wupatki national monument": "wupa",
				"yellowstone": "yell",
				"yellowstone national park": "yell",
				"yorktown battlefield": "york",
				"yorktown battlefield national historical park": "york",
				"yorktown battlefield part of colonial national historical park": "york",
				"yosemite": "yose",
				"yosemite national park": "yose",
				"yucca house": "yuho",
				"yucca house national monument": "yuho",
				"yukon charley": "yuch",
				"yukon charley rivers": "yuch",
				"yukon charley rivers national preserve": "yuch",
				"yuma crossing": "yucr",
				"yuma crossing national heritage area": "yucr",
				"zion": "zion",
				"zion national park": "zion"
			} />

		<cfset local.park_code_struct = StructFindKey( local.park_struct, local.park_name ) />
		
		<cfif ArrayLen(local.park_code_struct)>
			<cfset local.park_code = local.park_code_struct[1].value />
		<cfelse>
			<cfset local.park_code = 'none' />
		</cfif>

		<cfreturn local.park_code />
	
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
				<cfset setTitle('Description of #local.returnJSON.data[1].fullName#') />
				<cfset setText(local.returnJSON.data[1].description) />
				<cfset say(replaceSubstringsForVoice(local.returnJSON.data[1].description)) />
			<cfelse>
				<!--- No corresponding record --->
				<cfset setTitle('Description of #local.park_name#') />
				<cfset setText("No description found for #local.park_name#") />
				<cfset say("I did not find #local.park_name#") />
			</cfif>

		<cfelse>
			<!--- parse of site_name failed to find a result --->
			<cfif len(local.park_name)>
				<cfset say("I did not find #local.park_name#") />
			<cfelse>
				<cfset say("I did not understand you.") />
				<cfset onHelp() />
			</cfif>
		</cfif>
		
		<cfset say("Can I help you with anything else?") />

	</cffunction>
	
	<cffunction name="getRandomParkDescription" access="public" returntype="void">

		<cftry>
			<cfhttp url="#this.api_base#index.cfm?endpoint=%2Fparks" method="get" result="local.parkData" timeout="5">
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
			<cfset theParkIndex = RandRange(1, ArrayLen(local.returnJSON.data)) />
			<cfset setTitle('Description of #local.returnJSON.data[theParkIndex].fullName#') />
			<cfset setText(local.returnJSON.data[theParkIndex].description) />
			<cfset say(local.returnJSON.data[theParkIndex].description) />
		</cfif>
		
		<cfset say("Can I help you with anything else?") />
	</cffunction>
	
	<cffunction name="getParkDirections" access="public" returntype="void">
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

			<!--- say(ParkDirections) --->			
			<cfif local.returnJSON.total gt 0>
				<cfset local.directionsString = 'Directions to #local.returnJSON.data[1].fullName#: #local.returnJSON.data[1].directionsInfo#' />
				<cfset setTitle('Directions to #local.returnJSON.data[1].fullName#') />
				<cfset setText(local.directionsString) />
				<cfset say(local.directionsString) />
			<cfelse>
				<!--- No corresponding record --->
				<cfset setTitle('Directions to #local.park_name#') />
				<cfset setText("No directions found for #local.park_name#") />
				<cfset say("I did not find directions for #local.park_name#") />
			</cfif>

		<cfelse>
			<!--- parse of site_name failed to find a result --->
			<cfif len(local.park_name)>
				<cfset say("I did not find #local.park_name#") />
			<cfelse>
				<cfset say("I did not understand you.") />
				<cfset onHelp() />
			</cfif>
		</cfif>
		
		<cfset say("Can I help you with anything else?") />

	</cffunction>
	
	<cffunction name="getParkContacts" access="public" returntype="void">
		<cfargument name="Park" type="string" required="no" default="">

		<cfset local.park_name = trim(arguments.Park) />

		<!--- Parse park_name --->
		<cfset local.park_code = getParkCode(local.park_name) />
				
		<cfif local.park_code neq "none">
			<!--- Call NPS API to get park description --->
			<cftry>
				<cfhttp url="#this.api_base#index.cfm?endpoint=%2Fparks&parkCode=#local.park_code#&fields=contacts" method="get" result="local.parkData" timeout="5">
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
			
			<!--- say(ParkContacts) --->			
			<cfif local.returnJSON.total gt 0>
				<cfset local.thisParkURL = Insert('.',Insert('.',Insert('.',Insert('.',local.park_code,4),3),2),1) />
				<cfset local.contactsString = 'In order to contact #local.returnJSON.data[1].fullName#, visit online at nps.gov/#local.park_code#' />
				<cfif ArrayLen(local.returnJSON.data[1].contacts.phoneNumbers) and len(local.returnJSON.data[1].contacts.phoneNumbers[1].phoneNumber)>
					<cfset local.formattedPhoneNumber = formatPhoneNumber(local.returnJSON.data[1].contacts.phoneNumbers[1].phoneNumber) />
					<cfset local.contactsString &= '; or call #local.formattedPhoneNumber#' />
				</cfif>
				<cfif ArrayLen(local.returnJSON.data[1].contacts.emailAddresses) and len(local.returnJSON.data[1].contacts.emailAddresses[1].emailAddress)>
					<cfset local.contactsString &= '; or email #local.returnJSON.data[1].contacts.emailAddresses[1].emailAddress#' />
				</cfif>
				<cfset setTitle('Contact Information for #local.returnJSON.data[1].fullName#') />
				<cfset setText('#local.contactsString#.') />
				<cfset say(replace(local.contactsString,'/#local.park_code#',' forward slash #local.thisParkURL#')) />
			<cfelse>
				<!--- No corresponding record --->
				<cfset setTitle('Contact Information for #local.park_name#') />
				<cfset setText("I did not find #local.park_name#") />
				<cfset say("I did not find #local.park_name#") />
			</cfif>

		<cfelse>
			<!--- parse of site_name failed to find a result --->
			<cfif len(local.park_name)>
				<cfset say("I did not find #local.park_name#") />
			<cfelse>
				<cfset say("I did not understand you.") />
				<cfset onHelp() />
			</cfif>
		</cfif>
		
		<cfset say("Can I help you with anything else?") />

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
		<cftry>
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
				<cfif local.returnJSON.total eq 1>
					<cfset local.alert_output = "I found one alert. " />
				<cfelse>
					<cfset local.alert_output = "I found #local.returnJSON.total# alerts. " />
				</cfif>
				<cfloop array="#local.returnJSON.data#" index="local.thisAlert">
					<cfset local.alert_output &= "#local.thisAlert.category#: #local.thisAlert.title#. #local.thisAlert.description# " />
				</cfloop>

				<cfset setTitle('Alerts for #getOfficialParkName(local.park_code)#') />
				<cfset setText(local.alert_output) />
				<cfset say(local.alert_output) />
			<cfelse>
				<!--- No alerts --->
				<cfset setTitle('Alerts for #getOfficialParkName(local.park_code)#') />
				<cfset setText("There are no active alerts for #local.official_park_name#.") />
				<cfset say("There are no active alerts for #local.official_park_name#") />
			</cfif>

		<cfelse>
			<!--- parse of site_name failed to find a result --->
			<cfif len(local.park_name)>
				<cfset say("I did not find #local.park_name#") />
			<cfelse>
				<cfset say("I did not understand you.") />
				<cfset onHelp() />
			</cfif>
		</cfif>
		
		<cfset say("Can I help you with anything else?") />
		
			<cfcatch>
				<!--- Timeout or other HTTP error --->
				<cflog text="#SerializeJSON(cfcatch)#" type="information" file="alexa_debug" /> 
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="getParkNews" access="public" returntype="void">
	
		<cfargument name="Park" type="string" required="no">
		
		<cfset local.park_name = trim(arguments.Park) />

		<!--- Parse park_name --->
		<cfset local.park_code = getParkCode(local.park_name) />
		
		<cfif local.park_code neq "none">
			<!--- Call NPS API to get park description --->
			<cftry>
				<cfset local.official_park_name = getOfficialParkName(local.park_code) />
				
				<cfhttp url="#this.api_base#index.cfm?endpoint=%2Fnews&parkCode=#local.park_code#&limit=3" method="get" result="local.newsData" timeout="5">
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
				<cfset local.news_output = '' />
				<cfloop array="#local.returnJSON.data#" index="local.thisNews">
					<cfif local.thisNews.releaseDate lt DateAdd("w", -4, now())>
						<cfcontinue />
					</cfif>
					<cfif local.news_output eq ''>
						<cfset local.news_output = 'Here are the most current news items for #local.official_park_name#. ' />
					</cfif>
					<cfset local.news_output &= "News release: #local.thisNews.title#. #local.thisNews.abstract# " />
				</cfloop>
				
				<cfif local.news_output eq ''>
					<!--- No news --->
					<cfset setTitle('News for #local.official_park_name#') />
					<cfset setText("I did not find any news from the last four weeks for #local.official_park_name#") />
					<cfset say("I did not find any news from the last four weeks for #local.official_park_name#") />
				</cfif>
				
				<cfset setTitle('News for #local.official_park_name#') />
				<cfset setText(local.news_output) />
				<cfset say(local.news_output) />
			<cfelse>
				<!--- No news --->
				<cfset setTitle('News for #local.official_park_name#') />
				<cfset setText("I did not find any news for #local.official_park_name#") />
				<cfset say("I did not find any news for #local.official_park_name#") />
			</cfif>

		<cfelse>
			<!--- parse of site_name failed to find a result --->
			<cfif len(local.park_name)>
				<cfset say("I did not find #local.park_name#") />
			<cfelse>
				<cfset say("I did not understand you.") />
				<cfset onHelp() />
			</cfif>
		</cfif>
		
		<cfset say("Can I help you with anything else?") />

	</cffunction>
	
	<cffunction name="getParkEvents" access="public" returntype="void">
	
		<cfargument name="Park" type="string" required="no">
		<cfargument name="Date" type="string" required="no">

		<cfset local.park_name = trim(arguments.Park) />
		<cfif isdefined("arguments.date") and len(arguments.date)>
			<cfset local.requested_date = arguments.Date />
		</cfif>
		
		<!--- Parse park_name --->
		<cfset local.park_code = getParkCode(local.park_name) />
		
		<cfif local.park_code neq "none">
			<!--- Call NPS API to get park description --->
			<cftry>
				<cfset local.official_park_name = getOfficialParkName(local.park_code) />
				
				<cfhttp url="#this.api_base#index.cfm?endpoint=%2Fevents&parkCode=#local.park_code#&limit=3" method="get" result="local.newsData" timeout="5">
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
			<cfset local.eventArray = ArrayNew(1) />
			
			<cfloop array="#local.returnJSON.data#" index="local.thisEvent">
				<cfif not isdefined("local.requested_date") or local.thisEvent.dates contains local.requested_date>
					<cfset ArrayAppend(local.eventArray, local.thisEvent) />
				</cfif>
			</cfloop>
		
			<!--- Read off events --->			
			<cfif ArrayLen(local.eventArray)>
				<cfif ArrayLen(local.eventArray) eq 1>
					<cfset local.event_output = "There is one event at #local.official_park_name#" />
					<cfif isdefined("local.requested_date")>
						<cfset local.event_output &= " on #formatDate(local.requested_date)#" />
					</cfif>
					<cfset local.event_output &= ': ' />
				<cfelse>
					<cfset local.event_output = "There are #ArrayLen(local.eventArray)# events at #local.official_park_name#" />
					<cfif isdefined("local.requested_date")>
						<cfset local.event_output &= " on #formatDate(local.requested_date)#" />
					</cfif>
					<cfset local.event_output &= ': ' />
				</cfif>

				<cfset say(local.event_output) />
				<cfset local.event_output = '' />
				<cfif ArrayLen(local.eventArray)>
					<cfloop array="#local.eventArray#" index="local.thisEvent">
						<cfif local.thisEvent.time neq ''>
							<cfif local.thisEvent.time contains 'to'>
								<cfset local.event_output &= ' From #replace(local.thisEvent.time,',',' and ',"ALL")#, ' />
							<cfelse>
								<cfset local.event_output &= ' At #replace(local.thisEvent.time,',',' and ',"ALL")#, ' />
							</cfif>
						<cfelse>
							<cfset local.event_output &= ' At an unspecified time, ' />
						</cfif>
						<cfset local.event_output &= '#local.thisEvent.title#: #local.thisEvent.abstract#. ' />
					</cfloop>
					<cfset setTitle('Events at #local.official_park_name#') />
					<cfset setText(local.event_output) />
					<cfset say(local.event_output) />

				</cfif>
			<cfelse>
				<!--- No events --->
				<cfif isdefined("local.requested_date")>
					<cfset setTitle('Events at #local.park_name#') />
					<cfset setText("There are no events or programs happening at #local.official_park_name# on #formatDate(local.requested_date)#.") />
					<cfset say("There are no events or programs happening at #local.official_park_name# on #formatDate(local.requested_date)#.") />
				<cfelse>
					<cfset setTitle('Events at #local.park_name#') />
					<cfset setText("There are no events or programs happening at #local.official_park_name#") />
					<cfset say("There are no events or programs happening at #local.official_park_name#") />
				</cfif>
			</cfif>

		<cfelse>
			<!--- parse of site_name failed to find a result --->
			<cfif len(local.park_name)>
				<cfset say("I did not find #local.park_name#") />
			<cfelse>
				<cfset say("I did not understand you.") />
				<cfset onHelp() />
			</cfif>
		</cfif>
		
		<cfset say("Can I help you with anything else?") />

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
				<cfif local.returnJSON.total eq 1>
					<cfset local.park_output = "There is one park in #local.state_name#, " />
				<cfelse>
					<cfset local.park_output = "There are #local.returnJSON.total# parks in #local.state_name#: " />
				</cfif>
				<cfset local.array_index = 0 />
				<cfset local.array_len = ArrayLen(local.returnJSON.data) />
				<cfif local.array_len eq 1>
					<cfset local.park_output &= "#local.returnJSON.data[1].fullName#. " />
				<cfelse>
					<cfloop array="#local.returnJSON.data#" index="local.thisPark">
						<cfset local.array_index++ />
						<cfif local.array_len neq local.array_index>
							<cfset local.park_output &= "#local.thisPark.fullName#, " />
						<cfelse>
							<cfset local.park_output &= "and #local.thisPark.fullName#. " />
						</cfif>
					</cfloop>
				</cfif>
				
				<cfset setTitle('National Park Service Sites in #local.state_name#') />
				<cfset setText(local.park_output) />
				<cfset say(local.park_output)>
			<cfelse>
				<!--- No states --->
				<cfset setTitle('National Park Service Sites in #local.state_name#') />
				<cfset setText("I did not find any parks in #local.state_name#") />
				<cfset say("I did not find any parks in #local.state_name#") />
			</cfif>

		<cfelse>
			<!--- parse of state_name failed to find a result --->
			<cfif len(local.state_name)>
				<cfset say("I did not find #local.state_name#") />
			<cfelse>
				<cfset say("I did not understand you.") />
				<cfset onHelp() />
			</cfif>
		</cfif>
		
		<cfset say("Can I help you with anything else?") />

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
	
	<cffunction name="getParkDYK" access="public" returntype="void">
		<cfargument name="Park" type="string" required="no" default="">

		<cfset local.park_name = trim(arguments.Park) />
		
		<!--- Parse park_name --->
		<cfset local.park_code = getParkCode(local.park_name) />
					
		<cfif local.park_code neq "none">
			<!--- Pull in DYK.json --->
			<cftry>
				<cfset local.official_park_name = getOfficialParkName(local.park_code) />
				
				<cfhttp url="#this.dyk_base#" method="get" result="local.dykData" timeout="5"></cfhttp>
				<cfcatch>
					<!--- Timeout or other HTTP error --->
					<cflog text="#SerializeJSON(cfcatch)#" type="information" file="alexa_debug" />
				</cfcatch>
			</cftry>
			<cfset local.return_json = DeserializeJSON(local.dykData.filecontent) />
			<cfset local.fact_array = ArrayNew(1) />
			<cfloop array="#local.return_json#" index="thisFact">
				<cfif thisFact.alphacode eq '#local.park_code#'>
					<cfset ArrayAppend(local.fact_array, thisFact) />
				</cfif>
			</cfloop>
			
			<cfif ArrayLen(local.fact_array)>
				<cfset theFactIndex = RandRange(1, ArrayLen(local.fact_array)) />
				<cfset setTitle('Trivia for #local.official_park_name#') />
				<cfset setText(local.fact_array[theFactIndex].fact) />
				<cfset say('Trivia for #local.official_park_name#: #local.fact_array[theFactIndex].fact#') />
			<cfelse>
				<!--- No corresponding record --->
				<cfset setTitle("Trivia for #local.park_name#") />
				<cfset setText("I can''t find a fact for #local.park_name#. ") />
				<cfset say("I can''t find a fact for #local.park_name#. ") />
			</cfif>

		<cfelse>
			<!--- parse of site_name failed to find a result --->
			<cfif len(local.park_name)>
				<cfset say("I did not find #local.park_name#") />
			<cfelse>
				<cfset say("I did not understand you.") />
				<cfset onHelp() />
			</cfif>
		</cfif>
		
		<cfset say("Can I help you with anything else?") />
		
	</cffunction>
	
	<cffunction name="getRandomDYK" access="public" returntype="void">

		<!--- Pull in DYK.json --->
		<cftry>
			<cfhttp url="#this.dyk_base#" method="get" result="local.dykData" timeout="5"></cfhttp>
			<cfcatch>
				<!--- Timeout or other HTTP error --->
				<cflog text="#SerializeJSON(cfcatch)#" type="information" file="alexa_debug" />
			</cfcatch>
		</cftry>
		<cfset local.fact_array = DeserializeJSON(local.dykData.filecontent) />
		
		<cfif ArrayLen(local.fact_array)>
			<cfset theFactIndex = RandRange(1, ArrayLen(local.fact_array)) />
			<cfset setTitle("National Park Trivia") />
			<cfset setText("Trivia for #local.fact_array[theFactIndex]['Park Name']#: #local.fact_array[theFactIndex].fact#") />
			<cfset say("Trivia for #local.fact_array[theFactIndex]['Park Name']#: #local.fact_array[theFactIndex].fact#") />
		<cfelse>
			<!--- No corresponding record --->
			<cfset setTitle("National Park Trivia") />
			<cfset setText("I can't find National Park Trivia. ") />
			<cfset say("I can't find National Park Trivia. ") />
		</cfif>
		
		<cfset say("Can I help you with anything else?") />
		
	</cffunction>
	
	<cffunction name="onLaunch" access="public" returntype="void">
		<cfargument name="sessionInfo" required="yes">


		<cfset super.onLaunch(arguments.sessionInfo)>
		
		<cfset say("Welcome to the Alexa NPS Ranger skill. You can ask me for descriptions, alerts, or news for any national park service site.")>
	</cffunction>
	
	<cffunction name="formatPhoneNumber" access="private" returntype="string">
		<cfargument name="unformatted_phone_number" type="string" required="yes" default="" />
		
		<cfset local.unformatted_phone_number = trim(arguments.unformatted_phone_number) />
		
		<cfif len(local.unformatted_phone_number) eq 10>
			<cfset local.formatted_phone_number = '(#left(local.unformatted_phone_number,3)#) #mid(local.unformatted_phone_number,3,3)#-#right(local.unformatted_phone_number,4)#' />
		<cfelse>
			<!--- Not a standard US phone number w/ area code --->
			<cfset local.formatted_phone_number = '' />		
		</cfif>
		
		<cfreturn local.formatted_phone_number />
	
	</cffunction>
	
	<cffunction name="formatDate" access="private" returntype="string">
		<cfargument name="date" type="date" required="yes" default="" />
		
		<cfset local.date = arguments.date />
		
		<cfif DateCompare(now(),local.date, 'd') eq 0>
			<cfset local.date_output = 'today' />
		<cfelseif DateCompare(DateAdd("d", 1, now()),local.date, 'd') eq 0>
			<cfset local.date_output = 'tomorrow' />
		<cfelse>
			<cfset local.date_output = 'on #DateFormat(local.date, "Mmmmm d")#' />
		</cfif>
		
		<cfreturn local.date_output />
	
	</cffunction>
	
	<cffunction name="getOfficialParkName" access="private" returntype="string">
		<cfargument name="park_code" type="string" required="yes" default="" />
		
		<cfset local.park_code = arguments.park_code />
		
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
				<cfreturn local.returnJSON.data[1].fullname />
			</cfif>

		</cfif>
		
		<cfreturn '' />
	
	</cffunction>
	
	<cffunction name="replaceSubstringsForVoice" access="private" returntype="string">
		<cfargument name="targetString" type="string" required="yes" default="" />
		
		<!--- Handles special treatment of Alexa's pronunciation of particular terms
			TODO: Switch to use SSML phonetic spellings
		--->
		
		<cfset local.targetString = arguments.targetString />
		<cfset local.listOfReplacements = { 
				"Fort Larned": "fort lar ned",
				"Mesa Verde": "mesa ver de",
				"Noatak": "no attack",
				"Cuyahoga": "kaia hoaga"
			} />
			
		<cfloop collection="#local.listOfReplacements#" item="local.key">
			<cfset local.targetString = Replace(local.targetString, local.key, local.listOfReplacements[local.key], "ALL") />
		</cfloop>
		
		<cfreturn local.targetString />
	
	</cffunction>
	
</cfcomponent>