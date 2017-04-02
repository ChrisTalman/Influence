functionEstablishEquipmentCharacterView =
{
	_nearestBase = [position player, true] call functionFindNearestBase;
	_baseRadius = [_nearestBase] call functionGetBaseRadius;
	_equipmentAccessPointInRange = false;
	if (!(isNull _nearestBase))
	then
	{
		if ((position _nearestBase) distance (position player) <= _baseRadius)
		then
		{
			_equipmentAccessPointInRange = true;
		};
	};
	if (!_equipmentAccessPointInRange)
	then
	{
		{
			if ((_x getVariable 'team') == (player getVariable 'team'))
			then
			{
				if ((position _x) distance (position player) <= mobileRespawnSpawnRadius)
				then
				{
					_equipmentAccessPointInRange = true;
				};
			};
		} forEach mobileRespawnPoints;
	};
	if (_equipmentAccessPointInRange)
	then
	{
		['Open', true] spawn BIS_fnc_arsenal;
	}
	else
	{
		_message = 'You must be within radius of base, FOB, or mobile respawn to select equipment.';
		systemChat _message;
		hint _message;
	};
	/*equipmentCharacterViewOriginalPlayerDirection = direction player;
	_playerPosition2D = [-1.2, ([2.2, position player, equipmentCharacterViewOriginalPlayerDirection, 0] call functionGetAngleRelativePosition), equipmentCharacterViewOriginalPlayerDirection, 90] call functionGetAngleRelativePosition;
	equipmentCamera = "camera" camCreate [_playerPosition2D select 0, _playerPosition2D select 1, ((position player) select 2) + 0.9];
	[] spawn functionEquipmentCharacterViewAnimationLoop;
	equipmentCamera setDir ((equipmentCharacterViewOriginalPlayerDirection) - 180);
	player setDir ([player, equipmentCamera] call BIS_fnc_dirTo);
	showCinemaBorder false;
	equipmentCamera cameraEffect ["EXTERNAL", "BACK"];
	equipmentCharacterViewKeyDownEventListenerID = (findDisplay screenDisplayID) displayAddEventHandler ["KeyDown", {[_this select 1] call functionEquipmentCharacterViewPreventDialogueEscape}];*/
};

functionEquipmentCharacterViewAnimationLoop =
{
	while {!(isNull equipmentCamera)}
	do
	{
		player playMoveNow "AidlPercMstpSrasWrflDnon_G01";
		waitUntil {animationState player == "AidlPercMstpSrasWrflDnon_G01"};
		waitUntil {animationState player != "AidlPercMstpSrasWrflDnon_G01"};
	};
};

functionEquipmentCharacterViewPreventDialogueEscape =
{
	_preventDefaultKeyBehaviour = false;
	_keyDownID = _this select 0;
	if (_keyDownID == keyCodeESCAPE)
	then
	{
		_preventDefaultKeyBehaviour = true;
		call functionExitEquipmentCharacterView;
	}
	else
	{
		_preventDefaultKeyBehaviour = false;
	};
	_preventDefaultKeyBehaviour;
};

functionExitEquipmentCharacterView =
{
	(findDisplay screenDisplayID) displayRemoveEventHandler ["KeyDown", equipmentCharacterViewKeyDownEventListenerID];
	equipmentCamera cameraEffect ["terminate","back"];
	camDestroy equipmentCamera;
	player playMoveNow "amovpercmstpsraswrfldnon";
	player switchMove "amovpercmstpsraswrfldnon";
	player setDir equipmentCharacterViewOriginalPlayerDirection;
};

functionHandleVirtualArsenalOpenClose =
{
	while {true}
	do
	{
		waitUntil {!(isNull (uiNamespace getVariable 'RscDisplayArsenal'))};
		waitUntil {isNull (uiNamespace getVariable 'RscDisplayArsenal')};
		// playerLoadout array format: uniform, vest, backpack, headgear, goggles, weapon items, assigned items, uniform items, vest items, backpack items
		playerLoadout = [uniform player] + [vest player] + [backpack player] + [headgear player] + [goggles player] + [weaponsItems player] + [assignedItems player] + [uniformItems player] + [vestItems player] + [backpackItems player];
	};
};