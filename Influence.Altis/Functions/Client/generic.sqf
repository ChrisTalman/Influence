functionLogFromServer =
{
	_messageToLogFromServer = _this select 0;
	systemChat format ["Log From Server: %1", _messageToLogFromServer];
	diag_log format ["Log From Server: %1", _messageToLogFromServer];
};

// Establish Basic Items
functionEstablishBasicItems =
{
	player linkItem "ItemGPS";
	player linkItem "Rangefinder";
};

// Scroll Menu
functionEstablishDefaultScrollMenuForPlayer =
{
	_playerObject = _this select 0;
	// Core
	_playerObject addAction ['<t color="#0099FF">Command</t>', functionOpenCommandInterface, '', 1000, false, true, '', 'alive _target'];
	_playerObject addAction ['<t color="#0099FF">Missions</t>', functionOpenMissionsInterface, '', 1000, false, true, '', 'alive _target'];
	_playerObject addAction ['<t color="#0099FF">Equipment</t>', functionEstablishEquipmentCharacterView, '', 1000, false, true, '', 'alive _target'];
	_playerObject addAction ['<t color="#0099FF">Vehicles</t>', functionOpenVehicleAcquisitionInterface, '', 1000, false, true, '', 'alive _target'];
	_playerObject addAction ['<t color="#0099FF">AI</t>', functionOpenAIAcquisitionInterface, '', 1000, false, true, '', 'alive _target'];
	_playerObject addAction ['<t color="#0099FF">Options</t>', functionOpenOptionsInterface, '', 1000, false, true, '', 'alive _target'];
	_playerObject addAction ['<t color="#0099FF">Help</t>', functionOpenHelpInterface, '', 1000, false, true, '', 'alive _target'];
	// Occasional
	_playerObject addAction ['<t color="#86F078">Spot</t>', functionSpot, '', 1002, false, true, '', 'alive _target and (currentWeapon _target == "laserDesignator") and !(isNull (laserTarget _target)) and !(isNull (cursorTarget)) and !(manualSpotting)'];
};

// Command Interface
functionOpenCommandInterface =
{
	_interfaceHandler = createDialog 'nwDialogueCommand';
	_commander = missionNamespace getVariable format ['commander%1', ([side player] call functionGetTeamFORName)];
	if (_commander == (getPlayerUID player) or commanderCheat)
	then
	{
		ctrlSetText [1002, 'Resign as Commander'];
		buttonSetAction [1002, 'call functionResignAsCommanderClient;'];
	}
	else
	{
		ctrlEnable [1003, false];
		ctrlEnable [1004, false];
		ctrlEnable [1005, false];
		ctrlEnable [1006, false];
		ctrlEnable [1007, false];
		ctrlEnable [1008, false];
		ctrlEnable [1009, false];
		if (_commander != '')
		then
		{
			if ((missionNamespace getVariable format ['commanderChallengeElection%1InProgress', ([side player] call functionGetTeamFORName)]))
			then
			{
				ctrlEnable [1002, false];
			};
			ctrlSetText [1002, 'Challenge Commander in Vote'];
			buttonSetAction [1002, 'call functionOpenChallengeElectionInterface;'];
			ctrlEnable [1002, false];
		};
	};
	if (isNil format ['provinceActive%1', [side player] call functionGetTeamFORName])
	then
	{
		ctrlEnable [1008, false];
		diag_log 'provinceActive not yet set.';
	}
	else
	{
		_provinceActive = missionNamespace getVariable (format ['provinceActive%1', [side player] call functionGetTeamFORName]);
		diag_log format ['_provinceActive: %1. typeName: %2.', _provinceActive, typeName _provinceActive];
		if ((typeName _provinceActive) == 'STRING')
		then
		{
			ctrlSetText [1008, 'Deactivate Province'];
			buttonSetAction [1008, 'call functionDeactivateProvinceClient'];
		};
	};
	//ctrlEnable [1005, false];
};

