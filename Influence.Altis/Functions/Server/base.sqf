functionEstablishFirstBaseServer =
{
	_buildPosition = _this select 0;
	_playerObject = _this select 1;
	_team = _playerObject getVariable 'team';
	_firstBaseEstablished = missionNamespace getVariable (format ['firstBaseEstablished%1', [_team] call functionGetTeamFORName]);
	if (!(_firstBaseEstablished))
	then
	{
		missionNamespace setVariable [format ['firstBaseEstablished%1', [_team] call functionGetTeamFORName], true];
		[_buildPosition, 1000, _team] call functionRegisterBase;
		_playerObject setPos ([position _playerObject, 10, 20, 0, 0, 180, 0] call BIS_fnc_findSafePos);
	};
};

functionEstablishBaseServer =
{
	_position = _this select 0;
	_base = _this select 1;
	_clientPlayerObject = _this select 2;
	_team = _clientPlayerObject getVariable 'team';
	_baseSupplySufficient = false;
	_positionExclusive = true;
	if ((_base getVariable 'supplyAmount') >= baseSupplyCost)
	then
	{
		_baseSupplySufficient = true;
	};
	{
		if ((_x getVariable 'team') == _team)
		then
		{
			if ((_position distance (position _x)) <= baseExclusiveEstablishmentRadius)
			then
			{
				_positionExclusive = false;
			};
		};
	} forEach playerControlledBases;
	_teamLiteral = [_team] call functionGetTeamFORName;
	_missions = missionNamespace getVariable (format ['missions%1', _teamLiteral]);
	_positions = [_missions] call functionGetPlannedBases;
	{
		if ((_position distance _x) <= baseExclusiveEstablishmentRadius)
		then
		{
			_positionExclusive = false;
		};
	} forEach _positions;
	if (_baseSupplySufficient and _positionExclusive)
	then
	{
		// Base mission special arguments: build position, base object, construction vehicle object
		_base setVariable ['supplyAmount', (_base getVariable 'supplyAmount') - baseSupplyCost, true];
		['base', _team, [_position, _base, objNull]] call functionAddSingleMission;
		[[], 'functionEstablishBaseCloseMap', _clientPlayerObject] call BIS_fnc_MP;
	}
	else
	{
		if (_positionExclusive)
		then
		{
			[[['functionHandleBasePlanningError', []], ['functionHandleGetPlannedBasesResponse', [_positions]]], 'functionCallBulkFunctions', _clientPlayerObject] call BIS_fnc_MP;
		}
		else
		{
			[[], 'functionHandleBasePlanningError', _clientPlayerObject] call BIS_fnc_MP;
		};
	};
};

functionHandleGetPlannedBasesRequest =
{
	_clientPlayerObject = _this select 0;
	_team = _clientPlayerObject getVariable 'team';
	_teamLiteral = [_team] call functionGetTeamFORName;
	_missions = missionNamespace getVariable (format ['missions%1', _teamLiteral]);
	_positions = [_missions] call functionGetPlannedBases;
	[[_positions], 'functionHandleGetPlannedBasesResponse', _clientPlayerObject] call BIS_fnc_MP;
};

functionGetPlannedBases =
{
	private ['_missions', '_positions'];
	_missions = _this select 0;
	_positions = [];
	{
		_missionType = _x select 1;
		_missionSpecialArguments = _x select 4;
		if (_missionType == 'base')
		then
		{
			_buildPosition = _missionSpecialArguments select 0;
			_positions pushBack _buildPosition;
		};
	} forEach _missions;
	_positions;
};

