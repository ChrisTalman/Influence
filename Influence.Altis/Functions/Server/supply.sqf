functionHandleGetPlannedSupplyRelaysRequest =
{
	_clientPlayerObject = _this select 0;
	_team = _clientPlayerObject getVariable 'team';
	_teamLiteral = [_team] call functionGetTeamFORName;
	_missions = missionNamespace getVariable (format ['missions%1', _teamLiteral]);
	_positions = [_missions] call functionGetPlannedSupplyRelays;
	[[_positions], 'functionHandleGetPlannedSupplyRelaysResponse', _clientPlayerObject] call BIS_fnc_MP;
};

functionGetPlannedSupplyRelays =
{
	private ['_missions', '_positions'];
	_missions = _this select 0;
	_positions = [];
	{
		_missionType = _x select 1;
		_missionSpecialArguments = _x select 4;
		if (_missionType == 'supplyRelayStation')
		then
		{
			_buildPosition = _missionSpecialArguments select 0;
			_positions pushBack _buildPosition;
		};
	} forEach _missions;
	_positions;
};

functionPlanSupplyRelaysViaServer =
{
	_newPlannedSupplyRelaysPositions = _this select 0;
	_playerObject = _this select 1;
	_team = _playerObject getVariable 'team';
	// Supply relay mission special arguments: build position, base object, construction vehicle object
	if ((count _newPlannedSupplyRelaysPositions) == 1)
	then
	{
		_buildPosition = (_newPlannedSupplyRelaysPositions select 0) select 0;
		_baseObject = (_newPlannedSupplyRelaysPositions select 0) select 1;
		if ((_baseObject getVariable 'supplyAmount') >= supplyRelayStationSupplyCost)
		then
		{
			_baseObject setVariable ['supplyAmount', (_baseObject getVariable 'supplyAmount') - supplyRelayStationSupplyCost, true];
			['supplyRelayStation', _team, [_buildPosition, _baseObject, objNull]] call functionAddSingleMission;
		}
		else
		{
			[[], 'functionHandleSupplyRelaysPlanningError', _playerObject] call BIS_fnc_MP;
		};
	};
	if ((count _newPlannedSupplyRelaysPositions) > 1)
	then
	{
		_deploymentBases = [];
		_newMissionsSpecialArguments = [];
		{
			_buildPosition = _x select 0;
			_baseObject = _x select 1;
			_newMissionsSpecialArguments pushBack [_buildPosition, _baseObject, objNull];
			if ((_deploymentBases find _baseObject) == -1)
			then
			{
				_deploymentBases pushBack _baseObject;
			};
		} forEach _newPlannedSupplyRelaysPositions;
		_sufficientSupply = true;
		{
			_currentBase = _x;
			_missionsFromBase = { (_x select 1) == _currentBase } count _newPlannedSupplyRelaysPositions;
			_cumulativeSupplyCostAtBase = _missionsFromBase * supplyRelayStationSupplyCost;
			_baseSupplyAmount = (_currentBase getVariable 'supplyAmount');
			if (_baseSupplyAmount < _cumulativeSupplyCostAtBase)
			then
			{
				_sufficientSupply = false;
			};
		} forEach _deploymentBases;
		if (_sufficientSupply)
		then
		{
			{
				_currentBase = _x;
				_missionsFromBase = { (_x select 1) == _currentBase } count _newPlannedSupplyRelaysPositions;
				_cumulativeSupplyCostAtBase = _missionsFromBase * supplyRelayStationSupplyCost;
				_baseSupplyAmount = (_currentBase getVariable 'supplyAmount');
				_currentBase setVariable ['supplyAmount', _baseSupplyAmount - _cumulativeSupplyCostAtBase, true];
			} forEach _deploymentBases;
			['supplyRelayStation', _team, _newMissionsSpecialArguments] call functionAddMultipleMissions;
		}
		else
		{
			[[], 'functionHandleSupplyRelaysPlanningError', _playerObject] call BIS_fnc_MP;
		};
	};
};

