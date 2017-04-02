functionPublicVariableSetValue =
{
	private ['_publicVariableName', '_publicVariableNewValue'];
	_publicVariableName = _this select 0;
	_publicVariableNewValue = _this select 1;
	missionNamespace setVariable [_publicVariableName, _publicVariableNewValue];
	publicVariable _publicVariableName;
};

functionPublicVariableAppendToArray =
{
	private ["_publicVariableName", "_valueToAppend", "_publicVariableArrayCurrentValue"];
	_publicVariableName = _this select 0;
	_valueToAppend = _this select 1;
	_publicVariableArrayCurrentValue = (missionNamespace getVariable _publicVariableName);
	missionNamespace setVariable [_publicVariableName, _publicVariableArrayCurrentValue + [_valueToAppend]];
	publicVariable _publicVariableName;
};

functionPublicVariableRemoveFromArray =
{
	private ['_publicVariableName', '_valueToRemove'];
	_publicVariableName = _this select 0;
	_valueToRemove = _this select 1;
	_publicVariableValue = (missionNamespace getVariable _publicVariableName);
	_publicVariableValue deleteAt (_publicVariableValue find _valueToRemove);
	publicVariable _publicVariableName;
};

functionPublicVariableIncrementInteger =
{
	private ["_publicVariableName", "_publicVariableIntegerCurrentValue"];
	_publicVariableName = _this select 0;
	_publicVariableIntegerCurrentValue = (missionNamespace getVariable _publicVariableName);
	missionNamespace setVariable [_publicVariableName, _publicVariableIntegerCurrentValue + 1];
	publicVariable _publicVariableName;
};

functionPublicVariableRemoveNestedArrayWithIndexValue =
{
	private ["_publicVariableName", "_indexNestedArray", "_indexValue"];
	_publicVariableName = _this select 0;
	_indexNestedArray = _this select 1;
	_indexValue = _this select 2;
	missionNamespace setVariable [_publicVariableName, ([missionNamespace getVariable _publicVariableName, _indexNestedArray, _indexValue] call functionRemoveNestedArrayWithIndexValue)];
	publicVariable _publicVariableName;
};

functionRemoveNestedArrayWithIndexValue =
{
	private ['_array', '_indexNestedArray', '_indexValue'];
	_array = _this select 0;
	_indexNestedArray = _this select 1;
	_indexValue = _this select 2;
	{
		if ((_x select _indexNestedArray) == _indexValue)
		then
		{
			_array deleteAt _forEachIndex;
		};
	} forEach _array;
	_array;
};

functionGetNestedArrayWithIndexValue =
{
	private ['_array', '_indexNestedArray', '_indexValue', '_returnNestedArray'];
	_array = _this select 0;
	_indexNestedArray = _this select 1;
	_indexValue = _this select 2;
	//diag_log format ['_array: %1. _indexNestedArray: %2. _indexValue: %3.', _array, _indexNestedArray, _indexValue];
	_returnNestedArray = [];
	{
		if ((typeName (_x select _indexNestedArray)) == (typeName _indexValue))
		then
		{
			if ((_x select _indexNestedArray) == _indexValue)
			then
			{
				_returnNestedArray = _x;
			};
		};
	} forEach _array;
	_returnNestedArray;
};

functionObjectSetVariablePublicTarget =
{
	private ['_object', '_variableName', '_variableValue', '_publicTarget'];
	_object = _this select 0;
	_variableName = _this select 1;
	_variableValue = _this select 2;
	_publicTarget = _this select 3;
	//diag_log 'Public object variable setting.';
	[[_object, _variableName, _variableValue, _publicTarget], 'functionObjectSetVariablePublicTargetViaServer', false] call BIS_fnc_MP;
};

functionObjectSetVariablePublicTargetLocalEnactment =
{
	//diag_log 'Public object variable set (enacted).';
	private ['_object', '_variableName', '_variableValue'];
	_object = _this select 0;
	_variableName = _this select 1;
	_variableValue = _this select 2;
	_object setVariable [_variableName, _variableValue];
};