functionRegisterBase =
{
	_desiredBasePosition = _this select 0;
	_startingSupplyAmount = _this select 1;
	_team = _this select 2;
	_teamLiteral = [_team] call functionGetTeamFORName;
	_teamName = "undefined";
	_baseCount = 0;
	_flagObjectEngineName = "undefined";
	_newBaseOpposingTeam = false;
	if (_team == BLUFOR)
	then
	{
		_teamName = "BLUFOR";
		["totalBLUFORBasesCount"] call functionPublicVariableIncrementInteger;
		_baseCount = totalBLUFORBasesCount;
		_flagObjectEngineName = "Flag_Blue_F";
		_newBaseOpposingTeam = OPFOR;
	};
	if (_team == OPFOR)
	then
	{
		_teamName = "OPFOR";
		["totalOPFORBasesCount"] call functionPublicVariableIncrementInteger;
		_baseCount = totalOPFORBasesCount;
		_flagObjectEngineName = "Flag_Red_F";
		_newBaseOpposingTeam = BLUFOR;
	};
	_newBaseID = format ["base%1%2", _teamName, (totalBLUFORBasesCount + totalOPFORBasesCount)];
	_newBaseName = format ["Base %1", _baseCount];
	// Land_MobilePhone_old_F
	_newBaseObject = createVehicle [baseObjectEngineName, [_desiredBasePosition select 0, _desiredBasePosition select 1, 0], [], 0, 'NONE'];
	_newBaseObject allowDamage false;
	_newBaseFlagPosition = [(position _newBaseObject) select 0, (position _newBaseObject) select 1, (position _newBaseObject select 2) + baseFlagPositionYOffset];
	_newBaseFlagObject = createVehicle [_flagObjectEngineName, _newBaseFlagPosition, [], 0, 'CAN_COLLIDE'];
	_newBaseFlagObject allowDamage false;
	_newBaseObject setVariable ['flagObject', _newBaseFlagObject, true];
	[[_newBaseID, _newBaseName, ([_newBaseObject] call functionGetPosition2D)], 'functionHandleNewBase', _team] call BIS_fnc_MP;
	_newBaseObject setVariable ['id', _newBaseID, true];
	_newBaseObject setVariable ['type', 'Base', true];
	_newBaseObject setVariable ['name', _newBaseName, true];
	_newBaseObject setVariable ['team', _team, true];
	_newBaseObject setVariable ['supplyAmount', _startingSupplyAmount, true];
	_newBaseObject setVariable ['unusableSupplyAmount', 0, true];
	_newBaseObject setVariable ['supplyNodeNeighbors', [], true];
	_newBaseObject setVariable ['supplyAmountInProcessing', 0, true];
	_newBaseObject setVariable ['structures', [], true];
	_newBaseObject setVariable ['defences', [], true];
	_newBaseObject setVariable ['infantryFacility', objNull, true];
	_newBaseObject setVariable ['lightVehicleFacility', objNull, true];
	_newBaseObject setVariable ['heavyVehicleFacility', objNull, true];
	_newBaseObject setVariable ['airFacility', objNull, true];
	_newBaseObject setVariable ['navalFacility', objNull, true];
	_newBaseTriggerObject = createTrigger ['EmptyDetector', position _newBaseObject];
	_newBaseTriggerObject setVariable ['baseObject', _newBaseObject, true];
	_newBaseTriggerObject setTriggerArea [baseRadius, baseRadius, 0, false];
	_newBaseTriggerObject setTriggerActivation [str _newBaseOpposingTeam, 'PRESENT', true];
	_newBaseTriggerObject setTriggerStatements ['this', 'diag_log "Base trigger activated."; [thisTrigger] spawn functionHandleBaseTriggerActivation;', 'diag_log "Base trigger disactivated."; [thisTrigger] call functionHandleBaseTriggerDisactivation;'];
	_newBaseObject setVariable ['trigger', _newBaseTriggerObject, false];
	_newBaseObject setVariable ['contested', false, true];
	_newBaseObject setVariable ['neutralised', false, true];
	_newBaseObject setVariable ['control', 100];
	_newBaseObject setVariable ['province', false];
	_newBaseObjectNeighbors = [_newBaseObject, _team] call functionGetNodeNeighbors;
	{
		_x setVariable ['supplyNodeNeighbors', ((_x getVariable 'supplyNodeNeighbors') + [_newBaseObject]), true];
	} forEach _newBaseObjectNeighbors;
	_newBaseObject setVariable ['supplyNodeNeighbors', _newBaseObjectNeighbors, true];
	["playerControlledBases", _newBaseObject] call functionPublicVariableAppendToArray;
	[(format ['knownBases%1', _teamLiteral]), _newBaseObject] call functionPublicVariableAppendToArray;
	["supplyNodes", _newBaseObject] call functionPublicVariableAppendToArray;
	if (isNull (missionNamespace getVariable (format ['primaryBase%1', ([_team] call functionGetTeamFORName)])))
	then
	{
		[format ['primaryBase%1', ([_team] call functionGetTeamFORName)], _newBaseObject] call functionPublicVariableSetValue;
	};
	_provinceIDAtNewBasePosition = [position _newBaseObject] call functionGetProvinceAtPosition;
	if ((typeName _provinceIDAtNewBasePosition) == 'STRING')
	then
	{
		_provinceStatusData = [provincesStatusServer, 0, _provinceIDAtNewBasePosition] call functionGetNestedArrayWithIndexValue;
		_revisedProvinceStatusData = _provinceStatusData;
		_revisedProvinceStatusData set [2, (_revisedProvinceStatusData select 2) + [_newBaseObject]];
		provincesStatusServer set [provincesStatusServer find _provinceStatusData, _revisedProvinceStatusData];
		_newBaseObject setVariable ['province', _provinceIDAtNewBasePosition];
		[_provinceIDAtNewBasePosition] call functionUpdateProvinceServer;
	};
	_newBaseObject;
};

