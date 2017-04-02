functionEstablishMapGraphics =
{
	mapGraphicsPlayerTeamColour = [0, 0, 0, 1];
	if ((player getVariable 'team') == BLUFOR)
	then
	{
		mapGraphicsPlayerTeamColour = colourTeamMapDrawingsBLUFOR;
	};
	if ((player getVariable 'team') == OPFOR)
	then
	{
		mapGraphicsPlayerTeamColour = colourTeamMapDrawingsOPFOR;
	};
	{
		if ((_x getVariable 'team') == (player getVariable 'team'))
		then
		{
			_mapMarkerColourName = [player getVariable 'team'] call functionGetTeamMapMarkerColourName;
			//[_x getVariable 'id', position _x, _x getVariable 'roadblockDirection', _mapMarkerColourName, _x getVariable 'name'] call functionRoadblockCreateMarker;
		};
	} forEach roadblocks;
	disableSerialization;
	_defaultMapControl = ((findDisplay mapDisplayID) displayCtrl 51);
	_defaultMapControl ctrlAddEventHandler ['Draw', {call functionMapGraphicsMainMapFrameEvent;}];
	// Current implementation of minimap territory represetnation creates unacceptable FPS drop
	0 spawn
	{
		disableSerialization;
		_defaultMinimapControl=controlNull;
		while {isNull _defaultMinimapControl} do
		{
			{if !(isNil {_x displayctrl 101}) then {_defaultMinimapControl= _x displayctrl 101};} count (uiNamespace getVariable 'IGUI_Displays');
			sleep 0.1;
		};
		_defaultMinimapControl ctrlAddEventHandler ['Draw', {call functionMapGraphicsMiniMapFrameEvent;}];
	};
	_mapMarkerColourName = [player getVariable 'team'] call functionGetTeamMapMarkerColourName;
	{
		if ((_x getVariable 'team') == side player)
		then
		{
			//[(_x getVariable 'id'), (_x getVariable 'name'), ([_x] call functionGetPosition2D), _mapMarkerColourName] call functionRegisterBaseCreateMarker;
		};
	} forEach playerControlledBases;
	{
		if ((_x getVariable 'team') == side player)
		then
		{
			//[(_x getVariable 'id'), (_x getVariable 'name'), ([_x] call functionGetPosition2D), _mapMarkerColourName] call functionRegisterFOBCreateMarker;
		};
	} forEach FOBs;
};

functionMapGraphicsMainMapFrameEvent =
{
	call functionMapGraphicsTeam;
	if (townDefenceCheat)
	then
	{
		call functionMapGraphicsTownDefence;
	};
	//call functionMapGraphicsTerritory;
	call functionMapGraphicsProvinces;
};

functionMapGraphicsMiniMapFrameEvent =
{
	call functionMapGraphicsTeam;
	if (townDefenceCheat)
	then
	{
		call functionMapGraphicsTownDefence;
	};
};

