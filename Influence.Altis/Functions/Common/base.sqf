functionGetBaseObjectWithID =
{
	// Arguments: base ID, include FOBs
	private ['_baseID', '_includeFOBs', '_baseObject', '_basesAndFOBs'];
	_baseID = _this select 0;
	_includeFOBs = false;
	_baseObject = objNull;
	_basesAndFOBs = playerControlledBases;
	if ((count _this) > 1)
	then
	{
		_includeFOBs = true;
	};
	if (_includeFOBs)
	then
	{
		_basesAndFOBs = playerControlledBases + FOBs;
	};
	{
		if ((_x getVariable 'id') == _baseID)
		then
		{
			_baseObject = _x;
		};
	} forEach _basesAndFOBs;
	_baseObject;
};

functionGetPositionInBase =
{
	private ['_baseObject', '_playerObject', '_baseID', '_basePosition2D', '_positionInBase'];
	_baseObject = _this select 0;
	_playerObject = _this select 1;
	_baseID = _baseObject getVariable 'id';
	_basePosition2D = [(position _baseObject) select 0, (position _baseObject) select 1];
	_baseRadius = 0;
	if ((_baseID find 'base') > -1)
	then
	{
		_baseRadius = baseRadius;
	};
	if ((_baseID find 'FOB') > -1)
	then
	{
		_baseRadius = FOBRadius;
	};
	_positionInBase = [0, 0, 0];
	if (((position _playerObject) distance _basePosition2D) <= _baseRadius)
	then
	{
		_positionInBase = ([position _playerObject, 0, 0, 0, 0, 180, 0] call BIS_fnc_findSafePos);
	}
	else
	{
		_positionInBase = ([_basePosition2D, 0, _baseRadius, 0, 0, 180, 0] call BIS_fnc_findSafePos);
	};
	_positionInBase;
};

functionGetBaseFacilityIdentifierFromLiteral =
{
	private ['_facilityName'];
	_facilityName = _this select 0;
	_identifier = 'undefined';
	switch (_facilityName)
	do
	{
		case 'Infantry Facility':
		{
			_identifier = 'infantryFacility';
		};
		case 'Light Vehicle Facility':
		{
			_identifier = 'lightVehicleFacility';
		};
		case 'Heavy Vehicle Facility':
		{
			_identifier = 'heavyVehicleFacility';
		};
		case 'Air Facility':
		{
			_identifier = 'airFacility';
		};
		case 'Naval Facility':
		{
			_identifier = 'navalFacility';
		};
	};
	_identifier;
};

functionGetNeutralisedBases =
{
	private ['_team'];
	_team = _this select 0;
	_neutralisedBases = [];
	{
		if ((_x getVariable 'team') == _team)
		then
		{
			if ((_x getVariable 'neutralised'))
			then
			{
				_neutralisedBases pushBack _x;
			};
		};
	} forEach (playerControlledBases + FOBs);
	_neutralisedBases;
};

functionGetBaseRadius =
{
	// Arguments: base object
	private ['_baseObject', '_baseRadius'];
	_baseObject = _this select 0;
	_baseRadius = 0;
	if (((_baseObject getVariable 'id') find 'base') >= 0)
	then
	{
		_baseRadius = baseRadius;
	};
	if (((_baseObject getVariable 'id') find 'FOB') >= 0)
	then
	{
		_baseRadius = FOBRadius;
	};
	_baseRadius;
};

functionFindSafeAcquisitionPositionInBase =
{
	// Arguments: base object, player position
	_baseObject = _this select 0;
	_playerPosition = _this select 1;
	_basePosition = position _baseObject;
	_baseRadius = [_baseObject] call functionGetBaseRadius;
	_placementPosition = [0, 0, 0];
	if ((_playerPosition distance _basePosition) <= _baseRadius)
	then
	{
		_placementPosition = [_playerPosition, 0, 0, 0, 0, 180, 0/*, [[(_basePosition select 0) - 2, (_basePosition select 1) - 2], [(_basePosition select 0) + 2, (_basePosition select 1) + 2]]*/] call BIS_fnc_findSafePos;
	}
	else
	{
		_placementPosition = [_basePosition, 2, _baseRadius, 0, 0, 180, 0] call BIS_fnc_findSafePos;
	};
	_placementPosition;
};

functionGetBaseAtPosition =
{
	// Arguments: position, include FOBs
	_position = _this select 0;
	_includeFOBs = false;
	_bases = playerControlledBases;
	if ((count _this) > 1)
	then
	{
		_includeFOBs = _this select 1;
		if (_includeFOBs)
		then
		{
			_bases = playerControlledBases + FOBs;
		};
	};
	_baseAtPosition = objNull;
	{
		scopeName 'basesLoopScope';
		_baseRadius = 0;
		if (((_x getVariable 'id') find 'base') >= 0)
		then
		{
			_baseRadius = baseRadius;
		};
		if (((_x getVariable 'id') find 'FOB') >= 0)
		then
		{
			_baseRadius = FOBRadius;
		};
		if (((position _x) distance _position) <= _baseRadius)
		then
		{
			_baseAtPosition = _x;
			breakOut 'basesLoopScope';
		};
	} forEach _bases;
	_baseAtPosition;
};