functionHandleBaseTriggerActivation =
{
	_triggerObject = _this select 0;
	_triggerList = list _triggerObject;
	_triggerBaseObject = _triggerObject getVariable 'baseObject';
	_triggerBaseObject setVariable ['contested', true, true];
	_triggerBaseType = 'undefined';
	_triggerBaseTeam = _triggerBaseObject getVariable 'team';
	_triggerBaseDefendingTeam = false;
	_triggerBaseAttackingTeam = false;
	if (((_triggerBaseObject getVariable 'id') find 'base') >= 0)
	then
	{
		_triggerBaseType = 'Base';
	};
	if (((_triggerBaseObject getVariable 'id') find 'FOB') >= 0)
	then
	{
		_triggerBaseType = 'FOB';
	};
	if (_triggerBaseTeam == BLUFOR)
	then
	{
		_triggerBaseDefendingTeam = BLUFOR;
		_triggerBaseAttackingTeam = OPFOR;
	}
	else
	{
		if (_triggerBaseTeam == OPFOR)
		then
		{
			_triggerBaseDefendingTeam = OPFOR;
			_triggerBaseAttackingTeam = BLUFOR;
		};
	};
	_triggerBaseDefendingTeamLiteral =  [_triggerBaseDefendingTeam] call functionGetTeamFORName;
	_triggerBaseAttackingTeamLiteral =  [_triggerBaseAttackingTeam] call functionGetTeamFORName;
	_defenderAttackMessage = format ['%1 is attacking %2.', _triggerBaseAttackingTeamLiteral, (_triggerBaseObject getVariable 'name')];
	[['CaptureNotification', [_defenderAttackMessage]], 'bis_fnc_showNotification', _triggerBaseDefendingTeam] call BIS_fnc_MP;
	_knownBases = missionNamespace getVariable (format ['known%1s%2', _triggerBaseType, _triggerBaseAttackingTeamLiteral]);
	if (!(_triggerBaseObject in _knownBases))
	then
	{
		[(format ['known%1s%2', _triggerBaseType, _triggerBaseAttackingTeamLiteral]), _triggerBaseObject] call functionPublicVariableAppendToArray;
	};
	_controlNewValue = (_triggerBaseObject getVariable 'control');
	while {(((count _triggerList) > 0) or (_controlNewValue > -100 or _controlNewValue < 100)) and (_triggerBaseObject getVariable 'contested')}
	do
	{
		_currentServerTime = serverTime;
		// Optimisation may be possible with nearEntities - investigate in future
		_baseNearEntities = [];
		if (_triggerBaseType == 'Base')
		then
		{
			_baseNearEntities = _triggerBaseObject nearEntities ['Man', baseRadius];
		};
		if (_triggerBaseType == 'FOB')
		then
		{
			_baseNearEntities = _triggerBaseObject nearEntities ['Man', FOBRadius];
		};
		_defendingTeamCount = 0;
		_attackingTeamCount = 0;
		_basePlayers = [];
		{
			if (isPlayer _x)
			then
			{
				if (alive _x)
				then
				{
					_basePlayers pushBack _x;
					if ((side _x) == _triggerBaseDefendingTeam)
					then
					{
						_defendingTeamCount = _defendingTeamCount + 1;
					}
					else
					{
						if ((side _x) == _triggerBaseAttackingTeam)
						then
						{
							_attackingTeamCount = _attackingTeamCount + 1;
						};
					};
				};
			};
		} forEach _baseNearEntities;
		_plurality = _defendingTeamCount - _attackingTeamCount;
		_controlPreviousValue = _controlNewValue;
		_controlNewValue = (_triggerBaseObject getVariable 'control') + _plurality * baseCaptureProgressIntervalInSeconds * baseCaptureProgressIntervalAmount;
		//diag_log format ['_controlNewValue: %1. _controlPreviousValue: %2.', _controlNewValue, _controlPreviousValue];
		_triggerBaseObject setVariable ['control', _controlNewValue];
		{
			[[_controlNewValue, _triggerBaseDefendingTeam, _triggerBaseAttackingTeam], 'functionHandleBaseCaptureUpdate', _x] call BIS_fnc_MP;
		} forEach _basePlayers;
		if (_controlPreviousValue > 0 and _controlNewValue <= 0)
		then
		{
			_triggerBaseObject setVariable ['neutralised', true, true];
			[[_triggerBaseObject], 'functionHandleBaseNeutralisation', _triggerBaseDefendingTeam] call BIS_fnc_MP;
		};
		if (_controlPreviousValue <= 0 and _controlNewValue > 0)
		then
		{
			_triggerBaseObject setVariable ['neutralised', false, true];
		};
		if (_controlNewValue >= 100 and (count _triggerList) == 0)
		then
		{
			_triggerBaseObject setVariable ['contested', false, true];
			[[_triggerBaseObject], 'functionHandleBaseNoLongerContested', _triggerBaseDefendingTeam] call BIS_fnc_MP;
		}
		else
		{
			if (_controlNewValue <= -100)
			then
			{
				_triggerBaseObject setVariable ['contested', false, true];
				_triggerBaseObject setVariable ['neutralised', false, true];
				_triggerBaseObject setVariable ['control', 100];
				_triggerBaseObject setVariable ['team', _triggerBaseAttackingTeam, true];
				_newFlagObjectEngineName = false;
				if (_triggerBaseAttackingTeam == BLUFOR)
				then
				{
					_newFlagObjectEngineName = 'Flag_Blue_F';
				};
				if (_triggerBaseAttackingTeam == OPFOR)
				then
				{
					_newFlagObjectEngineName = 'Flag_Red_F';
				};
				_newFlagPosition = [0, 0, 0];
				if (_triggerBaseType == 'Base')
				then
				{
					_newFlagPosition = [(position _triggerBaseObject) select 0, (position _triggerBaseObject) select 1, (position _triggerBaseObject select 2) + baseFlagPositionYOffset];
				};
				if (_triggerBaseType == 'FOB')
				then
				{
					_newFlagPosition = [(position _triggerBaseObject) select 0, (position _triggerBaseObject) select 1, (position _triggerBaseObject select 2) + FOBFlagPositionYOffset];
				};
				_triggerBaseNewFlagObject = createVehicle [_newFlagObjectEngineName, _newFlagPosition, [], 0, 'CAN_COLLIDE'];
				deleteVehicle (_triggerBaseObject getVariable 'flagObject');
				_triggerBaseObject setVariable ['flagObject', _triggerBaseNewFlagObject, true];
				_defenderCaptureMessage = format ['%1 lost to %2.', (_triggerBaseObject getVariable 'name'), _triggerBaseAttackingTeamLiteral];
				_attackerCaptureMessage = format ['Captured %1 %2.', _triggerBaseDefendingTeamLiteral, _triggerBaseType];
				_baseCaptureMessage = format ['%1 lost %2 to %3.', _triggerBaseDefendingTeamLiteral, (_triggerBaseObject getVariable 'name'), _triggerBaseAttackingTeamLiteral];
				diag_log _baseCaptureMessage;
				[[_defenderCaptureMessage, _triggerBaseObject], 'functionHandleBaseLoss', _triggerBaseDefendingTeam] call BIS_fnc_MP;
				if ((typeName (_triggerBaseObject getVariable 'province')) == 'STRING')
				then
				{
					[(_triggerBaseObject getVariable 'province')] call functionUpdateProvinceServer;
				};
				_capturedBaseNewName = 'undefined';
				if (((_triggerBaseObject getVariable 'id') find 'base') >= 0)
				then
				{
					[format ['total%1BasesCount', _triggerBaseAttackingTeamLiteral]] call functionPublicVariableIncrementInteger;
					_capturedBaseNewName = format ['Base %1', missionNamespace getVariable (format ['total%1BasesCount', _triggerBaseAttackingTeamLiteral])];
					_currentPrimaryBase = missionNamespace getVariable (format ['primaryBase%1', _triggerBaseDefendingTeamLiteral]);
					if (_triggerBaseObject == _currentPrimaryBase)
					then
					{
						_newPrimaryBase = objNull;
						{
							scopeName 'baseLoopScope';
							if ((_x getVariable 'team') == _triggerBaseDefendingTeam)
							then
							{
								_newPrimaryBase = _x;
								breakOut 'baseLoopScope';
							};
						} forEach playerControlledBases;
						[format ['primaryBase%1', _triggerBaseDefendingTeamLiteral], _newPrimaryBase] call functionPublicVariableSetValue;
					};
					[_triggerBaseDefendingTeam] call functionHandleBaseLossServer;
				};
				if (((_triggerBaseObject getVariable 'id') find 'FOB') >= 0)
				then
				{
					[format ['total%1FOBsCount', _triggerBaseAttackingTeamLiteral]] call functionPublicVariableIncrementInteger;
					_capturedBaseNewName = format ['FOB %1', missionNamespace getVariable (format ['total%1FOBsCount', _triggerBaseAttackingTeamLiteral])];
				};
				_triggerBaseObject setVariable ['name', _capturedBaseNewName, true];
				[[_attackerCaptureMessage, _triggerBaseObject, _capturedBaseNewName], 'functionHandleBaseGain', _triggerBaseAttackingTeam] call BIS_fnc_MP;
				_capturedBaseHostileNodeNeighbors = [_triggerBaseObject, _triggerBaseDefendingTeam] call functionGetNodeNeighbors;
				{
					_x setVariable ['supplyNodeNeighbors', ((_x getVariable 'supplyNodeNeighbors') - [_triggerBaseObject]), true];
				} forEach _capturedBaseHostileNodeNeighbors;
				_capturedBaseFriendlyNodeNeighbors = [_triggerBaseObject, _triggerBaseAttackingTeam] call functionGetNodeNeighbors;
				{
					_x setVariable ['supplyNodeNeighbors', ((_x getVariable 'supplyNodeNeighbors') + [_triggerBaseObject]), true];
				} forEach _capturedBaseFriendlyNodeNeighbors;
				_triggerBaseObject setVariable ['supplyNodeNeighbors', _capturedBaseFriendlyNodeNeighbors, true];
				_triggerBaseObject setVariable ['supplyAmount', (_triggerBaseObject getVariable 'supplyAmount') + (_triggerBaseObject getVariable 'unusableSupplyAmount'), true];
				_triggerBaseObject setVariable ['supplyAmount', (_triggerBaseObject getVariable 'supplyAmount') + (_triggerBaseObject getVariable 'supplyAmountInProcessing'), true];
				_triggerBaseObject setVariable ['unusableSupplyAmount', 0, true];
				_triggerBaseObject setVariable ['supplyAmountInProcessing', 0, true];
				[_triggerBaseObject] call functionBaseTransitionStaticDefences;
				_triggerObject setTriggerActivation [str _triggerBaseDefendingTeam, 'PRESENT', true];
			};
		};
		sleep baseCaptureProgressIntervalInSeconds;
		_triggerList = list _triggerObject;
	};
};

