functionEstablishRespawnSystem =
{
	playerKilledCorpseObject = objNull;
	player addEventHandler ['Respawn', functionHandlePlayerRespawnEvent];
	player addEventHandler ['Killed', functionHandlePlayerKilledEvent];
	'playerControlledBases' addPublicVariableEventHandler {call functionHandlePlayerControlledBasesUpdate};
	'mobileRespawnPoints' addPublicVariableEventHandler {call functionHandleMobileRespawnPointsUpdate};
	call functionHandleUnitNowControlledByPlayer;
};

functionHandlePlayerRespawnEvent =
{
	_playerUnitObject = _this select 0;
	_playerUnitCorpseObject = _this select 1;
	_playerUnitObject setVariable ['team', (_playerUnitCorpseObject getVariable 'team'), true];
	_playerUnitObject setVariable ['respawning', true, true];
	[player] call functionUnitAddDamagePrevention;
	[_playerUnitObject] call functionEstablishDefaultScrollMenuForPlayer;
	_electionStage = missionNamespace getVariable (format ['generalElectionStage%1', (player getVariable 'team')]);
	if (_electionStage in ['stand', 'vote'])
	then
	{
		[player, true] call functionEstablishElectionScrollMenuOption;
	};
	if ((commanderChallengeElectionBLUFORInProgress and side player == BLUFOR) or (commanderChallengeElectionOPFORInProgress and side player == OPFOR))
	then
	{
		[player] call functionEstablishChallengeElectionScrollMenuOption;
	};
	call functionEstablishBasicItems;
	if (leader (group player) != player)
	then
	{
		(group player) selectLeader (player);
	};
	if (!(isNil 'slingLoadingRequestsPending'))
	then
	{
		{
			_vehicle = _x select 0;
			_requesterUID = _x select 1;
			[_vehicle, _requesterUID] call functionEstablishPrepareSlingLoadingRequestScrollMenuAction;
		} forEach slingLoadingRequestsPending;
	};
};

functionIlludePlayerRespawnAtPosition =
{
	_positionToIlludeRespawnAt = _this select 0;
	[player] call functionUnitRemoveDamagePrevention;
	player setPos _positionToIlludeRespawnAt;
	(uiNamespace getVariable 'respawnMenuMap') ctrlRemoveAllEventHandlers 'Draw';
	closeDialog 0;
	cutText ['', 'BLACK IN', 1, false];
	playerKilledCorpseObject = objNull;
	if ((typeName playerLoadout) == 'ARRAY')
	then
	{
		[player, playerLoadout] call functionUnitSetLoadout;
	};
	player setVariable ['respawning', false, true];
};

functionHandleUnitNowControlledByPlayer =
{
	//player allowDamage true;
	if (({(_x getVariable 'team') == side player} count playerControlledBases) == 0)
	then
	{
		[([call functionGetStartingPositionForPlayer, 0, startingPositionSpawnRadius, 0, 0, 180, 0] call BIS_fnc_findSafePos)] call functionIlludePlayerRespawnAtPosition;
	}
	else
	{
		if (({(_x getVariable "team") == side player} count playerControlledBases) == 1)
		then
		{
			_baseToSpawnAt = objNull;
			{
				if ((_x getVariable "team") == side player)
				then
				{
					_baseToSpawnAt = _x;
				};
			} forEach playerControlledBases;
			// May need FOB integration
			[([position _baseToSpawnAt, 5, (baseRadius - baseRespawnOuterSpawnAreaBufferSize), 0, 0, 180, 0] call BIS_fnc_findSafePos)] call functionIlludePlayerRespawnAtPosition;
		}
		else
		{
			call functionOpenRespawnInterface;
		};
	};
};

functionPreventClosureOfRespawnMenu =
{
	_codeOfKeyPressed = _this select 0;
	_preventDefaultKeyBehaviour = false;
	if (_codeOfKeyPressed == 1)
	then
	{
		_preventDefaultKeyBehaviour = true;
	}
	else
	{
		_preventDefaultKeyBehaviour = false;
	};
	_preventDefaultKeyBehaviour;
};

functionHandlePlayerKilledEvent =
{
	_playerKilled = _this select 0;
	_playerKiller = _this select 1;
	[[_playerKilled, _playerKiller], 'functionHandlePlayerKilledServer', false] call BIS_fnc_MP;
	if (!(isNull buildViewSelectedBaseObject))
	then
	{
		call functionExitBuildView;
	};
	if (_playerKilled == player)
	then
	{
		playerKilledCorpseObject = _playerKilled;
		[_playerKilled] call functionOpenRespawnInterface;
	};
};