functionOwnedVehicleEstablishLock =
{
	private ["_vehicle", "_lock"];
	_vehicle = _this select 0;
	_lock = _this select 1;
	if (_lock)
	then
	{
		_vehicle lock 2;
	}
	else
	{
		_vehicle lock 0;
	};
	_vehicle addAction ["<t color='#86F078'>Lock</t>", {(_this select 0) lock 2;}, "", 1003, false, true, "", "(alive _target) and ((locked _target) == 0)"];
	_vehicle addAction ["<t color='#86F078'>Unlock</t>", {(_this select 0) lock 0;}, "", 1003, false, true, "", "(alive _target) and ((locked _target) == 2)"];
};

functionHideOppositeTeamFromPlayer =
{
	_hide = _this select 0;
	_oppositeSide = false;
	if ((player getVariable 'team') == BLUFOR)
	then
	{
		_oppositeSide = OPFOR;
	};
	if ((player getVariable 'team') == OPFOR)
	then
	{
		_oppositeSide = BLUFOR;
	};
	{
		if ((side _x) == _oppositeSide)
		then
		{
			if (_hide)
			then
			{
				_x hideObject true;
			}
			else
			{
				_x hideObject false;
			};
		};
	} forEach playableUnits;
};

functionEstablishPublicObjectVariables =
{
	[[player], 'functionEstablishPublicObjectVariablesViaServer', false] call BIS_fnc_MP;
};

functionEstablishPublicObjectVariablesLocalEnactment =
{
	_publicObjectVariables = _this select 0;
	diag_log format ['_publicObjectVariables: %1.', _publicObjectVariables];
	{
		_object = _x select 0;
		_variableName = _x select 1;
		_variableValue = _x select 2;
		[_object, _variableName, _variableValue] call functionObjectSetVariablePublicTargetLocalEnactment;
	} forEach _publicObjectVariables;
};

functionEstablishAugmentedPublicVariablesClient =
{
	_augmentedPublicVariables = _this select 0;
	{
		_variableName = _x select 0;
		_variableValue = _x select 1;
		missionNamespace setVariable [_variableName, _variableValue];
	} forEach _augmentedPublicVariables;
};

functionAugmentedPublicVariableSetValueLocalEnactment =
{
	private ['_variableName', '_variableSetValue'];
	_variableName = _this select 0;
	_variableSetValue = _this select 1;
	missionNamespace setVariable [_variableName, _variableSetValue];
};

functionEstablishScreenKeyActions =
{
	(findDisplay screenDisplayID) displayAddEventHandler ['KeyUp', {_this call functionHandleScreenKeyUp;}];
};

functionHandleScreenKeyUp =
{
	_keyUpID = _this select 1;
	if (_keyUpID == keyCodeLWIN)
	then
	{
		call functionToggleOperationalHUD;
	};
};

functionNotifyServerClientReady =
{
	[[player], 'functionHandleClientReady', false] call BIS_fnc_MP;
};

functionCallBulkFunctions =
{
	_functions = _this;
	{
		_functionIdentifier = _x select 0;
		_functionArguments = _x select 1;
		diag_log format ['_functionIdentifier: %1. _functionArguments: %2.', _functionIdentifier, _functionArguments];
		_functionArguments call (missionNamespace getVariable _functionIdentifier);
	} forEach _functions;
};

functionHandlePlayerKillReward =
{
	player sideChat format ['You were awarded €%1 for killing an enemy player.', playerKillReward];
};

functionGetTeamMapMarkerColourName =
{
	private ['_team', '_mapMarkerColourName'];
	_team = _this select 0;
	_mapMarkerColourName = 'undefined';
	if (_team == BLUFOR)
	then
	{
		_mapMarkerColourName = colourTeamMapMarkersBLUFOR;
	};
	if (_team == OPFOR)
	then
	{
		_mapMarkerColourName = colourTeamMapMarkersOPFOR;
	};
	_mapMarkerColourName;
};

