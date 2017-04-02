functionPrepareSlingLoadingServer =
{
	_vehicle = _this select 0;
	_requesterObject = _this select 1;
	_team = _this select 2;
	_requesterUID = getPlayerUID _requesterObject;
	_ownerObject = [_vehicle getVariable 'ownerUID'] call functionGetPlayerObjectWithUID;
	if (isNull _ownerObject or (_requesterObject == _ownerObject))
	then
	{
		diag_log 'Owner is offline or owner is requester.';
		[_vehicle, _requesterUID, _team] spawn functionPrepareSlingLoadingEnactServer;
	}
	else
	{
		diag_log 'Owner is online, and requester is not owner.';
		[[_vehicle], 'functionHandlePrepareSlingLoadingRequestDispatched', _requesterObject] call BIS_fnc_MP;
		[[_vehicle, _requesterUID], 'functionHandlePrepareSlingLoadingRequest', _ownerObject] call BIS_fnc_MP;
	};
};

functionPrepareSlingLoadingEnactServer =
{
	_vehicle = _this select 0;
	_requesterUID = _this select 1;
	_team = _this select 2;
	_teamLiteral = [_team] call functionGetTeamFORName;
	_maximumMass = missionNamespace getVariable (format ['slingLoadingMaximumMass%1', _teamLiteral]);
	diag_log format ['_maximumMass: %1.', _maximumMass];
	if (getMass _vehicle > (_maximumMass / 2))
	then
	{
		[[_vehicle, _maximumMass / 2], 'functionObjectSetMass', owner _vehicle] call BIS_fnc_MP;
	};
	_vehicle enableRopeAttach true;
	[_vehicle] call functionDisableEngine;
	_vehicle setVariable ['slingLoadingPermitted', true, true];
	// In future, prevent engine from turning on while sling loading occurs
	_requesterObject = [_requesterUID] call functionGetPlayerObjectWithUID;
	[[_vehicle, _requesterUID], 'functionHandlePrepareSlingLoadingRequestApprove', _requesterObject] call BIS_fnc_MP;
	diag_log format ['Starting sling loading. Ropes Attached to Vehicle: %1', !(isNull (ropeAttachedTo _vehicle))];
	_scriptHandle = [_vehicle] spawn functionHandleSlingLoadingFinished;
	_vehicle setVariable ['slingLoadingScriptHandle', _scriptHandle];
	sleep slingLoadingPrepareDuration;
	diag_log format ['Slept prepare sling loading. Ropes Attached to Vehicle: %1', !(isNull (ropeAttachedTo _vehicle))];
	if (isNull (ropeAttachedTo _vehicle))
	then
	{
		terminate _scriptHandle;
		[[_vehicle, (_vehicle getVariable 'initialMass')], 'functionObjectSetMass', owner _vehicle] call BIS_fnc_MP;
		_vehicle enableRopeAttach false;
		[_vehicle] call functionEnableEngine;
		_vehicle setVariable ['slingLoadingPermitted', false, true];
	};
};

functionHandleSlingLoadingFinished =
{
	_vehicle = _this select 0;
	diag_log format ['Ropes not attached to vehicle. Ropes Attached to Vehicle: %1', !(isNull (ropeAttachedTo _vehicle))];
	waitUntil {!(isNull (ropeAttachedTo _vehicle))};
	diag_log format ['Ropes now attached to vehicle. Ropes Attached to Vehicle: %1', !(isNull (ropeAttachedTo _vehicle))];
	waitUntil {isNull (ropeAttachedTo _vehicle)};
	diag_log format ['Ropes now detached from vehicle. Ropes Attached to Vehicle: %1', !(isNull (ropeAttachedTo _vehicle))];
	[[_vehicle, (_vehicle getVariable 'initialMass')], 'functionObjectSetMass', owner _vehicle] call BIS_fnc_MP;
	_vehicle enableRopeAttach false;
	[_vehicle] call functionEnableEngine;
	_vehicle setVariable ['slingLoadingPermitted', false, true];
};

functionUnprepareSlingLoadingServer =
{
	_vehicle = _this select 0;
	if (isNull (ropeAttachedTo _vehicle))
	then
	{
		terminate (_vehicle getVariable 'slingLoadingScriptHandle');
		[[_vehicle, (_vehicle getVariable 'initialMass')], 'functionObjectSetMass', owner _vehicle] call BIS_fnc_MP;
		_vehicle enableRopeAttach false;
		[_vehicle] call functionEnableEngine;
		_vehicle setVariable ['slingLoadingPermitted', false, true];
	};
};

functionAwaitManualHookServer =
{
	_helicopter = _this select 0;
	_rope = _this select 1;
	_secondsSlept = 0;
	while {true}
	do
	{
		scopeName 'awaitManualHookLoop';
		_hookInProgress = _helicopter getVariable 'slingLoadingManualHookInProgress';
		_ropeConnectedToHelicopter = _rope in (ropes _helicopter);
		diag_log format ['_hookInProgress: %1. _ropeConnectedToHelicopter: %2.', _hookInProgress, _ropeConnectedToHelicopter];
		if (_hookInProgress and _ropeConnectedToHelicopter and _secondsSlept <= slingLoadingManualHookDuration)
		then
		{
			_ropeEndPositions = ropeEndPosition _rope;
			diag_log format ['_ropeEndPositions: %1.', _ropeEndPositions];
			_objectsIntersectingRope = lineIntersectsObjs [ATLToASL (_ropeEndPositions select 0), ATLToASL (_ropeEndPositions select 1), objNull, objNull, true];
			diag_log format ['_objectsIntersectingRope: %1.', _objectsIntersectingRope];
			_hookableObject = objNull;
			{
				scopeName 'objectsIntersectingRopeLoop';
				if ((_x getVariable ['slingLoadingPermitted', false]))
				then
				{
					_hookableObject = _x;
					breakOut 'objectsIntersectingRopeLoop';
				};
			} forEach _objectsIntersectingRope;
			if (!(isNull _hookableObject))
			then
			{
				diag_log 'About to hook _hookableObject.';
				[_helicopter, _rope, _hookableObject] spawn functionHandleManualHookUnexpectedDetachment;
				[[_hookableObject, _rope], 'functionEnactManualHookLocal', owner _helicopter] call BIS_fnc_MP;
				breakOut 'awaitManualHookLoop';
			};
			_secondsSlept = _secondsSlept + 1;
			sleep 1;
		}
		else
		{
			breakOut 'awaitManualHookLoop';
		};
	};
};

functionHandleManualHookUnexpectedDetachment =
{
	_helicopter = _this select 0;
	_rope = _this select 1;
	_hookedObject = _this select 2;
	diag_log 'Preparing to handle unexpected detachment.';
	waitUntil {(_hookedObject in (ropeAttachedObjects _helicopter))};
	diag_log 'Hook is now in place - ready to handle unexpected detachment.';
	waitUntil {!(_hookedObject in (ropeAttachedObjects _helicopter))};
	diag_log 'Hook has detached unexpectedly. Destroying rope.';
	[[_hookedObject, (_hookedObject getVariable 'initialMass')], 'functionObjectSetMass', owner _hookedObject] call BIS_fnc_MP;
	_vehicle setVariable ['slingLoadingPermitted', false, true];
	ropeDestroy _rope;
	_helicopter setVariable ['slingLoadingManualHookInProgress', false, true];
};