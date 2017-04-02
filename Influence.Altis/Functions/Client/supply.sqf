functionOpenSupplyInterface =
{
	_teamLiteral = [player getVariable 'team'] call functionGetTeamFORName;
	createDialog 'nwDialogueSupply';
	[5003, side player, objNull, objNull, true] call functionPopulateBaseList;
	[5017, side player, objNull, missionNamespace getVariable format ['primaryBase%1', [side player] call functionGetTeamFORName]] call functionPopulateBaseList;
	//lbSetCurSel [5003, 0];
	ctrlSetFocus ((findDisplay 5) displayCtrl 5090);
	ctrlShow [5003, false];
	ctrlShow [5004, false];
	ctrlShow [5006, false];
	ctrlShow [5007, false];
	ctrlShow [5008, false];
	ctrlShow [5010, false];
	ctrlShow [5009, true];
	ctrlShow [5020, true];
	ctrlShow [5021, true];
	ctrlShow [5013, false];
	ctrlShow [5016, false];
	ctrlShow [5017, false];
	ctrlShow [5018, false];
	ctrlShow [5019, false];
	_quotaProportion = missionNamespace getVariable (format ['influenceIncomeQuotaProportion%1', _teamLiteral]);
	_selectedIndex = 0;
	for '_proportionIndex' from 1 to 8
	do
	{
		_percentage = _proportionIndex * 10;
		_proportion = _proportionIndex / 10;
		_index = lbAdd [5019, (format ['%1%2', _percentage, '%'])];
		lbSetData [5019, _index, str _proportion];
		if (_proportion == _quotaProportion)
		then
		{
			lbSetCurSel [5019, _index];
		};
	};
	_totalSupply = [player getVariable 'team'] call functionGetTotalSupply;
	_totalQuota = [player getVariable 'team'] call functionGetTotalQuota;
	_totalQuotaOnline = [player getVariable 'team', true] call functionGetTotalQuota;
	_mostRecentIncome = missionNamespace getVariable (format ['mostRecentRegularSupplyIncome%1', personalTeamLiteral]);
	ctrlSetText [5020, format ['Total Supply: €%1.\n Supply Income (every %2 seconds): €%3.\n Total Quota (online and offline): €%4.\n Total Quota (only online): €%5.', _totalSupply, regularSupplyIncomeInterval, _mostRecentIncome, _totalQuota, _totalQuotaOnline]];
};

functionHandleSupplyDispatchToggle =
{
	ctrlShow [5003, true];
	ctrlShow [5004, true];
	ctrlShow [5006, true];
	ctrlShow [5007, true];
	ctrlShow [5008, true];
	ctrlShow [5010, true];
	ctrlShow [5020, false];
	ctrlShow [5021, false];
	ctrlShow [5009, false];
	ctrlShow [5013, false];
	ctrlShow [5016, false];
	ctrlShow [5017, false];
	ctrlShow [5018, false];
	ctrlShow [5019, false];
};

functionHandleSupplyMonitorToggle =
{
	ctrlShow [5003, false];
	ctrlShow [5004, false];
	ctrlShow [5006, false];
	ctrlShow [5007, false];
	ctrlShow [5008, false];
	ctrlShow [5010, false];
	ctrlShow [5020, true];
	ctrlShow [5021, true];
	ctrlShow [5009, true];
	ctrlShow [5013, false];
	ctrlShow [5016, false];
	ctrlShow [5017, false];
	ctrlShow [5018, false];
	ctrlShow [5019, false];
	lbClear 5009;
	{
		_supplyPackageID = _x select 0;
		_supplyPackageName = _x select 5;
		_supplyPackageStartBaseName = ((_x select 1) getVariable "name");
		_supplyPackageDestinationBaseName = ((_x select 2) getVariable "name");
		_supplyPackageAmount = _x select 3;
		_supplyPackageRemainingRouteNodes = _x select 4;
		_supplyPackageDelivered = _x select 6;
		_supplyPackageLiteralStatus = "";
		if (_supplyPackageDelivered)
		then
		{
			_supplyPackageLiteralStatus = "Delivered";
		}
		else
		{
			_supplyPackageLiteralStatus = format ["%1 relays remaining", count _supplyPackageRemainingRouteNodes];
		};
		lbAdd [5009, format ["%1. %2 to %3. $%4. %5.", _supplyPackageName, _supplyPackageStartBaseName, _supplyPackageDestinationBaseName, _supplyPackageAmount, _supplyPackageLiteralStatus]];
	} forEach supplyPackages;
};

