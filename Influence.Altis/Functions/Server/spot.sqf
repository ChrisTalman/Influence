functionSpotBaseServer =
{
	_base = _this select 0;
	_team = _this select 1;
	_teamLiteral = [_team] call functionGetTeamFORName;
	_baseType = _base getVariable 'type';
	_knownBases = missionNamespace getVariable (format ['known%1s%2', _baseType, _teamLiteral]);
	if (!(_base in _knownBases))
	then
	{
		[(format ['known%1s%2', _baseType, _teamLiteral]), _base] call functionPublicVariableAppendToArray;
		[['NotificationPositive', ['Spotted', 'Hostile base has been spotted.']], 'BIS_fnc_showNotification', _team] call BIS_fnc_MP;
	};
};

functionManualSpotServer =
{
	_spottedObject = _this select 0;
	sleep manualSpotRenewInterval;
	_spottedObject setVariable ['spottedObjectSpotted', false, true];
};