functionAugmentedPublicVariableSetValue =
{
	// Augmented public variables simply allow public variables with team as their target
	private ['_publicVariableName', '_publicVariableSetValue', '_publicVariableTarget'];
	_publicVariableName = _this select 0;
	_publicVariableSetValue = _this select 1;
	_publicVariableTarget = _this select 2;
	if ((typeName _publicVariableTarget) == 'SIDE')
	then
	{
		if (isServer or isDedicated)
		then
		{
			[_publicVariableName, _publicVariableSetValue, _publicVariableTarget] call functionAugmentedPublicVariableSetValueViaServer;
		};
		if (!isServer or !isDedicated)
		then
		{
			[[_publicVariableName, _publicVariableSetValue, _publicVariableTarget], 'functionAugmentedPublicVariableSetValueViaServer', false] call BIS_fnc_MP;
		};
	}
	else
	{
		diag_log 'Error: functionAugmentedPublicVariableSetValue only supports target of type side.';
	};
};

functionIsPositionInsideRadiusOfPosition =
{
	_position = _this select 0;
	_positionOfRadius = _this select 1;
	_positionRadius = _this select 2;
	_isInside = false;
	if (((((_position select 0) - (_positionOfRadius select 0)) ^ 2) + (((_position select 1) - (_positionOfRadius select 1)) ^ 2)) < (_positionRadius ^ 2))
	then
	{
		_isInside = true;
	}
	else
	{
		_isInside = false;
	};
	_isInside;
};

functionGetCoordinatesDistanceBetweenPoints =
{
	_pointOne = _this select 0;
	_pointTwo = _this select 1;
	_distance = ((((_position select 0) - (_positionOfRadius select 0)) ^ 2) + (((_position select 1) - (_positionOfRadius select 1)) ^ 2));
	_distance;
};

functionGetPosition2D =
{
	private ["_entity", "_position2D"];
	_entity = _this select 0;
	_position2D = [position _entity select 0, position _entity select 1];
	_position2D;
};

functionGetTeamFORName =
{
	private ['_team', '_returnValue'];
	_team = _this select 0;
	_returnValue = 'undefined';
	if (typeName _team == 'SIDE')
	then
	{
		if (_team == WEST)
		then
		{
			_returnValue = 'BLUFOR';
		};
		if (_team == EAST)
		then
		{
			_returnValue = 'OPFOR';
		};
	};
	if (_returnValue == 'undefined')
	then
	{
		diag_log 'Unrecognised team for functionGetTeamFORName.';
	};
	_returnValue;
};

functionGetAngleAsCardinalDirection =
{
	private ["_angle", "_returnValue"];
	_angle = _this select 0;
	if (_angle < 0 or _angle > 360)
	then
	{
		throw "functionGetAngleAsCardinalDirection: angle must be between 0 and 360, inclusive.";
	};
	_returnValue = "undefined";
	if (_angle >= 337.5 and _angle < 22.5)
	then
	{
		_returnValue = "North";
	};
	if (_angle >= 22.5 and _angle < 67.5)
	then
	{
		_returnValue = "North East";
	};
	if (_angle >= 67.5 and _angle < 112.5)
	then
	{
		_returnValue = "East";
	};
	if (_angle >= 112.5 and _angle < 157.5)
	then
	{
		_returnValue = "South East";
	};
	if (_angle >= 157.5 and _angle < 202.5)
	then
	{
		_returnValue = "South";
	};
	if (_angle >= 202.5 and _angle < 247.5)
	then
	{
		_returnValue = "South West";
	};
	if (_angle >= 247.5 and _angle < 292.5)
	then
	{
		_returnValue = "West";
	};
	if (_angle >= 292.5 and _angle < 337.5)
	then
	{
		_returnValue = "North West";
	};
	_returnValue;
};

functionGetAngleRelativePosition =
{
	// Arguments: distance from position, position, angle, relative angle
	private ['_distance', '_position', '_angle', '_relativeAngle', '_returnPosition2D'];
	_distance = _this select 0;
	_position = _this select 1;
	_angle = _this select 2;
	_relativeAngle = _this select 3;
	_returnPosition2D = [(_position select 0) + ((sin (_angle + _relativeAngle)) * _distance), (_position select 1) + ((cos (_angle + _relativeAngle)) * _distance)];
	_returnPosition2D;
};

