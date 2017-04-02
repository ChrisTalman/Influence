functionOpenBuildInterface =
{
	if ({(_x getVariable 'team') == side player} count playerControlledBases == 0)
	then
	{
		hint 'There are no bases to build at!';
	}
	else
	{
		buildViewSubjectObject = playerControlledBases select 0;
		[true] call functionHideOppositeTeamFromPlayer;
		_buildViewStartingPosition = position buildViewSubjectObject;
		_buildViewStartingPosition set [2, buildViewStartingAltitude];
		buildCamera = 'camera' camCreate _buildViewStartingPosition;
		showCinemaBorder false;
		buildCamera cameraEffect ['EXTERNAL', 'BACK'];
		buildCamera setVectorUp [0,0.99,0.01];
		buildViewLastFrameTime = (time * 1000);
		buildViewKeyDirectionsActive = [];
		createDialog 'nwDialogueBuildView';
		functionHandleBuildViewBaseLossReference = [] spawn functionHandleBuildViewBaseLoss;
		ctrlEnable [4001, false];
		[4004, side player, objNull, objNull, true] call functionPopulateBaseList;
		buildViewKeyDownEventListenerID = (findDisplay screenDisplayID) displayAddEventHandler ['KeyDown', {[_this select 1] call functionBuildViewKeyDownEvent}];
		buildViewKeyUpEventListenerID = (findDisplay screenDisplayID) displayAddEventHandler ['KeyUp', {[_this select 1] call functionBuildViewKeyUpEvent}];
		(findDisplay 4) displayAddEventHandler ['KeyDown', {[_this select 1] call functionBuildViewPreventDialogueEscape}];
		buildViewBuildBoundaryPring = [position buildViewSubjectObject, buildViewBuildRadius, [0.1, 0.2, 0.9, 0.5],  9, cycleBuildViewBorderQuality select 1] call pringCreate;
		buildViewCaptureBoundaryPring = [position buildViewSubjectObject,  buildViewRadius, [0.9, 0.2, 0.1, 0.5], -9, cycleBuildViewBorderQuality select 1] call pringCreate;
		['buildViewFrameEvent', 'onEachFrame', {call functionBuildViewFrameEvent;}] call BIS_fnc_addStackedEventHandler;
	};
};

functionUpdateBuildViewInformation =
{
	_text = '<t font="PuristaMedium" size="2" align="center">';
	_text = _text + 'WASD - Movement. Q,E - Altitude. Z,X - Rotation.<br/><t color="#801A33E6">Blue</t> Smoke - Build Boundary. <t color="#80E6331A">Red</t> Smoke - Capture Boundary.';
	_text = _text + (format ['<br/><br/>%1 has €%2.', buildViewSubjectObject getVariable 'name', buildViewSubjectObject getVariable 'supplyAmount']);
	_text = _text + '</t>';
	((findDisplay 4) displayCtrl 4000) ctrlSetStructuredText (parseText _text);
};