functionOpenRespawnInterface =
{
	cutText ['', 'BLACK FADED', 604800, false];
	createDialog 'iRespawnDialogue';
	(findDisplay 2) displayAddEventHandler ["KeyDown", {[_this select 1] call functionPreventClosureOfRespawnMenu}];
	(uiNamespace getVariable 'respawnMenuMap') ctrlAddEventHandler ['Draw', {call functionMapGraphicsMainMapFrameEvent;}];
	call functionPopulateRespawnInterfaceRespawnPointsList;
	if (!(alive player))
	then
	{
		if (!isNil("_this"))
		then
		{
			_playerKilledCorpseObject = _this select 0;
			[_playerKilledCorpseObject] spawn functionDelayRespawnInterfaceAccess;
		}
		else
		{
			[] spawn functionDelayRespawnInterfaceAccess;
		};
	};
};

functionPopulateRespawnInterfaceRespawnPointsList =
{
	lbClear 3002;
	{
		if ((_x getVariable 'team') == (player getVariable 'team'))
		then
		{
			if (!(_x getVariable 'neutralised'))
			then
			{
				_indexInList = lbAdd [3002, (_x getVariable 'name')];
				lbSetData [3002, _indexInList, (_x getVariable 'id')];
			};
		};
	} forEach (playerControlledBases + FOBs);
	if ((lbSize 3002) == 0)
	then
	{
		diag_log 'No respawns could be found.';
	};
	if (!(isNull playerKilledCorpseObject))
	then
	{
		_playerKilledCorpseObject = playerKilledCorpseObject;
		_playerKilledCorpseObjectPosition2D = [position _playerKilledCorpseObject select 0, position _playerKilledCorpseObject select 1];
		{
			if ((_x getVariable 'team') == (player getVariable 'team'))
			then
			{
				if (alive _x)
				then
				{
					_mobileRespawnPointPosition2D = [position _x select 0, position _x select 1];
					if (((_mobileRespawnPointPosition2D distance _playerKilledCorpseObjectPosition2D) <= mobileRespawnRadius) and ((_x getVariable 'mobileRespawnEnabled')))
					then
					{
						_indexInList = lbAdd [3002, (_x getVariable 'name')];
						lbSetData [3002, _indexInList, (_x getVariable 'id')];
					};
				}
				else
				{
					['mobileRespawnPoints', mobileRespawnPoints - [_x]] call functionPublicVariableSetValue;
				};
			};
		} forEach mobileRespawnPoints;
	};
};

functionHandleRespawnLocationListSelection =
{
	_locationID = lbData [3002, (lbCurSel 3002)];
	_locationObject = [_locationID, true] call functionGetBaseObjectWithID;
	if (isNull _locationObject)
	then
	{
		_locationObject = [_locationID] call functionGetMobileRespawnWithID;
	};
	(uiNamespace getVariable 'respawnMenuMap') ctrlMapAnimAdd [0, 0.05, position _locationObject];
	ctrlMapAnimCommit (uiNamespace getVariable 'respawnMenuMap');
};

functionHandleRespawnMenuMapClick =
{
	_mouseButton = _this select 1;
	_mousePosition = [_this select 2, _this select 3];
	// Left-click
	if (_mouseButton == 0)
	then
	{
		_worldPosition = (uiNamespace getVariable 'respawnMenuMap') ctrlMapScreenToWorld _mousePosition;
		_clickedBase = [_worldPosition, true] call functionGetBaseAtPosition;
		_clickedMobileRespawn = [_worldPosition] call functionGetMobileRespawnAtPosition;
		_clickedObject = _clickedBase;
		if (isNull _clickedBase)
		then
		{
			_clickedObject = _clickedMobileRespawn;
		};
		if (!(isNull _clickedObject))
		then
		{
			for '_locationItem' from 0 to ((lbSize 3002) - 1)
			do
			{
				scopeName 'locationItemsLoopScope';
				if ((_clickedObject getVariable 'id') == lbData [3002, _locationItem])
				then
				{
					lbSetCurSel [3002, _locationItem];
					breakOut 'locationItemsLoopScope';
				};
			};
		};
	};
};

functionHandlePlayerControlledBasesUpdate =
{
	call functionPopulateRespawnInterfaceRespawnPointsList;
};

functionHandleMobileRespawnPointsUpdate =
{
	call functionPopulateRespawnInterfaceRespawnPointsList;
};

