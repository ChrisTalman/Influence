functionManageRoadblocks =
{
	if (({(_x getVariable 'team') == (player getVariable 'team')} count playerControlledBases) == 0)
	then
	{
		hint parseText 'There are no bases to deploy roadblocks from!';
	}
	else
	{
		closeDialog 0;
		openMap true;
		hint parseText 'Left-click on a base for a new roadblock construction vehicle to be deployed from.';
		manageRoadblocksStage = 'baseSelection';
		manageRoadblocksSelectedBase = objNull;
		plannedRoadblocksPositions = [];
		plannedRoadblocksMapMarkerIDs = [];
		['manageRoadblocksMapClickEvent', 'onMapSingleClick', {[_pos, _shift] call functionHandleManageRoadblocksMapClick;}] call BIS_fnc_addStackedEventHandler;
		[] spawn functionHandleManageRoadblocksMapClosure;
		[[player], 'functionHandleGetPlannedRoadblocksRequest', false] call BIS_fnc_MP;
	};
};

functionHandleManageRoadblocksMapClick =
{
	_position = _this select 0;
	_position2D = [_position select 0, _position select 1];
	if (manageRoadblocksStage in ['baseSelection', 'baseConfirmation'])
	then
	{
		{
			if ((_x getVariable 'team') == side player)
			then
			{
				if (((position _x) distance _position2D) <= baseRadius)
				then
				{
					if (manageRoadblocksStage == 'baseSelection' or (manageRoadblocksStage == 'baseConfirmation' and manageRoadblocksSelectedBase != _x))
					then
					{
						if ((_x getVariable 'supplyAmount') >= auxiliaryRoadblockSupplyCost)
						then
						{
							manageRoadblocksSelectedBase = _x;
							manageRoadblocksStage = 'baseConfirmation';
							hint format ['The base you have selected has %1 supply. %2 is needed for a roadblock. If you would like to proceed, please left-click the same base once more.', (manageRoadblocksSelectedBase getVariable 'supplyAmount'), auxiliaryRoadblockSupplyCost];
						}
						else
						{
							hint parseText format ['<t color="#D00000">The base you have selected has insufficent supply. %1 is needed for a roadblock. Please select an alternative base.</t><br/><br/>Left-click on a base for a new roadblock construction vehicle to be deployed from.', auxiliaryRoadblockSupplyCost];
						};
					}
					else
					{
						if (manageRoadblocksStage == 'baseConfirmation' and manageRoadblocksSelectedBase == _x)
						then
						{
							manageRoadblocksStage = 'placement';
							hint 'Left-click on a road to select the location for a new roadblock.';
						};
					};
				};
			};
		} forEach playerControlledBases;
	}
	else
	{
		if (manageRoadblocksStage == 'placement')
		then
		{
			_roadSegments = _position nearRoads 10;
			if ((count _roadSegments) > 0)
			then
			{
				_road = _roadSegments select 0;
				manageRoadblocksNewRoadblockRoad = _road;
				_positionExclusive = true;
				{
					if ((_x getVariable 'team') == side player)
					then
					{
						if ((_position distance (position _x)) <= auxiliaryRoadblockExclusiveEstablishmentRadius)
						then
						{
							_positionExclusive = false;
						};
					};
				} forEach roadblocks;
				{
					if ((_position distance _x) <= auxiliaryRoadblockExclusiveEstablishmentRadius)
					then
					{
						_positionExclusive = false;
					};
				} forEach plannedRoadblocksPositions;
				if (_positionExclusive)
				then
				{
					[_road] call functionOpenRoadblockDirectionWindow;
					//hint 'Processing location selection...';
					//[[_position2D, manageRoadblocksSelectedBase, player], 'functionValidateRoadblockMissionServer', false] call BIS_fnc_MP;
				}
				else
				{
					hint parseText '<t color="#D00000">The location you have selected is within the exlusive radius of another roadblock.</t><br/><br/>Left-click on a road to select the location for a new roadblock.';
				};
			};
		}
		else
		{
			if (manageRoadblocksStage == 'serverValidation')
			then
			{
				hint 'Processing location selection...';
			};
		};
	};
};

functionOpenRoadblockDirectionWindow =
{
	private ['_road'];
	_road = _this select 0;
	_roadConnectedTo = roadsConnectedTo _road;
	_connectedRoad = _roadConnectedTo select 0;
	_roadDirection = [_road, _connectedRoad] call BIS_fnc_DirTo;
	_roadCoordinates = [_road modelToWorld ((boundingBoxReal _road) select 0), _road modelToWorld ((boundingBoxReal _road) select 1)];
	_roadDirectionOpposite = 'undefined';
	_firstOptionButtonText = 'undefined';
	_secondOptionButtonText = 'undefined';
	if (_roadDirection > 180)
	then
	{
		_roadDirectionOpposite = _roadDirection - 180;
	}
	else
	{
		_roadDirectionOpposite = _roadDirection + 180;
	};
	_firstOptionButtonText = [_roadDirection] call functionGetAngleAsCardinalDirection;
	_secondOptionButtonText = [_roadDirectionOpposite] call functionGetAngleAsCardinalDirection;
	createDialog 'nwDialogueRoadblockDirectionSelection';
	ctrlSetText [9000, _firstOptionButtonText];
	ctrlSetText [9001, _secondOptionButtonText];
	buttonSetAction [9000, format ['[%1, %2] call functionAddRoadblockMissionClient; closeDialog 0;', position _road, _roadDirection]];
	buttonSetAction [9001, format ['[%1, %2] call functionAddRoadblockMissionClient; closeDialog 0;', position _road, _roadDirectionOpposite]];
};