functionGetMobileRespawnAtPosition =
{
	// Arguments: position
	// Returns: mobile respawn vehicle object, or objNull
	private ['_position', '_mobileRespawn', '_mobileRespawnPointPosition2D'];
	_position = _this select 0;
	_mobileRespawn = objNull;
	{
		scopeName 'mobileRespawnLoopScope';
		if ((_x getVariable 'team') == side player)
		then
		{
			_mobileRespawnPointPosition2D = [position _x select 0, position _x select 1];
			if ((_mobileRespawnPointPosition2D distance _position) <= mobileRespawnRadius)
			then
			{
				_mobileRespawn = _x;
				breakOut 'mobileRespawnLoopScope';
			};
		};
	} forEach mobileRespawnPoints;
	_mobileRespawn;
};

functionGetMobileRespawnWithID =
{
	// Arguments: mobile respawn ID
	// Returns: mobile respawn object, or objNull
	private ['_mobileRespawnID', '_mobileRespawn'];
	_mobileRespawnID = _this select 0;
	_mobileRespawn = objNull;
	{
		scopeName 'mobileRespawnLoopScope';
		if ((_x getVariable 'id') == _mobileRespawnID)
		then
		{
			_mobileRespawn = _x;
			breakOut 'mobileRespawnLoopScope';
		};
	} forEach mobileRespawnPoints;
	_mobileRespawn;
};

functionControlFatigueLoss =
{
	while {true}
	do
	{
		player setFatigue ((getFatigue player) - controlFatigueLossCorrection);
		sleep controlFatigueLossInterval;
	};
};

functionEstablishMapDiary =
{
	player createDiarySubject ['gameModeSubject', 'Influence Help'];
	player createDiaryRecord ['gameModeSubject', ['Sling Loading', gameModeDiaryEntryDescriptionSlingLoading]];
	player createDiaryRecord ['gameModeSubject', ['Spotting', gameModeDiaryEntryDescriptionSpotting]];
	player createDiaryRecord ['gameModeSubject', ['Operational HUD', gameModeDiaryEntryDescriptionOperationalHUD]];
	player createDiaryRecord ['gameModeSubject', ['Missions', gameModeDiaryEntryDescriptionMissions]];
	player createDiaryRecord ['gameModeSubject', ['Provinces', gameModeDiaryEntryDescriptionProvinces]];
	player createDiaryRecord ['gameModeSubject', ['Influence', gameModeDiaryEntryDescriptionInfluence]];
	player createDiaryRecord ['gameModeSubject', ['Commanders', gameModeDiaryEntryDescriptionCommanders]];
	player createDiaryRecord ['gameModeSubject', ['Supply', gameModeDiaryEntryDescriptionSupply]];
	player createDiaryRecord ['gameModeSubject', ['Bases', gameModeDiaryEntryDescriptionBases]];
	player createDiaryRecord ['gameModeSubject', ['Introduction', gameModeDiaryEntryDescriptionIntroduction]];
};

functionOpenHelpInterface =
{
	processDiaryLink (createDiaryLink ['gameModeSubject', player, 'gameModeSubject']);
};

functionCloseDialogue =
{
	private ['_dialogueID'];
	_dialogueID = _this select 0;
	if (!(isNull (findDisplay _dialogueID)))
	then
	{
		closeDialog 0;
	};
};

functionCreateMarkerCircle =
{
	// Arguments: size X, size Y
	deleteMarker 'functionCreateMarkerCircle';
	_marker = createMarker ['functionCreateMarkerCircle', position player];
	_marker setMarkerShape 'ELLIPSE';
	_marker setMarkerSize [_this select 0, _this select 1];
};

functionGetNumberAsMetre =
{
	// Arguments: number
	private ['_number', '_roundedNumber', '_metre'];
	_number = _this select 0;
	_roundedNumber = round _number;
	_metre = '';
	if (_roundedNumber < 1000)
	then
	{
		_metre = format ['%1m', _roundedNumber];
	}
	else
	{
		_metre = format ['%1km', (round (_roundedNumber * 0.01) * 0.1)];
	};
	_metre;
};