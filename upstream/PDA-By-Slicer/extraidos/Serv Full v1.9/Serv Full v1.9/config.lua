-- The Forgotten Server Config
	-- Account manager
	accountManager = true
	namelockManager = true
	newPlayerChooseVoc = false
	newPlayerSpawnPosX = 49
	newPlayerSpawnPosY = 73
	newPlayerSpawnPosZ = 7
	newPlayerTownId = 1
	newPlayerLevel = 5
	newPlayerMagicLevel = 0
	generateAccountNumber = false

	lightInterval = 7500
		-- a cada "lightInterval" ms vai passar 1 minuto
	lightChange = 1
		-- quanto de light ira alterar durante passagem de dia/noite
	startupTime = 351
		-- quantas horas serão ao ligar o server (360 = 6:00 a.m, 1080 = 6:00 p.m, varia de 0 a 1440)
	startupLight = 40
		-- quanto de light vai estar ao ligar o server

	limitPokeballs = 6		-- deprecated
	happyDropTime = 12		-- a cada "happyDropTime" segundos o pokemon vai perder HAPPINESS
	minHappinessEffectDelay = 25	-- a cada min de "happinessEffectDelay" segundos o pokemon vai mostrar a felicidade
	maxHappinessEffectDelay = 40	-- a cada min de "happinessEffectDelay" segundos o pokemon vai mostrar a felicidade
	PokemonStageVeryHappy = 215	-- com quanto de happy o poke precisa pra estar muito feliz
	PokemonStageHappy = 160		-- ... pra estar feliz
	PokemonStageOK = 110		-- ... pra estar normal
	PokemonStageSad = 50		-- ... pra estar triste
	PokemonStageMad = 0		-- ... pra estar bravo
	maximumHunger = 120		-- maior fome possivel
	stateHunger = 100		-- 19estagio que precisa estar pra ficar com fome
	increaseHunger = 7		-- a cada X segundos (xml do monstro) aumenta o hunger em "increaseHunger"
	decreaseHappy = 1		-- HAPPINESS que o pokemon vai perder a cada "happyDropTime"
	decreaseHungryHappy = 4		-- 3HAPPINESS a mais que o pokemon vai perder se estiver com fome
	useTeleportWithFly = false
	dropHappyDuringBattles = true	-- HAPPINESS vai cair enquanto estiver batalhando ? true / false

	allowBlockSpawn = false
	
	rateGymSpellInterval = 0.68

	-- Unjustified kills
	-- NOTE: *Banishment and *BlackSkull variables are >summed up<
	-- (dailyFragsToRedSkull + dailyFragsToBanishment) with their
	-- *RedSkull equivalents.
	-- Auto banishing works only if useBlackSkull set to negative.
	-- advancedFragList is not advised if you use huge frags
	-- requirements.
	redSkullLength = 30 * 24 * 60 * 60
	blackSkullLength = 45 * 24 * 60 * 60
	dailyFragsToRedSkull = 3
	weeklyFragsToRedSkull = 5
	monthlyFragsToRedSkull = 10
	dailyFragsToBlackSkull = dailyFragsToRedSkull
	weeklyFragsToBlackSkull = weeklyFragsToRedSkull
	monthlyFragsToBlackSkull = monthlyFragsToRedSkull
	dailyFragsToBanishment = dailyFragsToRedSkull
	weeklyFragsToBanishment = weeklyFragsToRedSkull
	monthlyFragsToBanishment = monthlyFragsToRedSkull
	blackSkulledDeathHealth = 40
	blackSkulledDeathMana = 0
	useBlackSkull = true
	useFragHandler = true
	advancedFragList = false

	-- Banishments
	-- violationNameReportActionType 1 = just a report, 2 = name lock, 3 = player banishment
	-- killsBanLength works only if useBlackSkull option is disabled.
	notationsToBan = 3
	warningsToFinalBan = 4
	warningsToDeletion = 5
	banLength = 7 * 24 * 60 * 60
	killsBanLength = 7 * 24 * 60 * 60
	finalBanLength = 30 * 24 * 60 * 60
	ipBanishmentLength = 1 * 24 * 60 * 60
	broadcastBanishments = true
	maxViolationCommentSize = 200
	violationNameReportActionType = 2
	autoBanishUnknownBytes = false

	-- Battle
	-- NOTE: showHealingDamageForMonsters inheritates from showHealingDamage.
	-- loginProtectionPeriod is the famous Tibia anti-magebomb system.
	-- deathLostPercent set to nil enables manual mode.
	worldType = "pvp"
	protectionLevel = 1000
	pvpTileIgnoreLevelAndVocationProtection = true
	pzLocked = 18 * 1000
	huntingDuration = 60 * 1000
	criticalHitChance = 7
	criticalHitMultiplier = 1
	displayCriticalHitNotify = false
	removeWeaponAmmunition = true
	removeWeaponCharges = true
	removeRuneCharges = true
	whiteSkullTime = 15 * 60 * 1000
	noDamageToSameLookfeet = false
	showHealingDamage = false
	showHealingDamageForMonsters = false
	fieldOwnershipDuration = 5 * 1000
	stopAttackingAtExit = false
	oldConditionAccuracy = false
	loginProtectionPeriod = 10 * 1000
	deathLostPercent = 1
	stairhopDelay = 0 * 1000
	pushCreatureDelay = 1 * 1000
	deathContainerId = 0
	gainExperienceColor = 215
	addManaSpentInPvPZone = true
	squareColor = 0
	allowFightback = true

	-- Connection config
	worldId = 0
	ip = "127.0.0.1"
	bindOnlyConfiguredIpAddress = false
	loginPort = 7171
	gamePort = 7172
	adminPort = 7171
	statusPort = 7171
	loginTries = 10
	retryTimeout = 5 * 1000
	loginTimeout = 60 * 1000
	maxPlayers = 50	-- codificado e limitado para 7
	motd = "Welcome to pokemon dash!"
	displayOnOrOffAtCharlist = false
	onePlayerOnlinePerAccount = false
	allowClones = true
	serverName = "Pokemon Dash"
	loginMessage = "Welcome to pokemon dash server!"
	statusTimeout = 5 * 60 * 1000
	replaceKickOnLogin = true
	forceSlowConnectionsToDisconnect = false
	loginOnlyWithLoginServer = false
	premiumPlayerSkipWaitList = true

	-- Database
	-- NOTE: sqlFile is used only by sqlite database, and sqlKeepAlive by mysql database.
	-- To disable sqlKeepAlive such as mysqlReadTimeout use 0 value.
	sqlType = "sqlite"
	sqlHost = "localhost"
	sqlPort = 3306
	sqlUser = "root"
	sqlPass = ""
	sqlDatabase = "theforgottenserver"
	sqlFile = "forgottenserver.s3db"
	sqlKeepAlive = 0
	mysqlReadTimeout = 10
	mysqlWriteTimeout = 10
	encryptionType = "plain"

	-- Deathlist
	deathListEnabled = true
	deathListRequiredTime = 1 * 60 * 1000
	deathAssistCount = 19
	maxDeathRecords = 10

	-- Guilds
	ingameGuildManagement = true
	levelToFormGuild = 40
	premiumDaysToFormGuild = 0
	guildNameMinLength = 2
	guildNameMaxLength = 25

	-- Highscores
	highscoreDisplayPlayers = 15
	updateHighscoresAfterMinutes = 60

	-- Houses
	buyableAndSellableHouses = true
	houseNeedPremium = true
	bedsRequirePremium = true
	levelToBuyHouse = 1
	housesPerAccount = 0
	houseRentAsPrice = false
	housePriceAsRent = false
	housePriceEachSquare = 2975
	houseRentPeriod = "never"
	houseCleanOld = 0
	guildHalls = false

	-- Item usage
	timeBetweenActions = 500
	timeBetweenExActions = 500
	hotkeyAimbotEnabled = true

	-- Map
	-- NOTE: storeTrash costs more memory, but will perform alot faster cleaning.
	mapName = "mastermap"
	mapAuthor = "brun123"
	randomizeTiles = true
	storeTrash = false
	cleanProtectedZones = true
	mailboxDisabledTowns = "1"

	-- Process
	-- NOTE: defaultPriority works only on Windows and niceLevel on *nix
	-- coresUsed are seperated by comma cores ids used by server process,
	-- default is -1, so it stays untouched (automaticaly assigned by OS).
	defaultPriority = "high"
	niceLevel = 5
	coresUsed = "-1"

	-- Startup
	optimizeDatabaseAtStartup = true
	removePremiumOnInit = true
	confirmOutdatedVersion = false

	-- Spells
	formulaLevel = 5.0
	formulaMagic = 1.0
	bufferMutedOnSpellFailure = false
	spellNameInsteadOfWords = false
	emoteSpells = false

	-- Outfits
	allowChangeOutfit = true
	allowChangeColors = true
	allowChangeAddons = true
	disableOutfitsForPrivilegedPlayers = false
	addonsOnlyPremium = false

	-- Miscellaneous
	-- NOTE: promptExceptionTracerErrorBox works only with precompiled support feature,
	-- called "exception tracer" (__EXCEPTION_TRACER__ flag).
	dataDirectory = "data/"
	bankSystem = true
	displaySkillLevelOnAdvance = false
	promptExceptionTracerErrorBox = true
	separateViplistPerCharacter = false
	maximumDoorLevel = 500
	maxMessageBuffer = 4

	-- Saving-related
	-- useHouseDataStorage usage may be found at README.
	saveGlobalStorage = false
	useHouseDataStorage = false
	storePlayerDirection = false

	-- Loot
	-- monsterLootMessage 0 to disable, 1 - only party, 2 - only player, 3 - party or player (like Tibia's)
	checkCorpseOwner = true
	monsterLootMessage = 3
	monsterLootMessageType = 22

	-- Ghost mode
	ghostModeInvisibleEffect = false
	ghostModeSpellEffects = false

	-- Limits
	idleWarningTime = 14 * 60 * 1000
	idleKickTime = 15 * 60 * 1000
	expireReportsAfterReads = 1
	playerQueryDeepness = 2
	maxItemsPerPZTile = 0
	maxItemsPerHouseTile = 0

	-- Premium-related
	freePremium = false
	premiumForPromotion = true

	-- Blessings
	-- NOTE: blessingReduction* regards items/containers loss.
	-- eachBlessReduction is how much each bless reduces the experience/magic/skills loss.
	blessingOnlyPremium = true
	blessingReductionBase = 30
	blessingReductionDecreament = 5
	eachBlessReduction = 8

	-- Rates
	-- NOTE: experienceStages configuration is located in data/XML/stages.xml.
	-- rateExperienceFromPlayers 0 to disable.
	experienceStages = false
	rateExperience = 0
	rateExperienceFromPlayers = 0
	rateSkill = 1
	rateMagic = 1.0
	rateLoot = 1
	rateSpawn = 1

	-- Monster rates
	rateMonsterHealth = 1.0
	rateMonsterMana = 1.0
	rateMonsterAttack = 1.0
	rateMonsterDefense = 1.0

	-- Experience from players
	-- NOTE: min~Threshold* set to 0 will disable the minimum threshold:
	-- player will gain experience from every lower leveled player.
	-- max~Threshold* set to 0 will disable the maximum threshold:
	-- player will gain experience from every higher leveled player.
	minLevelThresholdForKilledPlayer = 0.9
	maxLevelThresholdForKilledPlayer = 1.1

	-- Stamina
	-- NOTE: Stamina is stored in miliseconds, so seconds are multiplied by 1000.
	-- rateStaminaHits multiplies every hit done a creature, which are later
	-- multiplied by player attack speed.
	-- rateStaminaGain is divider of every logged out second, eg:
	-- 60000 / 3 = 20000 milliseconds, what gives 20 stamina seconds for 1 minute being logged off.
	-- rateStaminaThresholdGain is divider for the premium stamina.
	-- staminaRatingLimit* is in minutes.
	rateStaminaLoss = 1
	rateStaminaGain = 3
	rateStaminaThresholdGain = 12
	staminaRatingLimitTop = 41 * 60
	staminaRatingLimitBottom = 14 * 60
	rateStaminaAboveNormal = 1.0
	rateStaminaUnderNormal = 1.0
	staminaThresholdOnlyPremium = true

	-- Party
	-- NOTE: experienceShareLevelDifference is float number.
	-- experienceShareLevelDifference is highestLevel * value
	experienceShareRadiusX = 30
	experienceShareRadiusY = 30
	experienceShareRadiusZ = 1
	experienceShareLevelDifference = 200 * 200
	extraPartyExperienceLimit = 20
	extraPartyExperiencePercent = 20
	experienceShareActivity = 2 * 60 * 1000

	-- Global save
	-- NOTE: globalSaveHour means like 03:00, not that it will save every 3 hours,
	-- if you want such a system please check out data/globalevents/globalevents.xml.
	globalSaveEnabled = false
	globalSaveHour = 8
	shutdownAtGlobalSave = true
	cleanMapAtGlobalSave = false

	-- Spawns
	deSpawnRange = 2
	deSpawnRadius = 25

	-- Summons
	maxPlayerSummons = 1
	teleportAllSummons = true
	teleportPlayerSummons = true

	-- Status
	ownerName = "Pokemon Dash Online [Advanced]"
	ownerEmail = ""
	url = ""
	location = "Brazil"
	displayGamemastersWithOnlineCommand = false

	-- Logs
	-- NOTE: This kind of logging does not work in GUI version.
	-- For such, please compile the software with __GUI_LOGS__ flag.
	adminLogsEnabled = false
	displayPlayersLogging = true
	prefixChannelLogs = ""
	runFile = ""
	outLogName = ""
	errorLogName = ""
	truncateLogsOnStartup = false