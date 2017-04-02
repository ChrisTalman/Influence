functionGetProvinceAtPosition =
{
	private ['_position', '_provinceFoundID', '_provinceFound'];
	_position = _this select 0;
	_provinceFoundID = false;
	{
		scopeName 'provincesScope';
		_polygonPoints = _x select 2;
		_provinceFound = [_position, _polygonPoints] call functionIsPointInPolygon;
		if (_provinceFound)
		then
		{
			_provinceFoundID = _x select 0;
			breakOut 'provincesScope';
		};
	} forEach provinces;
	_provinceFoundID;
};

functionTownDefenceGetSupplyQuotaRewardForUnitType =
{
	private ['_unitType', '_reward'];
	_unitType = _this select 0;
	_reward = 0;
	if (_unitType == 'I_soldier_F')
	then
	{
		_reward = townDefenceRiflemanKillSupplyQuotaReward;
	};
	if (_unitType == 'I_Soldier_AR_F')
	then
	{
		_reward = townDefenceAutoriflemanKillSupplyQuotaReward;
	};
	if (_unitType == 'I_Soldier_M_F')
	then
	{
		_reward = townDefenceMarksmanKillSupplyQuotaReward;
	};
	if (_unitType == 'I_officer_F')
	then
	{
		_reward = townDefenceOfficerKillSupplyQuotaReward;
	};
	if (_unitType == 'I_Soldier_LAT_F')
	then
	{
		_reward = townDefenceAntiTankKillSupplyQuotaReward;
	};
	if (_unitType == 'I_Soldier_AA_F')
	then
	{
		_reward = townDefenceAntiAirKillSupplyQuotaReward;
	};
	if (_unitType == 'I_G_Offroad_01_armed_F')
	then
	{
		_reward = townDefenceOffroadPatrolVehicleKillSupplyQuotaReward;
	};
	if (_unitType == 'I_APC_tracked_03_cannon_F')
	then
	{
		_reward = townDefenceMoraKillSupplyQuotaReward;
	};
	_reward;
};