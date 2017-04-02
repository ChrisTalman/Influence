functionEstablishTownDefence =
{
	private ['_provinceID', '_townCentre', '_townRadius'];
	_provinceID = _this select 0;
	_townCentre = _this select 1;
	_townRadius = _this select 2;
	_townDefenceID = format ['townDefence%1', provincesActivatedCount];
	provincesActivatedCount = provincesActivatedCount + 1;
	diag_log format ['functionEstablishTownDefence _townCentre: %1. _townRadius: %2.', _townCentre, _townRadius];
	_townRadiusBuildings = nearestObjects [_townCentre, ['House'], _townRadius];
	_townRadiusRoads = _townCentre nearRoads _townRadius;
	_independentGroups = [];
	_vehiclePatrolGroups = [];
	_vehiclePatrolObjects = [];
	_initialTotalPatrolGroupUnits = 0;
	// townDefenceKills array format: killed unit type, killer UID
	missionNamespace setVariable [format ['townDefence%1Kills', _townDefenceID], []];
	// townDefenceParticipants array format: participant UID
	missionNamespace setVariable [format ['townDefence%1Participants', _townDefenceID], []];
	_townDefencePatrolGroupsAmount = [_townRadius] call functionTownDefenceGetScaledPatrolGroupsAmount;
	diag_log format ['_townDefencePatrolGroupsAmount: %1.', _townDefencePatrolGroupsAmount];
	[] spawn functionReportGroupsAmountTeams;
	// Infantry Patrols
	for '_groupIndex' from 0 to (_townDefencePatrolGroupsAmount - 1)
	do
	{
		_independentGroup = createGroup Independent;
		diag_log format ['Created Group: %1.', _independentGroup];
		_independentGroup setVariable ['lastGroupSize', count (units _independentGroup)];
		_independentGroup setVariable ['backupDispatched', false];
		_independentGroup setVariable ['currentTarget', objNull];
		_independentGroups = _independentGroups + [_independentGroup];
		_independentGroup setCombatMode 'YELLOW';
		_independentGroup setBehaviour 'COMBAT';
		_startPoint = [_townCentre, 0, _townRadius, 0, 0, 180, 0] call BIS_fnc_findSafePos;
		for '_unitIndex' from 0 to (townDefenceStandardPatrolGroupUnitsSize - 1)
		do
		{
			_unitType = 'I_soldier_F';
			if (_unitIndex == (townDefenceStandardPatrolGroupUnitsSize - 1) or _unitIndex == (townDefenceStandardPatrolGroupUnitsSize - 2))
			then
			{
				_unitType = 'I_Soldier_LAT_F';
			};
			if (_unitIndex == (townDefenceStandardPatrolGroupUnitsSize - 3))
			then
			{
				_unitType = 'I_Soldier_M_F';
			};
			if (_unitIndex == (townDefenceStandardPatrolGroupUnitsSize - 4))
			then
			{
				_unitType = 'I_Soldier_AR_F';
			};
			if (_unitIndex == (townDefenceStandardPatrolGroupUnitsSize - 5))
			then
			{
				_unitType = 'I_officer_F';
			};
			_unit = _independentGroup createUnit [_unitType, _startPoint, [], 0, 'FORM'];
			diag_log format ['Created Unit: %1.', _unit];
			[_unit] join _independentGroup;
			[_unit] call functionTownDefenceUnitSetSkill;
			[_unit] call functionTownDefenceUnitRemoveItems;
			if (_unitIndex == 0)
			then
			{
				_independentGroup selectLeader _unit;
				_independentGroup setVariable ['lastGroupLeaderPosition', position _unit];
			};
			_unit setVariable ['townDefenceID', _townDefenceID];
			_unit addEventHandler ['Killed', functionHandleTownDefenceUnitDeath];
			_unit setVariable ['team', Independent, true];
		};
		_antiAircraftUnitChance = random 1;
		if (_antiAircraftUnitChance <= 0.25)
		then
		{
			_unit = _independentGroup createUnit ['I_Soldier_AA_F', _startPoint, [], 0, 'FORM'];
			[_unit] join _independentGroup;
			[_unit] call functionTownDefenceUnitSetSkill;
			[_unit] call functionTownDefenceUnitRemoveItems;
			_unit setVariable ['townDefenceID', _townDefenceID];
			_unit addEventHandler ['Killed', functionHandleTownDefenceUnitDeath];
			_unit setVariable ['team', Independent, true];
		};
		// Road Patrols
		if (_groupIndex >= 0 and _groupIndex < round (_townDefencePatrolGroupsAmount * townDefenceScaledRoadPatrolGroupsProportion))
		then
		{
			[_independentGroup, _townCentre, _townRadius] call functionInitialiseTownDefenceRoadPatrol;
			_independentGroup setVariable ['patrolType', 'road'];
		};
		// Free Patrols
		if (_groupIndex >= round (_townDefencePatrolGroupsAmount * townDefenceScaledRoadPatrolGroupsProportion) and _groupIndex < _townDefencePatrolGroupsAmount)
		then
		{
			[leader _independentGroup, _townCentre, _townRadius] call functionHandleTownDefenceFreePatrolWaypointCompletion;
			_independentGroup setVariable ['patrolType', 'free'];
		};
		diag_log format ['_independentGroup patrolType: %1', _independentGroup getVariable 'patrolType'];
		_independentGroup setVariable ['originalUnitSize', count (units _independentGroup)];
		_initialTotalPatrolGroupUnits = _initialTotalPatrolGroupUnits + (count (units _independentGroup));
	};
	//publicVariable 'independentGroups';
	// Consider spawning road patrol units on roads at start
	// Vehicle Patrols
	for '_patrolVehicleIndex' from 0 to (townDefencePatrolVehiclesAmount - 1)
	do
	{
		_vehiclePatrolGroup = createGroup Independent;
		_startPoint = [_townCentre, 0, _townRadius, 0, 0, 180, 0] call BIS_fnc_findSafePos;
		_patrolVehicle = createVehicle ['I_APC_tracked_03_cannon_F', _startPoint, [], 0, 'NONE'];
		_patrolVehicle lock 2;
		_patrolVehicle setVariable ['townDefenceID', _townDefenceID];
		_patrolVehicle addEventHandler ['Killed', functionHandleTownDefenceUnitDeath];
		_patrolVehicle setVariable ['team', Independent, true];
		for '_unitIndex' from 0 to 2
		do
		{
			_unit = _vehiclePatrolGroup createUnit ['I_soldier_F', _startPoint, [], 0, 'NONE'];
			[_unit] join _vehiclePatrolGroup;
			[_unit] call functionTownDefenceUnitSetSkill;
			[_unit] call functionTownDefenceUnitRemoveItems;
			if (_unitIndex == 0)
			then
			{
				_vehiclePatrolGroup selectLeader _unit;
				_unit moveInDriver _patrolVehicle;
			};
			if (_unitIndex == 1)
			then
			{
				_unit moveInGunner _patrolVehicle;
			};
			if (_unitIndex == 2)
			then
			{
				_unit moveInCommander _patrolVehicle;
			};
			_unit setVariable ['townDefenceID', _townDefenceID];
			_unit addEventHandler ['Killed', functionHandleTownDefenceUnitDeath];
			_unit setVariable ['team', Independent, true];
		};
		_vehiclePatrolGroup setVariable ['patrolType', 'road'];
		[_vehiclePatrolGroup, _townCentre, _townRadius] call functionInitialiseTownDefenceRoadPatrol;
		_vehiclePatrolGroups pushBack _vehiclePatrolGroup;
		_vehiclePatrolObjects pushBack _patrolVehicle;
	};
	//publicVariable 'lightVehiclePatrolGroup';
	// Building Defence Units
	_buildingsDefended = [];
	_buildingDefenceGroup = createGroup Independent;
	_buildingDefenceGroup setCombatMode 'RED';
	_buildingDefenceGroup setBehaviour 'COMBAT';
	[_buildingDefenceGroup] call functionGroupDeleteAllWaypoints;
	buildingDefenceGroup = _buildingDefenceGroup;
	publicVariable 'buildingDefenceGroup';
	for '_unitIndex' from 0 to (townDefenceBuildingDefenceUnitsAmount - 1)
	do
	{
		_building = objNull;
		_firstBuildingInteriorPosition = [0, 0, 0];
		_buildingInteriorPositions = [];
		while {_building in _buildingsDefended or (format ['%1', _firstBuildingInteriorPosition]) == '[0,0,0]' or _building == objNull}
		do
		{
			_building = _townRadiusBuildings select (floor (random (count (_townRadiusBuildings))));
			_buildingInteriorPosition = _building buildingPos 0;
			_firstBuildingInteriorPosition = _buildingInteriorPosition;
			while {(format ['%1', _buildingInteriorPosition]) != '[0,0,0]'}
			do
			{
				_buildingInteriorPositions = _buildingInteriorPositions + [_buildingInteriorPosition];
				_buildingInteriorPosition = _building buildingPos ((count _buildingInteriorPositions) + 1);
			};
		};
		_buildingsDefended = _buildingsDefended + [_building];
		_buildingPosition = _buildingInteriorPositions select (floor (random (count (_buildingInteriorPositions))));
		_unit = _buildingDefenceGroup createUnit ['I_soldier_F', _buildingPosition, [], 0, 'FORM'];
		[_unit] join _buildingDefenceGroup;
		doStop _unit;
		[_unit] call functionTownDefenceUnitSetSkill;
		[_unit] call functionTownDefenceUnitRemoveItems;
		_unit setVariable ['townDefenceID', _townDefenceID];
		_unit addEventHandler ['Killed', functionHandleTownDefenceUnitDeath];
		_unit setVariable ['team', Independent, true];
	};
	_buildingDefenceGroup enableAttack false;
	// Remove public variables once feature is in a stable state
	//publicVariable 'buildingDefenceUnits';
	[_provinceID, _townDefenceID, _townCentre, _townRadius, _independentGroups, _vehiclePatrolGroups, _vehiclePatrolObjects, _buildingDefenceGroup, _initialTotalPatrolGroupUnits] spawn functionCoordinateTownDefence;
};

