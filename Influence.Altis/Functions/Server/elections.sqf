/*functionResetPublicVariablesForCommanderChallengeElectionAfterElection =
{
	_team = _this select 0;
	[(format ["commanderChallengeElectionChallenger%1", _team]), ""] call functionPublicVariableSetValue;
	[(format ["commanderChallengeElectionChallengerRationale%1", _team]), ""] call functionPublicVariableSetValue;
	[(format ["commanderChallengeElectionCommanderRebuttal%1", _team]), ""] call functionPublicVariableSetValue;
	[(format ["commanderChallengeElectionPlayerVotes%1", _team]), []] call functionPublicVariableSetValue;
};

functionConductChallengeElectionForCommander =
{
	_team = _this select 0;
	_team = ([_team] call functionGetTeamFORName);
	[format ['commanderChallengeElectionInProgress%1', _team], true] call functionPublicVariableSetValue;
	[format ['commanderChallengeElectionStage%1', _team], 'rebuttal'] call functionPublicVariableSetValue;
	_currentServerTime = serverTime;
	waitUntil {serverTime >= (_currentServerTime + commanderChallengeElectionRebutPeriodInSeconds)};
	[format ['commanderChallengeElectionStage%1', _team], 'challenge'] call functionPublicVariableSetValue;
	_currentServerTime = serverTime;
	waitUntil {serverTime >= (_currentServerTime + commanderChallengeElectionChallengePeriodInSeconds)};
	[format ['commanderChallengeElectionInProgress%1', _team], false] call functionPublicVariableSetValue;
	_votesForCommander = 0;
	_votesForChallenger = 0;
	{
		_voterName = _x select 0;
		_voterSupportedName = _x select 1;
		if (_voterSupportedName == (missionNamespace getVariable format ["commanderName%1", _team]))
		then
		{
			_votesForCommander = _votesForCommander + 1;
		};
		if (_voterSupportedName == (missionNamespace getVariable format ["commanderChallengeElectionChallenger%1", _team]))
		then
		{
			_votesForChallenger = _votesForChallenger + 1;
		};
	} forEach (missionNamespace getVariable format ["commanderChallengeElectionPlayerVotes%1", _team]);
	if (_votesForChallenger > _votesForCommander)
	then
	{
		[format ['commanderName%1', _team], (missionNamespace getVariable format ['commanderChallengeElectionChallenger%1', _team])] call functionPublicVariableSetValue;
	};
	[_team] call functionResetPublicVariablesForCommanderChallengeElectionAfterElection;
	[format ['commanderChallengeElectionStage%1', _team], 'concluded'] call functionPublicVariableSetValue;
	[format ['commanderChallengeElectionStage%1', _team], ''] call functionPublicVariableSetValue;
};*/

functionStartGeneralElectionServer =
{
	_team = _this select 0;
	_teamLiteral = [_team] call functionGetTeamFORName;
	_electionStage = missionNamespace getVariable (format ['generalElectionStage%1', _teamLiteral]);
	_commander = missionNamespace getVariable (format ['commander%1', _teamLiteral]);
	if (_electionStage == 'none' and _commander == '')
	then
	{
		[_team] spawn functionConductGeneralElectionStandStage;
	};
};

functionConductGeneralElectionStandStage =
{
	_team = _this select 0;
	_teamLiteral = [_team] call functionGetTeamFORName;
	[format ['generalElectionStage%1', _teamLiteral], 'stand'] call functionPublicVariableSetValue;
	[format ['generalElectionCandidates%1', _teamLiteral], []] call functionPublicVariableSetValue;
	[format ['generalElectionVotes%1', _teamLiteral], []] call functionPublicVariableSetValue;
	_secondsElapsed = 0;
	while {_secondsElapsed < commanderElectionStandLengthInSeconds}
	do
	{
		sleep 1;
		_secondsElapsed = _secondsElapsed + 1;
		[format ['generalElectionStageElapsedSeconds%1', _teamLiteral], _secondsElapsed] call functionPublicVariableSetValue;
	};
	_candidates = missionNamespace getVariable (format ['generalElectionCandidates%1', _teamLiteral]);
	if (count _candidates == 0)
	then
	{
		[format ['generalElectionStage%1', _teamLiteral], 'noCandidates'] call functionPublicVariableSetValue;
		[format ['generalElectionStage%1', _teamLiteral], 'none'] call functionPublicVariableSetValue;
	}
	else
	{
		[_team] spawn functionConductGeneralElectionVoteStage;
		[format ['generalElectionStage%1', _teamLiteral], 'vote'] call functionPublicVariableSetValue;
	};
};

