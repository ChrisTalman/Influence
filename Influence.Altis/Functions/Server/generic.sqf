functionHandlePlayableUnitLocalityChange =
{
	{
		if ((owner _x) == serverOwnershipID)
		then
		{
			[_x] spawn functionDelayedIslandRepositioning;
			[_x] call functionDisablePlayableUnit;
			[_x] call functionDisablePlayableUnitAI;
			[_x] call functionUnitAddDamagePrevention;
			_unitTeam = _x getVariable ['team', Civilian];
			if (_unitTeam == BLUFOR or _unitTeam == OPFOR)
			then
			{
				_unitTeamLiteral = [_unitTeam] call functionGetTeamFORName;
				_defaultLoadout = missionNamespace getVariable (format ['defaultLoadout%1', _unitTeamLiteral]);
				[_x, _defaultLoadout] call functionUnitSetLoadout;
			};
		}
		else
		{
			[_x] call functionUnitRemoveDamagePrevention;
		};
	} forEach playableUnits;
};

functionDelayedIslandRepositioning =
{
	_unitObject = _this select 0;
	sleep 1;
	_unitObject setPos respawnIslandPosition;
};

functionEstablishServerPlayableUnits =
{
	{
		_x addEventHandler ['Local', {[_this select 0, _this select 1] spawn functionHandlePlayableUnitLocalityChange}];
		[_x] call functionDisablePlayableUnit;
		_x setVariable ['team', side _x, true];
		_x setVariable ['respawning', true, true];
	} forEach playableUnits;
};

functionDisablePlayableUnit =
{
	private ['_playableUnitObject'];
	_playableUnitObject = _this select 0;
	_playableUnitObject disableAI 'ANIM';
	_playableUnitObject setDamage 0;
	_playableUnitObject hideObjectGlobal true;
};

functionDisablePlayableUnitAI =
{
	_unit = _this select 0;
	_groupMembers = units (group _unit);
	{
		if (_x != _unit)
		then
		{
			_x setDamage 1;
		};
	} forEach _groupMembers;
};

functionEstablishStartingPositions =
{
	_startingPositionPairBLUFOR = round (random 1);
	_startingPositionPairOPFOR = 0;
	if (_startingPositionPairBLUFOR == 0)
	then
	{
		_startingPositionPairOPFOR = 1;
	};
	["startingPositionBLUFOR", (startingPositionPairs select (floor (random (count startingPositionPairs)))) select _startingPositionPairBLUFOR] call functionPublicVariableSetValue;
	["startingPositionOPFOR", (startingPositionPairs select (floor (random (count startingPositionPairs)))) select _startingPositionPairOPFOR] call functionPublicVariableSetValue;
	diag_log format ["startingPositionBLUFOR: %1. startingPositionOPFOR: %2.", startingPositionBLUFOR, startingPositionOPFOR];
};

functionEstablishStartingAssets =
{
	_hunter1 = createVehicle ['B_MRAP_01_F', ([startingPositionBLUFOR, 0, 30, 0, 0, 180, 0] call BIS_fnc_findSafePos), [], 0, 'NONE'];
	[_hunter1, 'Hunter', BLUFOR] call functionRegisterVehicle;
	_hunter2 = createVehicle ['B_MRAP_01_F', ([startingPositionBLUFOR, 0, 30, 0, 0, 180, 0] call BIS_fnc_findSafePos), [], 0, 'NONE'];
	[_hunter2, 'Hunter', BLUFOR] call functionRegisterVehicle;
	_ifrit1 = createVehicle ['O_MRAP_02_F', ([startingPositionOPFOR, 0, 30, 0, 0, 180, 0] call BIS_fnc_findSafePos), [], 0, 'NONE'];
	[_ifrit1, 'Ifrit', OPFOR] call functionRegisterVehicle;
	_ifrit2 = createVehicle ['O_MRAP_02_F', ([startingPositionOPFOR, 0, 30, 0, 0, 180, 0] call BIS_fnc_findSafePos), [], 0, 'NONE'];
	[_ifrit2, 'Ifrit', OPFOR] call functionRegisterVehicle;
};

