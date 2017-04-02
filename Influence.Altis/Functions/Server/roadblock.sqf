functionValidateRoadblockMissionServer =
{
	_position = _this select 0;
	_roadblockDirection = _this select 1;
	_road = _this select 2;
	_base = _this select 3;
	_clientPlayerObject = _this select 4;
	_team = _clientPlayerObject getVariable 'team';
	_baseSupplySufficient = false;
	_positionExclusive = true;
	if ((_base getVariable 'supplyAmount') >= auxiliaryRoadblockSupplyCost)
	then
	{
		_baseSupplySufficient = true;
	};
	{
		if ((_x getVariable 'team') == _team)
		then
		{
			if ((_position distance (position _x)) <= auxiliaryRoadblockExclusiveEstablishmentRadius)
			then
			{
				_positionExclusive = false;
			};
		};
	} forEach roadblocks;
	_teamLiteral = [_team] call functionGetTeamFORName;
	_missions = missionNamespace getVariable (format ['missions%1', _teamLiteral]);
	_positions = [_missions] call functionGetPlannedRoadblocks;
	{
		if ((_position distance _x) <= auxiliaryRoadblockExclusiveEstablishmentRadius)
		then
		{
			_positionExclusive = false;
		};
	} forEach _positions;
	if (_baseSupplySufficient and _positionExclusive)
	then
	{
		// Roadblock mission special arguments: build position, base object, construction vehicle object
		_base setVariable ['supplyAmount', (_base getVariable 'supplyAmount') - auxiliaryRoadblockSupplyCost, true];
		['roadblock', _team, [_position, _base, objNull, _roadblockDirection, _road]] call functionAddSingleMission;
		[[], 'functionManageRoadblocksCloseMap', _clientPlayerObject] call BIS_fnc_MP;
	}
	else
	{
		if (_positionExclusive)
		then
		{
			[[['functionHandleRoadblockPlanningError', []], ['functionHandleGetPlannedRoadblocksResponse', [_positions]]], 'functionCallBulkFunctions', _clientPlayerObject] call BIS_fnc_MP;
		}
		else
		{
			[[], 'functionHandleRoadblockPlanningError', _clientPlayerObject] call BIS_fnc_MP;
		};
	};
};

functionHandleGetPlannedRoadblocksRequest =
{
	_clientPlayerObject = _this select 0;
	_team = _clientPlayerObject getVariable 'team';
	_teamLiteral = [_team] call functionGetTeamFORName;
	_missions = missionNamespace getVariable (format ['missions%1', _teamLiteral]);
	_positions = [_missions] call functionGetPlannedRoadblocks;
	[[_positions], 'functionHandleGetPlannedRoadblocksResponse', _clientPlayerObject] call BIS_fnc_MP;
};

functionGetPlannedRoadblocks =
{
	private ['_missions', '_positions'];
	_missions = _this select 0;
	_positions = [];
	{
		_missionType = _x select 1;
		_missionSpecialArguments = _x select 4;
		if (_missionType == 'roadblock')
		then
		{
			_buildPosition = _missionSpecialArguments select 0;
			_positions pushBack _buildPosition;
		};
	} forEach _missions;
	_positions;
};

