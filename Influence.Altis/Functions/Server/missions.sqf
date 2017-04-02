functionAddSingleMission =
{
	// Arguments: mission type, mission team, special arguments for mission type
	_missionType = _this select 0;
	_missionTeam = _this select 1;
	_this call functionAddMission;
	[[['functionHandleNewMission', [_missionType]], ['functionEstablishAvailableMissionCount', [([_missionTeam] call functionGetAmountAvailableMissions)]]], 'functionCallBulkFunctions', _missionTeam] call BIS_fnc_MP;
};

functionAddMultipleMissions =
{
	// Arguments: mission type, missions
	// missions array format: special arguments for mission type
	_missionType = _this select 0;
	_missionTeam = _this select 1;
	_missions = _this select 2;
	{
		[_missionType, _missionTeam, _x] call functionAddMission;
	} forEach _missions;
	[[['functionHandleNewMission', [_missionType, count _missions]], ['functionEstablishAvailableMissionCount', [([_missionTeam] call functionGetAmountAvailableMissions)]]], 'functionCallBulkFunctions', _missionTeam] call BIS_fnc_MP;
};

functionAddMission =
{
	// Arguments: mission type, mission team, special arguments for mission type
	_missionType = _this select 0;
	_missionTeam = _this select 1;
	_missionTypeSpecialArguments = _this select 2;
	_missionTeamLiteral = [_missionTeam] call functionGetTeamFORName;
	// missions array format: mission ID, mission type, mission executor UID, mission in progress, special arguments for mission type
	_uniqueMissions = missionNamespace getVariable (format ['uniqueMissions%1', _missionTeamLiteral]);
	_newMissionID = format ['mission%1', _uniqueMissions];
	missionNamespace setVariable [format ['uniqueMissions%1', _missionTeamLiteral], _uniqueMissions + 1];
	_newMission = [_newMissionID, _missionType, false, false, _missionTypeSpecialArguments];
	_missions = missionNamespace getVariable (format ['missions%1', _missionTeamLiteral]);
	_missions pushBack _newMission;
};

functionHandleGetMissionsRequest =
{
	private ['_playerObject'];
	_playerObject = _this select 0;
	//diag_log format ['name _playerObject: %1. owner _playerObject: %2. _playerObject: %3.', name _playerObject, owner _playerObject, _playerObject];
	_team = _playerObject getVariable 'team';
	_teamLiteral = [_team] call functionGetTeamFORName;
	_missions = missionNamespace getVariable (format ['missions%1', _teamLiteral]);
	_abridgedMissions = [];
	{
		_missionExecutor = _x select 2;
		_missionExecutorOnline = false;
		if ((typeName _missionExecutor) == 'STRING')
		then
		{
			_missionExecutorOnline = [_missionExecutor] call functionIsPlayerOnline;
		};
		if (!(_missionExecutorOnline))
		then
		{
			_abridgedMission = +_x;
			_abridgedMission deleteAt 2;
			_abridgedMission deleteAt 2;
			_abridgedMissions pushBack _abridgedMission;
		};
	} forEach _missions;
	[[_abridgedMissions], 'functionHandleGetMissionsResponse', _playerObject] call BIS_fnc_MP;
};

functionGetAmountAvailableMissions =
{
	private ['_team', '_teamLiteral', '_missions', '_amountMissionsAvailable', '_missionExecutor', '_missionExecutorOnline'];
	_team = _this select 0;
	_teamLiteral = [_team] call functionGetTeamFORName;
	_missions = missionNamespace getVariable (format ['missions%1', _teamLiteral]);
	_amountMissionsAvailable = 0;
	{
		_missionExecutor = _x select 2;
		_missionExecutorOnline = false;
		if ((typeName _missionExecutor) == 'STRING')
		then
		{
			_missionExecutorOnline = [_missionExecutor] call functionIsPlayerOnline;
		};
		if (!(_missionExecutorOnline))
		then
		{
			_amountMissionsAvailable = _amountMissionsAvailable + 1;
		};
	} forEach _missions;
	_amountMissionsAvailable;
};