functionEstablishConnectionEvents =
{
	['connectEvent', 'onPlayerConnected', {[_name, _uid] call functionHandlePlayerConnect}] call BIS_fnc_addStackedEventHandler;
	['disconnectEvent', 'onPlayerDisconnected', {[_name, _uid] call functionHandlePlayerDisconnect}] call BIS_fnc_addStackedEventHandler;
};

functionHandlePlayerConnect =
{
	_playerName = _this select 0;
	_playerUID = _this select 1;
	//diag_log format ['Player connected. _playerName: %1. _playerUID: %2.', _playerName, _playerUID];
};

functionHandlePlayerDisconnect =
{
	_playerName = _this select 0;
	_playerUID = _this select 1;
	diag_log format ['Player disconnected. _playerName: %1. _playerUID: %2.', _playerName, _playerUID];
	if (commanderBLUFOR == _playerUID)
	then
	{
		['commanderBLUFOR', ''] call functionPublicVariableSetValue;
		[[_playerName, 'disconnect', BLUFOR], 'functionHandleNoCommander', BLUFOR] call BIS_fnc_MP;
	};
	if (commanderOPFOR == _playerUID)
	then
	{
		['commanderOPFOR', ''] call functionPublicVariableSetValue;
		[[_playerName, 'disconnect', OPFOR], 'functionHandleNoCommander', OPFOR] call BIS_fnc_MP;
	};
	[_playerUID] call functionMissionsHandlePlayerDisconnect;
};

functionEstablishBasesTestEnvironment =
{
	firstBaseEstablishedBLUFOR = true;
	firstBaseEstablishedBLUFOR = true;
	// Bases
	_sandBase = [[23627.7,18650.3,0], 1000, BLUFOR] call functionRegisterBase; // Sand Area
	[[23643.3,18623.9,0], 'infantryFacility', _sandBase] call functionEstablishBasesTestEnvironmentBaseFacility;
	[[23603.1,18663.2,0], 'heavyVehicleFacility', _sandBase] call functionEstablishBasesTestEnvironmentBaseFacility;
	[[23644.7,18681.4,0], 'lightVehicleFacility', _sandBase] call functionEstablishBasesTestEnvironmentBaseFacility;
	[[23698.1,18666.8,0], 'airFacility', _sandBase] call functionEstablishBasesTestEnvironmentBaseFacility;
	[[26775.1,22777.8,0], 250, BLUFOR] call functionRegisterBase; // Northernmost Base
	[[23494.6,19859.4,0], 2000, BLUFOR] call functionRegisterBase; // Road near Sand Area
	[[22552.7,20228.8,0], 500, BLUFOR] call functionRegisterBase;
	[[21744.6,15309.7,0], 250, OPFOR] call functionRegisterBase; // Southernmost Base
	[[21983.3,20246.4,0], 250, BLUFOR] call functionRegisterBase; // Coastal Base
	// FOBs
	[[23547.3,18785.4,0], 250, BLUFOR] call functionRegisterFOB; // Sand Area
	// Relay Channel 1
	[[22735.8,19943.1,0], BLUFOR] call functionRegisterSupplyRelayStation;
	[[22976.6,19596,0], BLUFOR] call functionRegisterSupplyRelayStation;
	[[23147.4,19290.6,0], BLUFOR] call functionRegisterSupplyRelayStation;
	[[23416.2,18919.8,0], BLUFOR] call functionRegisterSupplyRelayStation;
	// Relay Channel 2
	[[23827.4,18876.4,0], BLUFOR] call functionRegisterSupplyRelayStation;
	[[24217.2,19281.1,0], BLUFOR] call functionRegisterSupplyRelayStation;
	[[24554.8,19751.6,0], BLUFOR] call functionRegisterSupplyRelayStation;
	[[24889.2,20216.6,0], BLUFOR] call functionRegisterSupplyRelayStation;
	[[25199.7,20704.2,0], BLUFOR] call functionRegisterSupplyRelayStation;
	[[25502.9,21204.4,0], BLUFOR] call functionRegisterSupplyRelayStation;
	[[25832.7,21695.9,0], BLUFOR] call functionRegisterSupplyRelayStation;
	[[26257.8,22114.1,0], BLUFOR] call functionRegisterSupplyRelayStation;
	[[26641.5,22497.7,0], BLUFOR] call functionRegisterSupplyRelayStation;
	// Relay Channel 3
	[[23464.4,18296.7,0], BLUFOR] call functionRegisterSupplyRelayStation;
	[[23168.7,17840,0], BLUFOR] call functionRegisterSupplyRelayStation;
	[[22890.7,17363.3,0], BLUFOR] call functionRegisterSupplyRelayStation;
	[[22617,16884.3,0], BLUFOR] call functionRegisterSupplyRelayStation;
	[[22386,16409.5,0], BLUFOR] call functionRegisterSupplyRelayStation;
	[[22133.7,15968.9,0], BLUFOR] call functionRegisterSupplyRelayStation;
	[[21885.6,15532.7,0], BLUFOR] call functionRegisterSupplyRelayStation;
};