functionHandleSupplyRulesToggle =
{
	ctrlShow [5003, false];
	ctrlShow [5004, false];
	ctrlShow [5006, false];
	ctrlShow [5007, false];
	ctrlShow [5008, false];
	ctrlShow [5010, false];
	ctrlShow [5020, false];
	ctrlShow [5021, false];
	ctrlShow [5009, false];
	ctrlShow [5013, false];
	ctrlShow [5016, true];
	ctrlShow [5017, true];
	ctrlShow [5018, true];
	ctrlShow [5019, true];
};

functionHandleSupplyBaseSelection =
{
	_selectedBaseID = lbData [5003, (lbCurSel 5003)];
	_selectedBaseName = lbText [5003, (lbCurSel 5003)];
	_selectedBaseObject = objNull;
	{
		_baseObject = _x;
		if ((_baseObject getVariable 'id') == _selectedBaseID)
		then
		{
			_selectedBaseObject = _baseObject;
		};
	} forEach (playerControlledBases + FOBs);
	_selectedBaseSupplyAmount = (_selectedBaseObject getVariable 'supplyAmount');
	ctrlSetText [5004, format ['%1 has €%2.', _selectedBaseName, _selectedBaseSupplyAmount]];
	ctrlSetFocus ((findDisplay 5) displayCtrl 5090);
	[5007, side player, _selectedBaseObject, objNull, true] call functionPopulateBaseList;
};

functionIsBaseSupplyDispatchTimeLimitReached =
{
	// Code
};

functionDispatchSupply =
{
	_startBaseID = lbData [5003, (lbCurSel 5003)];
	_destinationBaseID = lbData [5007, (lbCurSel 5007)];
	_startBaseObject = [_startBaseID, true] call functionGetBaseObjectWithID;
	_destinationBaseObject = [_destinationBaseID, true] call functionGetBaseObjectWithID;
	diag_log format ['_startBaseObject: %1. _destinationBaseObject: %2.', _startBaseObject, _destinationBaseObject];
	_supplyAmount = parseNumber (ctrlText 5006);
	_dispatchSuccess = false;
	_dispatchFailureReason = "";
	if (isNull(_startBaseObject))
	then
	{
		_dispatchFailureReason = "startBaseUndefined";
	}
	else
	{
		if (isNull(_destinationBaseObject))
		then
		{
			_dispatchFailureReason = "destinationBaseUndefined";
		}
		else
		{
			if (_supplyAmount == 0)
			then
			{
				_dispatchFailureReason = "zeroDispatchSupply";
			}
			else
			{
				if ((_startBaseObject getVariable "supplyAmount") < _supplyAmount)
				then
				{
					_dispatchFailureReason = "insufficientSupply";
				}
				else
				{
					_routeInformation = [_startBaseObject, _destinationBaseObject] call functionFindBestSupplyRoute;
					_routeInformationRoutePossible = _routeInformation select 0;
					if (_routeInformationRoutePossible)
					then
					{
						_startBaseObject setVariable ["supplyAmount", (_startBaseObject getVariable "supplyAmount") - _supplyAmount, true];
						_startBaseObject setVariable ["unusableSupplyAmount", (_startBaseObject getVariable "unusableSupplyAmount") + _supplyAmount, true];
						if (_supplyAmount > supplyRelayStationSupplyCapacity)
						then
						{
							_supplyAmountSegmented = _supplyAmount / supplyRelayStationSupplyCapacity;
							_fullSegments = floor _supplyAmountSegmented;
							for "_segmentIndex" from 0 to (_fullSegments - 1)
							do
							{
								[[_startBaseObject, _destinationBaseObject, supplyRelayStationSupplyCapacity, _segmentIndex], "functionConductDispatchSupply", false, false, false] call BIS_fnc_MP;
							};
							_partialSegment = _supplyAmountSegmented - _fullSegments;
							_partialSegment = supplyRelayStationSupplyCapacity * _partialSegment;
							if (_partialSegment > 0)
							then
							{
								[[_startBaseObject, _destinationBaseObject, _partialSegment, _fullSegments], "functionConductDispatchSupply", false, false, false] call BIS_fnc_MP;
							};
						}
						else
						{
							[[_startBaseObject, _destinationBaseObject, _supplyAmount], "functionConductDispatchSupply", false, false, false] call BIS_fnc_MP;
						};
						_dispatchSuccess = true;
					}
					else
					{
						_dispatchFailureReason = "routeImpossible";
					};
				};
			};
		};
	};
	if (_dispatchSuccess)
	then
	{
		ctrlSetText [5010, "Supply now en route."];
		ctrlSetText [5004, format ["%1 has €%2.", (_startBaseObject getVariable "name"), (_startBaseObject getVariable "supplyAmount")]];
	}
	else
	{
		if (_dispatchFailureReason == "zeroDispatchSupply")
		then
		{
			ctrlSetText [5010, "Desired dispatch amount must be greater than zero."];
		};
		if (_dispatchFailureReason == "insufficientSupply")
		then
		{
			ctrlSetText [5010, "Insufficent supply at base to dispatch desired amount."];
		};
		if (_dispatchFailureReason == "routeImpossible")
		then
		{
			ctrlSetText [5010, "No relay stations connect this base to the desired destination base."];
		};
		if (_dispatchFailureReason == "startBaseUndefined")
		then
		{
			ctrlSetText [5010, "Base must be selected."];
		};
		if (_dispatchFailureReason == "destinationBaseUndefined")
		then
		{
			ctrlSetText [5010, "Destination base must be selected."];
		};

	};
	_returnInformation = [_dispatchSuccess, _dispatchFailureReason];
	_returnInformation;
};

