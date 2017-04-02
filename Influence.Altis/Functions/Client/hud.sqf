functionEstablishHUD =
{
	('hudLayer' call BIS_fnc_rscLayer) cutRsc['nwHUD', 'PLAIN', 0, false];
	call functionHandleHealth;
	player addEventHandler ['HandleDamage', {call functionHandleHealth}];
	player addEventHandler ['HandleHeal', {call functionHandleHealth}];
	[] spawn functionUpdatePanelHUDByInterval;
	[] spawn functionUpdateTeamsInformationHUDByInterval;
	[] spawn functionHandlePlayerGetInVehicle;
};

functionUpdatePanelHUD =
{
	_playerHealth = round (100 - ((damage player) * 100));
	_playerStamina = round (100 - ((getFatigue player) * 100));
	_objectiveBonus = '';
	if (personalSupplyQuotaObjectiveBonusAwarded)
	then
	{
		_objectiveBonus = ' incl. obj. bonus';
	};
	_objectivesCount = count objectivesBLUFOR;
	((uiNamespace getVariable 'nwHUD') displayCtrl 102) ctrlSetStructuredText (parseText format['<t size="2.5" shadow="2">€%1 (+€%2/%3s%4) | <t color="#86F078">Network</t> | Objectives: %5 | Missions: %6 | Health: %7 | Stamina: %8</t>', personalSupplyQuota, personalSupplyQuotaIncome, regularSupplyIncomeInterval, _objectiveBonus, _objectivesCount, amountMissionsAvailable, _playerHealth, _playerStamina]);
};

functionUpdatePanelHUDByInterval =
{
	_vehicle = _this select 0;
	while {true}
	do
	{
		call functionUpdatePanelHUD;
		_currentServerTime = serverTime;
		waitUntil {serverTime >= (_currentServerTime + panelHUDUpdateIntervalInSeconds)};
	};
};

functionHandleHealth = 
{
	call functionUpdatePanelHUD;
};

functionUpdateVehicleOccupancyHUD =
{
	_vehicle = _this select 0;
	_hudText = '<t size="2" shadow="2">';
	_vehicleName = _vehicle getVariable ['vehicleName', (getText (configFile >> 'CfgVehicles' >> (typeOf _vehicle) >> 'displayName'))];
	_hudText = _hudText + format ['%1<br/>', _vehicleName];
	{
		if (_x == (driver _vehicle))
		then
		{
			_hudText = _hudText + format ['%1 <img image="A3\ui_f\data\igui\cfg\commandbar\imageDriver_ca.paa"/><br/>', name _x];
		}
		else
		{
			if (_x == (gunner _vehicle))
			then
			{
				_hudText = _hudText + format ['%1 <img image="A3\ui_f\data\igui\cfg\commandbar\imageGunner_ca.paa"/><br/>', name _x];
			}
			else
			{
				if (_x == (commander _vehicle))
				then
				{
					_hudText = _hudText + format ['%1 <img image="A3\ui_f\data\igui\cfg\commandbar\imageCommander_ca.paa"/><br/>', name _x];
				}
				else
				{
					_hudText = _hudText + format ['%1<br/>', name _x];
				};
			};
		};
	} forEach (crew _vehicle);
	_hudText = _hudText + '</t>';
	((uiNamespace getVariable 'nwHUD') displayCtrl 103) ctrlSetStructuredText (parseText _hudText);
};

functionUpdateVehicleOccupancyHUDByInterval =
{
	_vehicle = _this select 0;
	while {(vehicle player) == _vehicle}
	do
	{
		[_vehicle] call functionUpdateVehicleOccupancyHUD;
		_currentServerTime = serverTime;
		waitUntil {serverTime >= (_currentServerTime + vehicleOccupancyHUDUpdateIntervalInSeconds)};
	};
};

functionClearVehicleOccupancyHUD =
{
	((uiNamespace getVariable 'nwHUD') displayCtrl 103) ctrlSetStructuredText (parseText '');
};

functionHandlePlayerGetInVehicle =
{
	while {true}
	do
	{
		waitUntil {vehicle player != player};
		_currentVehicle = (vehicle player);
		[_currentVehicle] spawn functionUpdateVehicleOccupancyHUDByInterval;
		_getInEventID = _currentVehicle addEventHandler ['GetIn', {[_this select 0] call functionUpdateVehicleOccupancyHUD}];
		_getOutEventID = _currentVehicle addEventHandler ['GetOut', {[_this select 0] call functionUpdateVehicleOccupancyHUD}];
		waitUntil {vehicle player == player};
		_currentVehicle removeEventHandler ['GetIn', _getInEventID];
		_currentVehicle removeEventHandler ['GetOut', _getOutEventID];
		call functionClearVehicleOccupancyHUD;
	};
};

functionUpdateTeamsInformationHUD =
{
	_amountPlayers = call functionGetPlayerCountForTeams;
	_amountBLUFORPlayers = _amountPlayers select 0;
	_amountOPFORPlayers = _amountPlayers select 1;
	_commanderNameBLUFOR = '<t color="#BDBDBD">No Commander</t>';
	_commanderNameOPFOR = '<t color="#BDBDBD">No Commander</t>';
	if (commanderBLUFOR != '')
	then
	{
		_playerDataRecord = [playersDataPublic, 0, commanderBLUFOR] call functionGetNestedArrayWithIndexValue;
		_playerName = _playerDataRecord select 1;
		_commanderNameBLUFOR = _playerName;
	};
	if (commanderOPFOR != '')
	then
	{
		_playerDataRecord = [playersDataPublic, 0, commanderOPFOR] call functionGetNestedArrayWithIndexValue;
		_playerName = _playerDataRecord select 1;
		_commanderNameOPFOR = _playerName;
	};
	_territoryControlPercentageBLUFOR = round (territoryControlBLUFOR * 100);
	_provinceControlAmountBLUFOR = [BLUFOR, provincesStatusClient] call functionGetTeamProvinceControlAmount;
	_territoryControlPercentageOPFOR = round (territoryControlOPFOR * 100);
	_provinceControlAmountOPFOR = [OPFOR, provincesStatusClient] call functionGetTeamProvinceControlAmount;
	((uiNamespace getVariable 'nwHUD') displayCtrl 104) ctrlSetStructuredText (parseText format ['<t size="2" shadow="2"><t color="#5882FA">BLUFOR</t><br/>%1 Players<br/>%2<br/>%3%4 Territory<br/>%5 Provinces<br/><t color="#FA5858">OPFOR</t><br/>%6 Players<br/>%7<br/>%8%9 Territory<br/>%10 Provinces</t>', _amountBLUFORPlayers, _commanderNameBLUFOR, _territoryControlPercentageBLUFOR, '%', _provinceControlAmountBLUFOR, _amountOPFORPlayers, _commanderNameOPFOR, _territoryControlPercentageOPFOR, '%', _provinceControlAmountOPFOR]);
};

functionUpdateTeamsInformationHUDByInterval =
{
	while {true}
	do
	{
		call functionUpdateTeamsInformationHUD;
		_currentServerTime = serverTime;
		waitUntil {serverTime >= (_currentServerTime + teamsInformationHUDUpdateIntervalInSeconds)};
	};
};