functionActivateObjectiveServer =
{
	_base = _this select 0;
	_team = _this select 1;
 	_teamLiteral = [_team] call functionGetTeamFORName;
 	_objectives = missionNamespace getVariable (format ['objectives%1', _teamLiteral]);
 	if (count _objectives == objectiveMaximumSimultaneous)
 	then
 	{
 		[format ['objectives%1', _teamLiteral], (_objectives select 0)] call functionPublicVariableRemoveFromArray;
 	};
	[format ['objectives%1', _teamLiteral], _base] call functionPublicVariableAppendToArray;
	[[_base], 'functionHandleNewObjective', _team] call BIS_fnc_MP;
};

functionIdentifyObjectiveParticipants =
{
	{
		_objective = _x;
		_objectiveOpposingTeam = BLUFOR;
		_objectiveOpposingTeamLiteral = 'BLUFOR';
		if ((_objective getVariable 'team') == BLUFOR)
		then
		{
			_objectiveOpposingTeam = OPFOR;
			_objectiveOpposingTeamLiteral = 'OPFOR';
		};
		_nearEntities = (position _objective) nearEntities ['AllVehicles', objectiveRadius];
		{
			_entity = _x;
			if (_entity isKindOf 'Man')
			then
			{
				if (isPlayer _entity)
				then
				{
					if ((_entity getVariable ['team', Civilian]) == _objectiveOpposingTeam)
					then
					{
						(missionNamespace getVariable (format ['objectiveParticipants%1', _objectiveOpposingTeamLiteral])) pushBack (getPlayerUID _entity);
					};
				};
			}
			else
			{
				{
					if (isPlayer _x)
					then
					{
						if ((_x getVariable ['team', Civilian]) == _objectiveOpposingTeam)
						then
						{
							(missionNamespace getVariable (format ['objectiveParticipants%1', _objectiveOpposingTeamLiteral])) pushBack (getPlayerUID _x);
						};
					};
				} forEach (crew _entity);
			};
		} forEach _nearEntities;
	} forEach (objectivesBLUFOR + objectivesOPFOR);
};

functionDeactivateObjectiveServer =
{
	_base = _this select 0;
	_team = _this select 1;
 	_teamLiteral = [_team] call functionGetTeamFORName;
 	_objectives = missionNamespace getVariable (format ['objectives%1', _teamLiteral]);
 	_objectiveIndex = _objectives find _base;
 	if (_objectiveIndex > -1)
 	then
 	{
		[format ['objectives%1', _teamLiteral], _base] call functionPublicVariableRemoveFromArray;
		[[_base], 'functionHandleRemovedObjective', _team] call BIS_fnc_MP;
	};
};