functionBuildBuildableObject =
{
	_desiredBuildableObjectName = lbData [4003, (lbCurSel 4003)];
	buildCameraPosition2D = [position buildCamera select 0, position buildCamera select 1];
	// Should be altered in future to more easily support removal of objects which have limited intersection on ground level
	if (_desiredBuildableObjectName == 'Remove')
	then
	{
		//_buildCameraPositionASL = [(getPosASL buildCamera) select 0, (getPosASL buildCamera) select 1, (((getPosASL buildCamera) select 2) - (position buildCamera select 2))];
		_buildCameraPositionLow = position buildCamera;
		_buildCameraPositionLow set [2, 0];
		_buildCameraPositionHigh = position buildCamera;
		_buildCameraPositionHigh set [2, buildViewMaximumAltitude];
		_objectsAtCameraPosition = lineIntersectsObjs [ATLToASL _buildCameraPositionLow, ATLToASL _buildCameraPositionHigh, objNull, objNull, true];
		//systemChat format ['_objectsAtCameraPosition: %1.', _objectsAtCameraPosition];
		//diag_log format ['_objectsAtCameraPosition: %1.', _objectsAtCameraPosition];
		if ((count _objectsAtCameraPosition) > 0)
		then
		{
			_closestObject = _objectsAtCameraPosition select ((count _objectsAtCameraPosition) - 1);
			_baseStructures = buildViewSubjectObject getVariable 'structures';
			_baseDefences = buildViewSubjectObject getVariable 'defences';
			if ((_closestObject in _baseStructures) or (_closestObject in _baseDefences))
			then
			{
				_modifiedArray = [];
				_structuresOrDefencesString = '';
				if (_closestObject in _baseStructures)
				then
				{
					_modifiedArray = _baseStructures;
					_structuresOrDefencesString = 'structures';
				}
				else
				{
					_modifiedArray = _baseDefences;
					_structuresOrDefencesString = 'defences';
				};
				_modifiedArray deleteAt (_modifiedArray find _closestObject);
				buildViewSubjectObject setVariable [_structuresOrDefencesString, _modifiedArray, true];
				if ((typeName (_closestObject getVariable 'staticDefenceUnit')) == 'OBJECT')
				then
				{
					deleteVehicle (_closestObject getVariable 'staticDefenceUnit');
				};
				deleteVehicle _closestObject;
			};
		};
	}
	else
	{
		_desiredBuildableObject = [baseBuildableObjects, 0, _desiredBuildableObjectName] call functionGetNestedArrayWithIndexValue;
		_desiredBuildableObjectEngineName = _desiredBuildableObject select 1;
		_desiredBuildableObjectSupplyCost = _desiredBuildableObject select 2;
		_buildPositionIsWater = surfaceIsWater buildCameraPosition2D;
		_buildPossible = true;
		if (_desiredBuildableObjectName == 'Naval Facility')
		then
		{
			if (!(_buildPositionIsWater))
			then
			{
				_buildPossible = false;
				systemChat 'Naval Facilities must be built in water.';
			};
		}
		else
		{
			if (_buildPositionIsWater)
			then
			{
				_buildPossible = false;
				systemChat format ['%1 must be built on land.', _desiredBuildableObjectName];
			};
		};
		if (_desiredBuildableObjectName in ['Infantry Facility', 'Light Vehicle Facility', 'Heavy Vehicle Facility', 'Air Facility', 'Naval Facility'])
		then
		{
			if (!(isNull (buildViewSubjectObject getVariable ([_desiredBuildableObjectName] call functionGetBaseFacilityIdentifierFromLiteral))))
			then
			{
				_buildPossible = false;
				systemChat format ['%1 has already been built.', _desiredBuildableObjectName];
			};
		};
		if ((buildViewSubjectObject getVariable 'supplyAmount') < _desiredBuildableObjectSupplyCost)
		then
		{
			_buildPossible = false;
			call functionUpdateBuildViewInformation;
			systemChat format ['%1 has insufficient supply.', buildViewSubjectObject getVariable 'name'];
		};
		if (_buildPossible)
		then
		{
			systemChat 'Processing build request...';
			[[_desiredBuildableObjectName, buildCameraPosition2D, getDir buildViewPreviewObject, buildViewSubjectObject, player], 'functionEnactBaseBuildRequest', false] call BIS_fnc_MP;
		};
	};
};

functionHandleBuildViewBuildSuccess =
{
	_buildName = _this select 0;
	call functionUpdateBuildViewInformation;
	systemChat format ['%1 has been built successfully.', _buildName];
};

functionHandleBuildViewBuildError =
{
	_buildName = _this select 0;
	systemChat format ['Unfortunately, an error has occurred while attempting to build %1. Please try again.', _buildName];
};

functionHandleBuildViewObjectListSelection =
{
	_desiredBuildableObjectName = lbData [4003, (lbCurSel 4003)];
	ctrlSetFocus ((findDisplay 4) displayCtrl 4001);
	if (_desiredBuildableObjectName == 'Nothing')
	then
	{
		ctrlEnable [4001, false];
		if (!(isNil('buildViewPreviewObject')))
		then
		{
			if (!(isNull(buildViewPreviewObject)))
			then
			{
				deleteVehicle buildViewPreviewObject;
			};
		};
	}
	else
	{
		ctrlEnable [4001, true];
		if (_desiredBuildableObjectName == 'Remove')
		then
		{
			ctrlSetText [4001, 'Remove'];
			if (!(isNull(buildViewPreviewObject)))
			then
			{
				deleteVehicle buildViewPreviewObject;
			};
			buildViewPreviewObject = 'Sign_Arrow_Large_F' createVehicleLocal ([position buildCamera select 0, position buildCamera select 1, 0]);
		}
		else
		{
			ctrlSetText [4001, 'Build'];
			_desiredBuildableObject = [baseBuildableObjects, 0, _desiredBuildableObjectName] call functionGetNestedArrayWithIndexValue;
			_desiredBuildableObjectEngineName = _desiredBuildableObject select 1;
			if (!(isNull(buildViewPreviewObject)))
			then
			{
				deleteVehicle buildViewPreviewObject;
			};
			buildViewPreviewObject = _desiredBuildableObjectEngineName createVehicleLocal ([position buildCamera select 0, position buildCamera select 1, 0]);
		};
	};
};

