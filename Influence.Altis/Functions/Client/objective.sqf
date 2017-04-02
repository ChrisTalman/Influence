functionManageObjectivesClient =
{
	closeDialog 0;
	openMap true;
	hint parseText 'Left-click on a hostile base or FOB to select as objective.<br/><br/>Shift left-click on a hostile base or FOB to deselect as objective.';
	manageObjectivesStage = 'start';
	manageObjectivesSelectedBase = objNull;
	['manageObjectivesMapClickEvent', 'onMapSingleClick', {[_pos, _shift] call functionHandleEstablishBaseMapClick;}] call BIS_fnc_addStackedEventHandler;
	[] spawn functionManageObjectivesHandleMapClosure;
};

functionHandleEstablishBaseMapClick =
{
	_position = _this select 0;
	_shiftPressed = _this select 1;
	_position2D = [_position select 0, _position select 1];
	_knownBases = missionNamespace getVariable (format ['knownBases%1', personalTeamLiteral]);
	{
		scopeName 'knownBases';
		_baseRadius = [_x] call functionGetBaseRadius;
		if ((_position2D distance (position _x)) <= _baseRadius and (_x getVariable 'team') != (player getVariable 'team'))
		then
		{
			if (manageObjectivesStage in ['start', 'confirmBase'] and !(_shiftPressed))
			then
			{
				_activateObjective = false;
				if (manageObjectivesStage == 'start' or (manageObjectivesStage == 'confirmBase' and _x != manageObjectivesSelectedBase))
				then
				{
					_objectives = missionNamespace getVariable (format ['objectives%1', personalTeamLiteral]);
					if (count _objectives == objectiveMaximumSimultaneous)
					then
					{
						hint parseText format ['Your team already has %1 objectives. You may select the base again, which will take the place of the current first objective, deselecting it.', objectiveMaximumSimultaneous];
						manageObjectivesStage = 'confirmBase';
					}
					else
					{
						_activateObjective = true;
					};
					manageObjectivesSelectedBase = _x;
				}
				else
				{
					_activateObjective = true;
				};
				if (_activateObjective)
				then
				{
					[[manageObjectivesSelectedBase, (player getVariable 'team')], 'functionActivateObjectiveServer', false] call BIS_fnc_MP;
					openMap false;
				};
			};
			if (_shiftPressed)
			then
			{
				[[_x, (player getVariable 'team')], 'functionDeactivateObjectiveServer', false] call BIS_fnc_MP;
			};
			breakOut 'knownBases';
		};
	} forEach _knownBases;
};

functionManageObjectivesCloseMap =
{
	private ['_message'];
	_message = _this select 0;
	openMap false;
	hint _message;
	systemChat _message;
};

functionManageObjectivesHandleMapClosure =
{ 
	waitUntil {!(visibleMap)};
	hint '';
	['manageObjectivesMapClickEvent', 'onMapSingleClick'] call BIS_fnc_removeStackedEventHandler;
};

functionHandleNewObjective =
{
	_base = _this select 0;
	_message = format ['Hostile %1 set as objective.', (_base getVariable 'name')];
	['NotificationPositive', ['New Objective', _message]] call BIS_fnc_showNotification;
	systemChat _message;
	call functionUpdatePanelHUD;
};

functionHandleRemovedObjective =
{
	_base = _this select 0;
	_message = format ['Hostile %1 no longer objective.', (_base getVariable 'name')];
	['NotificationNegative', ['Removed Objective', _message]] call BIS_fnc_showNotification;
	systemChat _message;
	call functionUpdatePanelHUD;
};