functionConductGeneralElectionVoteStage =
{
	_team = _this select 0;
	_teamLiteral = [_team] call functionGetTeamFORName;
	_secondsElapsed = 0;
	while {_secondsElapsed < commanderElectionLengthInSeconds}
	do
	{
		sleep 1;
		_secondsElapsed = _secondsElapsed + 1;
		[format ['generalElectionStageElapsedSeconds%1', _teamLiteral], _secondsElapsed] call functionPublicVariableSetValue;
	};
	_candidates = missionNamespace getVariable (format ['generalElectionCandidates%1', _teamLiteral]);
	_votes = missionNamespace getVariable (format ['generalElectionVotes%1', _teamLiteral]);
	_candidateVotes = [];
	{
		private ['_candidateUID', '_votesForCandidate'];
		_candidateUID = _x;
		_votesForCandidate = 0;
		{
			_voterRecordCandidateUID = _x select 1;
			if (_voterRecordCandidateUID == _candidateUID)
			then
			{
				_votesForCandidate = _votesForCandidate + 1;
			};
		} forEach _votes;
		_candidateVotes pushBack [_candidateUID, _votesForCandidate];
	} forEach _candidates;
	_mostVotes = 0;
	_mostVotesCandidate = [];
	{
		_candidateUID = _x select 0;
		_votesForCandidate = _x select 1;
		if (_votesForCandidate > _mostVotes)
		then
		{
			_mostVotesCandidate = [_candidateUID];
			_mostVotes = _votesForCandidate;
		}
		else
		{
			if (_votesForCandidate == _mostVotes)
			then
			{
				_mostVotesCandidate pushBack _candidateUID;
			};
		};
	} forEach _candidateVotes;
	_electedCandidateUID = false;
	if (count _mostVotesCandidate == 1)
	then
	{
		_electedCandidateUID = _mostVotesCandidate select 0;
	}
	else
	{
		_electedCandidateUID = _mostVotesCandidate select (floor (random (count _mostVotesCandidate)));
	};
	if (typeName _electedCandidateUID == 'BOOL')
	then
	{
		diag_log 'An error occurred during general election. No commander was elected.';
	}
	else
	{
		[format ['commander%1', _teamLiteral], _electedCandidateUID] call functionPublicVariableSetValue;
		_playerDataRecord = [playersData, 0, _electedCandidateUID] call functionGetNestedArrayWithIndexValue;
		_commanderName = _playerDataRecord select 1;
		[[_commanderName, _team], 'functionHandleNewCommander', _team] call BIS_fnc_MP;
	};
	[format ['generalElectionStage%1', _teamLiteral], 'concluded'] call functionPublicVariableSetValue;
	[format ['generalElectionStage%1', _teamLiteral], 'none'] call functionPublicVariableSetValue;
};

functionStandForGeneralElectionServer =
{
	_playerUID = _this select 0;
	_team = _this select 1;
	_teamLiteral = [_team] call functionGetTeamFORName;
	_candidates = missionNamespace getVariable (format ['generalElectionCandidates%1', _teamLiteral]);
	if (!(_playerUID in _candidates))
	then
	{
		[format ['generalElectionCandidates%1', _teamLiteral], _playerUID] call functionPublicVariableAppendToArray;
	};
	_candidates = missionNamespace getVariable (format ['generalElectionCandidates%1', _teamLiteral]);
	diag_log format ['functionStandForGeneralElectionServer Candidates: %1.', _candidates];
};

functionWithdrawFromGeneralElectionServer =
{
	_playerUID = _this select 0;
	_team = _this select 1;
	_teamLiteral = [_team] call functionGetTeamFORName;
	_candidates = missionNamespace getVariable (format ['generalElectionCandidates%1', _teamLiteral]);
	if (_playerUID in _candidates)
	then
	{
		[format ['generalElectionCandidates%1', _teamLiteral], _playerUID] call functionPublicVariableRemoveFromArray;
	};
	_candidates = missionNamespace getVariable (format ['generalElectionCandidates%1', _teamLiteral]);
	diag_log format ['functionWithdrawFromGeneralElectionServer Candidates: %1.', _candidates];
};

functionGeneralElectionRegisterVote =
{
	_voterUID = _this select 0;
	_candidateUID = _this select 1;
	_team = _this select 2;
	_teamLiteral = [_team] call functionGetTeamFORName;
	_votes = missionNamespace getVariable (format ['generalElectionVotes%1', _teamLiteral]);
	_voterRecord = [_votes, 0, _voterUID] call functionGetNestedArrayWithIndexValue;
	if (count _voterRecord == 0)
	then
	{
		[format ['generalElectionVotes%1', _teamLiteral], [_voterUID, _candidateUID]] call functionPublicVariableAppendToArray;
	}
	else
	{
		_currentVoterRecordCandidate = _voterRecord select 1;
		if (_currentVoterRecordCandidate != _candidateUID)
		then
		{
			_voterRecordRevised = +_voterRecord;
			_voterRecordRevised set [1, _candidateUID];
			_votes set [_votes find _voterRecord, _voterRecordRevised];
			[format ['generalElectionVotes%1', _teamLiteral], _votes] call functionPublicVariableSetValue;
		};
	};
	diag_log format ['generalElectionVotes: %1.', missionNamespace getVariable (format ['generalElectionVotes%1', _teamLiteral])];
};

functionGeneralElectionDeregisterVote =
{
	_voterUID = _this select 0;
	_team = _this select 1;
	_teamLiteral = [_team] call functionGetTeamFORName;
	[format ['generalElectionVotes%1', _teamLiteral], 0, _voterUID] call functionPublicVariableRemoveNestedArrayWithIndexValue;
};

functionResignAsCommanderServer =
{
	_team = _this select 0;
	_teamLiteral = [_team] call functionGetTeamFORName;
	_commanderUID = missionNamespace getVariable (format ['commander%1', _teamLiteral]);
	_playerDataRecord = [playersData, 0, _commanderUID] call functionGetNestedArrayWithIndexValue;
	_commanderName = _playerDataRecord select 1;
	[format ['commander%1', _teamLiteral], ''] call functionPublicVariableSetValue;
	[[_commanderName, 'resign', _team], 'functionHandleNoCommander', _team] call BIS_fnc_MP;
};