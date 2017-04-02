functionEstablishProvincesStatusClient =
{
	{
		// provincesStatusClient array format: province ID, province team, town defence defeated, town defence active
		provincesStatusClient = provincesStatusClient + [[_x select 0, Independent, false, false]];
	} forEach provinces;
};

functionUpdateProvinceClient =
{
	// Clientside
	if (!isServer or !isDedicated)
	then
	{
		_provinceID = _this select 0;
		_revisedProvinceTeam = _this select 1;
		_provinceStatusData = [provincesStatusClient, 0, _provinceID] call functionGetNestedArrayWithIndexValue;
		_revisedProvinceStatusData = _provinceStatusData;
		_revisedProvinceStatusData set [1, _revisedProvinceTeam];
		provincesStatusClient set [provincesStatusClient find _provinceStatusData, _revisedProvinceStatusData];
		_provinceProperties = [provinces, 0, _provinceID] call functionGetNestedArrayWithIndexValue;
		_provincePropertiesName = _provinceProperties select 1;
		//systemChat format ['%1 updated to control by %2.', _provinceID, _revisedProvinceTeam];
		_notificationType = 'Notification';
		_notificationTitle = 'Province Neutralised';
		_provinceTeamControlChangeMessage = '';
		if (_revisedProvinceTeam == BLUFOR or _revisedProvinceTeam == OPFOR)
		then
		{
			_provinceTeamControlChangeMessage = format ['%1 now under %2 control.', _provincePropertiesName, ([_revisedProvinceTeam] call functionGetTeamFORName)];
			_notificationTitle = 'Province Captured';
			if ((player getVariable 'team') == _revisedProvinceTeam)
			then
			{
				_notificationType = 'NotificationPositive';
			}
			else
			{
				_notificationType = 'NotificationNegative';
			};
		}
		else
		{
			_provinceTeamControlChangeMessage = format ['%1 has been neutralised.', _provincePropertiesName];
		};
		[_notificationType, [_notificationTitle, _provinceTeamControlChangeMessage]] call BIS_fnc_showNotification;
		[_provinceID] call functionUpdateProvinceMapTitle;
		call functionUpdateTeamsInformationHUD;
	};
};

functionBulkUpdateProvincesClient =
{
	_provincesStatus = _this select 0;
	_provinceActive = _this select 1;
	{
		_provinceStatusData = provincesStatusClient select _forEachIndex;
		_revisedProvinceStatusData = _provinceStatusData;
		_revisedProvinceStatusData set [1, _x select 0];
		_revisedProvinceStatusData set [2, _x select 1];
		_revisedProvinceStatusData set [3, _x select 2];
		if ((typeName (_x select 2)) == 'ARRAY')
		then
		{
			//[_revisedProvinceStatusData select 0, _x select 2] call functionTownDefencePositionCreateMarker;
		};
		provincesStatusClient set [_forEachIndex, _revisedProvinceStatusData];
		[_provinceStatusData select 0] call functionUpdateProvinceMapTitle;
	} forEach _provincesStatus;
	call functionUpdateTeamsInformationHUD;
	missionNamespace setVariable [format ['provinceActive%1', ([side player] call functionGetTeamFORName)], _provinceActive];
};

functionActivateProvinceClient =
{
	closeDialog 0;
	openMap true;
	hint parseText 'Left-click on a province to activate.';
	['provinceActivationMapClickEvent', 'onMapSingleClick', {[_pos, _shift] call functionHandleProvinceActivationMapClick;}] call BIS_fnc_addStackedEventHandler;
	[] spawn functionHandleProvinceActivationMapClosure;
};

functionHandleProvinceActivationMapClick =
{
	_position = _this select 0;
	_provinceID = [_position] call functionGetProvinceAtPosition;
	if ((typeName _provinceID) == 'STRING')
	then
	{
		_provinceStatusData = [provincesStatusClient, 0, _provinceID] call functionGetNestedArrayWithIndexValue;
		_provinceStatusDataTownDefenceDefeated = _provinceStatusData select 2;
		_provinceStatusDataTownDefenceActive = _provinceStatusData select 3;
		if (_provinceStatusDataTownDefenceDefeated)
		then
		{
			hint parseText '<t color="#D00000">Resistance within the province you have selected has already been defeated.</t><br/><br/>Left-click on a province to activate.';
		}
		else
		{
			[[_provinceID, side player], 'functionActivateProvinceServer', false] call BIS_fnc_MP;
			openMap false;
		};
	};
};

functionHandleProvinceActivationMapClosure =
{ 
	waitUntil {!(visibleMap)};
	hint '';
	['provinceActivationMapClickEvent', 'onMapSingleClick'] call BIS_fnc_removeStackedEventHandler;
};

functionDeactivateProvinceClient =
{
	[[side player], 'functionDeactivateProvinceServer', false] call BIS_fnc_MP;
	closeDialog 0;
};

