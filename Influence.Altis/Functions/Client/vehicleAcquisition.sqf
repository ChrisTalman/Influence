functionOpenVehicleAcquisitionInterface =
{
	vehicleAcquisitionBaseObject = objNull;
	createDialog 'nwDialogueVehicleAcquisition';
	ctrlEnable [7003, false];
	ctrlSetFocus ((findDisplay 7) displayCtrl 7090);
	_nearestBaseOrFOB = [position player, true] call functionFindNearestBase;
	_neutralisedBases = [side player] call functionGetNeutralisedBases;
	[7000, side player, _neutralisedBases, _nearestBaseOrFOB, true] call functionPopulateBaseList;
};

functionHandleVehicleAcquisitionBaseSelection =
{
	_selectedBaseID = lbData [7000, (lbCurSel 7000)];
	vehicleAcquisitionBaseObject = [_selectedBaseID, true] call functionGetBaseObjectWithID;
	ctrlSetText [7001, format ['You have €%1. %2 has €%3.', personalSupplyQuota, (vehicleAcquisitionBaseObject getVariable 'name'), (vehicleAcquisitionBaseObject getVariable 'supplyAmount')]];
	_acquirableVehicles = [vehicleAcquisitionBaseObject] call functionGetAcquirableVehicles;
	lbClear 7002;
	{
		_acquirableVehicleName = _x select 0;
		_acquirableVehicleSupplyCost = _x select 2;
		_indexInList = lbAdd [7002, format ['€%1 %2', _acquirableVehicleSupplyCost, _acquirableVehicleName]];
		lbSetData [7002, _indexInList, _acquirableVehicleName];
	} forEach _acquirableVehicles;
};

functionHandleVehicleAcquisitionSelection =
{
	ctrlEnable [7003, true];
};

functionAcquireVehicle =
{
	_acquirableVehicles = [vehicleAcquisitionBaseObject] call functionGetAcquirableVehicles;
	_vehicleToAcquireName = lbData [7002, (lbCurSel 7002)];
	_vehicleToAcquireData = [_acquirableVehicles, 0, _vehicleToAcquireName] call functionGetNestedArrayWithIndexValue;
	_vehicleToAcquireEngineName = _vehicleToAcquireData select 1;
	_vehicleToAcquireSupplyCost = _vehicleToAcquireData select 2;
	_basePosition2D = [position vehicleAcquisitionBaseObject select 0, position vehicleAcquisitionBaseObject select 1];
	_vehicleAcquisitionPermittedOnClient = false;
	if (_vehicleToAcquireSupplyCost > personalSupplyQuota)
	then
	{
		ctrlSetText [7004, format ['You cannot afford a %1.', _vehicleToAcquireName]];
	}
	else
	{
		if (_vehicleToAcquireSupplyCost > (vehicleAcquisitionBaseObject getVariable 'supplyAmount'))
		then
		{
			ctrlSetText [7004, format ['Selected base cannot afford a %1.', _vehicleToAcquireName]];
		}
		else
		{
			_vehicleAcquisitionPermittedOnClient = true;
		};
	};
	if (_vehicleAcquisitionPermittedOnClient)
	then
	{
		ctrlSetText [7004, 'Processing acquisition.'];
		[[player, _vehicleToAcquireSupplyCost, vehicleAcquisitionBaseObject, _vehicleToAcquireName], 'functionEnactAcquireVehicleViaServer', false] call BIS_fnc_MP;
	};
};

