functionEstablishDynamicTerritory =
{
	// Create map
	influenceMap = [1, 50, mapSize] call imapCreate;
	// Clientside
	if (!isServer or !isDedicated)
	then
	{
		// Map renderer
		influenceRendererMain = [influenceMap, 0, 25] call irenCreate;
		_eh = ((findDisplay 12) displayCtrl 51) ctrlAddEventHandler ["Draw", {
			[influenceRendererMain, _this select 0] call irenOnDraw;
		}];

		// Minimap renderer
		influenceRendererMini = [influenceMap, 0, 10] call irenCreate;
		0 spawn
		{
			disableSerialization;
			_defaultMinimapControl=controlNull;
			while {isNull _defaultMinimapControl} do
			{
				{if !(isNil {_x displayCtrl 101}) then {_defaultMinimapControl= _x displayCtrl 101};} count (uiNamespace getVariable 'IGUI_Displays');
				sleep 0.1;
			};
			_defaultMinimapControl ctrlAddEventHandler ["Draw", {
				[influenceRendererMini, _this select 0] call irenOnDraw;
			}];
		};
	};
	_cycleTracker = 0;
	while {true}
	do
	{
		sleep 5;//10;
		_cycleTracker = _cycleTracker + 1;
		if (isServer or isDedicated)
		then
		{
			if (_cycleTracker == 10)
			then
			{
				_cycleTracker = 0;
				_dump = [influenceMap] call imapGetDump;
				[[_dump], 'functionHandleImapDumpClient', call functionGetPlayerObjects] call BIS_fnc_MP;
			};
		};
		
		//hint "Busy";
		[influenceMap, true] call imapSetLock;
		
		//hint "Adding influence";
		{
			_influence = baseInfluenceAmount;
			if ((_x getVariable 'team') == BLUFOR)
			then
			{
				_influence = _influence * -1;
			};
			[influenceMap, 0, position _x, _influence] call imapAdd;
		} forEach playerControlledBases;
		{
			_influence = baseInfluenceAmount;
			if ((_x getVariable 'team') == BLUFOR)
			then
			{
				_influence = _influence * -1;
			};
			[influenceMap, 0, position _x, _influence] call imapAdd;
		} forEach FOBs;
		
		//hint "Updating influence map";
		_territoryControl = [influenceMap, 0, 1, 0.001] call imapUpdate;
		territoryControlBLUFOR = _territoryControl select 0;
		territoryControlOPFOR = _territoryControl select 1;
		
		//hint "Idle";
		[influenceMap, false] call imapSetLock;
	};
};