functionManageSupplyRelays =
{
	closeDialog 0;
	openMap true;
	hint parseText manageSupplyRelaysStartMessage;
	manageSupplyRelaysStage = 'start';
	manageSupplyRelaysSelectedBase = objNull;
	plannedSupplyRelaysPositions = [];
	plannedSupplyRelaysMapMarkerIDs = [];
	newPlannedSupplyRelaysPositions = [];
	['establishSupplyRelaysMapClickEvent', 'onMapSingleClick', functionHandleManageSupplyRelaysMapClick] call BIS_fnc_addStackedEventHandler;
	[] spawn functionHandleManageSupplyRelaysMapClosure;
	[[player], 'functionHandleGetPlannedSupplyRelaysRequest', false] call BIS_fnc_MP;
	supplyRelaysRadiusMapMarkerIDs = [];
	{
		if ((_x getVariable 'team') == side player)
		then
		{
			[_forEachIndex, position _x] call functionSupplyRelaysRadiusCreateMarker;
			supplyRelaysRadiusMapMarkerIDs pushBack _forEachIndex;
		};
	} forEach supplyRelayStations;
};

functionHandleManageSupplyRelaysMapClick =
{
	_position = _pos;
	_shiftPressed = _shift;
	_position2D = [_position select 0, _position select 1];
	if (manageSupplyRelaysStage == 'start' and _shiftPressed)
	then
	{
		manageSupplyRelaysStage = 'removeSupplyRelay';
	};
	if (manageSupplyRelaysStage == 'start' and !(_shiftPressed))
	then
	{
		manageSupplyRelaysStage = 'baseSelection';
	};
	if (manageSupplyRelaysStage in ['baseSelection', 'baseConfirmation'])
	then
	{
		_baseSelected = false;
		{
			_currentBase = _x;
			if ((_x getVariable 'team') == side player)
			then
			{
				if (((position _x) distance _position2D) <= baseRadius)
				then
				{
					_baseSelected = true;
					if (manageSupplyRelaysStage == 'baseSelection' or (manageSupplyRelaysStage == 'baseConfirmation' and manageSupplyRelaysSelectedBase != _x))
					then
					{
						_supplySufficient = false;
						_newPlannedSupplyRelaysPositionsForBaseCount = { (_x select 1) == _currentBase } count newPlannedSupplyRelaysPositions;
						if ((_x getVariable 'supplyAmount') >= supplyRelayStationSupplyCost)
						then
						{
							if (_newPlannedSupplyRelaysPositionsForBaseCount > 0)
							then
							{
								if ((((_newPlannedSupplyRelaysPositionsForBaseCount + 1) * supplyRelayStationSupplyCost) / (_x getVariable 'supplyAmount')) <= 1)
								then
								{
									_supplySufficient = true;
								};
							}
							else
							{
								_supplySufficient = true;
							};
						};
						if (_supplySufficient)
						then
						{
							manageSupplyRelaysSelectedBase = _x;
							manageSupplyRelaysStage = 'baseConfirmation';
							hint format ['The base you have selected has €%1. €%2 is needed for a supply relay station. If you would like to proceed, please left-click the same base once more.', (manageSupplyRelaysSelectedBase getVariable 'supplyAmount'), supplyRelayStationSupplyCost];
						}
						else
						{
							_plannedMessage = '';
							if (_newPlannedSupplyRelaysPositionsForBaseCount > 0)
							then
							{
								_plannedMessage = format [' (You have planned %1, with the cumulative cost being €%2. You may need to remove some that you have planned.)', _newPlannedSupplyRelaysPositionsForBaseCount, _newPlannedSupplyRelaysPositionsForBaseCount * supplyRelayStationSupplyCost];
							};
							hint parseText format ['<t color="#D00000">The base you have selected has insufficient supply (€%1). €%2 is needed for a supply relay station%3. Please select an alternative base.</t><br/><br/>%4', (manageSupplyRelaysSelectedBase getVariable 'supplyAmount'), supplyRelayStationSupplyCost, _plannedMessage, manageSupplyRelaysStartMessage];
							manageSupplyRelaysStage = 'start';
						};
					}
					else
					{
						if (manageSupplyRelaysStage == 'baseConfirmation' and manageSupplyRelaysSelectedBase == _x)
						then
						{
							manageSupplyRelaysStage = 'supplyRelayPlacement';
							hint parseText 'Left-click on a part of the map to select the location for a new supply relay station.';
						};
					};
				};
			};
		} forEach playerControlledBases;
		if (!(_baseSelected))
		then
		{
			hint parseText manageSupplyRelaysStartMessage;
			manageSupplyRelaysStage = 'start';
		};
	}
	else
	{
		if (manageSupplyRelaysStage == 'supplyRelayPlacement')
		then
		{
			newPlannedSupplyRelaysPositions pushBack [_position2D, manageSupplyRelaysSelectedBase];
			[count plannedSupplyRelaysMapMarkerIDs, _position2D] call functionPlannedSupplyRelaysCreateMarker;
			plannedSupplyRelaysMapMarkerIDs pushBack count plannedSupplyRelaysMapMarkerIDs;
			hint parseText 'Left-click on a base for a new supply relay station construction vehicle to be deployed from.<br/><br/>Shift right-click to remove a supply relay station.';
			manageSupplyRelaysStage = 'start';
		};
	};
	if (manageSupplyRelaysStage in ['removeSupplyRelay', 'removeSupplyRelayConfirmation'])
	then
	{
		{
			scopeName 'supplyRelayStationsLoop';
			if ((_x getVariable 'team') == side player)
			then
			{
				if (((position _x) distance _position2D) <= supplyRelayStationRadius)
				then
				{
					if (manageSupplyRelaysStage == 'removeSupplyRelay' or (manageSupplyRelaysStage == 'removeSupplyRelayConfirmation' and manageSupplyRelaysSelectedBase != _x))
					then
					{
						manageSupplyRelaysSelectedBase = _x;
						manageSupplyRelaysStage = 'removeSupplyRelayConfirmation';
						hint 'Select the supply relay station again to confirm removal.';
					}
					else
					{
						if (manageSupplyRelaysStage == 'removeSupplyRelayConfirmation' and manageSupplyRelaysSelectedBase == _x)
						then
						{
							hint 'Processing supply relay station removal...';
						};
					};
					breakOut 'supplyRelayStationsLoop';
				};
			};
		} forEach supplyRelayStations;
	};
};