functionGetLiteralNameForUnitType =
{
	private ['_unitType', '_staticOverride', '_returnValue'];
	_unitType = _this select 0;
	_returnValue = 'undefined';
	if (_unitType in ['B_crew_F', 'O_crew_F'])
	then
	{
		_returnValue = 'Crewman';
	};
	if (_unitType in ['B_Soldier_F', 'O_Soldier_F', 'I_soldier_F'])
	then
	{
		_returnValue = 'Rifleman';
	};
	if (_unitType in ['B_soldier_AR_F', 'I_Soldier_AR_F', 'O_soldier_AR_F'])
	then
	{
		_returnValue = 'Autorifleman';
	};
	if (_unitType == 'I_Soldier_M_F')
	then
	{
		_returnValue = 'Marksman';
	};
	if (_unitType == 'B_medic_F' or _unitType == 'O_medic_F')
	then
	{
		_returnValue = 'Medic';
	};
	if (_unitType == 'I_officer_F')
	then
	{
		_returnValue = 'Officer';
	};
	if (_unitType in ['B_soldier_LAT_F', 'O_soldier_LAT_F', 'I_Soldier_LAT_F'])
	then
	{
		_returnValue = "Rifleman Anti-Tank";
	};
	if (_unitType in ['B_soldier_AA_F', 'O_soldier_AA_F', 'I_Soldier_AA_F'])
	then
	{
		_returnValue = 'Rifleman Anti-Air';
	};
	if (_unitType == 'B_Soldier_lite_F' or _unitType == 'O_Soldier_lite_F')
	then
	{
		if (count _this > 1)
		then
		{
			_staticOverride = _this select 1;
			if (_staticOverride)
			then
			{
				_returnValue = 'Static Unit';
			};
		}
		else
		{
			_returnValue = 'Light Rifleman';
		};
	};
	if (_unitType == 'I_G_Offroad_01_armed_F')
	then
	{
		_returnValue = 'Offroad Vehicle';
	};
	if (_unitType == 'I_APC_tracked_03_cannon_F')
	then
	{
		_returnValue = 'Mora';
	};
	_returnValue;
};

functionGetLiteralInitialForUnitType =
{
	private ['_unitType', '_literalInitial'];
	_unitType = _this select 0;
	_literalInitial = '';
	switch (true)
	do
	{
		case (_unitType in ['B_crew_F', 'O_crew_F']):
		{
			_literalInitial = 'Crew';
		};
		case (_unitType in ['B_Soldier_F', 'O_Soldier_F', 'I_soldier_F']):
		{
			_literalInitial = 'Rifleman';
		};
		case (_unitType in ['B_soldier_LAT_F', 'O_soldier_LAT_F', 'I_Soldier_LAT_F']):
		{
			_literalInitial = 'AT';
		};
		case (_unitType in ['B_soldier_AA_F', 'O_soldier_AA_F', 'I_Soldier_AA_F']):
		{
			_literalInitial = 'AA';
		};
		case (_unitType in ['B_soldier_AR_F', 'I_Soldier_AR_F', 'O_soldier_AR_F']):
		{
			_literalInitial = 'Autorifleman';
		};
		default
		{
			_literalInitial = 'Unrecognised Unit Type';
		};
	};
	_literalInitial;
};

functionGroupDeleteAllWaypoints =
{
	private ["_group"];
	_group = _this select 0;
	while {(count (waypoints _group)) > 0}
	do
	{
		deleteWaypoint ((waypoints _group) select 0);
	};
	//(_group) addwaypoint [getpos _group, 0];
};

functionTestCircleRectangleIntersection =
{
	_circlePosition2D = _this select 0;
	_circleRadius = _this select 1;
	_rectanglePosition2D = _this select 2;
	_rectangleWidthHeight = _this select 3;
	_intersection = false;
	_circleDistanceX = abs((_circlePosition2D select 0) - (_rectanglePosition2D select 0));
	_circleDistanceY = abs((_circlePosition2D select 1) - (_rectanglePosition2D select 1));
	if (_circleDistanceX > ((_rectangleWidthHeight select 0) / 2) + _circleRadius)
	then
	{
		_intersection = false;
	}
	else
	{
		if (_circleDistanceY > ((_rectangleWidthHeight select 1) / 2) + _circleRadius)
		then
		{
			_intersection = false;
		}
		else
		{
			if (_circleDistanceX <= ((_rectangleWidthHeight select 0) / 2))
			then
			{
				_intersection = true;
			}
			else
			{
				if (_circleDistanceY <= ((_rectangleWidthHeight select 1) / 2))
				then
				{
					_intersection = true;
				}
				else
				{
					_cornerDistanceSquared = (_circleDistanceX - ((_rectangleWidthHeight select 0) / 2)) ^ 2 + (_circleDistanceY - ((_rectangleWidthHeight select 1) / 2)) ^ 2;
					_intersection = (_cornerDistanceSquared <= (_circleRadius ^ 2));
				};
			};
		};
	};
	_intersection;
};

