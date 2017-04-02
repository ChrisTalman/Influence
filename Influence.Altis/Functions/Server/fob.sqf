functionEstablishFOBServer =
{
	_position = _this select 0;
	_base = _this select 1;
	_clientPlayerObject = _this select 2;
	_team = _clientPlayerObject getVariable 'team';
	_baseSupplySufficient = false;
	_positionExclusive = true;
	if ((_base getVariable 'supplyAmount') >= FOBSupplyCost)
	then
	{
		_baseSupplySufficient = true;
	};
	{
		if ((_x getVariable 'team') == _team)
		then
		{
			if ((_position distance (position _x)) <= FOBExclusiveEstablishmentRadius)
			then
			{
				_positionExclusive = false;
			};
		};
	} forEach FOBs;
	_teamLiteral = [_team] call functionGetTeamFORName;
	_missions = missionNamespace getVariable (format ['missions%1', _teamLiteral]);
	_positions = [_missions] call functionGetPlannedFOBs;
	{
		if ((_position distance _x) <= FOBExclusiveEstablishmentRadius)
		then
		{
			_positionExclusive = false;
		};
	} forEach _positions;
	if (_baseSupplySufficient and _positionExclusive)
	then
	{
		// FOB mission special arguments: build position, base object, construction vehicle object
		_base setVariable ['supplyAmount', (_base getVariable 'supplyAmount') - FOBSupplyCost, true];
		['FOB', _team, [_position, _base, objNull]] call functionAddSingleMission;
		[[], 'functionEstablishFOBCloseMap', _clientPlayerObject] call BIS_fnc_MP;
	}
	else
	{
		if (_positionExclusive)
		then
		{
			[[['functionHandleFOBPlanningError', []], ['functionHandleGetPlannedFOBsResponse', [_positions]]], 'functionCallBulkFunctions', _clientPlayerObject] call BIS_fnc_MP;
		}
		else
		{
			[[], 'functionHandleFOBPlanningError', _clientPlayerObject] call BIS_fnc_MP;
		};
	};
};

functionHandleGetPlannedFOBsRequest =
{
	_clientPlayerObject = _this select 0;
	_team = _clientPlayerObject getVariable 'team';
	_teamLiteral = [_team] call functionGetTeamFORName;
	_missions = missionNamespace getVariable (format ['missions%1', _teamLiteral]);
	_positions = [_missions] call functionGetPlannedFOBs;
	[[_positions], 'functionHandleGetPlannedFOBsResponse', _clientPlayerObject] call BIS_fnc_MP;
};

functionGetPlannedFOBs =
{
	private ['_missions', '_positions'];
	_missions = _this select 0;
	_positions = [];
	{
		_missionType = _x select 1;
		_missionSpecialArguments = _x select 4;
		if (_missionType == 'FOB')
		then
		{
			_buildPosition = _missionSpecialArguments select 0;
			_positions pushBack _buildPosition;
		};
	} forEach _missions;
	_positions;
};