functionTownDefenceGetScaledPatrolGroupsAmount =
{
	private ['_townRadius', '_patrolGroupsAmount'];
	_townRadius = _this select 0;
	_patrolGroupsAmount = 0;
	if (_townRadius > 0 and _townRadius <= 300)
	then
	{
		_patrolGroupsAmount = 10;
	};
	if (_townRadius > 300 and _townRadius <= 600)
	then
	{
		_patrolGroupsAmount = 12;
	};
	if (_townRadius > 600 and _townRadius <= 1000)
	then
	{
		_patrolGroupsAmount = 14;
	};
	if (_patrolGroupsAmount == 0)
	then
	{
		diag_log format ['Town radius unrecognised in functionTownDefenceGetScaledPatrolGroupsAmount. _patrolGroupsAmount: %1.', _patrolGroupsAmount];
	};
	_patrolGroupsAmount;
};

functionTownDefenceUnitSetSkill =
{
	_unit = _this select 0;
	_unit setSkill 1;
	_unit setSkill ['aimingAccuracy', townDefenceAISkillAimingAccuracy];
	_unit setSkill ['aimingShake', townDefenceAISkillAimingAccuracy];
	_unit setSkill ['spotDistance', townDefenceAISkillSpotDistance];
};

functionTownDefenceUnitRemoveItems =
{
	_unit = _this select 0;
	//_unit removeItem 'FirstAidKit';
	removeUniform _unit;
	_unit forceAddUniform 'U_BG_Guerilla2_1';
	_unit addMagazines ['30Rnd_556x45_Stanag', 10];
	removeVest _unit;
	removeHeadgear _unit;
	_unit addHeadgear 'H_Cap_oli';
};