functionHandleBuildViewBaseSelection =
{
	_buildViewSelectedBaseID = lbData [4004, (lbCurSel 4004)];
	_buildableObjects = [];
	{
		_subjectObject = _x;
		if ((_subjectObject getVariable 'id') == _buildViewSelectedBaseID)
		then
		{
			buildViewSubjectObject = _subjectObject;
			if (((_subjectObject getVariable 'id') find 'base') >= 0)
			then
			{
				buildViewRadius = baseRadius;
				buildViewBuildRadius = baseBuildRadius;
				_buildableObjects = baseBuildableObjects;
			}
			else
			{
				if (((_subjectObject getVariable 'id') find 'FOB') >= 0)
				then
				{
					buildViewRadius = FOBRadius;
					buildViewBuildRadius = FOBBuildRadius;
					_buildableObjects = FOBBuildableObjects;
				};
			};
		};
	} forEach (playerControlledBases + FOBs);
	call functionUpdateBuildViewInformation;
	lbClear 4003;
	_indexInList = lbAdd [4003, 'Nothing'];
	lbSetData [4003, _indexInList, 'Nothing'];
	lbSetCurSel [4003, 0];
	{
		_buildableObjectName = _x select 0;
		_buildableObjectSupplyCost = _x select 2;
		_indexInList = lbAdd [4003, format ['€%1 %2', _buildableObjectSupplyCost, _buildableObjectName]];
		lbSetData [4003, _indexInList, _buildableObjectName];
	} forEach _buildableObjects;
	_indexInList = lbAdd [4003, 'Remove'];
	lbSetData [4003, _indexInList, 'Remove'];
	buildCamera setPos [position buildViewSubjectObject select 0, position buildViewSubjectObject select 1, ((position buildViewSubjectObject select 2) + 10)];
	ctrlSetFocus ((findDisplay 4) displayCtrl 4001);
};

functionBuildViewKeyDownEvent =
{
	_keyDownID = _this select 0;
	_preventDefaultKeyBehaviour = false;
	// Up
	if (_keyDownID == keyCodeW)
	then
	{
		if (!("up" in buildViewKeyDirectionsActive))
		then
		{
			buildViewKeyDirectionsActive = buildViewKeyDirectionsActive + ["up"];
		};
	};
	// Left
	if (_keyDownID == keyCodeA)
	then
	{
		if (!("left" in buildViewKeyDirectionsActive))
		then
		{
			buildViewKeyDirectionsActive = buildViewKeyDirectionsActive + ["left"];
		};
	};
	// Down
	if (_keyDownID == keyCodeS)
	then
	{
		if (!("down" in buildViewKeyDirectionsActive))
		then
		{
			buildViewKeyDirectionsActive = buildViewKeyDirectionsActive + ["down"];
		};
	};
	// Right
	if (_keyDownID == keyCodeD)
	then
	{
		if (!("right" in buildViewKeyDirectionsActive))
		then
		{
			buildViewKeyDirectionsActive = buildViewKeyDirectionsActive + ["right"];
		};
	};
	// Ascend
	if (_keyDownID == keyCodeQ)
	then
	{
		if (!("ascend" in buildViewKeyDirectionsActive))
		then
		{
			buildViewKeyDirectionsActive = buildViewKeyDirectionsActive + ["ascend"];
		};
	};
	// Descend
	if (_keyDownID == keyCodeE)
	then
	{
		if (!("descend" in buildViewKeyDirectionsActive))
		then
		{
			buildViewKeyDirectionsActive = buildViewKeyDirectionsActive + ["descend"];
		};
	};
	// Rotate Right
	if (_keyDownID == keyCodeX)
	then
	{
		if (!("rotateRight" in buildViewKeyDirectionsActive))
		then
		{
			buildViewKeyDirectionsActive = buildViewKeyDirectionsActive + ["rotateRight"];
		};
	};
	// Rotate Left
	if (_keyDownID == keyCodeZ)
	then
	{
		if (!("rotateLeft" in buildViewKeyDirectionsActive))
		then
		{
			buildViewKeyDirectionsActive = buildViewKeyDirectionsActive + ["rotateLeft"];
		};
	};
	// Shift
	if (_keyDownID == keyCodeLSHIFT)
	then
	{
		if (!("shift" in buildViewKeyDirectionsActive))
		then
		{
			buildViewKeyDirectionsActive = buildViewKeyDirectionsActive + ["shift"];
		};
	};
	// Escape
	if (_keyDownID == keyCodeESCAPE)
	then
	{
		_preventDefaultKeyBehaviour = true;
	};
	_preventDefaultKeyBehaviour;
};

