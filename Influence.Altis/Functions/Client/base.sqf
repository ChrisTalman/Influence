functionEstablishBaseClient =
{
	closeDialog 0;
	_firstBaseEstablished = missionNamespace getVariable (format ['firstBaseEstablished%1', [side player] call functionGetTeamFORName]);
	if (_firstBaseEstablished)
	then
	{
		openMap true;
		hint parseText 'Left-click on a base for a new base construction vehicle to be deployed from.';
		establishBaseStage = 'baseSelection';
		establishBaseSelectedBase = objNull;
		plannedBasesPositions = [];
		plannedBasesMapMarkerIDs = [];
		['establishBaseMapClickEvent', 'onMapSingleClick', {[_pos, _shift] call functionHandleEstablishBaseMapClick;}] call BIS_fnc_addStackedEventHandler;
		[] spawn functionHandleEstablishBaseMapClosure;
		[[player], 'functionHandleGetPlannedBasesRequest', false] call BIS_fnc_MP;
	}
	else
	{
		call functionEstablishFirstBaseClient;
	};
};

functionHandleEstablishBaseMapClick =
{
	_position = _this select 0;
	_position2D = [_position select 0, _position select 1];
	if (establishBaseStage in ['baseSelection', 'baseConfirmation'])
	then
	{
		{
			if ((_x getVariable 'team') == side player)
			then
			{
				if (((position _x) distance _position2D) <= baseRadius)
				then
				{
					if (establishBaseStage == 'baseSelection' or (establishBaseStage == 'baseConfirmation' and establishBaseSelectedBase != _x))
					then
					{
						if ((_x getVariable 'supplyAmount') >= baseSupplyCost)
						then
						{
							establishBaseSelectedBase = _x;
							establishBaseStage = 'baseConfirmation';
							hint format ['The base you have selected has %1 supply. %2 is needed for a base. If you would like to proceed, please left-click the same base once more.', (establishBaseSelectedBase getVariable 'supplyAmount'), baseSupplyCost];
						}
						else
						{
							hint parseText format ['<t color="#D00000">The base you have selected has insufficent supply. %1 is needed for a base. Please select an alternative base.</t><br/><br/>Left-click on a base for a new base construction vehicle to be deployed from.', baseSupplyCost];
						};
					}
					else
					{
						if (establishBaseStage == 'baseConfirmation' and establishBaseSelectedBase == _x)
						then
						{
							establishBaseStage = 'basePlacement';
							hint 'Left-click on a part of the map to select the location for a new base.';
						};
					};
				};
			};
		} forEach playerControlledBases;
	}
	else
	{
		if (establishBaseStage == 'basePlacement')
		then
		{
			_positionExclusive = true;
			{
				if ((_x getVariable 'team') == side player)
				then
				{
					if ((_position distance (position _x)) <= baseExclusiveEstablishmentRadius)
					then
					{
						_positionExclusive = false;
					};
				};
			} forEach playerControlledBases;
			{
				if ((_position distance _x) <= baseExclusiveEstablishmentRadius)
				then
				{
					_positionExclusive = false;
				};
			} forEach plannedBasesPositions;
			if (_positionExclusive)
			then
			{
				hint 'Processing location selection...';
				[[_position2D, establishBaseSelectedBase, player], 'functionEstablishBaseServer', false] call BIS_fnc_MP;
			}
			else
			{
				hint parseText '<t color="#D00000">The location you have selected is within the exlusive radius of another base.</t><br/><br/>Left-click on a part of the map to select the location for a new base.';
			};
		}
		else
		{
			if (establishBaseStage == 'serverValidation')
			then
			{
				hint 'Processing location selection...';
			};
		};
	};
};

functionHandleGetPlannedBasesResponse =
{
	plannedBasesPositions = _this select 0;
	call functionClearPlannedBasesMapMarkers;
	{
		[_forEachIndex, _x] call functionPlannedBaseCreateMarker;
		plannedBasesMapMarkerIDs pushBack _forEachIndex;
	} forEach plannedBasesPositions;
};