functionInitialiseTownDefenceRoadPatrol =
{
	private ['_independentGroup', '_nearestRoadSegmentDistance', '_nearestRoadSegment', '_waypoint'];
	_independentGroup = _this select 0;
	_townCentre = _this select 1;
	_townRadius = _this select 2;
	_nearestRoadSegmentDistance = mapSize;
	_nearestRoadSegment = objNull;
	{
		_currentRoadSegmentDistance = ((position _x) distance (position (leader _independentGroup)));
		if (_currentRoadSegmentDistance < _nearestRoadSegmentDistance)
		then
		{
			_nearestRoadSegment = _x;
			_nearestRoadSegmentDistance = _currentRoadSegmentDistance;
		};
	} forEach _townRadiusRoads;
	_independentGroup setVariable ['roadPatrolCurrentRoadSegment', _nearestRoadSegment];
	_independentGroup setVariable ['roadPatrolLastRoadSegment', objNull];
	[_independentGroup] call functionGroupDeleteAllWaypoints;
	_waypoint = _independentGroup addWaypoint [position _nearestRoadSegment, 0];
	_waypoint setWaypointSpeed 'LIMITED';
	_waypoint setWaypointStatements ['true', format ['[this, %1, %2] call functionHandleTownDefenceRoadPatrolWaypointCompletion', _townCentre, _townRadius]];
};

functionHandleTownDefenceRoadPatrolWaypointCompletion =
{
	_groupLeader = _this select 0;
	_townCentre = _this select 1;
	_townRadius = _this select 2;
	_group = group _groupLeader;
	[_group] call functionGroupDeleteAllWaypoints;
	_potentialNextRoadSegments = [];
	{
		if (_x != (_group getVariable 'roadPatrolLastRoadSegment'))
		then
		{
			if (((position _x) distance _townCentre) <= _townRadius)
			then
			{
				_potentialNextRoadSegments = _potentialNextRoadSegments + [_x];
			};
		};
	} forEach (roadsConnectedTo (_group getVariable 'roadPatrolCurrentRoadSegment'));
	_nextRoadSegment = objNull;
	if ((count _potentialNextRoadSegments) == 0)
	then
	{
		_nextRoadSegment = (_group getVariable 'roadPatrolLastRoadSegment');
	}
	else
	{
		_nextRoadSegment = _potentialNextRoadSegments select (floor (random (count (_potentialNextRoadSegments))));
	};
	_group setVariable ['roadPatrolLastRoadSegment', (_group getVariable 'roadPatrolCurrentRoadSegment')];
	_group setVariable ['roadPatrolCurrentRoadSegment', _nextRoadSegment];
	_waypoint = _group addWaypoint [position _nextRoadSegment, 0];
	_waypoint setWaypointSpeed 'LIMITED';
	_waypoint setWaypointStatements ['true', format ['[this, %1, %2] call functionHandleTownDefenceRoadPatrolWaypointCompletion', _townCentre, _townRadius]];
};