functionBuildViewKeyUpEvent =
{
	_keyDownID = _this select 0; // Needs to be changed from "down" to "up"
	// Up
	if (_keyDownID == keyCodeW)
	then
	{
		if ("up" in buildViewKeyDirectionsActive)
		then
		{
			buildViewKeyDirectionsActive = buildViewKeyDirectionsActive - ["up"];
		};
	};
	// Left
	if (_keyDownID == keyCodeA)
	then
	{
		if ("left" in buildViewKeyDirectionsActive)
		then
		{
			buildViewKeyDirectionsActive = buildViewKeyDirectionsActive - ["left"];
		};
	};
	// Down
	if (_keyDownID == keyCodeS)
	then
	{
		if ("down" in buildViewKeyDirectionsActive)
		then
		{
			buildViewKeyDirectionsActive = buildViewKeyDirectionsActive - ["down"];
		};
	};
	// Right
	if (_keyDownID == keyCodeD)
	then
	{
		if ("right" in buildViewKeyDirectionsActive)
		then
		{
			buildViewKeyDirectionsActive = buildViewKeyDirectionsActive - ["right"];
		};
	};
	// Ascend
	if (_keyDownID == keyCodeQ)
	then
	{
		if ("ascend" in buildViewKeyDirectionsActive)
		then
		{
			buildViewKeyDirectionsActive = buildViewKeyDirectionsActive - ["ascend"];
		};
	};
	// Descend
	if (_keyDownID == keyCodeE)
	then
	{
		if ("descend" in buildViewKeyDirectionsActive)
		then
		{
			buildViewKeyDirectionsActive = buildViewKeyDirectionsActive - ["descend"];
		};
	};
	// Rotate Right
	if (_keyDownID == keyCodeX)
	then
	{
		if ("rotateRight" in buildViewKeyDirectionsActive)
		then
		{
			buildViewKeyDirectionsActive = buildViewKeyDirectionsActive - ["rotateRight"];
		};
	};
	// Rotate Left
	if (_keyDownID == keyCodeZ)
	then
	{
		if ("rotateLeft" in buildViewKeyDirectionsActive)
		then
		{
			buildViewKeyDirectionsActive = buildViewKeyDirectionsActive - ["rotateLeft"];
		};
	};
	// Shift
	if (_keyDownID == keyCodeLSHIFT)
	then
	{
		if ("shift" in buildViewKeyDirectionsActive)
		then
		{
			buildViewKeyDirectionsActive = buildViewKeyDirectionsActive - ["shift"];
		};
	};
	// Enter or Return
	if (_keyDownID == keyCodeRETURN)
	then
	{
		call functionBuildBuildableObject;
	};
};