functionDelayRespawnInterfaceAccess =
{
	ctrlEnable [3003, false];
	_countdownCounted = 0;
	ctrlSetText [3003, format ['Respawn (%1)', timeInSecondsUntilPlayerRespawnAllowed]];
	while {_countdownCounted < timeInSecondsUntilPlayerRespawnAllowed}
	do
	{
		sleep 1;
		_countdownCounted = _countdownCounted + 1;
		ctrlSetText [3003, format ['Respawn (%1)', (timeInSecondsUntilPlayerRespawnAllowed - _countdownCounted)]];
	};
	ctrlEnable [3003, true];
	ctrlSetText [3003, 'Respawn'];
	if ({(_x getVariable "team") == side player} count (playerControlledBases + FOBs) == 0)
	then
	{
		[([call functionGetStartingPositionForPlayer, 0, startingPositionSpawnRadius, 0, 0, 180, 0] call BIS_fnc_findSafePos)] call functionIlludePlayerRespawnAtPosition;
	};
	/*if ({(_x getVariable 'team') == side player} count (playerControlledBases + FOBs) == 1)
	then
	{
		_onlyPlayerControlledBase = objNull;
		{
			if ((_x getVariable 'team') == side player)
			then
			{
				_onlyPlayerControlledBase = _x;
			};
		} forEach playerControlledBases;
		// May need FOB integration
		if (!isNil('_this'))
		then
		{
			_playerKilledCorpseObject = _this select 0;
			_playerKilledCorpseObjectPosition2D = [position _playerKilledCorpseObject select 0, position _playerKilledCorpseObject select 1];
			_mobileRespawnPointAvailable = false;
			{
				if ((_x getVariable 'team') == side player)
				then
				{
					_mobileRespawnPointPosition2D = [position _x select 0, position _x select 1];
					if ((_mobileRespawnPointPosition2D distance _playerKilledCorpseObjectPosition2D) <= mobileRespawnRadius)
					then
					{
						_mobileRespawnPointAvailable = true;
					};
				};
			} forEach mobileRespawnPoints;
			if (!(_mobileRespawnPointAvailable))
			then
			{
				[([position _onlyPlayerControlledBase, 5, (baseRadius - baseRespawnOuterSpawnAreaBufferSize), 0, 0, 180, 0] call BIS_fnc_findSafePos)] call functionIlludePlayerRespawnAtPosition;
			};
		}
		else
		{
			[([position _onlyPlayerControlledBase, 5, (baseRadius - baseRespawnOuterSpawnAreaBufferSize), 0, 0, 180, 0] call BIS_fnc_findSafePos)] call functionIlludePlayerRespawnAtPosition;
		};
	};*/
};

functionRespawnAtSelectedLocation =
{
	_desiredRespawnLocation = lbCurSel 3002;
	if (_desiredRespawnLocation == -1)
	then
	{
		hint 'To respawn, you must select a spawn location from the list.';
	}
	else
	{
		_desiredRespawnLocation = lbData [3002, _desiredRespawnLocation];
		_desiredRespawnLocationPosition = false;
		{
			if ((_x getVariable 'id') == _desiredRespawnLocation)
			then
			{
				_desiredRespawnLocationPosition = ([position _x, 5, (baseRadius - baseRespawnOuterSpawnAreaBufferSize), 0, 0, 180, 0] call BIS_fnc_findSafePos);
			};
		} forEach playerControlledBases;
		{
			if ((_x getVariable 'id') == _desiredRespawnLocation)
			then
			{
				_desiredRespawnLocationPosition = ([position _x, 5, FOBRadius, 0, 0, 180, 0] call BIS_fnc_findSafePos);
			};
		} forEach FOBs;
		{
			if ((_x getVariable 'id') == _desiredRespawnLocation)
			then
			{
				_desiredRespawnLocationPosition = ([position _x, 5, mobileRespawnSpawnRadius, 0, 0, 180, 0] call BIS_fnc_findSafePos);
			};
		} forEach mobileRespawnPoints;
		[_desiredRespawnLocationPosition] call functionIlludePlayerRespawnAtPosition;
	};
};

functionEstablishMobileRespawnVehicleFunctionalityLocal =
{
	private ['_mobileRespawnVehicle'];
	_mobileRespawnVehicle = _this select 0;
	if (alive _mobileRespawnVehicle)
	then
	{
		_mobileRespawnVehicle = _this select 0;
		_mobileRespawnVehicle setVariable ['mobileRespawnEnabled', false];
		_mobileRespawnVehicle setVariable ['mobileRespawnTransitioning', false];
		_establishActionID = _mobileRespawnVehicle addAction ['<t color="#86F078">Establish Mobile Respawn</t>', functionEstablishMobileRespawn, '', 1002, false, true, '', '(alive _target) and (driver _target == _this) and !(_target getVariable "mobileRespawnEnabled") and !(_target getVariable "mobileRespawnTransitioning")'];
		_disestablishActionID = _mobileRespawnVehicle addAction ['<t color="#86F078">Disestablish Mobile Respawn</t>', functionDisestablishMobileRespawn, '', 1002, false, true, '', '(alive _target) and (driver _target == _this) and (_target getVariable "mobileRespawnEnabled") and !(_target getVariable "mobileRespawnTransitioning")'];
		_mobileRespawnVehicle setVariable ['_establishActionID', _establishActionID];
		_mobileRespawnVehicle setVariable ['_disestablishActionID', _disestablishActionID];
	};
};