functionHandleBaseLossServer =
{
	_team = _this select 0;
	_otherTeam = OPFOR;
	if (_team == OPFOR)
	then
	{
		_otherTeam = BLUFOR;
	};
	if (({_x getVariable 'team' == _team} count playerControlledBases) == 0)
	then
	{
		[['MissionAccomplished', true, true], 'BIS_fnc_endMission', _otherTeam] call BIS_fnc_MP;
		[['MissionFailed', false, true], 'BIS_fnc_endMission', _team] call BIS_fnc_MP;
		call BIS_fnc_endMission;
	};
};

functionHandleBaseTriggerDisactivation =
{
	// Do nothing
};

functionBaseModifySupply =
{
	private ['_modifyAmount', '_base', '_baseCurrentSupplyAmount'];
	_modifyAmount = _this select 0;
	_base = _this select 1;
	_baseCurrentSupplyAmount = _base getVariable 'supplyAmount';
	_base setVariable ['supplyAmount', _baseCurrentSupplyAmount + _modifyAmount, true];
};

functionEnactBaseBuildRequest =
{
	_buildObjectName = _this select 0;
	_buildPosition = _this select 1;
	_buildDirection = _this select 2;
	_buildSubjectObject = _this select 3;
	_playerObject = _this select 4;
	_buildableObject = [baseBuildableObjects, 0, _buildObjectName] call functionGetNestedArrayWithIndexValue;
	_buildableObjectEngineName = _buildableObject select 1;
	_buildableObjectSupplyCost = _buildableObject select 2;
	_buildPossible = true;
	if ((_buildSubjectObject getVariable 'supplyAmount') < _buildableObjectSupplyCost)
	then
	{
		_buildPossible = false;
	};
	if (_buildObjectName in ['Infantry Facility', 'Light Vehicle Facility', 'Heavy Vehicle Facility', 'Air Facility', 'Naval Facility'])
	then
	{
		if (!(isNull (_buildSubjectObject getVariable ([_buildObjectName] call functionGetBaseFacilityIdentifierFromLiteral))))
		then
		{
			_buildPossible = false;
		};
	};
	if (_buildPossible)
	then
	{
		[-_buildableObjectSupplyCost, _buildSubjectObject] call functionBaseModifySupply;
		_builtObject = createVehicle [_buildableObjectEngineName, _buildPosition, [], 0, 'CAN_COLLIDE'];
		_builtObject setDir _buildDirection;
		if (_buildObjectName in ['Static HMG', 'Static AT', 'Static AA'])
		then
		{
			[_builtObject, _buildSubjectObject] call functionBaseEstablishStaticDefence;
			_baseDefences = _buildSubjectObject getVariable 'defences';
			_baseDefences pushBack _builtObject;
			_buildSubjectObject setVariable ['defences', _baseDefences, true];
		}
		else
		{
			_baseStructures = _buildSubjectObject getVariable 'structures';
			_baseStructures pushBack _builtObject;
			_buildSubjectObject setVariable ['structures', _baseStructures, true];
			_builtObject allowDamage false;
		};
		if (_buildObjectName in ['Infantry Facility', 'Light Vehicle Facility', 'Heavy Vehicle Facility', 'Air Facility', 'Naval Facility'])
		then
		{
			_buildSubjectObject setVariable [[_buildObjectName] call functionGetBaseFacilityIdentifierFromLiteral, _builtObject, true];
		};
		[[_buildObjectName], 'functionHandleBuildViewBuildSuccess', _playerObject] call BIS_fnc_MP;
	}
	else
	{
		[[_buildObjectName], 'functionHandleBuildViewBuildError', _playerObject] call BIS_fnc_MP;
	};
};