functionBuildViewFrameEvent =
{
	[buildViewBuildBoundaryPring] call pringUpdate;
	[buildViewCaptureBoundaryPring] call pringUpdate;
	_buildViewMoveSpeedMetresPerSecond = 4;
	_buildViewMoveShiftSpeedMetresPerSecond = 12;
	_buildViewMoveVerticalSpeedMetresPerSecond = 6;
	_buildViewMoveVerticalShiftSpeedMetresPerSecond = 14;
	_buildViewRotateSpeedDegreesPerSecond = 50;
	_buildViewRotateShiftSpeedDegreesPerSecond = 80;
	_secondsSinceLastFrame = (time * 1000) - buildViewLastFrameTime;
	_buildViewMoveAmount = 0;
	_buildViewVerticalMoveAmount = 0;
	_buildViewRotateAmount = 0;
	if ('shift' in buildViewKeyDirectionsActive)
	then
	{
		_buildViewMoveAmount = _buildViewMoveShiftSpeedMetresPerSecond * (_secondsSinceLastFrame / 1000);
		_buildViewVerticalMoveAmount = _buildViewMoveVerticalShiftSpeedMetresPerSecond * (_secondsSinceLastFrame / 1000);
		_buildViewRotateAmount = _buildViewRotateShiftSpeedDegreesPerSecond * (_secondsSinceLastFrame / 1000);
	}
	else
	{
		_buildViewMoveAmount = _buildViewMoveSpeedMetresPerSecond * (_secondsSinceLastFrame / 1000);
		_buildViewVerticalMoveAmount = _buildViewMoveVerticalSpeedMetresPerSecond * (_secondsSinceLastFrame / 1000);
		_buildViewRotateAmount = _buildViewRotateSpeedDegreesPerSecond * (_secondsSinceLastFrame / 1000);
	};
	_moveX = 0;
	_moveY = 0;
	_moveZ = 0;
	_moving = false;
	if ('up' in buildViewKeyDirectionsActive)
	then
	{
		_moveY = _buildViewMoveAmount;
		_moving = true;
	};
	if ('left' in buildViewKeyDirectionsActive)
	then
	{
		_moveX = -(_buildViewMoveAmount);
		_moving = true;
	};
	if ('down' in buildViewKeyDirectionsActive)
	then
	{
		_moveY = -(_buildViewMoveAmount);
		_moving = true;
	};
	if ('right' in buildViewKeyDirectionsActive)
	then
	{
		_moveX = _buildViewMoveAmount;
		_moving = true;
	};
	if ('ascend' in buildViewKeyDirectionsActive)
	then
	{
		_moveZ = _buildViewVerticalMoveAmount;
		_moving = true;
	};
	if ('descend' in buildViewKeyDirectionsActive)
	then
	{
		_moveZ = -(_buildViewVerticalMoveAmount);
		_moving = true;
	};
	if (((position buildCamera select 2) + _moveZ) > buildViewMaximumAltitude)
	then
	{
		_moveZ = (buildViewMaximumAltitude - (position buildCamera select 2));
	};
	if (!([[((position buildCamera select 0) + _moveX), ((position buildCamera select 1)), 0], position (buildViewSubjectObject), buildViewBuildRadius] call functionIsPositionInsideRadiusOfPosition))
	then
	{
		_moveX = 0;
	};
	if (!([[((position buildCamera select 0)), ((position buildCamera select 1) + _moveY), 0], position (buildViewSubjectObject), buildViewBuildRadius] call functionIsPositionInsideRadiusOfPosition))
	then
	{
		_moveY = 0;
	};
	if (_moving)
	then
	{
		buildCamera setPos [((position buildCamera select 0) + _moveX), ((position buildCamera select 1) + _moveY), ((position buildCamera select 2) + _moveZ)];
	};
	if (!(isNull(buildViewPreviewObject)))
	then
	{
		buildViewPreviewObject setPos [position buildCamera select 0, position buildCamera select 1, 0];
		_rotateDegrees = 0;
		_rotating = false;
		if ('rotateRight' in buildViewKeyDirectionsActive)
		then
		{
			_rotateDegrees = _buildViewRotateAmount;
			_rotating = true;
		};
		if ('rotateLeft' in buildViewKeyDirectionsActive)
		then
		{
			_rotateDegrees = -(_buildViewRotateAmount);
			_rotating = true;
		};
		if (_rotating)
		then
		{
			buildViewPreviewObject setDir ((getDir buildViewPreviewObject) + _rotateDegrees);
		};
	};
	/*if (count buildViewKeyDirectionsActive > 0)
	then
	{
		systemChat format ["buildCamera y: %1.", (position buildCamera select 2)];
	};*/
	buildViewLastFrameTime = (time * 1000);
};

functionBuildViewPreventDialogueEscape =
{
	_preventDefaultKeyBehaviour = false;
	_keyDownID = _this select 0;
	if (_keyDownID == keyCodeESCAPE)
	then
	{
		_preventDefaultKeyBehaviour = true;
		call functionExitBuildView;
	}
	else
	{
		_preventDefaultKeyBehaviour = false;
	};
	_preventDefaultKeyBehaviour;
};

functionHandleBuildViewBaseLoss =
{
	waitUntil {(buildViewSubjectObject getVariable 'team') != (player getVariable 'team')};
	call functionExitBuildView;
};

functionExitBuildView =
{
	closeDialog 0;
	terminate functionHandleBuildViewBaseLossReference;
	(findDisplay screenDisplayID) displayRemoveEventHandler ['KeyDown', buildViewKeyDownEventListenerID];
	(findDisplay screenDisplayID) displayRemoveEventHandler ['KeyUp', buildViewKeyUpEventListenerID];
	['buildViewFrameEvent', 'onEachFrame'] call BIS_fnc_removeStackedEventHandler;
	[buildViewBuildBoundaryPring] call pringDestroy;
	[buildViewCaptureBoundaryPring] call pringDestroy;
	if (!(isNil('buildViewPreviewObject')))
	then
	{
		if (!(isNull(buildViewPreviewObject)))
		then
		{
			deleteVehicle buildViewPreviewObject;
		};
	};
	buildCamera cameraEffect ['terminate', 'back'];
	camDestroy buildCamera;
	[false] call functionHideOppositeTeamFromPlayer;
	buildViewSubjectObject = objNull;
};