functionRegisterFOB =
{
	private ['_newFOBInformation'];
	_desiredPosition = _this select 0;
	_startingSupplyAmount = _this select 1;
	_team = _this select 2;
	_teamName = 'undefined';
	_FOBCount = 0;
	_flagObjectEngineName = 'undefined';
	_newFOBOpposingTeam = false;
	if (_team == BLUFOR)
	then
	{
		_teamName = 'BLUFOR';
		totalBLUFORFOBsCount = totalBLUFORFOBsCount + 1;
		_FOBCount = totalBLUFORFOBsCount;
		_flagObjectEngineName = 'Flag_Blue_F';
		_newFOBOpposingTeam = OPFOR;
	};
	if (_team == OPFOR)
	then
	{
		_teamName = 'OPFOR';
		totalOPFORFOBsCount = totalOPFORFOBsCount + 1;
		_FOBCount = totalOPFORFOBsCount;
		_flagObjectEngineName = 'Flag_Red_F';
		_newFOBOpposingTeam = BLUFOR;
	};
	_newFOBObject = createVehicle [FOBObjectEngineName, [_desiredPosition select 0, _desiredPosition select 1, 0], [], 0, 'CAN_COLLIDE'];
	_newFOBObject allowDamage false;
	_newFOBFlagPosition = [(position _newFOBObject) select 0, (position _newFOBObject) select 1, (position _newFOBObject select 2) + FOBFlagPositionYOffset];
	_newFOBFlagObject = createVehicle [_flagObjectEngineName, _newFOBFlagPosition, [], 0, 'CAN_COLLIDE'];
	_newFOBFlagObject allowDamage false;
	_newFOBObject setVariable ['flagObject', _newFOBFlagObject, true];
	_newFOBID = format ['FOB%1%2', _teamName, (totalBLUFORFOBsCount + totalOPFORFOBsCount)];
	_newFOBName = format ['FOB %1', _FOBCount];
	[[_newFOBID, _newFOBName, ([_newFOBObject] call functionGetPosition2D)], 'functionHandleNewFOB', _team] call BIS_fnc_MP;
	_newFOBObject setVariable ['id', _newFOBID, true];
	_newFOBObject setVariable ['type', 'FOB', true];
	_newFOBObject setVariable ['name', _newFOBName, true];
	_newFOBObject setVariable ['team', _team, true];
	_newFOBObject setVariable ['supplyAmount', _startingSupplyAmount, true];
	_newFOBObject setVariable ['unusableSupplyAmount', 0, true];
	_newFOBObject setVariable ['supplyNodeNeighbors', [], true];
	_newFOBObject setVariable ['supplyAmountInProcessing', 0, true];
	_newFOBObject setVariable ['structures', [], true];
	_newFOBObject setVariable ['defences', [], true];
	// May need to be altered - taken from base script
	_newFOBTriggerObject = createTrigger ['EmptyDetector', position _newFOBObject];
	_newFOBTriggerObject setVariable ['baseObject', _newFOBObject, true];
	_newFOBTriggerObject setTriggerArea [FOBRadius, FOBRadius, 0, false];
	_newFOBTriggerObject setTriggerActivation [str _newFOBOpposingTeam, 'PRESENT', true];
	_newFOBTriggerObject setTriggerStatements ['this', 'diag_log "FOB trigger activated."; [thisTrigger] spawn functionHandleBaseTriggerActivation;', 'diag_log "FOB trigger disactivated."; [thisTrigger] call functionHandleBaseTriggerDisactivation;'];
	_newFOBObject setVariable ['trigger', _newFOBTriggerObject, false];
	_newFOBObject setVariable ['contested', false, true];
	_newFOBObject setVariable ['neutralised', false, true];
	_newFOBObject setVariable ['control', 100];
	_newFOBObject setVariable ['province', false];
	_newFOBNeighbors = [_newFOBObject, _team] call functionGetNodeNeighbors;
	{
		_x setVariable ['supplyNodeNeighbors', ((_x getVariable 'supplyNodeNeighbors') + [_newFOBObject]), true];
	} forEach _newFOBNeighbors;
	_newFOBObject setVariable ['supplyNodeNeighbors', _newFOBNeighbors, true];
	['FOBs', _newFOBObject] call functionPublicVariableAppendToArray;
	[(format ['knownFOBs%1', _teamLiteral]), _newFOBObject] call functionPublicVariableAppendToArray;
	['supplyNodes', (supplyNodes + [_newFOBObject])] call functionPublicVariableSetValue;
	//[[_newFOBObject], 'functionEstablishFOBScrollMenu', _team, true] call BIS_fnc_MP;
	_provinceIDAtNewFOBPosition = [position _newFOBObject] call functionGetProvinceAtPosition;
	if ((typeName _provinceIDAtNewFOBPosition) == 'STRING')
	then
	{
		_provinceStatusData = [provincesStatusServer, 0, _provinceIDAtNewFOBPosition] call functionGetNestedArrayWithIndexValue;
		_revisedProvinceStatusData = _provinceStatusData;
		_revisedProvinceStatusData set [2, (_revisedProvinceStatusData select 2) + [_newFOBObject]];
		provincesStatusServer set [provincesStatusServer find _provinceStatusData, _revisedProvinceStatusData];
		_newFOBObject setVariable ['province', _provinceIDAtNewFOBPosition];
		[_provinceIDAtNewFOBPosition] call functionUpdateProvinceServer;
	};
	_newFOBInformation = [_newFOBID, _newFOBName, position _newFOBObject];
	_newFOBInformation;
};