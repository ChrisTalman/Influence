functionOpenMissionsInterface =
{
	createDialog 'nwDialogueMissions';
	[[player], 'functionHandleGetMissionsRequest', false] call BIS_fnc_MP;
	ctrlEnable [6001, false];
	if ((typeName activeMission) == 'ARRAY')
	then
	{
		ctrlEnable [6001, true];
		ctrlSetText [6001, 'Abandon Mission'];
		buttonSetAction [6001, 'call functionAbandonMission;'];
	};
};

functionHandleGetMissionsResponse =
{
	_missions = _this select 0;
	//diag_log format ['_missions: %1.', _missions];
	//systemChat format ['_missions: %1.', _missions];
	[_missions] call functionPopulateMissionsList;
};

functionPopulateMissionsList =
{
	private ['_missions'];
	_missions = _this select 0;
	lbClear 6000;
	{
		_missionID = _x select 0;
		_missionType = _x select 1;
		_missionSpecialArguments = _x select 2;
		_missionTitle = '';
		switch (_missionType)
		do
		{
			case 'supplyRelayStation':
			{
				_missionPosition = _missionSpecialArguments select 0;
				_missionBaseObject = _missionSpecialArguments select 1;
				_missionTitle = format ['Build supply relay station at %1 from %2.', _missionPosition, (_missionBaseObject getVariable 'name')];
			};
			case 'roadblock':
			{
				_missionPosition = _missionSpecialArguments select 0;
				_missionBaseObject = _missionSpecialArguments select 1;
				_missionTitle = format ['Build roadblock at %1 from %2.', _missionPosition, (_missionBaseObject getVariable 'name')];
			};
			case 'FOB':
			{
				_missionPosition = _missionSpecialArguments select 0;
				_missionBaseObject = _missionSpecialArguments select 1;
				_missionTitle = format ['Build FOB at %1 from %2.', _missionPosition, (_missionBaseObject getVariable 'name')];
			};
			case 'base':
			{
				_missionPosition = _missionSpecialArguments select 0;
				_missionBaseObject = _missionSpecialArguments select 1;
				_missionTitle = format ['Build base at %1 from %2.', _missionPosition, (_missionBaseObject getVariable 'name')];
			};
			default
			{
				_missionTitle = 'Unknown mission.';
			};
		};
		_indexInList = lbAdd [6000, _missionTitle];
		lbSetData [6000, _indexInList, _missionID];
	} forEach _missions;
	if ((typeName activeMission) == 'ARRAY')
	then
	{
		ctrlSetText [6003, 'You have already accepted a mission. Only one acceptable at a time.'];
	};
};

functionHandleNewMission =
{
	_missionType = _this select 0;
	_missionSingularPluralLiteral = 'Mission';
	if ((count _this) > 1)
	then
	{
		_multipleMissionsAmount = _this select 1;
		_missionSingularPluralLiteral = format ['%1 missions', _multipleMissionsAmount];
	};
	_newMissionMessage = '';
	switch (_missionType)
	do
	{
		case 'FOB':
		{
			_newMissionMessage = format ['%1 available to establish new FOB.', _missionSingularPluralLiteral];
		};
		case 'base':
		{
			_newMissionMessage = format ['%1 available to establish new base.', _missionSingularPluralLiteral];
		};
		case 'supplyRelayStation':
		{
			_newMissionMessage = format ['%1 available to establish new supply relay station.', _missionSingularPluralLiteral];
		};
		case 'roadblock':
		{
			_newMissionMessage = format ['%1 available to establish new roadblock.', _missionSingularPluralLiteral];
		};
		default
		{
			_newMissionMessage = 'Unknown mission.';
		};
	};
	['TaskAssigned', [_newMissionMessage]] call bis_fnc_showNotification;
};

functionHandleMissionListSelection =
{
	ctrlEnable [6001, true];
};

functionEstablishAvailableMissionCount =
{
	amountMissionsAvailable = _this select 0;
	call functionUpdatePanelHUD;
};

functionEstablishActiveMission =
{
	_mission = _this select 0;
	if ((typeName _mission) == 'ARRAY')
	then
	{
		activeMission = _mission;
		[_mission] call functionAcceptMissionLocalEnactment;
	};
};

functionAcceptMission =
{
	_missionID = lbData [6000, (lbCurSel 6000)];
	[[_missionID, player], 'functionAcceptMissionViaServer', false] call BIS_fnc_MP;
};

