functionSpot =
{
	_spottedObject = cursorTarget;
	_laserTarget = laserTarget player;
	if (!(isNull _spottedObject) and !(isNull _laserTarget))
	then
	{
		if (typeName (_spottedObject getVariable ['team', false]) == 'SIDE')
		then
		{
			if ((_spottedObject getVariable 'team') != (player getVariable 'team'))
			then
			{
				if (_spottedObject isKindOf 'Building')
				then
				{
					if ((typeOf _spottedObject) == baseObjectEngineName or (typeOf _spottedObject) == FOBObjectEngineName)
					then
					{
						if ((_spottedObject in playerControlledBases) or (_spottedObject in FOBs))
						then
						{
							_baseType = _spottedObject getVariable 'type';
							_knownBases = missionNamespace getVariable (format ['known%1s%2', _baseType, personalTeamLiteral]);
							if (!(_spottedObject in _knownBases))
							then
							{
								[[_spottedObject, (player getVariable 'team')], 'functionSpotBaseServer', false] call BIS_fnc_MP;
							}
							else
							{
								['Notification', ['Spotted', 'Hostile base already known to your team.']] call BIS_fnc_showNotification;
							};
						};
					};
				};
				if (_spottedObject isKindOf 'LandVehicle' or _spottedObject isKindOf 'AirVehicle' or _spottedObject isKindOf 'Ship')
				then
				{
					[_spottedObject] spawn functionManualSpot;
				};
			};
		};
	};
};

functionManualSpot =
{
	_spottedObject = _this select 0;
	while {true}
	do
	{
		scopeName 'manualSpotRenewLoopScope';
		_currentSpottedObject = cursorTarget;
		_currentLaserTarget = laserTarget player;
		if (!(isNull _currentLaserTarget) and _spottedObject == _currentSpottedObject)
		then
		{
			manualSpotting = true;
			waitUntil {!(_spottedObject getVariable ['spottedObjectSpotted', false])};
			_spottedObjectPosition = [_spottedObject] call functionGetRealVisualPosition;
			_spottedObject setVariable ['spottedObjectSpotted', true, true];
			[[_spottedObject], 'functionManualSpotServer', false] call BIS_fnc_MP;
			[[_spottedObjectPosition, _spottedObject], 'functionHandleManualSpot', (player getVariable 'team')] call BIS_fnc_MP;
			sleep manualSpotRenewInterval;
		}
		else
		{
			manualSpotting = false;
			breakOut 'manualSpotRenewLoopScope';
		};
	};
};

functionHandleManualSpot =
{
	_spottedObjectPosition = _this select 0;
	_spottedObject = _this select 1;
	if (_spottedObject in manualSpotObjects)
	then
	{
		terminate (_spottedObject getVariable 'spottedObjectDelayedRemovalScript');
	}
	else
	{
		manualSpotObjects pushBack _spottedObject;
	};
	_delayedRemovalScript = [_spottedObject] spawn functionManualSpotDelayedRemoval;
	_spottedObject setVariable ['spottedObjectPosition', _spottedObjectPosition];
	_spottedObject setVariable ['spottedObjectDelayedRemovalScript', _delayedRemovalScript];
};

functionManualSpotDelayedRemoval =
{
	_spottedObject = _this select 0;
	sleep manualSpotDelayedRemovalInterval;
	_spottedObjectIndex = manualSpotObjects find _spottedObject;
	if (_spottedObjectIndex > -1)
	then
	{
		manualSpotObjects deleteAt _spottedObjectIndex;
	};
};