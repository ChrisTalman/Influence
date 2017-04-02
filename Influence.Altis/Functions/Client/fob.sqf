functionEstablishFOBClient =
{
	if ({_x getVariable 'team' == side player} count playerControlledBases == 0)
	then
	{
		hint 'There are no bases to deploy FOBs from!';
	}
	else
	{
		closeDialog 0;
		openMap true;
		hint parseText 'Left-click on a base for a new Forward Operating Base construction vehicle to be deployed from.';
		establishFOBStage = 'baseSelection';
		establishFOBSelectedBase = objNull;
		plannedFOBsPositions = [];
		plannedFOBsMapMarkerIDs = [];
		['establishFOBMapClickEvent', 'onMapSingleClick', {[_pos, _shift] call functionHandleEstablishFOBMapClick;}] call BIS_fnc_addStackedEventHandler;
		[] spawn functionHandleEstablishFOBMapClosure;
		[[player], 'functionHandleGetPlannedFOBsRequest', false] call BIS_fnc_MP;
	};
};

functionHandleEstablishFOBMapClick =
{
	_position = _this select 0;
	_position2D = [_position select 0, _position select 1];
	if (establishFOBStage in ['baseSelection', 'baseConfirmation'])
	then
	{
		{
			if ((_x getVariable 'team') == side player)
			then
			{
				if (((position _x) distance _position2D) <= baseRadius)
				then
				{
					if (establishFOBStage == 'baseSelection' or (establishFOBStage == 'baseConfirmation' and establishFOBSelectedBase != _x))
					then
					{
						if ((_x getVariable 'supplyAmount') >= FOBSupplyCost)
						then
						{
							establishFOBSelectedBase = _x;
							establishFOBStage = 'baseConfirmation';
							hint format ['The base you have selected has %1 supply. %2 is needed for a FOB. If you would like to proceed, please left-click the same base once more.', (establishFOBSelectedBase getVariable 'supplyAmount'), FOBSupplyCost];
						}
						else
						{
							hint parseText format ['<t color="#D00000">The base you have selected has insufficent supply. %1 is needed for a FOB. Please select an alternative base.</t><br/><br/>Left-click on a base for a new Forward Operating Base construction vehicle to be deployed from.', FOBSupplyCost];
						};
					}
					else
					{
						if (establishFOBStage == 'baseConfirmation' and establishFOBSelectedBase == _x)
						then
						{
							establishFOBStage = 'FOBPlacement';
							hint 'Left-click on a part of the map to select the location for a new Forward Operating Base.';
						};
					};
				};
			};
		} forEach playerControlledBases;
	}
	else
	{
		if (establishFOBStage == 'FOBPlacement')
		then
		{
			_positionExclusive = true;
			{
				if ((_x getVariable 'team') == side player)
				then
				{
					if ((_position distance (position _x)) <= FOBExclusiveEstablishmentRadius)
					then
					{
						_positionExclusive = false;
					};
				};
			} forEach FOBs;
			{
				if ((_position distance _x) <= FOBExclusiveEstablishmentRadius)
				then
				{
					_positionExclusive = false;
				};
			} forEach plannedFOBsPositions;
			if (_positionExclusive)
			then
			{
				hint 'Processing location selection...';
				[[_position2D, establishFOBSelectedBase, player], 'functionEstablishFOBServer', false] call BIS_fnc_MP;
			}
			else
			{
				hint parseText '<t color="#D00000">The location you have selected is within the exlusive radius of another FOB.</t><br/><br/>Left-click on a part of the map to select the location for a new Forward Operating Base.';
			};
		}
		else
		{
			if (establishFOBStage == 'serverValidation')
			then
			{
				hint 'Processing location selection...';
			};
		};
	};
};

functionHandleGetPlannedFOBsResponse =
{
	plannedFOBsPositions = _this select 0;
	call functionClearPlannedFOBsMapMarkers;
	{
		[_forEachIndex, _x] call functionPlannedFOBCreateMarker;
		plannedFOBsMapMarkerIDs pushBack _forEachIndex;
	} forEach plannedFOBsPositions;
};

functionEstablishFOBCloseMap =
{
	openMap false;
	hint 'FOB mission created successfully.';
};

functionHandleEstablishFOBMapClosure =
{ 
	waitUntil {!(visibleMap)};
	hint '';
	['establishFOBMapClickEvent', 'onMapSingleClick'] call BIS_fnc_removeStackedEventHandler;
	call functionClearPlannedFOBsMapMarkers;
};

functionClearPlannedFOBsMapMarkers =
{
	{
		deleteMarkerLocal (format ['%1VisualMapMarker', _x]);
		deleteMarkerLocal (format ['%1VisualTextMapMarker', _x]);
	} forEach plannedFOBsMapMarkerIDs;
};

functionPlannedFOBCreateMarker =
{
	_id = _this select 0;
	_position = _this select 1;
	_visualMapMarker = createMarkerLocal [format ['%1VisualMapMarker', _id], _position];
	_visualMapMarker setMarkerShapeLocal 'ELLIPSE';
	_visualMapMarker setMarkerBrushLocal 'FDiagonal';
	_visualMapMarker setMarkerSizeLocal [FOBRadius, FOBRadius];
	_visualMapMarker setMarkerColorLocal 'ColorBlue';
	_visualTextMapMarker = createMarkerLocal [format ['%1VisualTextMapMarker', _id], _position];
	_visualTextMapMarker setMarkerTypeLocal 'EmptyIcon';
	_visualTextMapMarker setMarkerTextLocal 'Planned FOB';
	_visualTextMapMarker setMarkerColorLocal 'ColorWhite';
};

functionHandleNewFOB =
{
	_name = _this select 1;
	_mapMarkerColourName = [player getVariable 'team'] call functionGetTeamMapMarkerColourName;
	//(_this + [_mapMarkerColourName]) call functionRegisterFOBCreateMarker;
	_newFOBMessage = format ['New FOB %1 has been established.', _name];
	['NotificationPositive', ['New FOB', _newFOBMessage]] call BIS_fnc_showNotification;
};

functionRegisterFOBCreateMarker =
{
	waitUntil {!(isNull player) and hasInterface and !(isNull (findDisplay screenDisplayID)) and !(isNull (findDisplay mapDisplayID))};
	_id = _this select 0;
	_name = _this select 1;
	_position = _this select 2;
	_colourName = _this select 3;
	_visualMapMarker = createMarkerLocal [format ['%1VisualMapMarker', _id], _position];
	_visualMapMarker setMarkerShapeLocal 'ELLIPSE';
	_visualMapMarker setMarkerBrushLocal 'SOLID';
	_visualMapMarker setMarkerSizeLocal [FOBRadius, FOBRadius];
	_visualMapMarker setMarkerColorLocal _colourName;
	_visualTextMapMarker = createMarkerLocal [format ['%1VisualTextMapMarker', _id], _position];
	_visualTextMapMarker setMarkerTypeLocal 'EmptyIcon';
	_visualTextMapMarker setMarkerTextLocal format ['%1', _name];
	_visualTextMapMarker setMarkerColorLocal 'ColorWhite';
};

functionHandleFOBPlanningError =
{
	hint parseText '<t color="#D00000">Unfortunately, an error has occurred. Please try again.</t>';
};