functionGetMapSize =
{
	_worldPath = configfile >> 'cfgworlds' >> worldname;
	_mapSize = getnumber (_worldPath >> 'mapSize');
	_mapSize;
};

functionGetTerritoryGridIndexFromMapCoordinate =
{
	_position = _this select 0;
	_gridPositionSideLength = (mapSize / territoryGridResolution);
	_gridPositionX = floor ((_position select 0) / _gridPositionSideLength);
	_gridPositionY = floor ((_position select 1) / _gridPositionSideLength);
	_index = (_gridPositionY * territoryGridResolution) + _gridPositionX;
	_index;
};

functionIsPointInPolygon =
{
	// Argument 1: point. Argument 2: array containing polygon points. Note: convex polygons only
	private ['_point', '_polygonPoints', '_returnValue'];
	_point = _this select 0;
	_polygonPoints = _this select 1;
	//diag_log format ['_polygonPoints: %1', _polygonPoints];
	_returnValue = true;
	{
		_v1 = [_x, _point] call functionIsPointInPolygonNSub;
		_v2 = [_polygonPoints select ((_forEachIndex + 1) mod (count _polygonPoints)), _point] call functionIsPointInPolygonNSub;
		_edge = [_v1, _v2] call functionIsPointInPolygonNSub;
		_perpDot = [_edge, _v1] call functionIsPointInPolygonPerpDot;
		//diag_log format ['_perpDot: %1.', _perpDot];
		if (_perpDot < 0)
		then
		{
			//diag_log 'In _perpDot condition.';
			_returnValue = false;
		};
	} forEach _polygonPoints;
	_returnValue;
};

functionIsPointInPolygonNSub =
{
	private ['_a', '_b', '_returnValue'];
	_a = _this select 0;
	_b = _this select 1;
	_returnValue = [(_a select 0) - (_b select 0), (_a select 1) - (_b select 1)];
	_returnValue;
};

functionIsPointInPolygonPerpDot =
{
	private ['_a', '_b', '_returnValue'];
	_a = _this select 0;
	_b = _this select 1;
	_returnValue = (_a select 0) * (_b select 1) - (_a select 1) * (_b select 0);
	_returnValue;
};

functionMathGetAverage =
{
	private ['_numbers', '_total', '_average'];
	_numbers = _this select 0;
	_total = 0;
	{
		_total = _total + _x;
	} forEach _numbers;
	_average = _total / (count _numbers);
	_average;
};

functionMathGetAverageCoordinate =
{
	private ['_coordinates', '_xPoints', '_yPoints', '_xAverage', '_yAverage', '_averageCoordinate'];
	_coordinates = _this select 0;
	_xPoints = [];
	_yPoints = [];
	{
		_xPoints = _xPoints + [_x select 0];
		_yPoints = _yPoints + [_x select 1];
	} forEach _coordinates;
	_xAverage = [_xPoints] call functionMathGetAverage;
	_yAverage = [_yPoints] call functionMathGetAverage;
	_averageCoordinate = [_xAverage, _yAverage];
	_averageCoordinate;
};

functionGetPlayerObjects =
{
	// Arguments: player object (or array containing player objects) to exclude, team constraint (only team included)
	private ['_playerObjects', '_playerObjectToExclude', '_foundPlayerToExclude', '_teamConstraint'];
	_playerObjects = [];
	{
		if (isPlayer _x)
		then
		{
			_playerObjects pushBack _x;
		};
	} forEach playableUnits;
	if ((count _this) > 0)
	then
	{
		_playerObjectToExclude = _this select 0;
		if ((typeName _playerObjectToExclude) == 'OBJECT')
		then
		{
			_foundPlayerToExclude = _playerObjects find _playerObjectToExclude;
			if (_foundPlayerToExclude >= 0)
			then
			{
				_playerObjects deleteAt _foundPlayerToExclude;
			};
		}
		else
		{
			if ((typeName _playerObjectToExclude) == 'ARRAY')
			then
			{
				{
					_foundPlayerToExclude = _playerObjects find _x;
					if (_foundPlayerToExclude >= 0)
					then
					{
						_playerObjects deleteAt _foundPlayerToExclude;
					};
				} forEach _playerObjectToExclude;
			}
			else
			{
				diag_log 'functionGetPlayerObjects: playerObjectToExclude must be of type object or array.';
			};
		};
		if ((count _this) > 1)
		then
		{
			_teamConstraint = _this select 1;
			if ((typeName _teamConstraint) == 'SIDE')
			then
			{
				{
					if ((_x getVariable 'team') != _teamConstraint)
					then
					{
						_playerObjects deleteAt (_playerObjects find _x);
					};
				} forEach _playerObjects;
			}
			else
			{
				diag_log 'functionGetPlayerObjects: teamConstraint must be of type side.';
			};
		};
	};
	_playerObjects;
};