functionHandleGetPlannedSupplyRelaysResponse =
{
	plannedSupplyRelaysPositions = _this select 0;
	call functionClearPlannedSupplyRelaysMapMarkers;
	{
		[_forEachIndex, _x] call functionPlannedSupplyRelaysCreateMarker;
		plannedSupplyRelaysMapMarkerIDs pushBack _forEachIndex;
	} forEach plannedSupplyRelaysPositions;
};

functionHandleManageSupplyRelaysMapClosure =
{ 
	waitUntil {!(visibleMap)};
	hint '';
	['establishSupplyRelaysMapClickEvent', 'onMapSingleClick'] call BIS_fnc_removeStackedEventHandler;
	call functionClearSupplyRelaysRadiusMapMarkers;
	call functionClearPlannedSupplyRelaysMapMarkers;
	if ((count newPlannedSupplyRelaysPositions) > 0)
	then
	{
		[[newPlannedSupplyRelaysPositions, player], 'functionPlanSupplyRelaysViaServer', false] call BIS_fnc_MP;
	};
	//hint 'Supply relay missions created successfully.';
};

functionClearPlannedSupplyRelaysMapMarkers =
{
	{
		deleteMarkerLocal (format ['%1PlannedSupplyRelayVisualMapMarker', _x]);
		deleteMarkerLocal (format ['%1PlannedSupplyRelayVisualTextMapMarker', _x]);
	} forEach plannedSupplyRelaysMapMarkerIDs;
};