functionAcceptMissionViaServer =
{
	private ['_missionID', '_playerObject'];
	_missionID = _this select 0;
	_playerObject = _this select 1;
	_team = _playerObject getVariable 'team';
	_teamLiteral = [_team] call functionGetTeamFORName;
	_missions = missionNamespace getVariable (format ['missions%1', _teamLiteral]);
	_mission = [_missions, 0, _missionID] call functionGetNestedArrayWithIndexValue;
	if ((count _mission) == 0)
	then
	{
		[[], 'functionHandleAcceptMissionError', _playerObject] call BIS_fnc_MP;
	}
	else
	{
		_missionType = _mission select 1;
		_missionExecutor = _mission select 2;
		_missionInProgress = _mission select 3;
		_missionTypeLiteral = [_missionType] call functionGetMissionTypeLiteral;
		_missionTypeSpecialArguments = _mission select 4;
		_missionExecutorOnline = false;
		if ((typeName _missionExecutor) == 'STRING')
		then
		{
			_missionExecutorOnline = [_missionExecutor] call functionIsPlayerOnline;
		};
		if (_missionExecutorOnline)
		then
		{
			[['conflict'], 'functionAcceptMissionError', _playerObject] call BIS_fnc_MP;
		}
		else
		{
			if (_missionType in ['FOB', 'base', 'supplyRelayStation', 'roadblock'])
			then
			{
				if (_missionInProgress)
				then
				{
					_revisedMission = +_mission;
					_revisedMission set [2, getPlayerUID _playerObject];
					_missions set [_missions find _mission, _revisedMission];
					_missionConstructionVehicle = _missionTypeSpecialArguments select 2;
					_missionConstructionVehicle setOwner (owner _playerObject);
					_missionConstructionVehicle setVariable ['ownerUID', getPlayerUID _playerObject, true];
				}
				else
				{
					_missionBase = _missionTypeSpecialArguments select 1;
					_constructionVehicle = createVehicle ['B_Truck_01_box_F', ([_missionBase, _playerObject] call functionGetPositionInBase), [], 0, 'NONE'];
					_constructionMissionVehicleDeathScriptHandle = [_constructionVehicle, _team, _missionID] spawn functionConstructionMissionHandleVehicleDeath;
					_constructionVehicle setVariable ['ownerUID', getPlayerUID _playerObject, true];
					_constructionVehicle setVariable ['team', _team, true];
					_constructionVehicle setVariable ['initialMass', getMass _constructionVehicle, true];
					_constructionVehicle setVariable ['slingLoadingPermitted', false, true];
					_constructionVehicle setVariable ['constructionMissionVehicleDeathScriptHandle', _constructionMissionVehicleDeathScriptHandle];
					_constructionVehicle setOwner (owner _playerObject);
					[[_constructionVehicle], 'functionEstablishSlingLoadingFunctionalityLocal', _team, true] call BIS_fnc_MP;
					_constructionVehicle enableRopeAttach false;
					[_constructionVehicle, 'team', _team, _team] call functionObjectSetVariablePublicTarget;
					[_constructionVehicle, 'vehicleName', format ['%1 Construction Vehicle', _missionTypeLiteral], _team] call functionObjectSetVariablePublicTarget;
					[format ['vehicles%1', [_team] call functionGetTeamFORName], _constructionVehicle] call functionPublicVariableAppendToArray;
					_revisedMissionTypeSpecialArguments = +_missionTypeSpecialArguments;
					_revisedMissionTypeSpecialArguments set [2, _constructionVehicle];
					_revisedMission = +_mission;
					_revisedMission set [2, getPlayerUID _playerObject];
					_revisedMission set [3, true];
					_revisedMission set [4, _revisedMissionTypeSpecialArguments];
					_missions set [_missions find _mission, _revisedMission];
					_mission = _revisedMission;
				};
				[[_mission], 'functionAcceptMissionLocalEnactment', _playerObject] call BIS_fnc_MP;
				[[([_team] call functionGetAmountAvailableMissions)], 'functionEstablishAvailableMissionCount', _team] call BIS_fnc_MP;
			};
		};
	};
};

functionConstructionMissionHandleVehicleDeath =
{
	private ['_constructionVehicle', '_team', '_missionID', '_teamLiteral', '_missions', '_mission'];
	_constructionVehicle = _this select 0;
	_team = _this select 1;
	_missionID = _this select 2;
	_teamLiteral = [_team] call functionGetTeamFORName;
	waitUntil {!(alive _constructionVehicle)};
	_missions = missionNamespace getVariable (format ['missions%1', _teamLiteral]);
	_mission = [_missions, 0, _missionID] call functionGetNestedArrayWithIndexValue;
	_missionType = _mission select 1;
	_missionExecutor = _mission select 2;
	_missionTypeSpecialArguments = _mission select 4;
	_buildPosition = _missionTypeSpecialArguments select 0;
	_newConcludedMission = [_missionID, _missionType, _missionExecutor, false, [_buildPosition]];
	_concludedMissions = missionNamespace getVariable (format ['missionsConcluded%1', _teamLiteral]);
	_concludedMissions pushBack _newConcludedMission;
	[_missions, 0, _missionID] call functionRemoveNestedArrayWithIndexValue;
	_missionExecutorObject = objNull;
	if ((typeName _missionExecutor) == 'STRING')
	then
	{
		_missionExecutorObject = [_missionExecutor] call functionGetPlayerObjectWithUID;
	};
	if (!(isNull _missionExecutorObject))
	then
	{
		[[_mission], 'functionHandleMissionFailureClient', _missionExecutorObject] call BIS_fnc_MP;
	};
};

functionMissionsHandlePlayerClientReady =
{
	private ['_playerObject'];
	_playerObject = _this select 0;
	_playerActiveMission = _this select 1;
	if ((count _playerActiveMission) > 0)
	then
	{
		_missionType = _playerActiveMission select 1;
		_missionTypeSpecialArguments = _playerActiveMission select 4;
		if (_missionType in ['FOB', 'base', 'supplyRelayStation', 'roadblock'])
		then
		{
			_missionConstructionVehicle = _missionTypeSpecialArguments select 2;
			_missionConstructionVehicle setOwner (owner _playerObject);
		};
	};
};