functionRegisterRoadblock =
{
	_roadPosition = _this select 0;
	_roadblockDirection = _this select 1;
	_road = _this select 2;
	_team = _this select 3;
	_roadblockObject = createVehicle ['Land_MobilePhone_old_F', _roadPosition, [], 0, 'CAN_COLLIDE'];
	_roadblockObject allowDamage false;
	_roadblockID = format ['roadblock%1', totalRoadblocks];
	_roadblockName = format ['Roadblock %1', totalRoadblocks + 1];
	['totalRoadblocks'] call functionPublicVariableIncrementInteger;
	_roadblockObject setVariable ['id', _roadblockID, true];
	_roadblockObject setVariable ['name', _roadblockName, true];
	_roadblockObject setVariable ['roadblockRoad', _road, true];
	_roadblockObject setVariable ['roadblockDirection', _roadblockDirection, true];
	_roadblockObject setVariable ['team', _team, true];
	_machinegunTurret = createVehicle ['B_HMG_01_high_F', ([1, ([3, _roadPosition, _roadblockDirection, 90] call functionGetAngleRelativePosition), _roadblockDirection, 180] call functionGetAngleRelativePosition), [], 0, 'CAN_COLLIDE'];
	_machinegunTurret setDir _roadblockDirection;
	[_machinegunTurret, _roadblockObject] call functionRoadblockEstablishStaticDefence;
	_roadblockObject setVariable ['roadblockMachinegunTurret', _machinegunTurret];
	_staticDefenceWallOne = createVehicle ['Land_BagFence_Round_F', ([2.4, _roadPosition, _roadblockDirection, 90] call functionGetAngleRelativePosition), [], 0, 'CAN_COLLIDE'];
	_staticDefenceWallOne setDir (_roadblockDirection - 180);
	_staticDefenceWallOne setVectorUp (surfaceNormal (position _staticDefenceWallOne));
	_antiTankTurret = createVehicle ['B_static_AT_F', ([21, ([-3.4, _roadPosition, _roadblockDirection, 90] call functionGetAngleRelativePosition), _roadblockDirection, 180] call functionGetAngleRelativePosition), [], 0, 'CAN_COLLIDE'];
	_antiTankTurret setDir _roadblockDirection;
	[_antiTankTurret, _roadblockObject] call functionRoadblockEstablishStaticDefence;
	_roadblockObject setVariable ['roadblockAntiTankTurret', _antiTankTurret];
	_staticDefenceWallTwo = createVehicle ['Land_BagFence_Round_F', ([20, ([-3.4, _roadPosition, _roadblockDirection, 90] call functionGetAngleRelativePosition), _roadblockDirection, 180] call functionGetAngleRelativePosition), [], 0, 'CAN_COLLIDE'];
	_staticDefenceWallTwo setDir (_roadblockDirection - 180);
	_staticDefenceWallTwo setVectorUp (surfaceNormal (position _staticDefenceWallTwo));
	_roadblockObject setVariable ['roadblockObjects', [_staticDefenceWallOne, _staticDefenceWallTwo]];
	['roadblocks', _roadblockObject] call functionPublicVariableAppendToArray;
	[[_roadblockObject], 'functionHandleNewRoadblock', _team] call BIS_fnc_MP;
};

functionRoadblockEstablishStaticDefence =
{
	_staticDefenceObject = _this select 0;
	_staticDefenceRoadblock = _this select 1;
	_staticDefenceTeam = _staticDefenceRoadblock getVariable 'team';
	_staticDefenceTeamLiteral =  [_staticDefenceTeam] call functionGetTeamFORName;
	_staticDefenceObject setVariable ['roadblock', _staticDefenceRoadblock];
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
	_staticDefenceUnit setVariable ['roadblock', _staticDefenceRoadblock];
	_staticDefenceUnit addEventHandler ['Killed', functionRoadblockHandleStaticDefenceUnitKilled];
	_staticDefenceObject setVariable ['staticDefenceUnit', _staticDefenceUnit, true];
};

functionRoadblockHandleStaticDefenceUnitKilled =
{
	_unitKilled = _this select 0;
	_unitKiller = _this select 1;
	_roadblock = _unitKilled getVariable 'roadblock';
	_machinegunTurretUnitAlive = alive ((_roadblock getVariable 'roadblockMachinegunTurret') getVariable 'staticDefenceUnit');
	_antiTankTurretUnitAlive = alive ((_roadblock getVariable 'roadblockAntiTankTurret') getVariable 'staticDefenceUnit');
	if (!(_machinegunTurretUnitAlive) and !(_antiTankTurretUnitAlive))
	then
	{
		[[_roadblock], 'functionHandleRoadblockAttack', (_roadblock getVariable 'team')] call BIS_fnc_MP;
		sleep auxiliaryRoadblockDespawnDelay;
		deleteVehicle (_roadblock getVariable 'roadblockMachinegunTurret');
		deleteVehicle (_roadblock getVariable 'roadblockAntiTankTurret');
		{
			deleteVehicle _x;
		} forEach (_roadblock getVariable 'roadblockObjects');
		['roadblocks', 0, _roadblock] call functionPublicVariableRemoveNestedArrayWithIndexValue;
		deleteVehicle _roadblock;
	};
};