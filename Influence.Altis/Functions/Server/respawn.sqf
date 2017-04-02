/*functionEstablishMobileRespawnVehicleFunctionalityServer =
{
	_mobileRespawnVehicle = _this select 0;
	_mobileRespawnVehicle addEventHandler ['Killed', {call functionHandleMobileRespawnVehicleKilledServer;}];
};

functionHandleMobileRespawnVehicleKilledServer =
{
	_mobileRespawnVehicle = _this select 0;
	if (_mobileRespawnVehicle in mobileRespawnPoints)
	then
	{
		['mobileRespawnPoints', mobileRespawnPoints - [_mobileRespawnVehicle]] call functionPublicVariableSetValue;
	};
	_mobileRespawnVehicle removeEventHandler ['Engine', (_mobileRespawnVehicle getVariable 'engineEventID')];
	[[_mobileRespawnVehicle], 'functionHandleMobileRespawnVehicleKilledLocal', (_mobileRespawnVehicle getVariable 'team')] call BIS_fnc_MP;
};*/

functionEstablishMobileRespawnLocalEnactmentViaServer =
{
	_mobileRespawnVehicle = _this select 0;
	_target = _this select 1;
	[_mobileRespawnVehicle] call functionEstablishMobileRespawnLocalEnactment;
	[[_mobileRespawnVehicle], 'functionEstablishMobileRespawnLocalEnactment', _target, true] call BIS_fnc_MP;
};

functionDisestablishMobileRespawnLocalEnactmentViaServer =
{
	_mobileRespawnVehicle = _this select 0;
	_target = _this select 1;
	[_mobileRespawnVehicle] call functionDisestablishMobileRespawnLocalEnactment;
	[[_mobileRespawnVehicle], 'functionDisestablishMobileRespawnLocalEnactment', _target] call BIS_fnc_MP;
};