functionMissionsHandlePlayerDisconnect =
{
	private ['_playerUID'];
	_playerUID = _this select 0;
	_playerDataRecord = [playersData, 0, _playerUID] call functionGetNestedArrayWithIndexValue;
	if ((count _playerDataRecord) > 0)
	then
	{
		_playerDataRecordTeam = _playerDataRecord select 3;
		_teamLiteral = [_playerDataRecordTeam] call functionGetTeamFORName;
		_missions = missionNamespace getVariable (format ['missions%1', _teamLiteral]);
		_mission = [_missions, 2, _playerUID] call functionGetNestedArrayWithIndexValue;
		if ((count _mission) > 0)
		then
		{
			_missionTypeSpecialArguments = _mission select 4;
			_constructionVehicle = _missionTypeSpecialArguments select 2;
			_constructionVehicle lock 2;
			[[([_playerDataRecordTeam] call functionGetAmountAvailableMissions)], 'functionEstablishAvailableMissionCount', _playerDataRecordTeam] call BIS_fnc_MP;
		};
	};
};

functionAbandonMissionViaServer =
{
	_missionID = _this select 0;
	_team = _this select 1;
	_teamLiteral = [_team] call functionGetTeamFORName;
	_missions = missionNamespace getVariable (format ['missions%1', _teamLiteral]);
	_mission = [_missions, 0, _missionID] call functionRemoveNestedArrayWithIndexValue;
};

functionFulfilMissionViaServer =
{
	_missionID = _this select 0;
	_playerObject = _this select 1;
	_team = _playerObject getVariable 'team';
	_teamLiteral = [_team] call functionGetTeamFORName;
	_missions = missionNamespace getVariable (format ['missions%1', _teamLiteral]);
	_mission = [_missions, 0, _missionID] call functionGetNestedArrayWithIndexValue;
	_missionType = _mission select 1;
	_missionExecutor = _mission select 2;
	_missionTypeSpecialArguments = _mission select 4;
	_newConcludedMission = false;
	_fulfilPossible = true;
	switch (_missionType)
	do
	{
		case 'FOB':
		{
			_buildPosition = _missionTypeSpecialArguments select 0;
			if (isNull ([_buildPosition, true] call functionGetBaseAtPosition))
			then
			{
				[_buildPosition, 1000, _team] call functionRegisterFOB;
			}
			else
			{
				_fulfilPossible = false;
			};
			_newConcludedMission = [_missionID, _missionType, _missionExecutor, _fulfilPossible, [_buildPosition]];
		};
		case 'base':
		{
			_buildPosition = _missionTypeSpecialArguments select 0;
			if (isNull ([_buildPosition, true] call functionGetBaseAtPosition))
			then
			{
				[_buildPosition, 1000, _team] call functionRegisterBase;
			}
			else
			{
				_fulfilPossible = false;
			};
			_newConcludedMission = [_missionID, _missionType, _missionExecutor, _fulfilPossible, [_buildPosition]];
		};
		case 'supplyRelayStation':
		{
			_buildPosition = _missionTypeSpecialArguments select 0;
			[_buildPosition, _team] call functionRegisterSupplyRelayStation;
			_newConcludedMission = [_missionID, _missionType, _missionExecutor, true, [_buildPosition]];
		};
		case 'roadblock':
		{
			_buildPosition = _missionTypeSpecialArguments select 0;
			_buildDirection = _missionTypeSpecialArguments select 3;
			_road = _missionTypeSpecialArguments select 4;
			[_buildPosition, _buildDirection, _road, _team] call functionRegisterRoadblock;
			_newConcludedMission = [_missionID, _missionType, _missionExecutor, true, [_buildPosition]];
		};
		default
		{
			diag_log 'Unrecognised mission type to fulfil.';
		};
	};
	// _concludedMissions array format: mission ID, mission type, mission executor, mission successful, special arguments for mission type
	_concludedMissions = missionNamespace getVariable (format ['missionsConcluded%1', _teamLiteral]);
	_concludedMissions pushBack _newConcludedMission;
	[_missions, 0, _missionID] call functionRemoveNestedArrayWithIndexValue;
	if (_missionType in ['FOB', 'base', 'supplyRelayStation', 'roadblock'])
	then
	{
		_constructionVehicle = _missionTypeSpecialArguments select 2;
		terminate (_constructionVehicle getVariable 'constructionMissionVehicleDeathScriptHandle');
	};
	if (_fulfilPossible)
	then
	{
		[[_mission], 'functionFulfilConstructionMissionLocalEnactment', _playerObject] call BIS_fnc_MP;
	}
	else
	{
		[[_mission], 'functionHandleConstructionMissionCannotFulfilLocalEnactment', _playerObject] call BIS_fnc_MP;
	};
};