functionAcceptMissionLocalEnactment =
{
	_mission = _this select 0;
	_missionID = _mission select 0;
	_missionType = _mission select 1;
	activeMission = _mission;
	if (!(isNull (findDisplay 6)))
	then
	{
		closeDialog 0;
	};
	_missionTypeLiteral = [_missionType] call functionGetMissionTypeLiteral;
	_missionTypeSpecialArguments = _mission select 4;
	if (_missionType in ['FOB', 'base', 'supplyRelayStation', 'roadblock'])
	then
	{
		_buildPosition = _missionTypeSpecialArguments select 0;
		_constructionVehicle = _missionTypeSpecialArguments select 2;
		[_constructionVehicle, true] call functionOwnedVehicleEstablishLock;
		_frameEventID = [format ['%1FrameEvent', _missionID], 'onEachFrame', {_this call functionHandleConstructionMissionFrameEvent;}, [_buildPosition, _constructionVehicle, _missionTypeLiteral]] call BIS_fnc_addStackedEventHandler;
		_constructionVehicle setVariable ['missionFrameEventID', _frameEventID];
		[_buildPosition, _missionTypeLiteral] call functionEstablishConstructionMissionMapMarkers;
		_constructionVehicle addAction [format ['<t color="#86F078">Build %1</t>', _missionTypeLiteral], functionFulfilConstructionMission, [_missionID, _buildPosition, _constructionVehicle, _frameEventID], 1002, false, true, ''];
		['TaskAssigned', ['Use the construction vehicle at the build location.']] call bis_fnc_showNotification;
	};
};

functionAcceptMissionError =
{
	_errorType = _this select 0;
	switch (_errorType)
	do
	{
		case 'conflict':
		{
			[[player], 'functionHandleGetMissionsRequest', false] call BIS_fnc_MP;
			hint 'Unfortunately, that mission has already been accepted by another player.';
		};
		default
		{
			[[player], 'functionHandleGetMissionsRequest', false] call BIS_fnc_MP;
			hint 'Unfortunately, an error occurred while attempting to accept the mission. Please try again.';
		};
	};
};

functionAbandonMission =
{
	_activeMissionID = activeMission select 0;
	_activeMissionType = activeMission select 1;
	[[_activeMissionID, (player getVariable 'team')], 'functionAbandonMissionViaServer', false] call BIS_fnc_MP;
	if (_activeMissionType in ['FOB', 'base', 'supplyRelayStation', 'roadblock'])
	then
	{
		[format ['%1FrameEvent', _activeMissionID], 'onEachFrame'] call BIS_fnc_removeStackedEventHandler;
		call functionClearConstructionMissionMapMarkers;
	};
	activeMission = false;
	ctrlEnable [6001, false];
	ctrlSetText [6001, 'Accept Mission'];
	buttonSetAction [6001, 'call functionAcceptMission;'];
	ctrlSetText [6003, ''];
};

functionHandleMissionFailureClient =
{
	_mission = _this select 0;
	_missionID = _mission select 0;
	_missionType = _mission select 1;
	if (_missionType in ['FOB', 'base', 'supplyRelayStation'])
	then
	{
		call functionClearConstructionMissionMapMarkers;
		[format ['%1FrameEvent', _missionID], 'onEachFrame'] call BIS_fnc_removeStackedEventHandler;
		['TaskFailure', ['Mission failure, as construction vehicle has been destroyed.', 10]] call bis_fnc_showNotification;
	}
	else
	{
		['TaskFailure', ['Mission failure for unrecognised reasons.', 10]] call bis_fnc_showNotification;
	};
	activeMission = false;
};

functionHandleConstructionMissionFrameEvent =
{
	_buildPosition = _this select 0;
	_constructionVehicle = _this select 1;
	_missionTypeLiteral = _this select 2;
	_playerDistanceFromConstructionVehiclePosition = round ((position player) distance (position _constructionVehicle));
	_playerDistanceFromObjectivePosition = round ((position player) distance _buildPosition);
	// \A3\ui_f\data\map\groupicons\badge_simple.paa may be desirable
	if (!(player in (crew _constructionVehicle)))
	then
	{
		drawIcon3D ['\A3\ui_f\data\map\markers\handdrawn\objective_CA.paa', [1,1,1,1], position _constructionVehicle, 1, 1, 0, format ['%1 Construction Vehicle: %2m', _missionTypeLiteral, _playerDistanceFromConstructionVehiclePosition], 0, 0.03, 'PuristaMedium'];
	};
	drawIcon3D ['\A3\ui_f\data\map\markers\handdrawn\objective_CA.paa', [1,1,1,1], _buildPosition, 1, 1, 0, format ['%1: %2m', format ['%1 Build Location', _missionTypeLiteral], _playerDistanceFromObjectivePosition], 0, 0.03, 'PuristaMedium'];
};