functionEstablishBaseCloseMap =
{
	openMap false;
	hint 'Base mission created successfully.';
};

functionHandleEstablishBaseMapClosure =
{ 
	waitUntil {!(visibleMap)};
	hint '';
	['establishBaseMapClickEvent', 'onMapSingleClick'] call BIS_fnc_removeStackedEventHandler;
	call functionClearPlannedBasesMapMarkers;
};

functionClearPlannedBasesMapMarkers =
{
	{
		deleteMarkerLocal (format ['%1VisualMapMarker', _x]);
		deleteMarkerLocal (format ['%1VisualTextMapMarker', _x]);
	} forEach plannedBasesMapMarkerIDs;
};

functionPlannedBaseCreateMarker =
{
	_id = _this select 0;
	_position = _this select 1;
	_visualMapMarker = createMarkerLocal [format ['%1VisualMapMarker', _id], _position];
	_visualMapMarker setMarkerShapeLocal 'ELLIPSE';
	_visualMapMarker setMarkerBrushLocal 'FDiagonal';
	_visualMapMarker setMarkerSizeLocal [baseRadius, baseRadius];
	_visualMapMarker setMarkerColorLocal 'ColorBlue';
	_visualTextMapMarker = createMarkerLocal [format ['%1VisualTextMapMarker', _id], _position];
	_visualTextMapMarker setMarkerTypeLocal 'EmptyIcon';
	_visualTextMapMarker setMarkerTextLocal 'Planned Base';
	_visualTextMapMarker setMarkerColorLocal 'ColorWhite';
};

functionHandleNewBase =
{
	_name = _this select 1;
	_firstBaseEstablished = missionNamespace getVariable (format ['firstBaseEstablished%1', [player getVariable 'team'] call functionGetTeamFORName]);
	if (!(_firstBaseEstablished))
	then
	{
		missionNamespace setVariable [format ['firstBaseEstablished%1', [player getVariable 'team'] call functionGetTeamFORName], true];
	};
	_mapMarkerColourName = [player getVariable 'team'] call functionGetTeamMapMarkerColourName;
	//(_this + [_mapMarkerColourName]) call functionRegisterBaseCreateMarker;
	_newBaseMessage = format ['%1 has been established.', _name];
	['NotificationPositive', ['New Base', _newBaseMessage]] call BIS_fnc_showNotification;
};

functionRegisterBaseCreateMarker =
{
	waitUntil {!(isNull player) and hasInterface and !(isNull (findDisplay screenDisplayID)) and !(isNull (findDisplay mapDisplayID))};
	_id = _this select 0;
	_name = _this select 1;
	_position = _this select 2;
	_colourName = _this select 3;
	_visualMapMarker = createMarkerLocal [format ['%1VisualMapMarker', _id], _position];
	_visualMapMarker setMarkerShapeLocal 'ELLIPSE';
	_visualMapMarker setMarkerBrushLocal 'SOLID';
	_visualMapMarker setMarkerSizeLocal [baseRadius, baseRadius];
	_visualMapMarker setMarkerColorLocal _colourName;
	_visualTextMapMarker = createMarkerLocal [format ['%1VisualTextMapMarker', _id], _position];
	_visualTextMapMarker setMarkerTypeLocal 'EmptyIcon';
	_visualTextMapMarker setMarkerTextLocal format ['%1', _name];
	_visualTextMapMarker setMarkerColorLocal 'ColorWhite';
};

functionHandleBasePlanningError =
{
	hint parseText '<t color="#D00000">Unfortunately, an error has occurred. Please try again.</t>';
};

functionHandleBaseNeutralisation =
{
	_baseObject = _this select 0;
	_neutralisationMessage = format ['%1 neutralised. Facilities disabled.', _baseObject getVariable 'name'];
	['NotificationNegative', ['Base Neutralised', _neutralisationMessage]] call BIS_fnc_showNotification;
};