functionHandleTownDefenceFreePatrolWaypointCompletion =
{
	_groupLeader = _this select 0;
	_townCentre = _this select 1;
	_townRadius = _this select 2;
	_group = group _groupLeader;
	_patrolPoint = [_townCentre, 0, _townRadius, 0, 0, 180, 0] call BIS_fnc_findSafePos;
	[_group] call functionGroupDeleteAllWaypoints;
	_waypoint = _group addWaypoint [_patrolPoint, 0];
	_waypoint setWaypointSpeed 'NORMAL';
	_waypoint setWaypointStatements ['true', format ['[this, %1, %2] call functionHandleTownDefenceFreePatrolWaypointCompletion', _townCentre, _townRadius]];
};

functionCoordinateTownDefence =
{
	private ['_townRadius'];
	_provinceID = _this select 0;
	_townDefenceID = _this select 1;
	_townCentre = _this select 2;
	_townRadius = _this select 3;
	_independentGroups = _this select 4;
	_vehiclePatrolGroups = _this select 5;
	_vehiclePatrolObjects = _this select 6;
	_buildingDefenceGroup = _this select 7;
	_initialTotalPatrolGroupUnits = _this select 8;
	_deceasedIndependentGroups = [];
	townDefenceUnits = townDefenceUnits + (_independentGroups + _vehiclePatrolGroups + [_buildingDefenceGroup]);
	publicVariable 'townDefenceUnits';
	while {true}
	do
	{
		//diag_log 'About to set scope name.';
		scopeName 'townCoordinationScope';
		_currentServerTime = serverTime;
		//diag_log format ['%1 coordinating town defence.', _provinceID];
		_provinceActiveBLUFOR = 'false';
		_provinceActiveOPFOR = 'false';
		if ((typeName provinceActiveBLUFOR) == 'STRING')
		then
		{
			_provinceActiveBLUFOR = provinceActiveBLUFOR;
		};
		if ((typeName provinceActiveOPFOR) == 'STRING')
		then
		{
			_provinceActiveOPFOR = provinceActiveOPFOR;
		};
		if (!(_provinceActiveBLUFOR == _provinceID) and !(_provinceActiveOPFOR == _provinceID))
		then
		{
			//diag_log format ['%1 no longer active. Removing town defence.', _provinceID];
			[(_independentGroups + _vehiclePatrolGroups + [_buildingDefenceGroup] + _vehiclePatrolObjects), (_independentGroups + _vehiclePatrolGroups + _deceasedIndependentGroups + [_buildingDefenceGroup])] call functionCleanupTownDefence;
			breakOut 'townCoordinationScope';
		};
		_totalAlivePatrolGroupUnits = 0;
		{
			_group = _x;
			if (([_group] call functionGroupGetAliveUnitsAmount) == 0)
			then
			{
				if (!(_group in _deceasedIndependentGroups))
				then
				{
					_deceasedIndependentGroups = _deceasedIndependentGroups + [_group];
					_independentGroups = _independentGroups - [_group];
					diag_log 'Deceased group recognised.';
					if (!(_group getVariable 'backupDispatched'))
					then
					{
						[_group, _independentGroups, _townCentre, _townRadius, true] call functionRequestBackup;
						diag_log 'Backup dispatched to deceased group position.';
						//['Backup dispatched to deceased group position.'] call functionLogOnAllClients;
					};
				};
			}
			else
			{
				_totalAlivePatrolGroupUnits = _totalAlivePatrolGroupUnits + ({alive _x} count (units _group));
				_groupLeader = leader _group;
				if (!(alive _groupLeader))
				then
				{
					_group selectLeader ((units _group) select 0);
					_groupLeader = leader _group;
				};
				_nearTargets = _groupLeader nearTargets _townRadius;
				_nearTargetsFriendly = [];
				_nearTargetsHostile = [];
				_nearTargetsUnknown = [];
				{
					_targetPercievedSide = _x select 2;
					if (_targetPercievedSide == Independent)
					then
					{
						_nearTargetsFriendly = _nearTargetsFriendly + [_x];
					}
					else
					{
						if (_targetPercievedSide == BLUFOR or _targetPercievedSide == OPFOR)
						then
						{
							_nearTargetsHostile = _nearTargetsHostile + [_x];
						}
						else
						{
							if (_targetPercievedSide == sideUnknown)
							then
							{
								_nearTargetsUnknown = _nearTargetsUnknown + [_x];
							};
						};
					};
				} forEach _nearTargets;
				_group setVariable ['lastGroupNearTargetsHostile', _nearTargetsHostile];
				//diag_log format ['Near targets: %1 friendly, %2 hostile, %3 unknown.', count _nearTargetsFriendly, count _nearTargetsHostile, count _nearTargetsUnknown];
				if ((count _nearTargetsHostile) > 0)
				then
				{
					if (!(alive (assignedTarget _groupLeader)))
					then
					{
						{
							_hostileObject = _x select 4;
							scopeName 'nearTargetsHostileLoopScope';
							if (alive _hostileObject)
							then
							{
								(units _group) doTarget (_hostileObject);
								diag_log format ['Group has targeted hostile %1.', name _hostileObject];
								breakOut 'nearTargetsHostileLoopScope';
							};
						} forEach _nearTargetsHostile;
					};
					//[format ['Group has targeted hostile %1.', name ((_nearTargetsHostile select 0) select 4)]] call functionLogOnAllClients;
				};
				_group setVariable ['lastGroupLeaderPosition', position _groupLeader];
				_group setVariable ['lastGroupSize', count (units _group)];
				if (!(_group getVariable 'backupDispatched'))
				then
				{
					if ((count (units _group)) <= (ceil ((_group getVariable 'originalUnitSize') * townDefenceAIGroupBackupDeceasedUnitsThreshold)))
					then
					{
						[_group, _independentGroups, _townCentre, _townRadius, true] call functionRequestBackup;
						diag_log 'Backup dispatched to group with casualties position.';
					};
				};
			};
		} forEach _independentGroups;
		[_townDefenceID, _townCentre, _townRadius] spawn functionUpdatePlayerTownDefenceParticipationRecord;
		//diag_log format ['_totalAlivePatrolGroupUnits: %1. Threshold: %2.', _totalAlivePatrolGroupUnits, (ceil (_initialTotalPatrolGroupUnits * townDefenceSurrenderThresholdPercentage))];
		if (_totalAlivePatrolGroupUnits > (ceil (_initialTotalPatrolGroupUnits * townDefenceSurrenderThresholdPercentage)))
		then
		{
			sleep ((_currentServerTime + townDefenceCoordinationIntervalSeconds) - serverTime);
		}
		else
		{
			if (_totalAlivePatrolGroupUnits == 0)
			then
			{
				diag_log format ['Town has been neutralised.', _totalAlivePatrolGroupUnits];
				[(_independentGroups + _vehiclePatrolGroups + [_buildingDefenceGroup] + _vehiclePatrolObjects), (_independentGroups + _vehiclePatrolGroups + _deceasedIndependentGroups + [_buildingDefenceGroup])] call functionCleanupTownDefence;
				//[format ['Town has been neutralised.', _totalAlivePatrolGroupUnits]] call functionLogOnAllClients;
			}
			else
			{
				diag_log format ['Town has been neutralised. %1 patrol units were remaining, but have surrendered.', _totalAlivePatrolGroupUnits];
				[(_independentGroups + _vehiclePatrolGroups + [_buildingDefenceGroup] + _vehiclePatrolObjects), (_independentGroups + _vehiclePatrolGroups + _deceasedIndependentGroups + [_buildingDefenceGroup])] call functionCleanupTownDefence;
				//[format ['Town has been neutralised. %1 patrol units were remaining, but have surrendered.', _totalAlivePatrolGroupUnits]] call functionLogOnAllClients;
			};
			[_townDefenceID, _provinceID, _totalAlivePatrolGroupUnits] call functionHandleTownDefenceDefeatServer;
			breakOut 'townCoordinationScope';
		};
	};
	diag_log format ['%1 town coordination concluded.', _provinceID];
};