functionPlannedSupplyRelaysCreateMarker =
{
	_id = _this select 0;
	_position = _this select 1;
	_visualMapMarker = createMarkerLocal [format ['%1PlannedSupplyRelayVisualMapMarker', _id], _position];
	_visualMapMarker setMarkerShapeLocal 'ELLIPSE';
	_visualMapMarker setMarkerBrushLocal 'FDiagonal';
	_visualMapMarker setMarkerSizeLocal [supplyRelayStationRadius, supplyRelayStationRadius];
	_visualMapMarker setMarkerColorLocal 'ColorBlue';
	_visualTextMapMarker = createMarkerLocal [format ['%1PlannedSupplyRelayVisualTextMapMarker', _id], _position];
	_visualTextMapMarker setMarkerTypeLocal 'EmptyIcon';
	_visualTextMapMarker setMarkerTextLocal 'Planned Supply Relay Station';
	_visualTextMapMarker setMarkerColorLocal 'ColorWhite';
};

functionClearSupplyRelaysRadiusMapMarkers =
{
	{
		deleteMarkerLocal (format ['%1SupplyRelayRadiusVisualMapMarker', _x]);
		deleteMarkerLocal (format ['%1SupplyRelayRadiusVisualTextMapMarker', _x]);
	} forEach supplyRelaysRadiusMapMarkerIDs;
};

functionSupplyRelaysRadiusCreateMarker =
{
	_id = _this select 0;
	_position = _this select 1;
	_visualMapMarker = createMarkerLocal [format ['%1SupplyRelayRadiusVisualMapMarker', _id], _position];
	_visualMapMarker setMarkerShapeLocal 'ELLIPSE';
	_visualMapMarker setMarkerSizeLocal [supplyRelayStationRadius, supplyRelayStationRadius];
	_visualMapMarker setMarkerColorLocal 'ColorBlue';
	_visualTextMapMarker = createMarkerLocal [format ['%1SupplyRelayRadiusVisualTextMapMarker', _id], _position];
	_visualTextMapMarker setMarkerTypeLocal 'EmptyIcon';
	_visualTextMapMarker setMarkerTextLocal 'Supply Relay Station';
	_visualTextMapMarker setMarkerColorLocal 'ColorWhite';
};

functionHandleSupplyRelaysPlanningError =
{
	hint parseText '<t color="#D00000">Unfortunately, an error has occurred. Please try again.</t>';
};

functionHandleSupplyPrimaryBaseSelection =
{
	_baseSelectedID = lbData [5017, (lbCurSel 5017)];
	_baseSelectedObject = objNull;
	{
		if ((_x getVariable 'id') == _baseSelectedID)
		then
		{
			_baseSelectedObject = _x;
		};
	} forEach playerControlledBases;
	[format ['primaryBase%1', [side player] call functionGetTeamFORName], _baseSelectedObject] call functionPublicVariableSetValue;
};

functionHandleSupplyIncomeQuotaProportionSelection =
{
	_teamLiteral = [player getVariable 'team'] call functionGetTeamFORName;
	_quotaProportion = lbData [5019, (lbCurSel 5019)];
	[format ['influenceIncomeQuotaProportion%1', _teamLiteral], parseNumber _quotaProportion] call functionPublicVariableSetValue;
};

functionEstablishSupplyTransportationVehicleFunctionalityLocal =
{
	_supplyTransportationVehicle = _this select 0;
	if (alive _supplyTransportationVehicle)
	then
	{
		_supplyTransportationVehicle addAction ['Manage Supply Transportation', functionOpenSupplyTransportationInterface, '', 999, false, true, '', '(alive _target) and (driver _target == _this)'];
	};
};