functionAddRoadblockMissionClient =
{
	_position = _this select 0;
	_roadblockDirection = _this select 1;
	hint 'Processing location selection...';
	[[_position, _roadblockDirection, manageRoadblocksNewRoadblockRoad, manageRoadblocksSelectedBase, player], 'functionValidateRoadblockMissionServer', false] call BIS_fnc_MP;
};

functionHandleGetPlannedRoadblocksResponse =
{
	plannedRoadblocksPositions = _this select 0;
	call functionClearManageRoadblocksMapMarkers;
	{
		([_forEachIndex] + _x) call functionPlannedRoadblockCreateMarker;
		plannedRoadblocksMapMarkerIDs pushBack _forEachIndex;
	} forEach plannedRoadblocksPositions;
};

functionManageRoadblocksCloseMap =
{
	openMap false;
	hint 'Roadblock mission created successfully.';
};

functionHandleManageRoadblocksMapClosure =
{ 
	waitUntil {!(visibleMap)};
	hint '';
	['manageRoadblocksMapClickEvent', 'onMapSingleClick'] call BIS_fnc_removeStackedEventHandler;
	call functionClearManageRoadblocksMapMarkers;
};

functionClearManageRoadblocksMapMarkers =
{
	{
		deleteMarkerLocal (format ['%1VisualMapMarker', _x]);
		deleteMarkerLocal (format ['%1VisualTextMapMarker', _x]);
	} forEach plannedRoadblocksMapMarkerIDs;
};

functionPlannedRoadblockCreateMarker =
{
	_id = _this select 0;
	_position = _this select 1;
	_angle = _this select 2;
	_visualMapMarker = createMarkerLocal [format ['%1VisualMapMarker', _id], _position];
	_visualMapMarker setMarkerShapeLocal 'RECTANGLE';
	_visualMapMarker setMarkerSizeLocal [10, 3];
	_visualMapMarker setMarkerDirLocal _angle;
	_visualMapMarker setMarkerColorLocal 'ColorBlue';
	_visualMapMarker setMarkerBrushLocal 'FDiagonal';
};

functionRoadblockCreateMarker =
{
	private ['_id', '_position', '_angle', '_name', '_colourName', '_visualMapMarker'];
	_id = _this select 0;
	_position = _this select 1;
	_angle = _this select 2;
	_colourName = _this select 3;
	_name = _this select 4;
	_visualMapMarker = createMarkerLocal [format ['%1VisualMapMarker', _id], _position];
	_visualMapMarker setMarkerShapeLocal 'RECTANGLE';
	_visualMapMarker setMarkerSizeLocal [10, 3];
	_visualMapMarker setMarkerDirLocal _angle;
	_visualMapMarker setMarkerColorLocal _colourName;
	_visualMapMarker setMarkerBrushLocal 'SOLID';
	_visualTextMapMarker = createMarkerLocal [format ['%1VisualTextMapMarker', _id], _position];
	_visualTextMapMarker setMarkerTypeLocal 'EmptyIcon';
	_visualTextMapMarker setMarkerTextLocal _name;
	_visualTextMapMarker setMarkerColorLocal 'ColorWhite';
};

functionHandleNewRoadblock =
{
	_roadblock = _this select 0;
	//[_roadblock getVariable 'id', position _roadblock, _roadblock getVariable 'roadblockDirection', ([player getVariable 'team'] call functionGetTeamMapMarkerColourName), _roadblock getVariable 'name'] call functionRoadblockCreateMarker;
};

functionHandleRoadblockAttack =
{
	_roadblock = _this select 0;
	_nearestBase = [position _roadblock, true] call functionFindNearestBase;
	_attackMessage = format ['%1 attacked. (Near %2)', _roadblock getVariable 'name', _nearestBase getVariable 'name'];
	sleep auxiliaryRoadblockAttackNotificationDelay;
	['NotificationNegative', ['Roadblock Attacked', _attackMessage]] call BIS_fnc_showNotification;
	sleep (auxiliaryRoadblockDespawnMapMarkerDelay - auxiliaryRoadblockAttackNotificationDelay);
	deleteMarkerLocal (format ['%1VisualMapMarker', _roadblock getVariable 'id']);
	deleteMarkerLocal (format ['%1VisualTextMapMarker', _roadblock getVariable 'id']);
};