functionRegisterSupplyRelayStation =
{
	_position = _this select 0;
	_team = _this select 1;
	_newSupplyRelayStationObject = createVehicle ['Land_TBox_F', [_position select 0, _position select 1, 0], [], 0, 'CAN_COLLIDE'];
	_newSupplyRelayStationObject allowDamage false;
	_newSupplyRelayStationID = format ['supplyRelayStation%1', totalSupplyRelayStations];
	totalSupplyRelayStations = totalSupplyRelayStations + 1;
	_newSupplyRelayStationObject setVariable ['id', _newSupplyRelayStationID, true];
	_newSupplyRelayStationObject setVariable ['team', _team, true];
	_newSupplyRelayStationObject setVariable ['supplyAmountInProcessing', 0, true];
	_newSupplyRelayStationNeighbors = [_newSupplyRelayStationObject, _team] call functionGetNodeNeighbors;
	{
		_x setVariable ['supplyNodeNeighbors', ((_x getVariable 'supplyNodeNeighbors') + [_newSupplyRelayStationObject]), true];
	} forEach _newSupplyRelayStationNeighbors;
	_newSupplyRelayStationObject setVariable ['supplyNodeNeighbors', _newSupplyRelayStationNeighbors, true];
	['supplyRelayStations', (supplyRelayStations + [_newSupplyRelayStationObject])] call functionPublicVariableSetValue;
	['supplyNodes', (supplyNodes + [_newSupplyRelayStationObject])] call functionPublicVariableSetValue;
};

functionConductDispatchSupply =
{
	private ["_routeInformation", "_startBaseObject", "_destinationBaseObject", "_supplyAmount", "_supplyPackageNode", "_supplyPackageNextNode", "_processStartServerTime", "_routeInformation", "_routeInformationBestRouteFirstNode", "_routeInformationBestRouteNodesInSequence"];
	_startBaseObject = _this select 0;
	_destinationBaseObject = _this select 1;
	_supplyAmount = _this select 2;
	if (isNil("totalSupplyPackageCount"))
	then
	{
		totalSupplyPackageCount = 0;
	}
	else
	{
		if (count _this > 3)
		then
		{
			_supplyPackageSegmentIndex = _this select 3;
			if (_supplyPackageSegmentIndex == 0)
			then
			{
				totalSupplyPackageCount = totalSupplyPackageCount + 1;
			};
		}
		else
		{
			totalSupplyPackageCount = totalSupplyPackageCount + 1;
		};
	};
	_supplyPackageName = "";
	if (count _this > 3)
	then
	{
		_supplyPackageSegmentIndex = _this select 3;
		_supplyPackageName = format ["Supply Package %1 (Segment %2)", (totalSupplyPackageCount + 1), (_supplyPackageSegmentIndex + 1)];
	}
	else
	{
		_supplyPackageName = format ["Supply Package %1", (totalSupplyPackageCount + 1)];
	};
	_supplyPackage = [format ["supplyPackage%1", totalSupplyPackageCount], _startBaseObject, _destinationBaseObject, _supplyAmount, [], _supplyPackageName, false];
	_supplyPackageNode = _startBaseObject;
	_supplyPackageNextNode = objNull;
	["supplyPackages", supplyPackages + [_supplyPackage]] call functionPublicVariableSetValue;
	_dispatchComplete = false;
	while {!(_dispatchComplete)}
	do
	{
		if (_supplyPackageNode == _destinationBaseObject)
		then
		{
			_supplyPackageNode setVariable ["supplyAmount", (_supplyPackageNode getVariable "supplyAmount") + _supplyAmount, true];
			_supplyPackage set [6, true];
			publicVariable "supplyPackages";
			_dispatchComplete = true;
		}
		else
		{
			_routeInformation = [_supplyPackageNode, _destinationBaseObject] call functionFindBestSupplyRoute;
			_routeInformationBestRouteFirstNode = _routeInformation select 1;
			_routeInformationBestRouteNodesInSequence = _routeInformation select 2;
			_supplyPackage set [4, _routeInformationBestRouteNodesInSequence];
			publicVariable "supplyPackages";
			_supplyPackageNextNode = _routeInformationBestRouteFirstNode;
			if (_supplyPackageNode == _startBaseObject)
			then
			{
				waitUntil {((_supplyPackageNextNode getVariable "supplyAmountInProcessing") + _supplyAmount) <= supplyRelayStationSupplyCapacity};
				_supplyPackageNode setVariable ["unusableSupplyAmount", (_supplyPackageNode getVariable "unusableSupplyAmount") - _supplyAmount, true];
			}
			else
			{
				_supplyPackageNode setVariable ["supplyAmountInProcessing", (_supplyPackageNode getVariable "supplyAmountInProcessing") + _supplyAmount, true];
				_processStartServerTime = serverTime;
				waitUntil {serverTime >= (_processStartServerTime + supplyRelayStationProcessTimeInSeconds)};
				if (!(_supplyPackageNextNode == _destinationBaseObject))
				then
				{
					waitUntil {((_supplyPackageNextNode getVariable "supplyAmountInProcessing") + _supplyAmount) <= supplyRelayStationSupplyCapacity};
				};
				_supplyPackageNode setVariable ["supplyAmountInProcessing", (_supplyPackageNode getVariable "supplyAmountInProcessing") - _supplyAmount, true];
			};
			_supplyPackageNode = _supplyPackageNextNode;
		};
	};
};