functionMapGraphicsTeam =
{
	_teamLiteral = [player getVariable 'team'] call functionGetTeamFORName;
	// Could be expanded to include friendly vehicles and buildings
	{
		if ((side _x) == (player getVariable 'team'))
		then
		{
			if (isPlayer _x)
			then
			{
				if (!(_x getVariable 'respawning'))
				then
				{
					{
						if ((vehicle _x) == _x)
						then
						{
							_unitName = name _x;
							if (!(isPlayer _x))
							then
							{
								_unitName = format ["%1's AI (%2, %3)", name (leader (group _x)), [name _x] call functionGetLastName, [typeOf _x] call functionGetLiteralInitialForUnitType];
							};
							(_this select 0) drawIcon [missionRoot + 'Assets\playerIcon.paa', mapGraphicsPlayerTeamColour, position _x, 45, 45, direction _x, '', 0, 0.04 / (getResolution select 5), 'PuristaMedium', 'right'];
							(_this select 0) drawIcon ['#(argb,8,8,3)color(0,0,0,0)', mapGraphicsPlayerTeamColour, position _x, 45, 45, 0, _unitName, 0, 0.04 / (getResolution select 5), 'PuristaMedium', 'right'];
						};
					} forEach units (group _x);
				};
			};
		};
	} forEach playableUnits;
	// Consider changing vehicle icon to one that represents vehicles, rather than being same icon as for infantry
	{
		_vehicleName = 'Unknown Vehicle';
		if ((typeName (_x getVariable 'vehicleName')) == 'STRING')
		then
		{
			_vehicleName = (_x getVariable 'vehicleName');
		};
		_vehicleDriver = '';
		if (!(isNull (driver _x)))
		then
		{
			if (alive (driver _x))
			then
			{
				_vehicleDriver = format [' (%1)', name (driver _x)];
			};
		};
		_vehicleIconColour = mapGraphicsPlayerTeamColour;
		if (!(alive _x))
		then
		{
			_vehicleIconColour = colourTeamMapDrawingsDeceased;
		};
		(_this select 0) drawIcon ['\A3\ui_f\data\map\markers\nato\b_inf.paa', _vehicleIconColour, position _x, 29, 29, 0, format ['%1%2', _vehicleName, _vehicleDriver], 0, 0.04 / (getResolution select 5), 'PuristaMedium', 'right'];
	} forEach (missionNamespace getVariable (format ['vehicles%1', personalTeamLiteral]));
	_objectives = missionNamespace getVariable (format ['objectives%1', personalTeamLiteral]);
	_knownBases = missionNamespace getVariable (format ['knownBases%1', personalTeamLiteral]);
	_knownFOBs = missionNamespace getVariable (format ['knownFOBs%1', personalTeamLiteral]);
	{
		_teamColour = colourTeamMapDrawingsBLUFOR;
		if ((_x getVariable 'team') == OPFOR)
		then
		{
			_teamColour = colourTeamMapDrawingsOPFOR;
		};
		_assetPath = 'Assets\baseIcon.paa';
		if ((_x getVariable 'type') == 'FOB')
		then
		{
			_assetPath = 'Assets\fobIcon.paa';
		};
		_textColour = [1, 1, 1, 1];
		_baseName = _x getVariable 'name';
		if (_x in _objectives)
		then
		{
			_baseName = format ['%1 (Objective)', _baseName];
			_textColour = [0, 1, 0, 1];
		};
		(_this select 0) drawIcon [missionRoot + _assetPath, _teamColour, position _x, 64, 64, 0, '', 0, 0.04 / (getResolution select 5), 'PuristaMedium', 'right'];
		(_this select 0) drawIcon ['#(argb,8,8,3)color(0,0,0,0)', _textColour, position _x, 64, 64, 0, _baseName, 2, 0.04 / (getResolution select 5), 'PuristaMedium', 'right'];
	} forEach (_knownBases + _knownFOBs);
	{
		if ((_x getVariable 'team') == (player getVariable 'team'))
		then
		{
			(_this select 0) drawIcon [missionRoot + 'Assets\roadblockIcon.paa', mapGraphicsPlayerTeamColour, position _x, 64, 64, _x getVariable 'roadblockDirection', '', 0, 0.04 / (getResolution select 5), 'PuristaMedium', 'right'];
			(_this select 0) drawIcon ['#(argb,8,8,3)color(0,0,0,0)', [1, 1, 1, 1], position _x, 64, 64, 0, (_x getVariable 'name'), 2, 0.04 / (getResolution select 5), 'PuristaMedium', 'right'];
		};
	} forEach roadblocks;
	{
		_teamColour = colourTeamMapDrawingsBLUFOR;
		if ((_x getVariable 'team') == OPFOR)
		then
		{
			_teamColour = colourTeamMapDrawingsOPFOR;
		}
		else
		{
			if ((_x getVariable 'team') == Independent)
			then
			{
				_teamColour = colourTeamMapDrawingsIndependent;
			};
		};
		(_this select 0) drawIcon [missionRoot + 'Assets\playerIcon.paa', _teamColour, (_x getVariable 'spottedObjectPosition'), 45, 45, 0, '', 0, 0.04 / (getResolution select 5), 'PuristaMedium', 'right'];
		(_this select 0) drawIcon ['#(argb,8,8,3)color(0,0,0,0)', _teamColour, (_x getVariable 'spottedObjectPosition'), 45, 45, 0, 'Hostile', 0, 0.04 / (getResolution select 5), 'PuristaMedium', 'right'];
	} forEach manualSpotObjects;

};

functionMapGraphicsTownDefence =
{
	{
		if ((typeName _x) == 'OBJECT')
		then
		{
			(_this select 0) drawIcon ['\A3\ui_f\data\map\markers\nato\b_inf.paa', [1, 1, 1, 1], position _x, 29, 29, 0, 'Soldier', 0, 0.04 / (getResolution select 5), 'PuristaMedium', 'right'];
		};
		if ((typeName _x) == 'GROUP')
		then
		{
			{
				(_this select 0) drawIcon ['\A3\ui_f\data\map\markers\nato\b_inf.paa', [1, 1, 1, 1], position _x, 29, 29, 0, 'Soldier', 0, 0.04 / (getResolution select 5), 'PuristaMedium', 'right'];
			} forEach (units _x);
		};
	} forEach townDefenceUnits;
};