functionEstablishStaticDefenceGroups =
{
	staticDefenceGroupBLUFOR setCombatMode 'YELLOW';
	staticDefenceGroupBLUFOR setBehaviour 'COMBAT';
	staticDefenceGroupOPFOR setCombatMode 'YELLOW';
	staticDefenceGroupOPFOR setBehaviour 'COMBAT';
};

functionBaseEstablishStaticDefence =
{
	_staticDefenceObject = _this select 0;
	_staticDefenceBase = _this select 1;
	_staticDefenceTeam = _staticDefenceBase getVariable 'team';
	_staticDefenceTeamLiteral =  [_staticDefenceTeam] call functionGetTeamFORName;
	_staticDefenceObject setVariable ['base', _staticDefenceBase];
	_staticDefenceGroup = missionNamespace getVariable (format ['staticDefenceGroup%1', _staticDefenceTeamLiteral]);
	_staticDefenceUnitEngineName = 'undefined';
	if (_staticDefenceTeam == BLUFOR)
	then
	{
		_staticDefenceUnitEngineName = 'B_soldier_F';
	};
	if (_staticDefenceTeam == OPFOR)
	then
	{
		_staticDefenceUnitEngineName = 'O_soldier_F';
	};
	_staticDefenceUnit = _staticDefenceGroup createUnit [_staticDefenceUnitEngineName, position _staticDefenceObject, [], 0, 'NONE'];
	[_staticDefenceUnit] join _staticDefenceGroup;
	_staticDefenceUnit setSkill 1;
	_staticDefenceUnit moveInGunner _staticDefenceObject;
	_staticDefenceUnit lookAt ([20, position _staticDefenceObject, getDir _staticDefenceObject, 0] call functionGetAngleRelativePosition);
	_staticDefenceObject setVariable ['staticDefenceUnit', _staticDefenceUnit, true];
};

functionReplenishStaticDefences =
{
	while {true}
	do
	{
		sleep replenishStaticDefencesIntervalSeconds;
		{
			_base = _x;
			_defences = _base getVariable 'defences';
			{
				_x setVehicleAmmo 1;
				_staticDefenceUnit = _x getVariable 'staticDefenceUnit';
				if (!(alive _staticDefenceUnit))
				then
				{
					if (!(_base getVariable 'contested'))
					then
					{
						[_x, _base] call functionBaseEstablishStaticDefence;
					};
				};
			} forEach _defences;
		} forEach (playerControlledBases + FOBs);
	};
};

functionBaseTransitionStaticDefences =
{
	private ['_base', '_defences', '_staticDefenceUnit'];
	_base = _this select 0;
	_defences = _base getVariable 'defences';
	{
		_staticDefenceUnit = _x getVariable 'staticDefenceUnit';
		deleteVehicle _staticDefenceUnit;
		[_x, _base] call functionBaseEstablishStaticDefence;
	} forEach _defences;
};