functionRequestBackup =
{
	// Arguments: group requesting backup, independent groups, town centre, town radius, (optional) vehicle requested
	// Returns: nothing
	private ['_group', '_independentGroups'];
	_group = _this select 0;
	_independentGroups = _this select 1;
	_townCentre = _this select 2;
	_townRadius = _this select 3;
	_vehicleRequested = false;
	if (count _this > 4)
	then
	{
		_vehicleRequested = _this select 4;
	};
	_group setVariable ['backupDispatched', true];
	_backupGroup = [(_group getVariable 'lastGroupLeaderPosition'), _independentGroups, _group] call functionTownDefenceGetNearestPatrolGroup;
	if (!(isNull _backupGroup))
	then
	{
		[_backupGroup, (_group getVariable 'lastGroupLeaderPosition'), (_group getVariable 'lastGroupNearTargetsHostile'), _townCentre, _townRadius] call functionDispatchBackupGroup;
	};
	if (_vehicleRequested)
	then
	{
		_backupVehicleGroup = [(_group getVariable 'lastGroupLeaderPosition'), _vehiclePatrolGroups] call functionTownDefenceGetNearestVehiclePatrol;
		if (!(isNull _backupVehicleGroup))
		then
		{
			[_backupVehicleGroup, (_group getVariable 'lastGroupLeaderPosition'), (_group getVariable 'lastGroupNearTargetsHostile'), _townCentre, _townRadius] call functionDispatchBackupGroup;
		};
	};
};