functionEstablishMobileRespawn =
{
	_mobileRespawnVehicle = _this select 0;
	_mobileRespawnVehiclePosition2D = [position _mobileRespawnVehicle select 0, position _mobileRespawnVehicle select 1];
	_anotherMobileRespawnWithinExclusiveEstablishmentRadius = false;
	{
		if ((_x getVariable 'team') == (player getVariable 'team'))
		then
		{
			if (alive _x)
			then
			{
				_mobileRespawnPointPosition2D = [position _x select 0, position _x select 1];
				if ((_mobileRespawnVehiclePosition2D distance _mobileRespawnPointPosition2D) <= mobileRespawnExclusiveEstablishmentRadius)
				then
				{
					_anotherMobileRespawnWithinExclusiveEstablishmentRadius = true;
				};
			};
		};
	} forEach mobileRespawnPoints;
	if (_anotherMobileRespawnWithinExclusiveEstablishmentRadius)
	then
	{
		_message = format ['Cannot establish mobile respawn within %1m of another.', mobileRespawnExclusiveEstablishmentRadius];
		systemChat _message;
		hint _message;
	}
	else
	{
		if (_mobileRespawnVehicle getVariable 'slingLoadingPermitted')
		then
		{
			_message = 'Cannot establish mobile respawn that is prepared for sling loading.';
			systemChat _message;
			hint 'Cannot establish mobile respawn that is prepared for sling loading.';
		}
		else
		{
			[_mobileRespawnVehicle, 'mobileRespawnTransitioning', true, side player] call functionObjectSetVariablePublicTarget;
			[_mobileRespawnVehicle] call functionDisableEngine;
			//[[_mobileRespawnVehicle, side player], 'functionEstablishMobileRespawnLocalEnactmentViaServer', false] call BIS_fnc_MP;
			_message = format ['Establishment will take %1 seconds.', mobileRespawnEstablishTimeInSeconds];
			systemChat _message;
			hint _message;
			_establishStartServerTime = serverTime;
			waitUntil {serverTime >= (_establishStartServerTime + mobileRespawnEstablishTimeInSeconds)};
			['mobileRespawnPoints', mobileRespawnPoints + [_mobileRespawnVehicle]] call functionPublicVariableSetValue;
			[_mobileRespawnVehicle, 'mobileRespawnEnabled', true, side player] call functionObjectSetVariablePublicTarget;
			[_mobileRespawnVehicle, 'mobileRespawnTransitioning', false, side player] call functionObjectSetVariablePublicTarget;
			_message = 'Mobile spawn point established.';
			systemChat _message;
			hint _message;
		};
	};
};

functionDisestablishMobileRespawn =
{
	_mobileRespawnVehicle = _this select 0;
	['mobileRespawnPoints', mobileRespawnPoints - [_mobileRespawnVehicle]] call functionPublicVariableSetValue;
	[_mobileRespawnVehicle, 'mobileRespawnTransitioning', true, side player] call functionObjectSetVariablePublicTarget;
	_message = format ['Disestablishment will take %1 seconds.', mobileRespawnDisestablishTimeInSeconds];
	systemChat _message;
	hint _message;
	_disestablishStartServerTime = serverTime;
	waitUntil {serverTime >= (_disestablishStartServerTime + mobileRespawnDisestablishTimeInSeconds)};
	[_mobileRespawnVehicle] call functionEnableEngine;
	//[[_mobileRespawnVehicle, side player], 'functionDisestablishMobileRespawnLocalEnactmentViaServer', false] call BIS_fnc_MP;
	[_mobileRespawnVehicle, 'mobileRespawnEnabled', false, side player] call functionObjectSetVariablePublicTarget;
	[_mobileRespawnVehicle, 'mobileRespawnTransitioning', false, side player] call functionObjectSetVariablePublicTarget;
	_message = 'Mobile spawn point disestablished.';
	systemChat _message;
	hint _message;
};

/*functionHandleMobileRespawnVehicleKilledLocal =
{
	_mobileRespawnVehicle = _this select 0;
	_mobileRespawnVehicle removeAction (_mobileRespawnVehicle getVariable 'establishActionID');
	_mobileRespawnVehicle removeAction (_mobileRespawnVehicle getVariable 'disestablishActionID');
	_mobileRespawnVehicle removeEventHandler ['Engine', (_mobileRespawnVehicle getVariable 'engineEventID')];
	call functionPopulateRespawnInterfaceRespawnPointsList;
};*/

functionGetStartingPositionForPlayer =
{
	_startingPosition = false;
	if (side player == BLUFOR)
	then
	{
		_startingPosition = startingPositionBLUFOR;
	}
	else
	{
		if (side player == OPFOR)
		then
		{
			_startingPosition = startingPositionOPFOR;
		};
	};
	_startingPosition;
};