functionHandleBaseNoLongerContested =
{
	_baseObject = _this select 0;
	_message = format ['%1 no longer contested. Facilities functional.', _baseObject getVariable 'name'];
	['NotificationPositive', ['Base Secure', _message]] call BIS_fnc_showNotification;
};

functionHandleBaseGain =
{
	_gainMessage = _this select 0;
	_baseObject = _this select 1;
	_newBaseName = _this select 2;
	//[_baseObject getVariable 'id', _newBaseName, position _baseObject, [player getVariable 'team'] call functionGetTeamMapMarkerColourName] call functionRegisterBaseCreateMarker;
	['NotificationPositive', ['Base Captured', _gainMessage]] call BIS_fnc_showNotification;
};

functionHandleBaseLoss =
{
	_lossMessage = _this select 0;
	_baseObject = _this select 1;
	deleteMarkerLocal format ['%1VisualMapMarker', _baseObject getVariable 'id'];
	deleteMarkerLocal format ['%1VisualTextMapMarker', _baseObject getVariable 'id'];
	['NotificationNegative', ['Base Lost', _lossMessage]] call BIS_fnc_showNotification;
};

functionPopulateBaseList =
{
	// Argument 1: list control IDC. Argument 2: team. Argument 3: Base object (or array of base objects) to ignore. Argument 4: Base object to select. Argument 5: Include FOBs. Argument 6: Override list control clear.
	_listControlIDC = _this select 0;
	_team = _this select 1;
	_ignoreBaseObject = objNull;
	_selectBaseObject = objNull;
	_selectBaseIndexInList = 0;
	_includeFOBs = false;
	_basesAndFOBs = playerControlledBases;
	_overrideListClear = false;
	if ((count _this) > 2)
	then
	{
		_ignoreBaseObject = _this select 2;
	};
	if ((count _this) > 3)
	then
	{
		_selectBaseObject = _this select 3;
	};
	if ((count _this) > 4)
	then
	{
		_includeFOBs = _this select 4;
	};
	if ((count _this) > 5)
	then
	{
		_overrideListClear = _this select 4;
	};
	if (!(_overrideListClear))
	then
	{
		lbClear _listControlIDC;
	};
	if (_includeFOBs)
	then
	{
		_basesAndFOBs = (playerControlledBases + FOBs);
	};
	{
		if ((_x getVariable 'team') == _team)
		then
		{
			_includeCurrentBaseObject = true;
			if ((typeName _ignoreBaseObject == 'ARRAY'))
			then
			{
				if (_x in _ignoreBaseObject)
				then
				{
					_includeCurrentBaseObject = false;
				};
			};
			if ((typeName _ignoreBaseObject == 'OBJECT'))
			then
			{
				if (_x == _ignoreBaseObject)
				then
				{
					_includeCurrentBaseObject = false;
				};
			};
			if (_includeCurrentBaseObject)
			then
			{
				_indexInList = lbAdd [_listControlIDC, (_x getVariable 'name')];
				lbSetData [_listControlIDC, _indexInList, (_x getVariable 'id')];
				if ((count _this) > 3 and !(isNull _selectBaseObject))
				then
				{
					if (_x == _selectBaseObject)
					then
					{
						_selectBaseIndexInList = _indexInList;
					};
				};
			};
		};
	} forEach _basesAndFOBs;
	if ((count _this) > 3 and !(isNull _selectBaseObject))
	then
	{
		lbSetCurSel [_listControlIDC, _selectBaseIndexInList];
	}
	else
	{
		if ((count playerControlledBases) > 0)
		then
		{
			lbSetCurSel [_listControlIDC, 0];
		};
	};
};

