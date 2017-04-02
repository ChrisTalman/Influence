functionEstablishSlingLoadingFunctionalityLocal =
{
	private ['_vehicle'];
	_vehicle = _this select 0;
	if (alive _vehicle)
	then
	{
		_prepareSlingLoadActionID = _vehicle addAction ['<t color="#86F078">Prepare Sling Loading</t>', functionPrepareSlingLoadingClient, '', 1001, false, true, '', '(alive _target) and !(_target getVariable "slingLoadingPermitted") and (isNull (ropeAttachedTo _target))'];
		_unprepareSlingLoadActionID = _vehicle addAction ['<t color="#86F078">Unprepare Sling Loading</t>', functionUnprepareSlingLoadingClient, '', 1001, false, true, '', '(alive _target) and (_target getVariable "slingLoadingPermitted") and (isNull (ropeAttachedTo _target))'];
		_vehicle setVariable ['prepareSlingLoadActionID', _prepareSlingLoadActionID];
		_vehicle setVariable ['unprepareSlingLoadActionID', _unprepareSlingLoadActionID];
	};
};

functionPrepareSlingLoadingClient =
{
	_vehicle = _this select 0;
	if (!(_vehicle getVariable ['mobileRespawnEnabled', false]) and !(_vehicle getVariable ['mobileRespawnTransitioning', false]))
	then
	{
		[[_vehicle, player, (player getVariable 'team')], 'functionPrepareSlingLoadingServer', false] call BIS_fnc_MP;
	}
	else
	{
		_message = 'Cannot prepare mobile respawn for sling loading while it is established, establishing, or disestablishing.';
		systemChat _message;
		hint _message;
	};
};

functionHandlePrepareSlingLoadingRequestDispatched =
{
	_vehicle = _this select 0;
	_playerDataRecord = [playersDataPublic, 0, (_vehicle getVariable 'ownerUID')] call functionGetNestedArrayWithIndexValue;
	_ownerName = _playerDataRecord select 1;
	_message = format ['Prepare sling loading request dispatched to %1.', _ownerName];
	systemChat _message;
	['Notification', ['Request Dispatched', _message]] call bis_fnc_showNotification;
};

functionHandlePrepareSlingLoadingRequest =
{
	_vehicle = _this select 0;
	_requesterUID = _this select 1;
	_duplicateRequest = [];
	if (isNil 'slingLoadingRequestsPending')
	then
	{
		slingLoadingRequestsPending = [[_vehicle, _requesterUID]];
	}
	else
	{
		_duplicateRequest = [slingLoadingRequestsPending, 0, _vehicle] call functionGetNestedArrayWithIndexValue;
		if (count _duplicateRequest == 0)
		then
		{
			slingLoadingRequestsPending pushBack [_vehicle, _requesterUID];
		};
	};
	if (count _duplicateRequest == 0)
	then
	{
		if (isNil 'slingLoadingRequestsCount')
		then
		{
			slingLoadingRequestsCount = 0;
		}
		else
		{
			slingLoadingRequestsCount = slingLoadingRequestsCount + 1;
		};
		[_vehicle, _requesterUID] call functionEstablishPrepareSlingLoadingRequestScrollMenuAction;
	};
};

functionEstablishPrepareSlingLoadingRequestScrollMenuAction =
{
	_vehicle = _this select 0;
	_requesterUID = _this select 1;
	player addAction ['<t color="#FF8000">Sling Loading Request</t>', functionOpenPrepareSlingLoadingRequest, [_vehicle, _requesterUID], 2000, true, true, '', 'alive _target'];
};

functionOpenPrepareSlingLoadingRequest =
{
	_scrollMenuActionID = _this select 2;
	_vehicle = (_this select 3) select 0;
	_requesterUID = (_this select 3) select 1;
	createDialog 'nwDialogueSlingLoadingRequest';
	_playerDataRecord = [playersDataPublic, 0, _requesterUID] call functionGetNestedArrayWithIndexValue;
	_requesterName = _playerDataRecord select 1;
	_requestInformation = format ['%1 requests your %2 to be prepared for sling loading.', _requesterName, (_vehicle getVariable 'vehicleName')];
	ctrlSetText [16000, _requestInformation];
	slingLoadingRequestVehicleVariableName = format ['slingLoadingRequestVehicle%1', slingLoadingRequestsCount];
	missionNamespace setVariable [slingLoadingRequestVehicleVariableName, _vehicle];
	buttonSetAction [16001, format ['["%1", "%2", %3] call functionPrepareSlingLoadingRequestApprove; closeDialog 0;', slingLoadingRequestVehicleVariableName, _requesterUID, _scrollMenuActionID]];
	buttonSetAction [16002, format ['["%1", "%2", %3] call functionPrepareSlingLoadingRequestDecline; closeDialog 0;', slingLoadingRequestVehicleVariableName, _requesterUID, _scrollMenuActionID]];
};