functionTownDefenceGetNearestPatrolGroup =
{
	// Arguments: position for backup, patrol groups, exclude patrol group
	private ['_position', '_patrolGroups', '_nearestPatrolGroup', '_nearestPatrolDistance', '_leader', '_distanceFromCurrentPatrol'];
	_position = _this select 0;
	_patrolGroups = _this select 1;
	_excludePatrolGroup = grpNull;
	if ((count _this) > 2)
	then
	{
		_excludePatrolGroup = _this select 2;
	};
	_nearestPatrolGroup = grpNull;
	_nearestPatrolDistance = 0;
	{
		if (_x != _excludePatrolGroup)
		then
		{
			_leader = leader _x;
			if (_forEachIndex == 0)
			then
			{
				_nearestPatrolDistance = (position _leader) distance (_position);
				_nearestPatrolGroup = _x;
			}
			else
			{
				_distanceFromCurrentPatrol = (position _leader) distance (_position);
				if (_distanceFromCurrentPatrol < _nearestPatrolDistance)
				then
				{
					_nearestPatrolDistance = _distanceFromCurrentPatrol;
					_nearestPatrolGroup = _x;
				};
			};
		};
	} forEach _patrolGroups;
	_nearestPatrolGroup;
};

functionTownDefenceGetNearestVehiclePatrol =
{
	// Arguments: position for backup, vehicle patrol groups
	private ['_position', '_nearestGroup', '_nearestDistance', '_leader', '_distanceFromCurrentGroup'];
	_position = _this select 0;
	_vehiclePatrolGroups = _this select 1;
	_nearestGroup = grpNull;
	_nearestDistance = 0;
	{
		_leader = leader _x;
		if (_forEachIndex == 0 and ([_x] call functionGroupGetAliveUnitsAmount) > 0)
		then
		{
			_nearestDistance = (position _leader) distance (_position);
			_nearestGroup = _x;
		}
		else
		{
			_distanceFromCurrentGroup = (position _leader) distance (_position);
			if (_distanceFromCurrentGroup < _nearestDistance and ([_x] call functionGroupGetAliveUnitsAmount) > 0)
			then
			{
				_nearestDistance = _distanceFromCurrentGroup;
				_nearestGroup = _x;
			};
		};
	} forEach _vehiclePatrolGroups;
	_nearestGroup;
};

functionDispatchBackupGroup =
{
	private ['_backupGroup', '_backupPosition', '_waypoint'];
	_backupGroup = _this select 0;
	_backupPosition = _this select 1;
	_nearTargetsHostile = _this select 2;
	_townCentre = _this select 3;
	_townRadius = _this select 4;
	{
		_backupGroup reveal (_x select 4);
	} forEach _nearTargetsHostile;
	[_backupGroup] call functionGroupDeleteAllWaypoints;
	_waypoint = _backupGroup addWaypoint [_backupPosition, 0];
	_waypoint setWaypointType 'SAD';
	_waypoint setWaypointSpeed 'FULL';
	_waypoint setWaypointStatements ['true', format ['[this, %1, %2] call functionHandleTownDefenceBackupWaypointCompletion', _townCentre, _townRadius]];
};

functionHandleTownDefenceBackupWaypointCompletion =
{
	_groupLeader = _this select 0;
	_townCentre = _this select 1;
	_townRadius = _this select 2;
	_group = group _groupLeader;
	_patrolType = _group getVariable 'patrolType';
	if (_patrolType == 'road')
	then
	{
		[_group, _townCentre, _townRadius] call functionInitialiseTownDefenceRoadPatrol;
	};
	if (_patrolType == 'free')
	then
	{
		[leader _group, _townCentre, _townRadius] call functionHandleTownDefenceFreePatrolWaypointCompletion;
	};
};

