functionOpenAIAcquisitionInterface =
{
	AIAcquisitionBaseObject = objNull;
	createDialog 'nwDialogueAIAcquisition';
	ctrlEnable [12003, false];
	ctrlSetFocus ((findDisplay 12) displayCtrl 12090);
	_nearestBaseOrFOB = [position player, true] call functionFindNearestBase;
	_neutralisedBases = [side player] call functionGetNeutralisedBases;
	[12000, side player, _neutralisedBases, _nearestBaseOrFOB, true] call functionPopulateBaseList;
	AIAcquisitionProcessing = false;
};

functionHandleAIAcquisitionBaseSelection =
{
	_selectedBaseID = lbData [12000, (lbCurSel 12000)];
	AIAcquisitionBaseObject = [_selectedBaseID, true] call functionGetBaseObjectWithID;
	ctrlSetText [12001, format ['You have €%1. %2 has €%3.', personalSupplyQuota, (AIAcquisitionBaseObject getVariable 'name'), (AIAcquisitionBaseObject getVariable 'supplyAmount')]];
	_acquirableAI = [AIAcquisitionBaseObject] call functionGetAcquirableAI;
	lbClear 12002;
	{
		_acquirableAIName = _x select 0;
		_acquirableAISupplyCost = _x select 2;
		_indexInList = lbAdd [12002, format ['€%1 %2', _acquirableAISupplyCost, _acquirableAIName]];
		lbSetData [12002, _indexInList, _acquirableAIName];
	} forEach _acquirableAI;
};

functionHandleAIAcquisitionSelection =
{
	if (!(AIAcquisitionProcessing))
	then
	{
		ctrlEnable [12003, true];
	};
};

functionAcquireAI =
{
	_acquirableAI = [AIAcquisitionBaseObject] call functionGetAcquirableAI;
	_AIToAcquireName = lbData [12002, (lbCurSel 12002)];
	_AIToAcquireData = [_acquirableAI, 0, _AIToAcquireName] call functionGetNestedArrayWithIndexValue;
	_AIToAcquireEngineName = _AIToAcquireData select 1;
	_AIToAcquireSupplyCost = _AIToAcquireData select 2;
	_basePosition2D = [position AIAcquisitionBaseObject select 0, position AIAcquisitionBaseObject select 1];
	_AIAcquisitionPermittedOnClient = false;
	if (_AIToAcquireSupplyCost > personalSupplyQuota)
	then
	{
		ctrlSetText [12004, format ['You cannot afford a %1.', _AIToAcquireName]];
	}
	else
	{
		if (_AIToAcquireSupplyCost > (AIAcquisitionBaseObject getVariable 'supplyAmount'))
		then
		{
			ctrlSetText [12004, format ['Selected base cannot afford a %1.', _AIToAcquireName]];
		}
		else
		{
			if (((count (units (group player))) - 1) >= maximumAIPerPlayer)
			then
			{
				ctrlSetText [12004, format ['You may not exceed four AI.', _AIToAcquireName]];
			}
			else
			{
				_AIAcquisitionPermittedOnClient = true;
			};
		};
	};
	if (_AIAcquisitionPermittedOnClient)
	then
	{
		ctrlSetText [12004, 'Processing acquisition.'];
		AIAcquisitionProcessing = true;
		ctrlEnable [12003, false];
		[[player, _AIToAcquireSupplyCost, AIAcquisitionBaseObject, _AIToAcquireName], 'functionEnactAcquireAIViaServer', false] call BIS_fnc_MP;
	};
};

functionEnactAcquireAI =
{
	_AIToAcquireName = _this select 0;
	_revisedPersonalSupplyQuota = _this select 1;
	_AIAcquisitionBaseSupplyAmount = _this select 2;
	AIAcquisitionProcessing = false;
	ctrlEnable [12003, true];
	_acquirableAI = [AIAcquisitionBaseObject] call functionGetAcquirableAI;
	_AIToAcquireData = [_acquirableAI, 0, _AIToAcquireName] call functionGetNestedArrayWithIndexValue;
	_AIToAcquireEngineName = _AIToAcquireData select 1;
	_AIToAcquireSupplyCost = _AIToAcquireData select 2;
	personalSupplyQuota = _revisedPersonalSupplyQuota;
	call functionUpdatePanelHUD;
	ctrlSetText [12001, format ['You have €%1. %2 has €%3.', personalSupplyQuota, (AIAcquisitionBaseObject getVariable 'name'), _AIAcquisitionBaseSupplyAmount]];
	_basePosition2D = [position AIAcquisitionBaseObject select 0, position AIAcquisitionBaseObject select 1];
	_acquiredAI = objNull;
	_acquiredAI = (group player) createUnit [_AIToAcquireEngineName, ([AIAcquisitionBaseObject, position player] call functionFindSafeAcquisitionPositionInBase), [], 0, 'FORM'];
	[_acquiredAI] joinSilent (group player);
	if (!(isNull _acquiredAI))
	then
	{
		//[_acquiredAI, 'team', side player, side player] call functionObjectSetVariablePublicTarget;
		//[_acquiredAI, 'vehicleName', _AIToAcquireName, side player] call functionObjectSetVariablePublicTarget;
		//[format ['vehicles%1', [side player] call functionGetTeamFORName], _acquiredAI] call functionPublicVariableAppendToArray;
		ctrlSetText [12004, 'Acquisition processed successfully.'];
		hint format ['%1 has been spawned at %2.', _AIToAcquireName, (AIAcquisitionBaseObject getVariable 'name')];
	};
};

functionHandleAIAcquisitionError =
{
	ctrlSetText [12004, 'Apologies, but an error occurred. Please try again.'];
};

functionGetAcquirableAI =
{
	private ['_baseObject', '_acquirableAI'];
	_baseObject = _this select 0;
	_acquirableAI = [];
	if (((_baseObject getVariable 'id') find 'base') >= 0)
	then
	{
		if (!(isNull (_baseObject getVariable 'infantryFacility')))
		then
		{
			_acquirableAI = missionNamespace getVariable (format ['baseAIAcquisitionOptions%1', ([side player] call functionGetTeamFORName)]);
		};
	};
	if (((_baseObject getVariable 'id') find 'FOB') >= 0)
	then
	{
		_acquirableAI = missionNamespace getVariable (format ['FOBAIAcquisitionOptions%1', ([side player] call functionGetTeamFORName)]);
	};
	_acquirableAI;
};

functionManageAI =
{
	closeDialog 0;
	createDialog 'nwDialogueAIManagement';
	call functionManageAIPopulateSquadList;
};

functionManageAIPopulateSquadList =
{
	lbClear 15002;
	{
		if (alive _x)
		then
		{
			if (!(isPlayer _x))
			then
			{
				_unitName = format ['%1 (%2)', ([typeOf _x] call functionGetLiteralNameForUnitType), ([name _x] call functionGetLastName)];
				_indexInList = lbAdd [15002, _unitName];
				lbSetData [15002, _indexInList, netId _x];
			};
		};
	} forEach (units (group player));
};

functionDisbandAI =
{
	_selectedListItemID = lbCurSel 15002;
	if (_selectedListItemID > -1)
	then
	{
		_unitNetID = lbData [15002, _selectedListItemID];
		(objectFromNetId _unitNetID) setDamage 1;
		call functionManageAIPopulateSquadList;
	};
};

functionCloseAIManagement =
{
	closeDialog 0;
	call functionOpenAIAcquisitionInterface;
};