functionEstablishNewSupplySystemTestEnvironment =
{
	firstBaseEstablishedBLUFOR = true;
	firstBaseEstablishedBLUFOR = true;
	//[[23627.7,18650.3,0], 1000, BLUFOR] call functionRegisterBase; // Sand Area
	[[8663.96,15864.9,0.0015564], 250, BLUFOR] call functionRegisterFOB;
	[[8675.36,12911.9,0.00138092], 250, OPFOR] call functionRegisterBase;
	[[8641.81,19054.6,0.00166321], 250, OPFOR] call functionRegisterBase;
};

functionEstablishBasesTestEnvironmentBaseFacility =
{
	_facilityPosition = _this select 0;
	_facilityIndentifier = _this select 1;
	_baseObject = _this select 2;
	_facilityObjectEngineName = 'undefined';
	switch (_facilityIndentifier)
	do
	{
		case 'infantryFacility': { _facilityObjectEngineName = 'Land_MilOffices_V1_F' };
		case 'lightVehicleFacility': { _facilityObjectEngineName = 'Land_CarService_F' };
		case 'heavyVehicleFacility': { _facilityObjectEngineName = 'Land_dp_smallFactory_F' };
		case 'airFacility': { _facilityObjectEngineName = 'Land_Airport_Tower_F' };
		case 'navalFacility': { _facilityObjectEngineName = 'Land_BuoyBig_F' };
	};
	_facilityObject = createVehicle [_facilityObjectEngineName, _facilityPosition, [], 0, 'CAN_COLLIDE'];
	_baseObject setVariable [_facilityIndentifier, _facilityObject, true];
	_baseStructures = _baseObject getVariable 'structures';
	_baseStructures pushBack _facilityObject;
	_baseObject setVariable ['structures', _baseStructures, true];
};

functionEstablishAITestEnvironment =
{
	[[8532.06,11532.8,1.65617], 1000, BLUFOR] call functionRegisterBase;
	_townCentre = [9232.4307, 11886.366, 17.094887];
	_townRadius = 500;
	//[_townCentre, _townRadius] call functionEstablishTownDefence;
};

functionAllowDamageForUnit =
{
	private ['_unit'];
	_unit = _this select 0;
	_unit allowDamage true;
};

functionObjectSetVariablePublicTargetViaServer =
{
	_object = _this select 0;
	_variableName = _this select 1;
	_variableValue = _this select 2;
	_publicTarget = _this select 3;
	//diag_log format ['Adding public object variable. _object: %1. _variableName: %2. _variableValue: %3. _publicTarget: %4.', _object, _variableName, _variableValue, _publicTarget];
	if (isNil 'publicObjectVariables')
	then
	{
		publicObjectVariables = [];
	};
	// publicObjectVariables array format: object, variable public name, variable public value, variable public target
	publicObjectVariables = publicObjectVariables + [[_object, _variableName, _variableValue, _publicTarget]];
	[[_object, _variableName, _variableValue], 'functionObjectSetVariablePublicTargetLocalEnactment', _publicTarget] call BIS_fnc_MP;
};