functionCleanupTownDefence =
{
	private ['_units', '_groups'];
	_units = _this select 0;
	_groups = _this select 1;
	{
		if ((typeName _x) == 'GROUP')
		then
		{
			{
				deleteVehicle _x;
			} forEach (units _x);
		};
		if ((typeName _x) == 'OBJECT')
		then
		{
			deleteVehicle _x;
		};
	} forEach _units;
	diag_log format ['functionCleanupTownDefence before deletion _groups: %1.', _groups];
	{
		diag_log format ['Deleting group. Group: %1. units: %2.', _x, units _x];
		deleteGroup _x;
	} forEach _groups;
	diag_log format ['functionCleanupTownDefence after delition _groups: %1.', _groups];
};

functionReportGroupsAmountTeams =
{
	_groupsIndependent = [];
	_groupsBLUFOR = [];
	_groupsOPFOR = [];
	{
		if (side _x == Independent)
		then
		{
			_groupsIndependent pushBack _x;
		};
		if (side _x == BLUFOR)
		then
		{
			_groupsBLUFOR pushBack _x;
		};
		if (side _x == OPFOR)
		then
		{
			_groupsOPFOR pushBack _x;
		};
	} forEach allGroups;
	diag_log format ['Independent Groups: %1. BLUFOR Groups: %2. OPFOR Groups: %3.', count _groupsIndependent, count _groupsBLUFOR, count _groupsOPFOR];
	diag_log format ['Independent Groups: %1.', _groupsIndependent];
	diag_log format ['BLUFOR Groups: %1.', _groupsBLUFOR];
	diag_log format ['OPFOR Groups: %1.', _groupsOPFOR];
};

functionUpdatePlayerTownDefenceParticipationRecord =
{
	_townDefenceID = _this select 0;
	_townCentre = _this select 1;
	_townRadius = _this select 2;
	_nearEntities = _townCentre nearEntities ['Man', _townRadius];
	_currentParticipants = [];
	_nearEntities = (position _objective) nearEntities ['AllVehicles', objectiveRadius];
	{
		_entity = _x;
		if (_entity isKindOf 'Man')
		then
		{
			if (isPlayer _entity)
			then
			{
				_currentParticipants pushBack (getPlayerUID _entity);
			};
		}
		else
		{
			{
				if (isPlayer _x)
				then
				{
					_currentParticipants pushBack (getPlayerUID _x);
				};
			} forEach (crew _entity);
		};
	} forEach _nearEntities;
	_townDefenceParticipants = missionNamespace getVariable (format ['townDefence%1Participants', _townDefenceID]);
	_newParticipants = [];
	{
		if (!(_x in _townDefenceParticipants))
		then
		{
			_newParticipants pushBack _x;
		};
	} forEach _currentParticipants;
	missionNamespace setVariable [format ['townDefence%1Participants', _townDefenceID], (_townDefenceParticipants + _newParticipants)];
};

functionHandleTownDefenceUnitDeath =
{
	_killedUnit = _this select 0;
	_killerUnit = _this select 1;
	// Must ensure that kills are recorded for players in vehicles at all times
	_killerUID = false;
	if (isPlayer _killerUnit)
	then
	{
		_killerUID = getPlayerUID _killerUnit;
	}
	else
	{
		if ((typeOf _killerUnit) isKindOf 'Man')
		then
		{
			_leader = leader (group _killerUnit);
			if (isPlayer _leader)
			then
			{
				_killerUID = getPlayerUID _leader;
			};
		};
	};
	if (typeName _killerUID == 'STRING')
	then
	{
		_townDefenceID = _killedUnit getVariable 'townDefenceID';
		_townDefenceKills = missionNamespace getVariable (format ['townDefence%1Kills', _townDefenceID]);
		_newKillRecord = [typeOf _killedUnit, _killerUID];
		missionNamespace setVariable [format ['townDefence%1Kills', _townDefenceID], _townDefenceKills + [_newKillRecord]];
	};
};

