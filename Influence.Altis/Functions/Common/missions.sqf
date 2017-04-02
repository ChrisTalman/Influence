functionGetMissionTypeLiteral =
{
	private ['_missionType', '_literal'];
	_missionType = _this select 0;
	_literal = '';
	switch (_missionType)
	do
	{
		case 'base':
		{
			_literal = 'Base';
		};
		case 'FOB':
		{
			_literal = 'FOB';
		};
		case 'supplyRelayStation':
		{
			_literal = 'Supply Relay Station';
		};
		case 'roadblock':
		{
			_literal = 'Roadblock';
		};
	};
	_literal;
};