functionEstablishPublicObjectVariablesViaServer =
{
	private ['_playerObject'];
	_playerObject = _this select 0;
	//diag_log 'Serving public object variables.';
	if (!(isNil 'publicObjectVariables'))
	then
	{
		//diag_log format ['publicObjectVariables: %1.', publicObjectVariables];
		_abridgedPublicObjectVariables = [];
		{
			//diag_log format ['publicObjectVariable: %1.', _x];
			_publicTarget = _x select 3;
			if ((typeName _publicTarget) == 'SIDE')
			then
			{
				if ((_playerObject getVariable 'team') == _publicTarget)
				then
				{
					_abridgedPublicObjectVariable = +_x;
					_abridgedPublicObjectVariable deleteAt 3;
					_abridgedPublicObjectVariables = _abridgedPublicObjectVariables + [_abridgedPublicObjectVariable];
					//diag_log format ['_abridgedPublicObjectVariable: %1.', _abridgedPublicObjectVariable];
				};
			};
		} forEach publicObjectVariables;
		//diag_log format ['_abridgedPublicObjectVariables: %1.', _abridgedPublicObjectVariables];
		[[_abridgedPublicObjectVariables], 'functionEstablishPublicObjectVariablesLocalEnactment', owner _playerObject] call BIS_fnc_MP;
	};
};

functionAugmentedPublicVariableSetValueViaServer =
{
	private ['_publicVariableName', '_publicVariableSetValue', '_publicVariableTarget'];
	_variableName = _this select 0;
	_variableSetValue = _this select 1;
	_variableTarget = _this select 2;
	_foundAugmentedPublicVariables = [];
	{
		_currentVariableName = _x select 0;
		if (_currentVariableName == _variableName)
		then
		{
			_foundAugmentedPublicVariables = _foundAugmentedPublicVariables + [_x];
		};
	} forEach augmentedPublicVariables;
	_foundAugmentedPublicVariable = false;
	{
		_currentVariableTarget = _x select 2;
		if (_currentVariableTarget == _variableTarget)
		then
		{
			_foundAugmentedPublicVariable = _x;
		};
	} forEach _foundAugmentedPublicVariables;
	if ((typeName _foundAugmentedPublicVariable) == 'ARRAY')
	then
	{
		_revisedFoundAugmentedPublicVariable = +_foundAugmentedPublicVariable;
		_revisedFoundAugmentedPublicVariable set [1, _variableSetValue];
		augmentedPublicVariables set [augmentedPublicVariables find _foundAugmentedPublicVariable, _revisedFoundAugmentedPublicVariable];
		_abridgedAugmentedPublicVariable = +_revisedFoundAugmentedPublicVariable;
		_abridgedAugmentedPublicVariable deleteAt 2;
		[_abridgedAugmentedPublicVariable, 'functionAugmentedPublicVariableSetValueLocalEnactment', _variableTarget] call BIS_fnc_MP;
	}
	else
	{
		augmentedPublicVariables = augmentedPublicVariables + [_this];
	};
};

functionEstablishTeamsHostility =
{
	Independent setFriend [BLUFOR, 0];
	Independent setFriend [OPFOR, 0];
	BLUFOR setFriend [Independent, 0];
	OPFOR setFriend [Independent, 0];
};