functionDistributeTerritorialSupplyIncomeByInterval =
{
	while {true}
	do
	{
		call functionIdentifyObjectiveParticipants;
		_playersBLUFOR = [[], BLUFOR] call functionGetPlayerObjects;
		_playersOPFOR = [[], OPFOR] call functionGetPlayerObjects;
		if (!(isNull primaryBaseBLUFOR))
		then
		{
			_provinceControlAmountBLUFOR = [BLUFOR, provincesStatusServer] call functionGetTeamProvinceControlAmount;
			_teamIncome = (round ([territoryControlBLUFOR, regularSupplyIncomeInfluenceAmount] call functionGetEasedProportion)) + (_provinceControlAmountBLUFOR * regularSupplyIncomeProvinceAmount);
			if ((count _playersBLUFOR) > 0)
			then
			{
				_quotaProportion = missionNamespace getVariable 'influenceIncomeQuotaProportionBLUFOR';
				_playerQuotaIncomeTotal = _teamIncome * _quotaProportion;
				_playerQuotaIncomeIndividual = floor (_playerQuotaIncomeTotal / (count _playersBLUFOR));
				{
					_objectiveBonusAwarded = false;
					if ((getPlayerUID _x) in objectiveParticipantsBLUFOR)
					then
					{
						_playerQuotaIncomeIndividual = _playerQuotaIncomeIndividual + regularSupplyIncomeObjectiveReward;
						_objectiveBonusAwarded = true;
					};
					_newSupplyQuota = [getPlayerUID _x, _playerQuotaIncomeIndividual] call functionAddPlayerSupplyQuota;
					[[_newSupplyQuota, _playerQuotaIncomeIndividual, _objectiveBonusAwarded], 'functionEstablishSupplyQuota', _x] call BIS_fnc_MP;
				} forEach _playersBLUFOR;
			};
			_teamIncome = _teamIncome + (count objectiveParticipantsBLUFOR * regularSupplyIncomeObjectiveReward);
			primaryBaseBLUFOR setVariable ['supplyAmount', (primaryBaseBLUFOR getVariable 'supplyAmount') + _teamIncome, true];
			['mostRecentRegularSupplyIncomeBLUFOR', _teamIncome] call functionPublicVariableSetValue;
			objectiveParticipantsBLUFOR = [];
		};
		if (!(isNull primaryBaseOPFOR))
		then
		{
			_provinceControlAmountOPFOR = [OPFOR, provincesStatusServer] call functionGetTeamProvinceControlAmount;
			_teamIncome = (round ([territoryControlOPFOR, regularSupplyIncomeInfluenceAmount] call functionGetEasedProportion)) + (_provinceControlAmountOPFOR * regularSupplyIncomeProvinceAmount);
			if ((count _playersOPFOR) > 0)
			then
			{
				_quotaProportion = missionNamespace getVariable 'influenceIncomeQuotaProportionOPFOR';
				_playerQuotaIncomeTotal = _teamIncome * _quotaProportion;
				_playerQuotaIncomeIndividual = floor (_playerQuotaIncomeTotal / (count _playersOPFOR));
				{
					_objectiveBonusAwarded = false;
					if ((getPlayerUID _x) in objectiveParticipantsOPFOR)
					then
					{
						_playerQuotaIncomeIndividual = _playerQuotaIncomeIndividual + regularSupplyIncomeObjectiveReward;
						_objectiveBonusAwarded = true;
					};
					_newSupplyQuota = [getPlayerUID _x, _playerQuotaIncomeIndividual] call functionAddPlayerSupplyQuota;
					[[_newSupplyQuota, _playerQuotaIncomeIndividual, _objectiveBonusAwarded], 'functionEstablishSupplyQuota', _x] call BIS_fnc_MP;
				} forEach _playersOPFOR;
			};
			_teamIncome = _teamIncome + (count objectiveParticipantsOPFOR * regularSupplyIncomeObjectiveReward);
			primaryBaseOPFOR setVariable ['supplyAmount', (primaryBaseOPFOR getVariable 'supplyAmount') + _teamIncome, true];
			['mostRecentRegularSupplyIncomeOPFOR', _teamIncome] call functionPublicVariableSetValue;
			objectiveParticipantsOPFOR = [];
		};
		sleep regularSupplyIncomeInterval;
	};
};