functionEnactAcquireVehicle =
{
	_vehicleToAcquireName = _this select 0;
	_revisedPersonalSupplyQuota = _this select 1;
	_vehicleAcquisitionBaseSupplyAmount = _this select 2;
	_acquirableVehicles = [vehicleAcquisitionBaseObject] call functionGetAcquirableVehicles;
	_vehicleToAcquireData = [_acquirableVehicles, 0, _vehicleToAcquireName] call functionGetNestedArrayWithIndexValue;
	_vehicleToAcquireEngineName = _vehicleToAcquireData select 1;
	_vehicleToAcquireSupplyCost = _vehicleToAcquireData select 2;
	personalSupplyQuota = _revisedPersonalSupplyQuota;
	call functionUpdatePanelHUD;
	ctrlSetText [7001, format ['You have €%1. %2 has €%3.', personalSupplyQuota, (vehicleAcquisitionBaseObject getVariable 'name'), _vehicleAcquisitionBaseSupplyAmount]];
	_basePosition2D = [position vehicleAcquisitionBaseObject select 0, position vehicleAcquisitionBaseObject select 1];
	_acquiredVehicle = objNull;
	if ((count ([(missionNamespace getVariable (format ['baseVehicleAcquisitionOptionsNavy%1', ([player getVariable 'team'] call functionGetTeamFORName)])), 0, _vehicleToAcquireName] call functionGetNestedArrayWithIndexValue)) > 0)
	then
	{
		_navalSpawnPosition2D = [(position (vehicleAcquisitionBaseObject getVariable 'navalFacility')) select 0, (position (vehicleAcquisitionBaseObject getVariable 'navalFacility')) select 1];
		_acquiredVehicle = createVehicle [_vehicleToAcquireEngineName, ([_navalSpawnPosition2D, 0, navalSpawnRadius, 0, 2, 180, 0] call BIS_fnc_findSafePos), [], 0, 'NONE'];
	}
	else
	{
		_acquiredVehicle = createVehicle [_vehicleToAcquireEngineName, ([vehicleAcquisitionBaseObject, position player] call functionFindSafeAcquisitionPositionInBase), [], 0, 'NONE'];
	};
	if (!(isNull _acquiredVehicle))
	then
	{
		_acquiredVehicle setVariable ['ownerUID', getPlayerUID player, true];
		_acquiredVehicle setVariable ['team', side player, true];
		_acquiredVehicle setVariable ['vehicleName', _vehicleToAcquireName, true];
		_acquiredVehicle setVariable ['initialMass', getMass _acquiredVehicle, true];
		_acquiredVehicle setVariable ['slingLoadingPermitted', false, true];
		[format ['vehicles%1', [side player] call functionGetTeamFORName], _acquiredVehicle] call functionPublicVariableAppendToArray;
		[_acquiredVehicle, true] call functionOwnedVehicleEstablishLock;
		if (_acquiredVehicle isKindOf 'Air')
		then
		{
			_acquiredVehicle setVariable ['slingLoadingManualHookInProgress', false, true];
			[[_acquiredVehicle], 'functionEstablishManualHookScrollMenuAction', (player getVariable 'team'), true] call BIS_fnc_MP;
		}
		else
		{
			[[_acquiredVehicle], 'functionEstablishSlingLoadingFunctionalityLocal', (player getVariable 'team'), true] call BIS_fnc_MP;
			_acquiredVehicle enableRopeAttach false;
		};
		if (_vehicleToAcquireName == 'Mobile Respawn Vehicle')
		then
		{
			_acquiredVehicle setVariable ['id', format ['mobileRespawnPoint%1', totalMobileRespawnPointsCount], true];
			_acquiredVehicle setVariable ['name', format ['Mobile Respawn %1', (totalMobileRespawnPointsCount + 1)], true];
			['totalMobileRespawnPointsCount', totalMobileRespawnPointsCount + 1] call functionPublicVariableSetValue;
			[[_acquiredVehicle], 'functionEstablishMobileRespawnVehicleFunctionalityLocal', side player, true] call BIS_fnc_MP;
			//[[_acquiredVehicle], 'functionEstablishMobileRespawnVehicleFunctionalityServer', side player, false] call BIS_fnc_MP;
		};
		if (_vehicleToAcquireName == 'Supply Transportation Vehicle')
		then
		{
			_acquiredVehicle setVariable ['supplyAmount', 0, true];
			[[_acquiredVehicle], 'functionEstablishSupplyTransportationVehicleFunctionalityLocal', side player, true] call BIS_fnc_MP;
		};
		ctrlSetText [7004, 'Acquisition processed successfully.'];
		hint format ['%1 has been spawned at %2.', _vehicleToAcquireName, (vehicleAcquisitionBaseObject getVariable 'name')];
	};
};

functionHandleVehicleAcquisitionError =
{
	ctrlSetText [7004, 'Apologies, but an error occurred. Please try again.'];
};

functionGetAcquirableVehicles =
{
	private ['_baseObject', '_acquirableVehicles'];
	_baseObject = _this select 0;
	_acquirableVehicles = [];
	if (((_baseObject getVariable 'id') find 'base') >= 0)
	then
	{
		if (!(isNull (_baseObject getVariable 'lightVehicleFacility')))
		then
		{
			_acquirableVehicles = _acquirableVehicles + (missionNamespace getVariable (format ['baseVehicleAcquisitionOptionsLight%1', ([side player] call functionGetTeamFORName)]));
		};
		if (!(isNull (_baseObject getVariable 'heavyVehicleFacility')))
		then
		{
			_acquirableVehicles = _acquirableVehicles + (missionNamespace getVariable (format ['baseVehicleAcquisitionOptionsHeavy%1', ([side player] call functionGetTeamFORName)]));
		};
		if (!(isNull (_baseObject getVariable 'airFacility')))
		then
		{
			_acquirableVehicles = _acquirableVehicles + (missionNamespace getVariable (format ['baseVehicleAcquisitionOptionsAir%1', ([side player] call functionGetTeamFORName)]));
		};
		if (!(isNull (_baseObject getVariable 'navalFacility')))
		then
		{
			_acquirableVehicles = _acquirableVehicles + (missionNamespace getVariable (format ['baseVehicleAcquisitionOptionsNavy%1', ([side player] call functionGetTeamFORName)]));
		};
	};
	if (((_baseObject getVariable 'id') find 'FOB') >= 0)
	then
	{
		_acquirableVehicles = missionNamespace getVariable (format ['FOBVehicleAcquisitionOptions%1', ([side player] call functionGetTeamFORName)]);
	};
	_acquirableVehicles;
};