functionOpenSupplyTransportationInterface =
{
	_supplyTransportationVehicle = _this select 0;
	createDialog 'nwDialogueSupplyTransportationInterface';
	ctrlSetText [11001, format ['Supply in Vehicle: €%1', (_supplyTransportationVehicle getVariable 'supplyAmount')]];
	{
		if ((_x getVariable 'team') == side player)
		then
		{
			if ((position player) distance (position _x) <= baseRadius)
			then
			{
				_addedIndex = lbAdd [11002, (_x getVariable 'name')];
				lbSetData [11002, _addedIndex, (_x getVariable 'id')];
			};
		};
	} forEach playerControlledBases;
	{
		if ((_x getVariable 'team') == side player)
		then
		{
			if ((position player) distance (position _x) <= FOBRadius)
			then
			{
				_addedIndex = lbAdd [11002, (_x getVariable 'name')];
				lbSetData [11002, _addedIndex, (_x getVariable 'id')];
			};
		};
	} forEach FOBs;
	{
		if ((_x getVariable 'team') == side player)
		then
		{
			if ((position player) distance (position _x) <= supplyTransportationVehicleMobileRespawnVehicleTransferRadius)
			then
			{
				_addedIndex = lbAdd [11002, (_x getVariable 'name')];
				lbSetData [11002, _addedIndex, (_x getVariable 'id')];
			};
		};
	} forEach mobileRespawnPoints;
	lbSetCurSel [11002, 0];
};

functionHandleSupplyTransferFocusSelection =
{
	_transferFocusID = lbData [11002, (lbCurSel 11002)];
	_transferFocusObject = [_transferFocusID] call functionGetSupplyTransferFocusSelectionObject;
	ctrlSetText [11003, format ['%1 has €%2.', (_transferFocusObject getVariable 'name'), (_transferFocusObject getVariable 'supplyAmount')]];
};

functionGetSupplyTransferFocusSelectionObject =
{
	private ['_transferFocusID', '_transferFocusObject'];
	_transferFocusID = _this select 0;
	_transferFocusObject = objNull;
	{
		if ((_x getVariable 'id') == _transferFocusID)
		then
		{
			_transferFocusObject = _x;
		};
	} forEach (playerControlledBases + FOBs + mobileRespawnPoints);
	_transferFocusObject;
};

functionSupplyTransportationVehicleImportTransfer =
{
	_transferAmount = parseNumber (ctrlText 11004);
	_transferFocusID = lbData [11002, (lbCurSel 11002)];
	_transferFocusObject = [_transferFocusID] call functionGetSupplyTransferFocusSelectionObject;
	if (_transferAmount <= supplyTransportationVehicleSupplyCapacity)
	then
	{
		if ((_transferFocusObject getVariable 'supplyAmount') >= _transferAmount)
		then
		{
			ctrlSetText [11007, 'Processing transfer...'];
			[[_transferAmount, _transferFocusObject, player], 'functionSupplyTransportationVehicleImportTransferViaServer', false] call BIS_fnc_MP;
		}
		else
		{
			ctrlSetText [11007, 'Insufficient supply.'];
		};
	}
	else
	{
		ctrlSetText [11007, format ['Cannot exceed capacity €%1.', supplyTransportationVehicleSupplyCapacity]];
	};
};

functionSupplyTransportationVehicleExportTransfer =
{
	_transferAmount = parseNumber (ctrlText 11004);
	_transferFocusID = lbData [11002, (lbCurSel 11002)];
	_transferFocusObject = [_transferFocusID] call functionGetSupplyTransferFocusSelectionObject;
	if (((vehicle player) getVariable 'supplyAmount') >= _transferAmount)
	then
	{
		ctrlSetText [11007, 'Processing transfer...'];
		[[_transferAmount, _transferFocusObject, player], 'functionSupplyTransportationVehicleExportTransferViaServer', false] call BIS_fnc_MP;
	}
	else
	{
		ctrlSetText [11007, 'Insufficient supply.'];
	};
};

functionHandleSupplyTransportationSuccess =
{
	_transferFocusObject = _this select 0;
	_supplyTransportationVehicle = _this select 1;
	ctrlSetText [11001, format ['Supply in Vehicle: €%1', (_supplyTransportationVehicle getVariable 'supplyAmount')]];
	ctrlSetText [11003, format ['%1 has €%2.', (_transferFocusObject getVariable 'name'), (_transferFocusObject getVariable 'supplyAmount')]];
	ctrlSetText [11007, 'Transfer successful.'];
};

functionHandleSupplyTransportationError =
{
	hint parseText '<t color="#D00000">Unfortunately, an error has occurred. Please try again.</t>';
};

functionEstablishSupplyQuota =
{
	_supplyQuota = _this select 0;
	if (count _this > 1)
	then
	{
		personalSupplyQuotaIncome = _this select 1;
	};
	if (count _this > 2)
	then
	{
		personalSupplyQuotaObjectiveBonusAwarded = _this select 2;
	};
	personalSupplyQuota = _supplyQuota;
	call functionUpdatePanelHUD;
};