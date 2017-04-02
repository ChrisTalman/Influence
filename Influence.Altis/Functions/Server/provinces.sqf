functionEstablishProvincesStatusServer =
{
	{
		// provincesStatusServer array format: province ID, province team, array of bases and FOBs in province, town defence defeated, town defence active
		provincesStatusServer = provincesStatusServer + [[_x select 0, Independent, [], false, false]];
	} forEach provinces;
};

functionUpdateProvinceServer =
{
	_provinceID = _this select 0;
	_provinceStatusData = [provincesStatusServer, 0, _provinceID] call functionGetNestedArrayWithIndexValue;
	_provinceStatusDataCurrentTeam = _provinceStatusData select 1;
	_provinceStatusDataResidentBases = _provinceStatusData select 2;
	_provinceDefeated = _provinceStatusData select 3;
	if (_provinceDefeated)
	then
	{
		_provinceBLUFORBasePresence = false;
		_provinceOPFORBasePresence = false;
		{
			scopeName '_provinceStatusDataResidentBasesScope';
			if ((_x getVariable 'team') == BLUFOR)
			then
			{
				_provinceBLUFORBasePresence = true;
			};
			if ((_x getVariable 'team') == OPFOR)
			then
			{
				_provinceOPFORBasePresence = true;
			};
			if (_provinceBLUFORBasePresence and _provinceOPFORBasePresence)
			then
			{
				breakOut '_provinceStatusDataResidentBasesScope';
			};
		} forEach _provinceStatusDataResidentBases;
		_revisedProvinceTeam = Independent;
		if (_provinceBLUFORBasePresence and !(_provinceOPFORBasePresence))
		then
		{
			_revisedProvinceTeam = BLUFOR;
		};
		if (_provinceOPFORBasePresence and !(_provinceBLUFORBasePresence))
		then
		{
			_revisedProvinceTeam = OPFOR;
		};
		_revisedProvinceStatusData = _provinceStatusData;
		_revisedProvinceStatusData set [1, _revisedProvinceTeam];
		provincesStatusServer set [provincesStatusServer find _provinceStatusData, _revisedProvinceStatusData];
		if (_provinceStatusDataCurrentTeam != _revisedProvinceTeam)
		then
		{
			[[_provinceID, _revisedProvinceTeam], 'functionUpdateProvinceClient'] call BIS_fnc_MP;
		};
	};
};

functionActivateProvinceServer =
{
	_provinceID = _this select 0;
	_team = _this select 1;
	_teamLiteral = [_team] call functionGetTeamFORName;
	_otherTeam = objNull;
	if (_team == BLUFOR)
	then
	{
		_otherTeam = OPFOR;
	};
	if (_team == OPFOR)
	then
	{
		_otherTeam = BLUFOR;
	};
	_otherTeamLiteral = [_otherTeam] call functionGetTeamFORName;
	_provinceStatusData = [provincesStatusServer, 0, _provinceID] call functionGetNestedArrayWithIndexValue;
	_provinceStatusDataTownDefenceDefeated = _provinceStatusData select 3;
	_provinceStatusDataTownDefenceActive = _provinceStatusData select 4;
	_provinceActiveTeam = missionNamespace getVariable (format ['provinceActive%1', _teamLiteral]);
	diag_log format ['functionActivateProvinceServer _provinceStatusDataTownDefenceActive: %1.', _provinceStatusDataTownDefenceActive];
	if (!(_provinceStatusDataTownDefenceDefeated))
	then
	{
		if (typeName _provinceStatusDataTownDefenceActive == 'BOOL')
		then
		{
			diag_log 'Province will be activated.';
			_provinceProperties = [provinces, 0, _provinceID] call functionGetNestedArrayWithIndexValue;
			_provincePropertiesName = _provinceProperties select 1;
			_provincePropertiesTownDefences = _provinceProperties select 3;
			_townDefenceRandomIndex = floor (random (count _provincePropertiesTownDefences));
			_townDefence = (_provincePropertiesTownDefences select (_townDefenceRandomIndex));
			diag_log format ['Random Town. _townDefenceRandomIndex: %1. _townDefence: %2.', _townDefenceRandomIndex, _townDefence];
			_townDefenceCentre = _townDefence select 0;
			_townDefenceRadius = _townDefence select 1;
			_revisedProvinceStatusData = _provinceStatusData;
			_revisedProvinceStatusData set [4, _townDefenceCentre];
			provincesStatusServer set [provincesStatusServer find _provinceStatusData, _revisedProvinceStatusData];
			missionNamespace setVariable [(format ['provinceActive%1', _teamLiteral]), _provinceID];
			[[_provinceID, _townDefenceCentre], 'functionHandleProvinceActivation', _otherTeam] call BIS_fnc_MP;
			[[['functionHandleProvinceActivation', [_provinceID, _townDefenceCentre]], ['functionHandleProvinceActiveTeamChange', [_provinceID]]], 'functionCallBulkFunctions', _team] call BIS_fnc_MP;
			[_provinceID, _townDefenceCentre, _townDefenceRadius] call functionEstablishTownDefence;
		}
		else
		{
			_notifyTeam = false;
			if (typeName _provinceActiveTeam == 'BOOL')
			then
			{
				_notifyTeam = true;
			}
			else
			{
				if (_provinceActiveTeam != _provinceID)
				then
				{
					_notifyTeam = true;
				};
			};
			if (_notifyTeam)
			then
			{
				diag_log 'Province is already active. Will notify team.';
				missionNamespace setVariable [(format ['provinceActive%1', _teamLiteral]), _provinceID];
				[[_provinceID], 'functionHandleProvinceActiveTeamChange', _team] call BIS_fnc_MP;
			}
			else
			{
				diag_log 'Province is already active. Will not notify team.';
			};
		};
	};
};

functionDeactivateProvinceServer =
{
	_team = _this select 0;
	_provinceID = missionNamespace getVariable (format ['provinceActive%1', [_team] call functionGetTeamFORName]);
	missionNamespace setVariable [format ['provinceActive%1', [_team] call functionGetTeamFORName], false];
	_provinceActiveBLUFOR = 'false';
	_provinceActiveOPFOR = 'false';
	if ((typeName provinceActiveBLUFOR) == 'STRING')
	then
	{
		_provinceActiveBLUFOR = provinceActiveBLUFOR;
	};
	if ((typeName provinceActiveOPFOR) == 'STRING')
	then
	{
		_provinceActiveOPFOR = provinceActiveOPFOR;
	};
	if (!(_provinceActiveBLUFOR == _provinceID) and !(_provinceActiveOPFOR == _provinceID))
	then
	{
		_provinceStatusData = [provincesStatusServer, 0, _provinceID] call functionGetNestedArrayWithIndexValue;
		_revisedProvinceStatusData = _provinceStatusData;
		_revisedProvinceStatusData set [4, false];
		provincesStatusServer set [provincesStatusServer find _provinceStatusData, _revisedProvinceStatusData];
		[[_provinceID], 'functionHandleProvinceDeactivation'] call BIS_fnc_MP;
	};
};

functionHandleProvinceResistanceDefeat =
{
	_provinceID = _this select 0;
	_provinceStatusData = [provincesStatusServer, 0, _provinceID] call functionGetNestedArrayWithIndexValue;
	_revisedProvinceStatusData = _provinceStatusData;
	_revisedProvinceStatusData set [3, true];
	_revisedProvinceStatusData set [4, false];
	provincesStatusServer set [provincesStatusServer find _provinceStatusData, _revisedProvinceStatusData];
	[_provinceID] call functionUpdateProvinceServer;
};