functionMapGraphicsProvinces =
{
	if (!(isNil 'provinceMapTitles'))
	then
	{
		{
			_provinceTeam = (provincesStatusClient select _forEachIndex) select 1;
			_provinceActiveCoordinate = (provincesStatusClient select _forEachIndex) select 3;
			_provincePolygonPoints = _x select 2;
			_colourRGBA = [0,0,0,1];
			if (_provinceTeam == BLUFOR)
			then
			{
				_colourRGBA = [0,0,1,1];
			};
			if (_provinceTeam == OPFOR)
			then
			{
				_colourRGBA = [1,0,0,1];
			};
			[_provincePolygonPoints, _colourRGBA, _this select 0] call functionDrawPolygonOnMap;
			_provinceMapTitle = provinceMapTitles select _forEachIndex;
			_provinceMapTitleCoordinate = _provinceMapTitle select 1;
			_provinceMapTitleText = _provinceMapTitle select 2;
			(_this select 0) drawIcon ['#(argb,8,8,3)color(0,0,0,0)', [0, 0, 0, 1], _provinceMapTitleCoordinate, 29, 29, 0, _provinceMapTitleText, 0, 0.04 / (getResolution select 5), 'PuristaMedium', 'center'];
			if (typeName _provinceActiveCoordinate == 'ARRAY')
			then
			{
				(_this select 0) drawIcon [missionRoot + 'Assets\resistanceIcon.paa', [1, 1, 1, 1], _provinceActiveCoordinate, 64, 64, 0, 'Resistance', 2, 0.04 / (getResolution select 5), 'PuristaMedium', 'right'];
			};
		} forEach provinces;
	};
};

functionDrawPolygonOnMap =
{
	_polygonPoints = _this select 0;
	_colourRGBA = _this select 1;
	if (count _polygonPoints < 3)
	then
	{
		diag_log 'Error: functionDrawPolygonOnMap requires at least three polygon points.'
	}
	else
	{
		{
			_position3DOne = _x;
			_position3DTwo = false;
			if (_forEachIndex == (count _polygonPoints) - 1)
			then
			{
				_position3DTwo = _polygonPoints select 0;
			}
			else
			{
				_position3DTwo = _polygonPoints select (_forEachIndex + 1);
			};
			(_this select 2) drawLine [_position3DOne, _position3DTwo, _colourRGBA];
		} forEach _polygonPoints;
	};
};

functionToggleOperationalHUD =
{
	if (isNil 'operationalHUDEnabled')
	then
	{
		operationalHUDEnabled = false;
	};
	if (operationalHUDEnabled)
	then
	{
		operationalHUDEnabled = false;
		['operationalHUDFrameEvent', 'onEachFrame'] call BIS_fnc_removeStackedEventHandler;
		systemChat 'Operational HUD disabled.';
	}
	else
	{
		operationalHUDEnabled = true;
		['operationalHUDFrameEvent', 'onEachFrame', {call functionOperationalHUDFrameEvent;}] call BIS_fnc_addStackedEventHandler;
		systemChat 'Operational HUD enabled.';
	};
};

functionOperationalHUDFrameEvent =
{
	{
		if ((side _x) == (player getVariable 'team'))
		then
		{
			if (isPlayer _x)
			then
			{
				if (!(_x getVariable 'respawning'))
				then
				{
					{
						if (_x != player)
						then
						{
							_position = [_x] call functionGetRealVisualPosition;
							_position set [2, (_position select 2) + standardUnitHeight];
							_unitName = format ['%1 %2', name _x, ([(position player) distance (position _x)] call functionGetNumberAsMetre)];
							if (!(isPlayer _x))
							then
							{
								_unitName = format ["%1's AI %2 (%3, %4)", name (leader (group _x)), ([(position player) distance (position _x)] call functionGetNumberAsMetre), [name _x] call functionGetLastName, [typeOf _x] call functionGetLiteralInitialForUnitType];
							};
							drawIcon3D ['#(argb,8,8,3)color(0,0,0,0)', mapGraphicsPlayerTeamColour, _position, 1, 1, 0, _unitName, 1, 0.03, 'PuristaMedium'];
						};
					} forEach units (group _x);
				};
			};
		};
	} forEach playableUnits;
	{
		_teamColour = colourTeamMapDrawingsBLUFOR;
		if ((_x getVariable 'team') == OPFOR)
		then
		{
			_teamColour = colourTeamMapDrawingsOPFOR;
		}
		else
		{
			if ((_x getVariable 'team') == Independent)
			then
			{
				_teamColour = colourTeamMapDrawingsIndependent;
			};
		};
		_boundingBox = boundingBox _x;
		_spottedObjectPosition = +(_x getVariable 'spottedObjectPosition');
		_spottedObjectPosition set [2, (_spottedObjectPosition select 2) + (abs (((_boundingBox select 0) select 2) - ((_boundingBox select 1) select 2)))];
		drawIcon3D [missionRoot + 'Assets\spottedHUDIcon.paa', _teamColour, _spottedObjectPosition, 1, 1, 0, 'Hostile', 1, 0.03, 'PuristaMedium'];
	} forEach manualSpotObjects;
	// Consider 3D base markers
};