functionGetPlayerCountForTeams =
{
	private ['_amountBLUFORPlayers', '_amountOPFORPlayers', '_count'];
	// Arguments: None
	// Returns: array containing two integers representing BLUFOR and OPFOR player counts respectively
	_amountBLUFORPlayers = 0;
	_amountOPFORPlayers = 0;
	{
		if (isPlayer _x)
		then
		{
			if ((_x getVariable 'team') == BLUFOR)
			then
			{
				_amountBLUFORPlayers = _amountBLUFORPlayers + 1;
			}
			else
			{
				if ((_x getVariable 'team') == OPFOR)
				then
				{
					_amountOPFORPlayers = _amountOPFORPlayers + 1;
				};
			};
		};
	} forEach playableUnits;
	_count = [_amountBLUFORPlayers, _amountOPFORPlayers];
	_count;
};

functionGetPlayerObjectWithUID =
{
	// Arguments: player UID
	// Returns: object or objNull
	private ['_playerUID', '_playerObject'];
	_playerUID = _this select 0;
	_playerObject = objNull;
	{
		scopeName 'playableUnitsLoopScope';
		if ((getPlayerUID _x) == _playerUID)
		then
		{
			_playerObject = _x;
			breakOut 'playableUnitsLoopScope';
		};
	} forEach playableUnits;
	_playerObject;
};

functionIsPlayerOnline =
{
	// Arguments: player UID
	// Returns: boolean
	private ['_playerUID', '_playerObject', '_playerOnline'];
	_playerUID = _this select 0;
	_playerObject = [_playerUID] call functionGetPlayerObjectWithUID;
	_playerOnline = false;
	if (!(isNull _playerObject))
	then
	{
		_playerOnline = true;
	};
	_playerOnline;
};

functionGetEasedProportion =
{
	// Arguments: proportion as decimal point percentage, maximum
	// Returns: eased proportion of maximum
	_proportion = _this select 0;
	_maximum = _this select 1;
	_start = 0;
	_duration = 1;
	_proportion = _proportion / _duration;
	_return = -_maximum * _proportion * (_proportion - 2) + _start;
	_return;
};

functionGetTeamProvinceControlAmount =
{
	// Arguments: team, provinceStatuses
	// Returns: amount of provinces controlled by team, as integer
	private ['_team', '_controlAmount', '_provinceTeam'];
	_team = _this select 0;
	_provinceStatuses = _this select 1;
	_controlAmount = 0;
	{
		_provinceTeam = _x select 1;
		if (_provinceTeam == _team)
		then
		{
			_controlAmount = _controlAmount + 1;
		};
	} forEach _provinceStatuses;
	_controlAmount;
};

functionUnitAddDamagePrevention =
{
	private ['_unit', '_eventID'];
	_unit = _this select 0;
	if ((typeName (_unit getVariable ['damageProtectionEventID', false])) == 'BOOL')
	then
	{
		_eventID = _unit addEventHandler ['HandleDamage', {false}];
		_unit setVariable ['damageProtectionEventID', _eventID];
	};
};

functionUnitRemoveDamagePrevention =
{
	private ['_unit'];
	_unit = _this select 0;
	if ((typeName (_unit getVariable ['damageProtectionEventID', false])) == 'SCALAR')
	then
	{
		_unit removeEventHandler ['HandleDamage', (_unit getVariable 'damageProtectionEventID')];
	};
};