functionFindNearestBase =
{
	private ['_position', '_includeFOBs', '_nearestBaseOrFOB', '_nearestBaseOrFOBDistance'];
	_position = _this select 0;
	_includeFOBs = false;
	_nearestBaseOrFOB = objNull;
	_nearestBaseOrFOBDistance = 0;
	_basesAndFOBs = playerControlledBases;
	if ((count _this) > 1)
	then
	{
		_includeFOBs = _this select 1;
	};
	if (_includeFOBs)
	then
	{
		_basesAndFOBs = playerControlledBases + FOBs;
	};
	{
		if (_forEachIndex == 0)
		then
		{
			_nearestBaseOrFOBDistance = _position distance (position _x);
			_nearestBaseOrFOB = _x;
		}
		else
		{
			_currentBaseOrFOBDistance = _position distance (position _x);
			if (_currentBaseOrFOBDistance < _nearestBaseOrFOBDistance)
			then
			{
				_nearestBaseOrFOBDistance = _currentBaseOrFOBDistance;
				_nearestBaseOrFOB = _x;
			};
		};
	} forEach _basesAndFOBs;
	_nearestBaseOrFOB;
};

functionEstablishFirstBaseEstablished =
{
	_firstBaseEstablished = _this select 0;
	missionNamespace setVariable [format ['firstBaseEstablished%1', [player getVariable 'team'] call functionGetTeamFORName], _firstBaseEstablished];
};

functionEstablishFirstBaseClient =
{
	if (([side player] call functionIsBaseWithinExclusiveRadiusOfAnother))
	then
	{
		hint format ['Cannot establish base within %1m of another.', baseExclusiveEstablishmentRadius];
	}
	else
	{
		[[([player] call functionGetPosition2D), player], 'functionEstablishFirstBaseServer', false] call BIS_fnc_MP;
	};
};

functionIsBaseWithinExclusiveRadiusOfAnother =
{
	_team = _this select 0;
	_anotherBaseWithinExclusiveEstablishmentRadius = false;
	{
		if ((_x getVariable "team") == _team)
		then
		{
			if ((([player] call functionGetPosition2D) distance ([_x] call functionGetPosition2D)) <= baseExclusiveEstablishmentRadius)
			then
			{
				_anotherBaseWithinExclusiveEstablishmentRadius = true;
			};
		};
	} forEach playerControlledBases;
	_anotherBaseWithinExclusiveEstablishmentRadius;
};

functionHandleBaseCaptureUpdate =
{
	private ['_control', '_progressBarClassName'];
	_control = _this select 0;
	_defendingTeam = _this select 1;
	_attackingTeam = _this select 2;
	_defendingTeamLiteral = [_defendingTeam] call functionGetTeamFORName;
	_attackingTeamLiteral = [_attackingTeam] call functionGetTeamFORName;
	if (!(isNil 'captureProgressBarDelayedRemoval'))
	then
	{
		terminate captureProgressBarDelayedRemoval;
	};
	_progressBarClassName = 'undefined';
	_facilitiesNeutralisedText = '';
	if (_control > 0)
	then
	{
		_progressBarClassName = format ['progressBar%1', _defendingTeamLiteral];
	};
	if (_control <= 0)
	then
	{
		_progressBarClassName = format ['progressBar%1', _attackingTeamLiteral];
		_facilitiesNeutralisedText = ' (Facilities Neutralised)';
	};	
	('progressBarLayer' call BIS_fnc_rscLayer) cutRsc [_progressBarClassName, 'PLAIN', 0, false];
	_progressPosition = abs (_control) / 100;
	(uiNamespace getVariable 'captureProgressBar') progressSetPosition _progressPosition;
	(uiNamespace getVariable 'captureProgressBarInformation') ctrlSetStructuredText (parseText format ['<t size="2" shadow="2">%1 Attacking %2%3</t>', _attackingTeamLiteral, _defendingTeamLiteral, _facilitiesNeutralisedText]);
	captureProgressBarDelayedRemoval = [] spawn functionCaptureProgressBarDelayedRemoval;
};

functionCaptureProgressBarDelayedRemoval =
{
	sleep (baseCaptureProgressIntervalInSeconds + 2);
	('progressBarLayer' call BIS_fnc_rscLayer) cutText ['', 'PLAIN'];
};