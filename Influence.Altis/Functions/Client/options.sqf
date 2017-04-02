functionEstablishOptions =
{
	cycleInfluenceMapQuality = ['Medium', 25, 10];
	cycleBuildViewBorderQuality = ['Medium', 10];
	_profileInfluenceMapQuality = profileNamespace getVariable ['influenceGameMode_influenceMapQuality', false];
	if (typeName _profileInfluenceMapQuality == 'ARRAY')
	then
	{
		cycleInfluenceMapQuality = _profileInfluenceMapQuality;
	};
	_profileBuildViewBorderQuality = profileNamespace getVariable ['influenceGameMode_buildViewBorderQuality', false];
	if (typeName _profileBuildViewBorderQuality == 'ARRAY')
	then
	{
		cycleBuildViewBorderQuality = _profileBuildViewBorderQuality;
	};
};

functionOpenOptionsInterface =
{
	createDialog 'DialogueOptions';
	ctrlSetText [17000, format ['Influence Map Quality: %1', cycleInfluenceMapQuality select 0]];
	ctrlSetText [17001, format ['Build View Border Quality: %1', cycleBuildViewBorderQuality select 0]];
};

functionCycleInfluenceMapQuality =
{
	_pressedButton = _this select 1;
	_qualityChange = 0;
	if (_pressedButton == 0)
	then
	{
		_qualityChange = 1;
	};
	if (_pressedButton == 1)
	then
	{
		_qualityChange = -1;
	};
	// _qualityOptions array format: quality name, main map quality, minimap quality
	_qualityOptions = [['Very Low', 15, 5], ['Low', 20, 7], ['Medium', 25, 10], ['High', 30, 12], ['Very High', 35, 15]];
	_currentQualityOptionIndex = _qualityOptions find cycleInfluenceMapQuality;
	_newQualityOptionIndex = _currentQualityOptionIndex + _qualityChange;
	_newQualityOption = '';
	if (_newQualityOptionIndex == -1)
	then
	{
		_newQualityOptionIndex = (count _qualityOptions) - 1;
	};
	if (_newQualityOptionIndex > ((count _qualityOptions) - 1))
	then
	{
		_newQualityOptionIndex = 0;
	};
	cycleInfluenceMapQuality = _qualityOptions select _newQualityOptionIndex;
	profileNamespace setVariable ['influenceGameMode_influenceMapQuality', cycleInfluenceMapQuality];
	_qualityName = cycleInfluenceMapQuality select 0;
	_qualityMainMap = cycleInfluenceMapQuality select 1;
	_qualityMinimap = cycleInfluenceMapQuality select 2;
	[influenceRendererMain, _qualityMainMap] call irenSetQuality;
	[influenceRendererMini, _qualityMinimap] call irenSetQuality;
	ctrlSetText [17000, format ['Influence Map Quality: %1', _qualityName]];
};

functionCycleBuildViewBorderQuality =
{
	_pressedButton = _this select 1;
	_qualityChange = 0;
	if (_pressedButton == 0)
	then
	{
		_qualityChange = 1;
	};
	if (_pressedButton == 1)
	then
	{
		_qualityChange = -1;
	};
	_qualityOptions = [['Very Low', 5], ['Low', 7], ['Medium', 10], ['High', 12], ['Very High', 15]];
	_currentQualityOptionIndex = _qualityOptions find cycleBuildViewBorderQuality;
	_newQualityOptionIndex = _currentQualityOptionIndex + _qualityChange;
	_newQualityOption = '';
	if (_newQualityOptionIndex == -1)
	then
	{
		_newQualityOptionIndex = (count _qualityOptions) - 1;
	};
	if (_newQualityOptionIndex > ((count _qualityOptions) - 1))
	then
	{
		_newQualityOptionIndex = 0;
	};
	cycleBuildViewBorderQuality = _qualityOptions select _newQualityOptionIndex;
	profileNamespace setVariable ['influenceGameMode_buildViewBorderQuality', cycleBuildViewBorderQuality];
	ctrlSetText [17001, format ['Build View Border Quality: %1', cycleBuildViewBorderQuality select 0]];
};