functionHandleClientReady =
{
	private ['_playerObject'];
	_playerObject = _this select 0;
	_playerObject hideObjectGlobal false;
	_teamLiteral = [_playerObject getVariable 'team'] call functionGetTeamFORName;
	_playerDataRecord = [playersData, 0, getPlayerUID _playerObject] call functionGetNestedArrayWithIndexValue;
	_playerDataSupplyQuota = false;
	if (count _playerDataRecord == 0)
	then
	{
		// playersData array format: player Steam unique ID, player profile name, player supply quota, player team
		playersData pushBack [getPlayerUID _playerObject, name _playerObject, personalSupplyQuotaStartingAmount, (_playerObject getVariable 'team')];
		['playersDataPublic', call functionPlayersDataGetAbridged] call functionPublicVariableSetValue;
		_playerDataSupplyQuota = personalSupplyQuotaStartingAmount;
	}
	else
	{
		_playerDataName = _playerDataRecord select 1;
		_playerDataSupplyQuota = _playerDataRecord select 2;
		_playerDataTeam = _playerDataRecord select 3;
		if (_playerDataTeam != (_playerObject getVariable 'team'))
		then
		{
			// Player has already played as one team, and is attempting to switch to another
		};
		diag_log format ['_playerDataName: %1. name _playerObject: %2.', _playerDataName, name _playerObject];
		if (_playerDataName != name _playerObject)
		then
		{
			_playerDataRecordRevised = +_playerDataRecord;
			_playerDataRecordRevised set [1, name _playerObject];
			[playersData find _playerDataRecord, _playerDataRecordRevised] call functionPlayersDataSetRecord;
		};
	};
	_provincesStatusClient = [];
	{
		_provincesStatusClient = _provincesStatusClient + [[_x select 1, _x select 3, _x select 4]];
	} forEach provincesStatusServer;
	_provinceActive = missionNamespace getVariable (format ['provinceActive%1', _teamLiteral]);
	_augmentedPublicVariablesForClient = [];
	{
		_augmentedPublicVariableTarget = _x select 2;
		if ((_playerObject getVariable 'team') == _augmentedPublicVariableTarget)
		then
		{
			_abridgedPublicObjectVariable = +_x;
			_abridgedPublicObjectVariable deleteAt 2;
			_augmentedPublicVariablesForClient = _augmentedPublicVariablesForClient + [_abridgedPublicObjectVariable];
		};
	} forEach augmentedPublicVariables;
	_firstBaseEstablished = missionNamespace getVariable (format ['firstBaseEstablished%1', _teamLiteral]);
	_missions = missionNamespace getVariable (format ['missions%1', _teamLiteral]);
	_availableMissionsCount = [_playerObject getVariable 'team'] call functionGetAmountAvailableMissions;
	_playerActiveMission = [_missions, 2, getPlayerUID _playerObject] call functionGetNestedArrayWithIndexValue;
	[_playerObject, _playerActiveMission] call functionMissionsHandlePlayerClientReady;
	if ((count _playerActiveMission) == 0)
	then
	{
		_playerActiveMission = false;
	}
	else
	{
		[[_availableMissionsCount], 'functionEstablishAvailableMissionCount', _playerObject getVariable 'team'] call BIS_fnc_MP;
	};
	[[['functionEstablishSupplyQuota', [_playerDataSupplyQuota]], ['functionBulkUpdateProvincesClient', [_provincesStatusClient, _provinceActive]], ['functionEstablishAugmentedPublicVariablesClient', [_augmentedPublicVariablesForClient]], ['functionEstablishFirstBaseEstablished', [_firstBaseEstablished]], ['functionEstablishAvailableMissionCount', [_availableMissionsCount]], ['functionEstablishActiveMission', [_playerActiveMission]]], 'functionCallBulkFunctions', _playerObject] call BIS_fnc_MP;
};

functionPlayersDataSetRecord =
{
	// Arguments: record index, new value
	private ['_recordIndex', '_newValue', '_playersDataAbridged'];
	_recordIndex = _this select 0;
	_newValue = _this select 1;
	playersData set [_recordIndex, _newValue];
	_playersDataAbridged = call functionPlayersDataGetAbridged;
	//diag_log format ['playersDataPublic: %1.', playersDataPublic];
	['playersDataPublic', _playersDataAbridged] call functionPublicVariableSetValue;
};

functionPlayersDataGetAbridged =
{
	private ['_playersDataAbridged', '_playerDataAbridged'];
	// playersDataAbridged array format: player Steam unique ID, player profile name
	/*_playersDataAbridged = [];
	{
		_playerDataAbridged = [_x select 0, _x select 1];
		_playersDataAbridged pushBack _playerDataAbridged;
	} forEach playersData;*/
	_playersDataAbridged = playersData;
	_playersDataAbridged;
};

functionHandlePlayerKilledServer =
{
	_playerKilled = _this select 0;
	_playerKiller = _this select 1;
	if (isPlayer _playerKiller)
	then
	{
		if (_playerKiller != _playerKilled)
		then
		{
			if ((_playerKiller getVariable 'team') != (_playerKilled getVariable 'team'))
			then
			{
				diag_log format ['%1 was killed by %2.', name _playerKilled, name _playerKiller];
				//sleep playerKillRewardDelaySeconds;
				_newSupplyQuota = [getPlayerUID _playerKiller, playerKillReward] call functionAddPlayerSupplyQuota;
				[[['functionHandlePlayerKillReward', []], ['functionEstablishSupplyQuota', [_newSupplyQuota]]], 'functionCallBulkFunctions', _playerKiller] call BIS_fnc_MP;
				diag_log format ['%1 was rewarded for killing %2.', name _playerKiller, name _playerKilled];
			};
		};
	};
};