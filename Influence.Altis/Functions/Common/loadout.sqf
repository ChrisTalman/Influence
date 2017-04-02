functionUnitSetLoadout =
{
	// Arguments: unit object, loadout
	private ['_unit', '_loadout', '_uniform', '_vest', '_backpack', '_headgear', '_goggles', '_weaponItems', '_assignedItems', '_uniformItems', '_vestItems', '_backpackItems', '_weaponItemsGroup', '_weaponMagazine', '_weaponMagazineName', '_weaponName', '_weaponAccessories'];
	_unit = _this select 0;
	_loadout = _this select 1;
	_uniform = _loadout select 0;
	_vest = _loadout select 1;
	_backpack = _loadout select 2;
	_headgear = _loadout select 3;
	_goggles = _loadout select 4;
	_weaponItems = _loadout select 5;
	_assignedItems = _loadout select 6;
	_uniformItems = _loadout select 7;
	_vestItems = _loadout select 8;
	_backpackItems = _loadout select 9;
	removeUniform _unit;
	removeVest _unit;
	removeBackpack _unit;
	removeAllWeapons _unit;
	removeAllAssignedItems _unit;
	removeGoggles _unit;
	removeHeadgear _unit;
	_unit forceAddUniform _uniform;
	_unit addVest _vest;
	_unit addBackpack _backpack;
	_unit addHeadgear _headgear;
	_unit addGoggles _goggles;
	{
		_weaponItemsGroup = _x;
		if ((count _weaponItemsGroup) > 4)
		then
		{
			_weaponMagazine = _weaponItemsGroup select 4;
			if (count _weaponMagazine > 0)
			then
			{
				_weaponMagazineName = _weaponMagazine select 0;
				_unit addMagazine _weaponMagazineName;
			};
		};
		_weaponName = _weaponItemsGroup select 0;
		_unit addWeapon _weaponName;
		_weaponAccessories = [_weaponItemsGroup select 1, _weaponItemsGroup select 2, _weaponItemsGroup select 3];
		if (count _weaponItemsGroup > 5)
		then
		{
			_weaponAccessories pushBack (_weaponItemsGroup select 5);
		};
		{
			_weaponAccessory = _x;
			_unit addPrimaryWeaponItem _weaponAccessory;
			_unit addSecondaryWeaponItem _weaponAccessory;
			_unit addHandgunItem _weaponAccessory;
		} forEach _weaponAccessories;
	} forEach _weaponItems;
	{
		_unit linkItem _x;
	} forEach _assignedItems;
	{
		_unit addItemToUniform _x;
	} forEach _uniformItems;
	{
		_unit addItemToVest _x;
	} forEach _vestItems;
	{
		_unit addItemToBackpack _x;
	} forEach _backpackItems;
};