functionHandleProvinceActivation =
{
	_provinceID = _this select 0;
	_townDefencePosition = _this select 1;
	//[_provinceID, _townDefencePosition] call functionTownDefencePositionCreateMarker;
	_provinceProperties = [provinces, 0, _provinceID] call functionGetNestedArrayWithIndexValue;
	_provincePropertiesName = _provinceProperties select 1;
	_provinceActivationMessage = format ['Resistance has mobilised in %1.', _provincePropertiesName];
	['Notification', ['Resistance Mobilised', _provinceActivationMessage]] call BIS_fnc_showNotification;
	_provinceStatusData = [provincesStatusClient, 0, _provinceID] call functionGetNestedArrayWithIndexValue;
	_revisedProvinceStatusData = _provinceStatusData;
	_revisedProvinceStatusData set [3, _townDefencePosition];
	provincesStatusClient set [provincesStatusClient find _provinceStatusData, _revisedProvinceStatusData];
	missionNamespace setVariable [format ['provinceActive%1', ([side player] call functionGetTeamFORName)], _provinceID];
	[_provinceID] call functionUpdateProvinceMapTitle;
};

functionHandleProvinceActiveTeamChange =
{
	_provinceActive = _this select 0;
	missionNamespace setVariable [format ['provinceActive%1', [side player] call functionGetTeamFORName], _provinceActive];
};

functionHandleProvinceDeactivation =
{
	if (!isServer or !isDedicated)
	then
	{
		_provinceID = _this select 0;
		_provinceStatusData = [provincesStatusClient, 0, _provinceID] call functionGetNestedArrayWithIndexValue;
		_revisedProvinceStatusData = _provinceStatusData;
		_revisedProvinceStatusData set [3, false];
		provincesStatusClient set [provincesStatusClient find _provinceStatusData, _revisedProvinceStatusData];
		missionNamespace setVariable [format ['provinceActive%1', ([side player] call functionGetTeamFORName)], false];
		[_provinceID] call functionTownDefencePositionRemoveMarker;
		_provinceProperties = [provinces, 0, _provinceID] call functionGetNestedArrayWithIndexValue;
		_provincePropertiesName = _provinceProperties select 1;
		_provinceDeactivationMessage = format ['Resistance has demobilised in %1.', _provincePropertiesName];
		['Notification', ['Resistance Demobilised', _provinceDeactivationMessage]] call BIS_fnc_showNotification;
		[_provinceID] call functionUpdateProvinceMapTitle;
	};
};

functionTownDefencePositionCreateMarker =
{
	private ['_id', '_position', '_visualMapMarker', '_visualTextMapMarker'];
	_id = _this select 0;
	_position = _this select 1;
	_visualMapMarker = createMarkerLocal [format ['%1TownDefencePositionVisualMapMarker', _id], _position];
	_visualMapMarker setMarkerTypeLocal 'mil_dot';
	_visualMapMarker setMarkerBrushLocal 'SOLID';
	_visualMapMarker setMarkerColorLocal 'Color4_FD_F';
	_visualTextMapMarker = createMarkerLocal [format ['%1TownDefencePositionVisualTextMapMarker', _id], _position];
	_visualTextMapMarker setMarkerTypeLocal 'EmptyIcon';
	_visualTextMapMarker setMarkerTextLocal 'Approximate Province Resistance Position';
	_visualTextMapMarker setMarkerColorLocal 'ColorWhite';
};

functionTownDefencePositionRemoveMarker =
{
	private ['_id'];
	_id = _this select 0;
	deleteMarkerLocal (format ['%1TownDefencePositionVisualMapMarker', _id]);
	deleteMarkerLocal (format ['%1TownDefencePositionVisualTextMapMarker', _id]);
};

functionHandleTownDefenceDefeatClient =
{
	_provinceID = _this select 0;
	_provinceStatusData = [provincesStatusClient, 0, _provinceID] call functionGetNestedArrayWithIndexValue;
	_revisedProvinceStatusData = _provinceStatusData;
	_revisedProvinceStatusData set [2, true];
	_revisedProvinceStatusData set [3, false];
	provincesStatusClient set [provincesStatusClient find _provinceStatusData, _revisedProvinceStatusData];
	missionNamespace setVariable [format ['provinceActive%1', ([side player] call functionGetTeamFORName)], false];
	_provinceProperties = [provinces, 0, _provinceID] call functionGetNestedArrayWithIndexValue;
	_provincePropertiesName = _provinceProperties select 1;
	_provinceDefeatMessage = format ['Resistance has been defeated in %1.', _provincePropertiesName];
	['Notification', ['Resistance Defeated', _provinceDefeatMessage]] call BIS_fnc_showNotification;
	[_provinceID] call functionTownDefencePositionRemoveMarker;
	[_provinceID] call functionUpdateProvinceMapTitle;
	call functionUpdateTeamsInformationHUD;
};