functionEstablishConstructionMissionMapMarkers =
{
	private ['_buildPosition', '_missionTypeLiteral', '_mapMarker', '_textMapMarker'];
	_buildPosition = _this select 0;
	_missionTypeLiteral = _this select 1;
	_mapMarker = createMarkerLocal ['constructionMissionMapMarker', _buildPosition];
	_mapMarker setMarkerTypeLocal 'mil_dot';
	_mapMarker setMarkerBrushLocal 'SOLID';
	_mapMarker setMarkerColorLocal 'Color4_FD_F';
	_textMapMarker = createMarkerLocal ['constructionMissionTextMapMarker', _buildPosition];
	_textMapMarker setMarkerTypeLocal 'EmptyIcon';
	_textMapMarker setMarkerTextLocal format ['%1 Build Location', _missionTypeLiteral];
	_textMapMarker setMarkerColorLocal 'ColorWhite';
};

functionClearConstructionMissionMapMarkers =
{
	deleteMarkerLocal 'constructionMissionMapMarker';
	deleteMarkerLocal 'constructionMissionTextMapMarker';
};

functionFulfilConstructionMission =
{
	_customArguments = _this select 3;
	_missionID = _customArguments select 0;
	_buildPosition = _customArguments select 1;
	_constructionVehicle = _customArguments select 2;
	if (((position _constructionVehicle) distance _buildPosition) <= missionRemoteConstructionPositionRadius)
	then
	{
		[[_missionID, player, _customArguments], 'functionFulfilMissionViaServer', false] call BIS_fnc_MP;
	}
	else
	{
		hint format ['The construction vehicle must be within %1m of the build position to fulfil the mission.', missionRemoteConstructionPositionRadius];
	};
};

functionFulfilConstructionMissionLocalEnactment =
{
	_mission = _this select 0;
	_missionID = _mission select 0;
	_missionTypeSpecialArguments = _mission select 4;
	_missonConstructionVehicle = _missionTypeSpecialArguments select 2;
	[format ['%1FrameEvent', _missionID], 'onEachFrame'] call BIS_fnc_removeStackedEventHandler;
	call functionClearConstructionMissionMapMarkers;
	[_missonConstructionVehicle] call functionConstructionMissionReplaceConstructionVehicle;
	['TaskSuccess', ['Mission completed. Excellent work!']] call bis_fnc_showNotification;
	activeMission = false;
};

functionHandleConstructionMissionCannotFulfilLocalEnactment =
{
	_mission = _this select 0;
	_missionID = _mission select 0;
	_missionTypeSpecialArguments = _mission select 4;
	_missonConstructionVehicle = _missionTypeSpecialArguments select 2;
	[format ['%1FrameEvent', _missionID], 'onEachFrame'] call BIS_fnc_removeStackedEventHandler;
	call functionClearConstructionMissionMapMarkers;
	[_missonConstructionVehicle] call functionConstructionMissionReplaceConstructionVehicle;
	['TaskFailure', ['Mission cannot be fulfilled.']] call bis_fnc_showNotification;
	activeMission = false;
};

functionConstructionMissionReplaceConstructionVehicle =
{	
	private ['_constructionVehicle', '_quadbikeVehicle'];
	_constructionVehicle = _this select 0;
	_quadbikeVehicle = createVehicle ['B_G_Quadbike_01_F', position player, [], 0, 'NONE'];
	[_quadbikeVehicle, 'team', side player, side player] call functionObjectSetVariablePublicTarget;
	[_quadbikeVehicle, 'vehicleName', 'Quadbike', side player] call functionObjectSetVariablePublicTarget;
	[format ['vehicles%1', [side player] call functionGetTeamFORName], _quadbikeVehicle] call functionPublicVariableAppendToArray;
	player action ['Eject', _constructionVehicle];
	player setPos ([position player, 0, 5, 0, 0, 180, 0] call BIS_fnc_findSafePos);
	player action ['GetInDriver', _quadbikeVehicle];
	[format ['vehicles%1', [side player] call functionGetTeamFORName], _constructionVehicle] call functionPublicVariableRemoveFromArray;
	deleteVehicle _constructionVehicle;
};