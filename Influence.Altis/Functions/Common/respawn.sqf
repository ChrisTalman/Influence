functionEstablishMobileRespawnLocalEnactment =
{
	_mobileRespawnVehicle = _this select 0;
	if (alive _mobileRespawnVehicle)
	then
	{
		_eventID = _mobileRespawnVehicle addEventHandler ['Engine', {_this call functionHandleMobileRespawnVehicleEngineEvent;}];
		_mobileRespawnVehicle setVariable ['engineEventID', _eventID];
		_mobileRespawnVehicle engineOn false;
	};
};

functionDisestablishMobileRespawnLocalEnactment =
{
	_mobileRespawnVehicle = _this select 0;
	_mobileRespawnVehicle removeEventHandler ['Engine', (_mobileRespawnVehicle getVariable 'engineEventID')];
};

functionHandleMobileRespawnVehicleEngineEvent =
{
	_mobileRespawnVehicle = _this select 0;
	_engineState = _this select 1;
	if (_engineState)
	then
	{
		_mobileRespawnVehicle engineOn false;
	};
};