functionEnactAcquireVehicleViaServer =
{
	_clientPlayerObject = _this select 0;
	_vehicleToAcquireSupplyCost = _this select 1;
	_vehicleAcquisitionBaseObject = _this select 2;
	_vehicleToAcquireName = _this select 3;
	_playerDataRecord = [playersData, 0, getPlayerUID _clientPlayerObject] call functionGetNestedArrayWithIndexValue;
	_playerDataSupplyQuota = _playerDataRecord select 2;
	if (_playerDataSupplyQuota >= _vehicleToAcquireSupplyCost and (_vehicleAcquisitionBaseObject getVariable 'supplyAmount') >= _vehicleToAcquireSupplyCost)
	then
	{
		_playerDataRecordRevised = _playerDataRecord;
		_playerDataRecordRevised set [2, (_playerDataRecord select 2) - _vehicleToAcquireSupplyCost];
		_playerDataRecordRevisedPersonalQuota = _playerDataRecordRevised select 2;
		[playersData find _playerDataRecord, _playerDataRecordRevised] call functionPlayersDataSetRecord;
		_vehicleAcquisitionBaseObject setVariable ['supplyAmount', (_vehicleAcquisitionBaseObject getVariable 'supplyAmount') - _vehicleToAcquireSupplyCost, true];
		[[_vehicleToAcquireName, _playerDataRecordRevisedPersonalQuota, (_vehicleAcquisitionBaseObject getVariable 'supplyAmount')], 'functionEnactAcquireVehicle', owner _clientPlayerObject] call BIS_fnc_MP;
	}
	else
	{
		[[], 'functionHandleVehicleAcquisitionError', owner _clientPlayerObject] call BIS_fnc_MP;
	};
};