functionHandleTownDefenceDefeatServer =
{
	_townDefenceID = _this select 0;
	_provinceID = _this select 1;
	_totalAlivePatrolGroupUnits = _this select 2;
	// rewards array format: player UID, supply quota reward amount, array containing number of each unit type killed
	_rewards = [];
	_townDefenceParticipants = missionNamespace getVariable (format ['townDefence%1Participants', _townDefenceID]);
	diag_log format ['_townDefenceParticipants: %1.', _townDefenceParticipants];
	{
		_playerUID = _x;
		_rewards = _rewards + [[_playerUID, townDefenceDefeatParticipationSupplyQuotaReward, []]];
	} forEach _townDefenceParticipants;
	_townDefenceKills = missionNamespace getVariable (format ['townDefence%1Kills', _townDefenceID]);
	diag_log format ['_townDefenceKills: %1.', _townDefenceKills];
	{
		_killedUnitType = _x select 0;
		_killerUID = _x select 1;
		_killerRewardRecord = [_rewards, 0, _killerUID] call functionGetNestedArrayWithIndexValue;
		if ((count _killerRewardRecord) > 0)
		then
		{
			_killerRewardRecordSupplyQuotaReward = _killerRewardRecord select 1;
			// unitTypesKilled array format: unit type, amount killed
			_unitTypesKilled = _killerRewardRecord select 2;
			_unitTypesKilledRecord = [_unitTypesKilled, 0, _killedUnitType] call functionGetNestedArrayWithIndexValue;
			if ((count _unitTypesKilledRecord) > 0)
			then
			{
				_revisedUnitTypesKilledRecord = _unitTypesKilledRecord;
				_revisedUnitTypesKilledRecord set [1, (_revisedUnitTypesKilledRecord select 1) + 1];
				_unitTypesKilled set [_unitTypesKilled find _unitTypesKilledRecord, _revisedUnitTypesKilledRecord];
			}
			else
			{
				_unitTypesKilled pushBack [_killedUnitType, 1];
			};
			_revisedKillerRewardRecord = _killerRewardRecord;
			_revisedKillerRewardRecord set [1, _killerRewardRecordSupplyQuotaReward + ([_killedUnitType] call functionTownDefenceGetSupplyQuotaRewardForUnitType)];
			_revisedKillerRewardRecord set [2, _unitTypesKilled];
			_rewards set [_rewards find _killerRewardRecord, _revisedKillerRewardRecord];
		}
		else
		{
			_rewards = _rewards + [[_killerUID, (townDefenceDefeatParticipationSupplyQuotaReward + ([_killedUnitType] call functionTownDefenceGetSupplyQuotaRewardForUnitType)), [[_killedUnitType, 1]]]];
		};
	} forEach _townDefenceKills;
	_cumulativeBLUFORSupplyReward = 0;
	_cumulativeOPFORSupplyReward = 0;
	{
		_playerUID = _x select 0;
		_supplyQuotaReward = _x select 1;
		[_playerUID, _supplyQuotaReward] call functionAddPlayerSupplyQuota;
		_playerDataRecord = [playersData, 0, _playerUID] call functionGetNestedArrayWithIndexValue;
		_playerDataTeam = _playerDataRecord select 3;
		if (_playerDataTeam == BLUFOR)
		then
		{
			_cumulativeBLUFORSupplyReward = _cumulativeBLUFORSupplyReward + _supplyQuotaReward;
		};
		if (_playerDataTeam == OPFOR)
		then
		{
			_cumulativeOPFORSupplyReward = _cumulativeOPFORSupplyReward + _supplyQuotaReward;
		};
	} forEach _rewards;
	diag_log format ['primaryBaseBLUFOR: %1. _cumulativeBLUFORSupplyReward: %2. primaryBaseOPFOR: %3. _cumulativeOPFORSupplyReward: %4.', primaryBaseBLUFOR, _cumulativeBLUFORSupplyReward, primaryBaseOPFOR, _cumulativeOPFORSupplyReward];
	primaryBaseBLUFOR setVariable ['supplyAmount', (primaryBaseBLUFOR getVariable 'supplyAmount') + _cumulativeBLUFORSupplyReward, true];
	primaryBaseOPFOR setVariable ['supplyAmount', (primaryBaseOPFOR getVariable 'supplyAmount') + _cumulativeOPFORSupplyReward, true];
	{
		if (isPlayer _x)
		then
		{
			_rewardRecord = [_rewards, 0, getPlayerUID _x] call functionGetNestedArrayWithIndexValue;
			diag_log format ['_rewardRecord: %1.', _rewardRecord];
			if ((count _rewardRecord) > 0)
			then
			{
				_abridgedRewardRecord = +_rewardRecord;
				_abridgedRewardRecord deleteAt 0;
				diag_log format ['_abridgedRewardRecord: %1.', _abridgedRewardRecord];
				_playerDataRecord = [playersData, 0, getPlayerUID _x] call functionGetNestedArrayWithIndexValue;
				_playerDataSupplyQuota = _playerDataRecord select 2;
				[[['functionHandleTownDefenceReward', _abridgedRewardRecord], ['functionHandleTownDefenceDefeatClient', [_provinceID]], ['functionEstablishSupplyQuota', [_playerDataSupplyQuota]]], 'functionCallBulkFunctions', owner _x] call BIS_fnc_MP;
			}
			else
			{
				[[_provinceID], 'functionHandleTownDefenceDefeatClient', owner _x] call BIS_fnc_MP;
			};
		};
	} forEach playableUnits;
	diag_log format ['_rewards: %1.', _rewards];
	[_provinceID] call functionHandleProvinceResistanceDefeat;
};