functionGetLastName =
{
	private ['_name', '_characterCodes', '_index', '_lastName'];
	_name = _this select 0;
	_characterCodes = toArray _name;
	reverse _characterCodes;
	_index = _characterCodes find 32;
	_lastName = 'undefined';
	if (_index > -1)
	then
	{
		_characterCodes resize _index;
		reverse _characterCodes;
		_lastName = toString _characterCodes;
	};
	_lastName;
};

functionStringSplit =
{
	// Work In Progress
	/*_string = _this select 0;
	_delimiter = _this select 1;
	_splitStringWork = _string;
	_splitString = [];
	_splitProgressing = true;
	while {_splitProgressing}
	do
	{
		_index = _splitStringWork find _delimiter;
		_splitString pushBack (_splitStringWork select [0, _index]);
	};*/
};

functionGroupGetAliveUnitsAmount =
{
	// Arguments: group
	private ['_group', '_units', '_aliveUnitsAmount'];
	_group = _this select 0;
	_units = units _group;
	_aliveUnitsAmount = 0;
	{
		if (alive _x)
		then
		{
			_aliveUnitsAmount = _aliveUnitsAmount + 1;
		};
	} forEach _units;
	_aliveUnitsAmount;
};

functionRegisterVehicle =
{
	private ['_vehicle', '_vehicleName'];
	_vehicle = _this select 0;
	_vehicleName = _this select 1;
	_team = _this select 2;
	[_vehicle, 'vehicleName', _vehicleName, _team] call functionObjectSetVariablePublicTarget;
	[format ['vehicles%1', [_team] call functionGetTeamFORName], _vehicle] call functionPublicVariableAppendToArray;
};

functionObjectSetMass =
{
	private ['_object', '_mass'];
	_object = _this select 0;
	_mass = _this select 1;
	_object setMass _mass;
};

functionDisableEngine =
{
	// Arguments: vehicle object
	private ['_vehicle'];
	_vehicle = _this select 0;
	_engineDisabled = _vehicle getVariable ['engineDisabled', false];
	if (!_engineDisabled)
	then
	{
		_vehicle setVariable ['engineDisabled', true, true];
		[[_vehicle], 'functionDisableEngineLocalEnactment', true, true] call BIS_fnc_MP;
	};
};

functionDisableEngineLocalEnactment =
{
	// Arguments: vehicle object
	private ['_vehicle'];
	_vehicle = _this select 0;
	if (alive _vehicle)
	then
	{
		//systemChat format ['engineDisabled: %1.', _vehicle getVariable 'engineDisabled'];
		//diag_log format ['engineDisabled: %1.', _vehicle getVariable 'engineDisabled'];
		_engineDisabled = _vehicle getVariable ['engineDisabled', false];
		if (_engineDisabled)
		then
		{
			//systemChat format ['engineEventID: %1.', _vehicle getVariable 'engineEventID'];
			//diag_log format ['engineEventID: %1.', _vehicle getVariable 'engineEventID'];
			_engineEventID = _vehicle getVariable ['engineEventID', -1];
			if (_engineEventID == -1)
			then
			{
				_eventID = _vehicle addEventHandler ['Engine', {_this call functionHandleDisableEngineEngineEvent;}];
				_vehicle setVariable ['engineEventID', _eventID];
				_vehicle engineOn false;
			};
		};
	};
};

functionHandleDisableEngineEngineEvent =
{
	_vehicle = _this select 0;
	_engineState = _this select 1;
	if (_engineState)
	then
	{
		_vehicle engineOn false;
	};
};

functionEnableEngine =
{
	// Arguments: vehicle object
	private ['_vehicle'];
	_vehicle = _this select 0;
	[[_vehicle], 'functionEnableEngineLocalEnactment', true] call BIS_fnc_MP;
	_vehicle setVariable ['engineDisabled', false, true];
};

functionEnableEngineLocalEnactment =
{
	_vehicle = _this select 0;
	_engineEventID = _vehicle getVariable ['engineEventID', -1];
	if (_engineEventID > -1)
	then
	{
		_vehicle removeEventHandler ['Engine', _engineEventID];
		_vehicle setVariable ['engineEventID', nil];
	};
};

functionGetRealVisualPosition =
{
	// Arguments: object
	private ['_object', '_position'];
	_object = _this select 0;
	_position = visiblePositionASL _object;
	if (!(surfaceIsWater _position))
	then
	{
		_position = ASLtoATL _position;
	};
	_position;
};