functionHandleTownDefenceReward =
{
	_rewardData = _this;
	_actionID = player addAction ['<t color="#FF8000">Rewards</t>', functionOpenTownDefenceRewardInterface, _rewardData, 1000, true, true, '', 'alive _target'];
	[_actionID] spawn functionRemoveTownDefenceRewardActionAfterInterval;
};

functionOpenTownDefenceRewardInterface =
{
	_rewardData = _this select 3;
	_rewardDataSupplyQuotaReward = _rewardData select 0;
	_rewardDataKills = _rewardData select 1;
	createDialog 'nwDialogueTownDefenceReward';
	_rewardText = '<t font="PuristaMedium" color="#FFFFFF" size="2.5" align="center">';
	_rewardText = _rewardText + 'Congratulations, the province resistance has been defeated. Below are your rewards.';
	_rewardText = _rewardText + (format ['<br/><br/>Participation Reward: €%1', townDefenceDefeatParticipationSupplyQuotaReward]);
	{
		_unitType = _x select 0;
		_amountKilled = _x select 1;
		_rewardText = _rewardText + (format ['<br/>%1 x %2 (€%3 each): €%4', ([_unitType] call functionGetLiteralNameForUnitType), _amountKilled, ([_unitType] call functionTownDefenceGetSupplyQuotaRewardForUnitType), (_amountKilled * ([_unitType] call functionTownDefenceGetSupplyQuotaRewardForUnitType))]);
	} forEach _rewardDataKills;
	_rewardText = _rewardText + (format ['<br/>Total Reward: €%1', _rewardDataSupplyQuotaReward]);
	_rewardText = _rewardText + '</t>';
	((findDisplay 14) displayCtrl 14000) ctrlSetStructuredText parseText _rewardText;
};

functionRemoveTownDefenceRewardActionAfterInterval =
{
	private ['_actionID'];
	_actionID = _this select 0;
	sleep removeTownDefenceRewardActionIntervalInSeconds;
	player removeAction _actionID;
};

functionEstablishProvinceMapTitles =
{
	// provinceMapTitles array format: province ID, province average coordinate, province status text
	provinceMapTitles = [];
	{
		_provinceID = _x select 0;
		_provincePolygonPoints = _x select 2;
		_provinceAverageCoordinate = [_provincePolygonPoints] call functionMathGetAverageCoordinate;
		provinceMapTitles = provinceMapTitles + [[_provinceID, _provinceAverageCoordinate, 'undefined']];
		[_provinceID] call functionUpdateProvinceMapTitle;
	} forEach provinces;
};

functionUpdateProvinceMapTitle =
{
	private ['_provinceID', '_provinceStatusData', '_provinceTeam', '_provinceDefeated', '_provinceActive', '_provinceStatusText', '_provinceProperties', '_provincePropertiesName', '_provinceMapTitleText', '_provinceMapTitle', '_revisedProvinceMapTitle'];
	_provinceID = _this select 0;
	_provinceStatusData = [provincesStatusClient, 0, _provinceID] call functionGetNestedArrayWithIndexValue;
	_provinceTeam = _provinceStatusData select 1;
	_provinceDefeated = _provinceStatusData select 2;
	_provinceActive = _provinceStatusData select 3;
	_provinceStatusText = '';
	if (_provinceTeam == Independent)
	then
	{
		if (_provinceDefeated)
		then
		{
			_provinceStatusText = 'Neutral';
		}
		else
		{
			if ((typeName _provinceActive) == 'ARRAY')
			then
			{
				_provinceStatusText = 'Resistance Active';
			}
			else
			{
				_provinceStatusText = 'Resistance Inactive';
			};
		};
	};
	if (_provinceTeam == BLUFOR)
	then
	{
		_provinceStatusText = 'BLUFOR Controlled';
	};
	if (_provinceTeam == OPFOR)
	then
	{
		_provinceStatusText = 'OPFOR Controlled';
	};
	_provinceProperties = [provinces, 0, _provinceID] call functionGetNestedArrayWithIndexValue;
	_provincePropertiesName = _provinceProperties select 1;
	_provinceMapTitleText = format ['%1 (%2)', _provincePropertiesName, _provinceStatusText];
	_provinceMapTitle = [provinceMapTitles, 0, _provinceID] call functionGetNestedArrayWithIndexValue;
	_revisedProvinceMapTitle = _provinceMapTitle;
	_revisedProvinceMapTitle set [2, _provinceMapTitleText];
	provinceMapTitles set [provinceMapTitles find _provinceMapTitle, _revisedProvinceMapTitle];
};

// Development - Obsolete
functionIsPlayerInsideProvince =
{
	_insideProvinceName = 'undefined';
	{
		_polygonPoints = _x select 2;
		_insideProvince = [position player, _polygonPoints] call functionIsPointInPolygon;
		if (_insideProvince)
		then
		{
			_insideProvinceName = _x select 1;
		};
	} forEach provinces;
	if (_insideProvinceName != 'undefined')
	then
	{
		systemChat format ['Inside %1.', _insideProvinceName];
	}
	else
	{
		systemChat 'Not inside any province.';
	};
};