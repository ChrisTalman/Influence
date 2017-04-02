functionEstablishPlayerConnectionListeners =
{
	['playerConnectedEvent', 'onPlayerConnected', {[_uid, _name] call functionHandlePlayerConnectedEvent;}] call BIS_fnc_addStackedEventhandler;
};

functionHandlePlayerConnectedEvent =
{
	// Code
};