functionPrepareSlingLoadingRequestApprove =
{
	_vehicle = missionNamespace getVariable (_this select 0);
	_requesterUID = _this select 1;
	_scrollMenuActionID = _this select 2;
	player removeAction _scrollMenuActionID;
	[slingLoadingRequestsPending, 0, _vehicle] call functionRemoveNestedArrayWithIndexValue;
	[[_vehicle, _requesterUID, (player getVariable 'team')], 'functionPrepareSlingLoadingEnactServer', false] call BIS_fnc_MP;
};

functionPrepareSlingLoadingRequestDecline =
{
	_vehicle = missionNamespace getVariable (_this select 0);
	_requesterUID = _this select 1;
	_scrollMenuActionID = _this select 2;
	player removeAction _scrollMenuActionID;
	[slingLoadingRequestsPending, 0, _vehicle] call functionRemoveNestedArrayWithIndexValue;
	_requesterObject = [_requesterUID] call functionGetPlayerObjectWithUID;
	if (!(isNull _requesterObject))
	then
	{
		[[_vehicle], 'functionHandlePrepareSlingLoadingRequestDecline', _requesterObject] call BIS_fnc_MP;
	};
};

functionHandlePrepareSlingLoadingRequestApprove =
{
	_vehicle = _this select 0;
	_requesterUID = _this select 1;
	_requesterDataRecord = [playersDataPublic, 0, _requesterUID] call functionGetNestedArrayWithIndexValue;
	_requesterName = _requesterDataRecord select 1;
	_ownerDataRecord = [playersDataPublic, 0, (_vehicle getVariable 'ownerUID')] call functionGetNestedArrayWithIndexValue;
	_ownerName = _ownerDataRecord select 1;
	_ownerObject = [_vehicle getVariable 'ownerUID'] call functionGetPlayerObjectWithUID;
	_requesterObject = [_requesterUID] call functionGetPlayerObjectWithUID;
	_message = '';
	if (_ownerObject == _requesterObject or isNull _ownerObject)
	then
	{
		_message = format ['%1 prepared for sling loading.', (_vehicle getVariable 'vehicleName')];
	}
	else
	{
		_message = format ['%1 approved sling loading.', _ownerName];
	};
	systemChat _message;
	['NotificationPositive', ['Prepared Sling Loading', _message]] call bis_fnc_showNotification;
};

functionHandlePrepareSlingLoadingRequestDecline =
{
	_vehicle = _this select 0;
	_playerDataRecord = [playersDataPublic, 0, (_vehicle getVariable 'ownerUID')] call functionGetNestedArrayWithIndexValue;
	_ownerName = _playerDataRecord select 1;
	_message = format ['%1 declined sling loading.', _ownerName];
	systemChat _message;
	['NotificationNegative', ['Request Declined', _message]] call bis_fnc_showNotification;
};

functionUnprepareSlingLoadingClient =
{
	_vehicle = _this select 0;
	[[_vehicle], 'functionUnprepareSlingLoadingServer', false] call BIS_fnc_MP;
};

functionEstablishManualHookScrollMenuAction =
{
	_helicopter = _this select 0;
	_helicopter addAction ['<t color="#86F078">Manual Hook</t>', functionBeginManualHook, [_helicopter], 1002, false, true, '', '(alive _target) and (driver _target == _this) and !(_target getVariable "slingLoadingManualHookInProgress") and (count (ropes _target) == 0)'];
	_helicopter addAction ['<t color="#86F078">Manual Unhook</t>', functionAbortManualHook, [_helicopter], 1002, false, true, '', '(alive _target) and (driver _target == _this) and (_target getVariable "slingLoadingManualHookInProgress")'];
};

functionBeginManualHook =
{
	_helicopter = (_this select 3) select 0;
	_helicopter setVariable ['slingLoadingManualHookInProgress', true, true];
	_rope = ropeCreate [_helicopter, 'slingLoad0', slingLoadingManualHookLength];
	[[_helicopter, _rope], 'functionAwaitManualHookServer', false] call BIS_fnc_MP;
};

functionEnactManualHookLocal =
{
	_hookableObject = _this select 0;
	_rope = _this select 1;
	[_hookableObject, [0,0,0], [0,0,-1]] ropeAttachTo _rope;
	_message = format ['%1 hooked.', (_hookableObject getVariable 'vehicleName')];
	systemChat _message;
	['NotificationPositive', ['Hooked', _message]] call bis_fnc_showNotification;
};

functionAbortManualHook =
{
	_helicopter = (_this select 3) select 0;
	{
		ropeDestroy _x;
	} forEach (ropes _helicopter);
	_helicopter setVariable ['slingLoadingManualHookInProgress', false, true];
};