functionEnactAcquireAIViaServer =
{
	_clientPlayerObject = _this select 0;
	_AIToAcquireSupplyCost = _this select 1;
	_AIAcquisitionBaseObject = _this select 2;
	_AIToAcquireName = _this select 3;
	_playerDataRecord = [playersData, 0, getPlayerUID _clientPlayerObject] call functionGetNestedArrayWithIndexValue;
	_playerDataSupplyQuota = _playerDataRecord select 2;
	if (_playerDataSupplyQuota >= _AIToAcquireSupplyCost and (_AIAcquisitionBaseObject getVariable 'supplyAmount') >= _AIToAcquireSupplyCost)
	then
	{
		_playerDataRecordRevised = _playerDataRecord;
		_playerDataRecordRevised set [2, (_playerDataRecord select 2) - _AIToAcquireSupplyCost];
		_playerDataRecordRevisedPersonalQuota = _playerDataRecordRevised select 2;
		[playersData find _playerDataRecord, _playerDataRecordRevised] call functionPlayersDataSetRecord;
		_AIAcquisitionBaseObject setVariable ['supplyAmount', (_AIAcquisitionBaseObject getVariable 'supplyAmount') - _AIToAcquireSupplyCost, true];
		[[_AIToAcquireName, _playerDataRecordRevisedPersonalQuota, (_AIAcquisitionBaseObject getVariable 'supplyAmount')], 'functionEnactAcquireAI', owner _clientPlayerObject] call BIS_fnc_MP;
	}
	else
	{
		[[], 'functionHandleAIAcquisitionError', owner _clientPlayerObject] call BIS_fnc_MP;
	};
};

functionAddPlayerSupplyQuota =
{
	// Arguments: player UID, add supply quota amount
	private ['_playerUID', '_addAmount', '_playerDataRecord', '_playerDataSupplyQuota', '_playerDataRecordRevised', '_newSupplyQuota'];
	_playerUID = _this select 0;
	_addAmount = _this select 1;
	_playerDataRecord = [playersData, 0, _playerUID] call functionGetNestedArrayWithIndexValue;
	_playerDataSupplyQuota = _playerDataRecord select 2;
	_playerDataRecordRevised = _playerDataRecord;
	_playerDataRecordRevised set [2, _playerDataSupplyQuota + _addAmount];
	[playersData find _playerDataRecord, _playerDataRecordRevised] call functionPlayersDataSetRecord;
	_newSupplyQuota = _playerDataSupplyQuota + _addAmount;
	_newSupplyQuota;
};

functionSupplyTransportationVehicleImportTransferViaServer =
{
	_transferAmount = _this select 0;
	_transferFocusObject = _this select 1;
	_playerObject = _this select 2;
	_supplyTransportationVehicle = vehicle _playerObject;
	_transferFocusSupplyAmount = _transferFocusObject getVariable 'supplyAmount';
	if (_transferFocusSupplyAmount >= _transferAmount)
	then
	{
		_transferFocusObject setVariable ['supplyAmount', _transferFocusSupplyAmount - _transferAmount, true];
		_supplyTransportationVehicle setVariable ['supplyAmount', (_supplyTransportationVehicle getVariable 'supplyAmount') + _transferAmount, true];
		[[_transferFocusObject, _supplyTransportationVehicle], 'functionHandleSupplyTransportationSuccess', _playerObject] call BIS_fnc_MP;
	}
	else
	{
		[[], 'functionHandleSupplyTransportationError', _playerObject] call BIS_fnc_MP;
	};
};

functionSupplyTransportationVehicleExportTransferViaServer =
{
	_transferAmount = _this select 0;
	_transferFocusObject = _this select 1;
	_playerObject = _this select 2;
	_supplyTransportationVehicle = vehicle _playerObject;
	_transferFocusSupplyAmount = _transferFocusObject getVariable 'supplyAmount';
	_supplyTransportationVehicleSupplyAmount = _supplyTransportationVehicle getVariable 'supplyAmount';
	if (_supplyTransportationVehicleSupplyAmount >= _transferAmount)
	then
	{
		_supplyTransportationVehicle setVariable ['supplyAmount', _supplyTransportationVehicleSupplyAmount - _transferAmount, true];
		_transferFocusObject setVariable ['supplyAmount', (_transferFocusObject getVariable 'supplyAmount') + _transferAmount, true];
		[[_transferFocusObject, _supplyTransportationVehicle], 'functionHandleSupplyTransportationSuccess', _playerObject] call BIS_fnc_MP;
	}
	else
	{
		[[], 'functionHandleSupplyTransportationError', _playerObject] call BIS_fnc_MP;
	};
};