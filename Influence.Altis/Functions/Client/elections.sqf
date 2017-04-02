/*functionEstablishCommanderElectionsEvents =
{
	(format ["commanderName%1", ([side player] call functionGetTeamFORName)]) addPublicVariableEventHandler {call functionHandleCommanderNameChange};
	(format ["commanderGeneralElectionStage%1", ([side player] call functionGetTeamFORName)]) addPublicVariableEventHandler {call functionHandleElectionStageChange};
	(format ["commanderChallengeElectionStage%1", ([side player] call functionGetTeamFORName)]) addPublicVariableEventHandler {call functionHandleChallengeElectionStageChange};
};

functionOpenCommanderElectionInterface =
{
	_interfaceHandler = createDialog "nwDialogueCommanderElection";
	systemChat format ["commanderGeneralElectionStage: %1", (missionNamespace getVariable format ["commanderGeneralElectionStage%1", ([side player] call functionGetTeamFORName)])];
	if ((missionNamespace getVariable format ["commanderGeneralElectionStage%1", ([side player] call functionGetTeamFORName)]) == "stand")
	then
	{
		ctrlShow [2004, false];
		ctrlShow [2005, false];
		ctrlSetText [2002, format ["Election Begins In: %1", (commanderElectionStandLengthInSeconds - standCountdownCounted)]];
		if (name player in (missionNamespace getVariable format ["commanderGeneralElectionCandidates%1", ([side player] call functionGetTeamFORName)]))
		then
		{
			ctrlSetText [2003, "Withdraw from Election"];
			buttonSetAction [2003, "call functionWithdrawFromCommanderElection;"];
		};
	};
	if ((missionNamespace getVariable format ["commanderGeneralElectionStage%1", ([side player] call functionGetTeamFORName)]) == "election")
	then
	{
		ctrlShow [2002, false];
		ctrlShow [2003, false];
		ctrlSetText [2004, format ["Election Concludes In: %1", (commanderElectionLengthInSeconds - electionCountdownCounted)]];
		_voteRecordFound = "";
		{
			_voteRecordVoter = _x select 0;
			_voteRecordVotedForCandidate = _x select 1;
			if (_voteRecordVoter == name player)
			then
			{
				_voteRecordFound = _voteRecordVotedForCandidate;
			};
		} forEach (missionNamespace getVariable format ["commanderGeneralElectionPlayerVotes%1", ([side player] call functionGetTeamFORName)]);
		_loopCounter = 0;
		{
			lbAdd [2005, _x];
			systemChat format ["Candidate: %1. Vote record: %2.", _x, _voteRecordFound];
			if (_x == _voteRecordFound)
			then
			{
				lbSetCurSel [2005, _loopCounter];
			};
			_loopCounter = _loopCounter + 1;
		} forEach (missionNamespace getVariable format ["commanderGeneralElectionCandidates%1", ([side player] call functionGetTeamFORName)]);
	};
};

functionEstablishElectionScrollMenuOption =
{
	_objectForScrollMenu = _this select 0;
	_showScrollMenuItemOnCrosshair = _this select 1;
	_scrollMenuItemTitle = "undefined";
	if ((missionNamespace getVariable format ["commanderGeneralElectionStage%1", ([side player] call functionGetTeamFORName)]) == "stand")
	then
	{
		_scrollMenuItemTitle = "Stand in Election";
	};
	if ((missionNamespace getVariable format ["commanderGeneralElectionStage%1", ([side player] call functionGetTeamFORName)]) == "election")
	then
	{
		_scrollMenuItemTitle = "Vote";
	};
	_scrollMenuItemTitle = format ["<t color='#FF8000'>%1</t>", _scrollMenuItemTitle];
	scrollMenuVoteItemID = _objectForScrollMenu addAction [_scrollMenuItemTitle, functionOpenCommanderElectionInterface, "", 2000, _showScrollMenuItemOnCrosshair, true, "", "alive _target and _target == player"];
};

functionStartElectionForCommander =
{
	if (!(missionNamespace getVariable format ["commanderGeneralElectionInProgress%1", ([side player] call functionGetTeamFORName)]))
	then
	{
		[[side player], "functionConductElectionForCommander", false] call BIS_fnc_MP;
		missionNamespace setVariable [format ["commanderGeneralElectionStage%1", ([side player] call functionGetTeamFORName)], "stand"];
		standCountdownCounted = 0;
	};
};

functionHandleElectionStageChange =
{
	systemChat format ["commanderGeneralElectionStage change: %1", (missionNamespace getVariable format ["commanderGeneralElectionStage%1", ([side player] call functionGetTeamFORName)])];
	if ((missionNamespace getVariable format ["commanderGeneralElectionStage%1", ([side player] call functionGetTeamFORName)]) == "stand")
	then
	{
		[] spawn functionDisplayStandCountdown;
		[player, false] call functionEstablishElectionScrollMenuOption;
	};
	if ((missionNamespace getVariable format ["commanderGeneralElectionStage%1", ([side player] call functionGetTeamFORName)]) == "election")
	then
	{
		[] spawn functionDisplayElectionCountdown;
		player removeAction scrollMenuVoteItemID;
		[player, true] call functionEstablishElectionScrollMenuOption;
	};
	if ((missionNamespace getVariable format ["commanderGeneralElectionStage%1", ([side player] call functionGetTeamFORName)]) == "noCandidates")
	then
	{
		ctrlSetText [2004, "Election cancelled - no candidates."];
		ctrlShow [2002, false];
		ctrlShow [2003, false];
		player removeAction scrollMenuVoteItemID;
		systemChat "Commander election has been cancelled, as there were no candidates for election.";
	};
	if ((missionNamespace getVariable format ["commanderGeneralElectionStage%1", ([side player] call functionGetTeamFORName)]) == "concluded")
	then
	{
		ctrlSetText [2004, "Commander election has concluded."];
		ctrlShow [2005, false];
		player removeAction scrollMenuVoteItemID;
		systemChat format ["Commander election has concluded. New commander is %1.", (missionNamespace getVariable format ["commanderName%1", ([side player] call functionGetTeamFORName)])];
	};
};

functionDisplayStandCountdown =
{
	standCountdownCounted = 0;
	while {(missionNamespace getVariable format ["commanderGeneralElectionStage%1", ([side player] call functionGetTeamFORName)]) == "stand"}
	do
	{
		ctrlSetText [2002, format ["Election Begins In: %1", (commanderElectionStandLengthInSeconds - standCountdownCounted)]];
		sleep 1;
		standCountdownCounted = standCountdownCounted + 1;
	};
	ctrlShow [2002, false];
	ctrlShow [2003, false];
	ctrlShow [2004, true];
	ctrlShow [2005, true];
};

functionDisplayElectionCountdown =
{
	{
		lbAdd [2005, _x];
	} forEach (missionNamespace getVariable format ["commanderGeneralElectionCandidates%1", ([side player] call functionGetTeamFORName)]);
	electionCountdownCounted = 0;
	while {(missionNamespace getVariable format ["commanderGeneralElectionStage%1", ([side player] call functionGetTeamFORName)]) == "election"}
	do
	{
		ctrlSetText [2004, format ["Election Concludes In: %1", (commanderElectionLengthInSeconds - electionCountdownCounted)]];
		sleep 1;
		electionCountdownCounted = electionCountdownCounted + 1;
	};
};

functionStandForCommanderElection =
{
	if (!(name player in (missionNamespace getVariable format ["commanderGeneralElectionCandidates%1", ([side player] call functionGetTeamFORName)])))
	then
	{
		[format ["commanderGeneralElectionCandidates%1", ([side player] call functionGetTeamFORName)], (missionNamespace getVariable format ["commanderGeneralElectionCandidates%1", ([side player] call functionGetTeamFORName)]) + [name player]] call functionPublicVariableSetValue;
		ctrlSetText [2003, "Withdraw from Election"];
		buttonSetAction [2003, "call functionWithdrawFromCommanderElection;"];
	};
};

functionWithdrawFromCommanderElection =
{
	[format ["commanderGeneralElectionCandidates", ([side player] call functionGetTeamFORName)], (missionNamespace getVariable format ["commanderGeneralElectionCandidates%1", ([side player] call functionGetTeamFORName)]) - [name player]] call functionPublicVariableSetValue;
	ctrlSetText [2003, "Stand for Election to Commander"];
	buttonSetAction [2003, "call functionStandForCommanderElection;"];
};

functionHandleCommanderElectionCandidateSelection =
{
	_candidateSelected = lbText [2005, _this select 1];
	_voteRecordFound = false;
	{
		_voteRecordVoter = _x select 0;
		if (_voteRecordVoter == name player)
		then
		{
			_x set [1, _candidateSelected];
			_voteRecordFound = true;
		};
	} forEach (missionNamespace getVariable format ["commanderGeneralElectionPlayerVotes%1", ([side player] call functionGetTeamFORName)]);
	if (!(_voteRecordFound))
	then
	{
		[format ["commanderGeneralElectionPlayerVotes%1", ([side player] call functionGetTeamFORName)], (missionNamespace getVariable format ["commanderGeneralElectionPlayerVotes%1", ([side player] call functionGetTeamFORName)]) + [[name player, _candidateSelected]]] call functionPublicVariableSetValue;
	};
};

functionHandleCommanderNameChange =
{
	_commanderName = _this select 1;
	if (_commanderName == "")
	then
	{
		systemChat "The team no longer has a commander.";
	};
};

functionOpenChallengeElectionInterface =
{
	createDialog "nwDialogueCommanderChallengeElection";
	ctrlSetFocus ((findDisplay 8) displayCtrl 8090);
	if ((missionNamespace getVariable format ["commanderChallengeElectionStage%1", ([side player] call functionGetTeamFORName)]) == "")
	then
	{
		ctrlShow [8001, true];
		ctrlShow [8002, true];
		ctrlShow [8003, true];
		ctrlShow [8004, false];
		ctrlShow [8005, false];
		ctrlShow [8006, false];
		ctrlShow [8007, false];
		ctrlShow [8008, false];
		ctrlShow [8009, false];
		ctrlShow [8010, false];
		ctrlShow [8011, false];
		ctrlSetText [8000, "Prepare Challenge"];
	};
	if ((missionNamespace getVariable format ["commanderChallengeElectionStage%1", ([side player] call functionGetTeamFORName)]) == "rebuttal")
	then
	{
		ctrlShow [8001, false];
		ctrlShow [8002, false];
		ctrlShow [8003, false];
		ctrlShow [8004, true];
		ctrlShow [8005, true];
		ctrlShow [8006, true];
		ctrlShow [8007, true];
		ctrlShow [8008, false];
		ctrlShow [8009, false];
		ctrlShow [8010, false];
		ctrlShow [8011, false];
		ctrlSetText [8000, format ["Rebut In: %1", (commanderChallengeElectionRebutPeriodInSeconds - rebutPeriodCountdownCountedSeconds)]];
		ctrlSetText [8004, format ["Challenger's Rationale: %1", (missionNamespace getVariable format ["commanderChallengeElectionChallengerRationale%1", ([side player] call functionGetTeamFORName)])]];
	};
	if ((missionNamespace getVariable format ["commanderChallengeElectionStage%1", ([side player] call functionGetTeamFORName)]) == "challenge")
	then
	{
		ctrlShow [8001, false];
		ctrlShow [8002, false];
		ctrlShow [8003, false];
		ctrlShow [8004, false];
		ctrlShow [8005, false];
		ctrlShow [8006, false];
		ctrlShow [8007, false];
		ctrlShow [8008, true];
		ctrlShow [8009, true];
		ctrlShow [8010, true];
		ctrlShow [8011, true];
		ctrlSetText [8000, format ["Challenge Concludes In: %1", (commanderChallengeElectionChallengePeriodInSeconds - challengePeriodCountdownCountedSeconds)]];
		ctrlSetText [8008, (missionNamespace getVariable format ["commanderChallengeElectionChallengerRationale%1", ([side player] call functionGetTeamFORName)])];
		if ((missionNamespace getVariable format ["commanderChallengeElectionCommanderRebuttal%1", ([side player] call functionGetTeamFORName)]) == "")
		then
		{
			ctrlSetText [8009, "Commander did not provide a rebuttal."];
		}
		else
		{
			ctrlSetText [8009, (missionNamespace getVariable format ["commanderChallengeElectionCommanderRebuttal%1", ([side player] call functionGetTeamFORName)])];
		};
	};
};

functionHandleChallengeElectionStageChange =
{
	systemChat format ["commanderChallengeElectionStage: %1.", (missionNamespace getVariable format ["commanderChallengeElectionStage%1", ([side player] call functionGetTeamFORName)])];
	if (((missionNamespace getVariable format ["commanderChallengeElectionStage%1", ([side player] call functionGetTeamFORName)]) == "rebuttal") and (name player == (missionNamespace getVariable format ["commanderName%1", ([side player] call functionGetTeamFORName)])))
	then
	{
		[] spawn functionDisplayRebutPeriodCountdown;
		[player] call functionEstablishChallengeElectionScrollMenuOption;
	};
	if ((missionNamespace getVariable format ["commanderChallengeElectionStage%1", ([side player] call functionGetTeamFORName)]) == "challenge")
	then
	{
		[] spawn functionDisplayChallengePeriodCountdown;
		systemChat "Commander challenge has begun.";
		ctrlShow [8001, false];
		ctrlShow [8002, false];
		ctrlShow [8003, false];
		ctrlShow [8004, false];
		ctrlShow [8005, false];
		ctrlShow [8006, false];
		ctrlShow [8007, false];
		ctrlShow [8008, true];
		ctrlShow [8009, true];
		ctrlShow [8010, true];
		ctrlShow [8011, true];
		ctrlSetText [8008, format ["Challenger's Rationale: %1", (missionNamespace getVariable format ["commanderChallengeElectionChallengerRationale%1", ([side player] call functionGetTeamFORName)])]];
		if ((missionNamespace getVariable format ["commanderChallengeElectionCommanderRebuttal%1", ([side player] call functionGetTeamFORName)]) == "")
		then
		{
			ctrlSetText [8009, "Commander did not provide a rebuttal."];
		}
		else
		{
			ctrlSetText [8009, format ["Commander's Rebuttal: %1", (missionNamespace getVariable format ["commanderChallengeElectionCommanderRebuttal%1", ([side player] call functionGetTeamFORName)])]];
		};
		player removeAction scrollMenuVoteItemID;
		[player] call functionEstablishChallengeElectionScrollMenuOption;
	};
	if ((missionNamespace getVariable format ["commanderChallengeElectionStage%1", ([side player] call functionGetTeamFORName)]) == "concluded")
	then
	{
		ctrlShow [8001, false];
		ctrlShow [8002, false];
		ctrlShow [8003, false];
		ctrlShow [8004, false];
		ctrlShow [8005, false];
		ctrlShow [8006, false];
		ctrlShow [8007, false];
		ctrlShow [8008, false];
		ctrlShow [8009, false];
		ctrlShow [8010, false];
		ctrlShow [8011, false];
		player removeAction scrollMenuVoteItemID;
		if ((missionNamespace getVariable format ["commanderName%1", ([side player] call functionGetTeamFORName)]) != (missionNamespace getVariable format ["commanderChallengeElectionChallenger%1", ([side player] call functionGetTeamFORName)]))
		then
		{
			systemChat format ["Commander challenge has concluded. %1 remains commander.", (missionNamespace getVariable format ["commanderName%1", ([side player] call functionGetTeamFORName)])];
			ctrlSetText [8000, format ["Challenge concluded. %1 remains commander.", (missionNamespace getVariable format ["commanderName%1", ([side player] call functionGetTeamFORName)])]];
		}
		else
		{
			systemChat format ["Commander challenge has concluded. %1 is the new commander.", (missionNamespace getVariable format ["commanderChallengeElectionChallenger%1", ([side player] call functionGetTeamFORName)])];
			ctrlSetText [8000, format ["Challenge concluded. %1 is the new commander.", (missionNamespace getVariable format ["commanderChallengeElectionChallenger%1", ([side player] call functionGetTeamFORName)])]];
		};
	};
};

functionEstablishChallengeElectionScrollMenuOption =
{
	_objectForScrollMenu = _this select 0;
	if ((missionNamespace getVariable format ["commanderChallengeElectionStage%1", ([side player] call functionGetTeamFORName)]) == "rebuttal" and (missionNamespace getVariable format ["commanderName%1", ([side player] call functionGetTeamFORName)]) == name player)
	then
	{
		scrollMenuVoteItemID = _objectForScrollMenu addAction ["<t color='#FF8000'>Rebut Challenge</t>", functionOpenChallengeElectionInterface, "", 2000, true, true, "", "alive _target"];
	};
	if ((missionNamespace getVariable format ["commanderChallengeElectionStage%1", ([side player] call functionGetTeamFORName)]) == "challenge")
	then
	{
		scrollMenuVoteItemID = _objectForScrollMenu addAction ["<t color='#FF8000'>Vote</t>", functionOpenChallengeElectionInterface, "", 2000, true, true, "", "alive _target"];
	};
};

functionDisplayRebutPeriodCountdown =
{
	rebutPeriodCountdownCountedSeconds = 0;
	while {(missionNamespace getVariable format ["commanderChallengeElectionStage%1", ([side player] call functionGetTeamFORName)]) == "rebuttal"}
	do
	{
		ctrlSetText [8000, format ["Rebut in %1", (commanderChallengeElectionRebutPeriodInSeconds - rebutPeriodCountdownCountedSeconds)]];
		sleep 1;
		rebutPeriodCountdownCountedSeconds = rebutPeriodCountdownCountedSeconds + 1;
	};
};

functionHandleChallengeElectionRationaleClick =
{
	if ((ctrlText 8001) == "Explain your rationale for challenging the commander...")
	then
	{
		ctrlSetText [8001, ""];
	};
};

functionHandleChallengeElectionRationaleLoseFocus =
{
	if ((ctrlText 8001) == "")
	then
	{
		ctrlSetText [8001, "Explain your rationale for challenging the commander..."];
	};
};

functionHandleChallengeElectionRationaleChange =
{
	ctrlSetText [8002, format ["Characters: %1/%2.", (count (toArray (ctrlText 8001))), challengeElectionRationaleCharacterLimit]];
};

functionLaunchCommanderChallenge =
{
	if ((missionNamespace getVariable format ['commanderChallengeElectionChallenger%1', ([side player] call functionGetTeamFORName)]) == "")
	then
	{
		_challengeRationaleText = ctrlText 8001;
		_lengthOfChallengeRationale = count (toArray (ctrlText 8001));
		if ((_lengthOfChallengeRationale >= challengeElectionRationaleMinimumLength) or (_challengeRationaleText != "Explain your rationale for challenging the commander..."))
		then
		{
			[format ["commanderChallengeElectionChallenger%1", ([side player] call functionGetTeamFORName)], name player] call functionPublicVariableSetValue;
			[format ["commanderChallengeElectionChallengerRationale%1", ([side player] call functionGetTeamFORName)], ctrlText 8001] call functionPublicVariableSetValue;
			[[side player], "functionConductChallengeElectionForCommander", false] call BIS_fnc_MP;
			closeDialog 0;
			hint format ["The commander will be given %1 seconds to rebut your challenge.", commanderChallengeElectionRebutPeriodInSeconds];
		}
		else
		{
			hint format ["Challenge rationale must be at least %1 characters in length.", challengeElectionRationaleMinimumLength];
		};
	}
	else
	{
		hint format ["Another challenge by %1 is already underway.", (missionNamespace getVariable format ['commanderChallengeElectionChallenger%1', ([side player] call functionGetTeamFORName)])];
	};
};

functionHandleChallengeElectionRebuttalClick =
{
	if ((ctrlText 8005) == "Rebut your challenger's rationale...")
	then
	{
		ctrlSetText [8005, ""];
	};
};

functionHandleChallengeElectionRebuttalChange =
{
	ctrlSetText [8006, format ["Characters: %1/%2.", (count (toArray (ctrlText 8005))), challengeElectionRebuttalCharacterLimit]];
};

functionIssueCommanderChallengeElectionRebuttal =
{
	_rationaleRebuttal = ctrlText 8005;
	if (_rationaleRebuttal != "Rebut your challenger's rationale...")
	then
	{
		[format ["commanderChallengeElectionCommanderRebuttal%1", ([side player] call functionGetTeamFORName)], ctrlText 8005] call functionPublicVariableSetValue;
		closeDialog 0;
		hint "Rebuttal will be displayed when the challenge election begins.";
	}
	else
	{
		hint "Please input a rebuttal into the text field.";
	};
};

functionDisplayChallengePeriodCountdown =
{
	challengePeriodCountdownCountedSeconds = 0;
	while {(missionNamespace getVariable format ["commanderChallengeElectionStage%1", ([side player] call functionGetTeamFORName)]) == "challenge"}
	do
	{
		ctrlSetText [8000, format ["Challenge Concludes In: %1", (commanderChallengeElectionChallengePeriodInSeconds - challengePeriodCountdownCountedSeconds)]];
		sleep 1;
		challengePeriodCountdownCountedSeconds = challengePeriodCountdownCountedSeconds + 1;
	};
};

functionChallengeElectionSupportCommander =
{
	_alreadySupported = false;
	{
		if ((_x select 0) == (name player))
		then
		{
			_x set [1, (missionNamespace getVariable format ["commanderName%1", ([side player] call functionGetTeamFORName)])];
			_alreadySupported = true;
		};
	} forEach (missionNamespace getVariable format ["commanderChallengeElectionPlayerVotes%1", ([side player] call functionGetTeamFORName)]);
	publicVariable format ["commanderChallengeElectionPlayerVotes%1", ([side player] call functionGetTeamFORName)];
	if (!(_alreadySupported))
	then
	{
		[format ["commanderChallengeElectionPlayerVotes%1", ([side player] call functionGetTeamFORName)], (missionNamespace getVariable format ["commanderChallengeElectionPlayerVotes%1", ([side player] call functionGetTeamFORName)]) + [[name player, (missionNamespace getVariable format ["commanderName%1", ([side player] call functionGetTeamFORName)])]]] call functionPublicVariableSetValue;
	};
	hint "Registered support for commander.";
};

functionChallengeElectionSupportChallenger =
{
	_alreadySupported = false;
	{
		if ((_x select 0) == (name player))
		then
		{
			_x set [1, (missionNamespace getVariable format ["commanderChallengeElectionChallenger%1", ([side player] call functionGetTeamFORName)])];
			_alreadySupported = true;
		};
	} forEach (missionNamespace getVariable format ["commanderChallengeElectionPlayerVotes%1", ([side player] call functionGetTeamFORName)]);
	publicVariable format ["commanderChallengeElectionPlayerVotes%1", ([side player] call functionGetTeamFORName)];
	if (!(_alreadySupported))
	then
	{
		[format ["commanderChallengeElectionPlayerVotes%1", ([side player] call functionGetTeamFORName)], (missionNamespace getVariable format ["commanderChallengeElectionPlayerVotes%1", ([side player] call functionGetTeamFORName)]) + [[name player, (missionNamespace getVariable format ["commanderChallengeElectionChallenger%1", ([side player] call functionGetTeamFORName)])]]] call functionPublicVariableSetValue;
	};
	hint "Registered support for challenger.";
};

functionResignAsCommander =
{
	[format ["commanderName%1", ([side player] call functionGetTeamFORName)], ""] call functionPublicVariableSetValue;
	systemChat "The team no longer has a commander.";
	ctrlSetText [1002, "Stand for Election to Commander"];
	buttonSetAction [1002, "closeDialog 0; call functionStartElectionForCommander; call functionOpenCommanderElectionInterface;"];
	ctrlEnable [1003, false];
	ctrlEnable [1004, false];
	ctrlEnable [1005, false];
	ctrlEnable [1006, false];
};*/

functionEstablishCommanderElectionsEvents =
{
	_teamLiteral = [side player] call functionGetTeamFORName;
	(format ['generalElectionStage%1', _teamLiteral]) addPublicVariableEventHandler functionHandleGeneralElectionStageChange;
	(format ['commanderChallengeElectionStage%1', _teamLiteral]) addPublicVariableEventHandler {call functionHandleChallengeElectionStageChange};
};

functionStartGeneralElectionClient =
{
	call functionOpenCommanderElectionInterface;
	[[side player], 'functionStartGeneralElectionServer', false] call BIS_fnc_MP;
};

functionHandleGeneralElectionStageChange =
{
	_teamLiteral = [side player] call functionGetTeamFORName;
	_electionStage = missionNamespace getVariable (format ['generalElectionStage%1', _teamLiteral]);
	//systemChat format ['Election Stage: %1', _electionStage];
	switch (_electionStage)
	do
	{
		case 'stand':
		{
			ctrlShow [2002, true];
			ctrlShow [2003, true];
			[] spawn functionGeneralElectionStandCountdown;
			[player, false] call functionEstablishElectionScrollMenuOption;
			_message = 'Candidates may now stand for the commander election.';
			systemChat _message;
			['Notification', ['Commander Election', _message]] call bis_fnc_showNotification;
		};
		case 'vote':
		{
			ctrlShow [2002, false];
			ctrlShow [2003, false];
			ctrlShow [2004, true];
			ctrlShow [2005, true];
			[] spawn functionGeneralElectionVoteCountdown;
			player removeAction scrollMenuVoteItemID;
			[player, true] call functionEstablishElectionScrollMenuOption;
			[] call functionGeneralElectionPopulateCandidateList;
			_message = 'Voters may now vote in the commander election.';
			systemChat _message;
			['Notification', ['Commander Election', _message]] call bis_fnc_showNotification;
		};
		case 'noCandidates':
		{
			player removeAction scrollMenuVoteItemID;
			systemChat 'Commander election cancelled, as there were no candidates.';
			[2] call functionCloseDialogue;
		};
		case 'concluded':
		{
			player removeAction scrollMenuVoteItemID;
			[2] call functionCloseDialogue;
		};
	};
};

functionEstablishGeneralElectionStageClient =
{
	_teamLiteral = [side player] call functionGetTeamFORName;
	_electionStage = missionNamespace getVariable (format ['generalElectionStage%1', _teamLiteral]);
	switch (_electionStage)
	do
	{
		case 'stand':
		{
			_elapsedSeconds = missionNamespace getVariable (format ['generalElectionStageElapsedSeconds%1', _teamLiteral]);
			[_elapsedSeconds] spawn functionGeneralElectionStandCountdown;
			[player, false] call functionEstablishElectionScrollMenuOption;
		};
		case 'vote':
		{
			_elapsedSeconds = missionNamespace getVariable (format ['generalElectionStageElapsedSeconds%1', _teamLiteral]);
			[_elapsedSeconds] spawn functionGeneralElectionVoteCountdown;
			[player, true] call functionEstablishElectionScrollMenuOption;
		};
	};
};

functionEstablishElectionScrollMenuOption =
{
	_objectForScrollMenu = _this select 0;
	_showScrollMenuItemOnCrosshair = _this select 1;
	_scrollMenuItemTitle = 'undefined';
	_teamLiteral = [side player] call functionGetTeamFORName;
	_electionStage = missionNamespace getVariable (format ['generalElectionStage%1', _teamLiteral]);
	if (_electionStage == 'stand')
	then
	{
		_scrollMenuItemTitle = 'Stand in Election';
	};
	if (_electionStage == 'vote')
	then
	{
		_scrollMenuItemTitle = 'Vote';
	};
	_scrollMenuItemTitle = format ['<t color="#FF8000">%1</t>', _scrollMenuItemTitle];
	scrollMenuVoteItemID = _objectForScrollMenu addAction [_scrollMenuItemTitle, functionOpenCommanderElectionInterface, '', 2000, _showScrollMenuItemOnCrosshair, true, '','alive _target and _target == player'];
};

functionGeneralElectionStandCountdown =
{
	_teamLiteral = [side player] call functionGetTeamFORName;
	standCountdownCounted = 0;
	if (count _this > 0)
	then
	{
		standCountdownCounted = _this select 0;
	};
	while {(missionNamespace getVariable (format ['generalElectionStage%1', _teamLiteral])) == 'stand' and (commanderElectionStandLengthInSeconds - standCountdownCounted) > 0}
	do
	{
		ctrlSetText [2002, format ['Election Begins: %1', (commanderElectionStandLengthInSeconds - standCountdownCounted)]];
		sleep 1;
		standCountdownCounted = standCountdownCounted + 1;
	};
	ctrlShow [2002, false];
	ctrlShow [2003, false];
};

functionGeneralElectionVoteCountdown =
{
	_teamLiteral = [side player] call functionGetTeamFORName;
	electionCountdownCounted = 0;
	if (count _this > 0)
	then
	{
		electionCountdownCounted = _this select 0;
	};
	while {(missionNamespace getVariable (format ['generalElectionStage%1', _teamLiteral])) == 'vote' and (commanderElectionLengthInSeconds - electionCountdownCounted) > 0}
	do
	{
		ctrlSetText [2004, format ['Election Concludes: %1', (commanderElectionLengthInSeconds - electionCountdownCounted)]];
		sleep 1;
		electionCountdownCounted = electionCountdownCounted + 1;
	};
	ctrlShow [2005, false];
	ctrlSetText [2004, 'Election Concluded'];
};

functionOpenCommanderElectionInterface =
{
	createDialog 'nwDialogueCommanderElection';
	ctrlShow [2002, false];
	ctrlShow [2003, false];
	ctrlShow [2004, false];
	ctrlShow [2005, false];
	_teamLiteral = [side player] call functionGetTeamFORName;
	_electionStage = missionNamespace getVariable (format ['generalElectionStage%1', _teamLiteral]);
	//systemChat format ['Election Stage: %1', _electionStage];
	_candidates = missionNamespace getVariable (format ['generalElectionCandidates%1', _teamLiteral]);
	switch (_electionStage)
	do
	{
		case 'stand':
		{
			ctrlShow [2002, true];
			ctrlShow [2003, true];
			ctrlShow [2004, false];
			ctrlShow [2005, false];
			ctrlSetText [2002, format ['Election Begins: %1', (commanderElectionStandLengthInSeconds - standCountdownCounted)]];
			if (getPlayerUID player in _candidates)
			then
			{
				ctrlSetText [2003, 'Withdraw from Election'];
				buttonSetAction [2003, 'call functionWithdrawFromGeneralElection;'];
			};
		};
		case 'vote':
		{
			ctrlShow [2002, false];
			ctrlShow [2003, false];
			ctrlShow [2004, true];
			ctrlShow [2005, true];
			ctrlSetText [2004, format ['Election Concludes: %1', (commanderElectionLengthInSeconds - electionCountdownCounted)]];
			[] call functionGeneralElectionPopulateCandidateList;
		};
	};
};

functionGeneralElectionPopulateCandidateList =
{
	_ignoreVoterRecord = false;
	if (count _this > 0)
	then
	{
		_ignoreVoterRecord = _this select 0;
	};
	//diag_log format ['_ignoreVoterRecord: %1. typeName: %2.', _ignoreVoterRecord, typeName _ignoreVoterRecord];
	//systemChat format ['_ignoreVoterRecord: %1. typeName: %2.', _ignoreVoterRecord, typeName _ignoreVoterRecord];
	_teamLiteral = [side player] call functionGetTeamFORName;
	lbClear 2005;
	_votes = missionNamespace getVariable (format ['generalElectionVotes%1', _teamLiteral]);
	_voterRecord = [_votes, 0, getPlayerUID player] call functionGetNestedArrayWithIndexValue;
	_candidates = missionNamespace getVariable (format ['generalElectionCandidates%1', _teamLiteral]);
	//diag_log format ['Candidates: %1.', _candidates];
	{
		_candidateUID = _x;
		_playerDataRecord = [playersDataPublic, 0, _candidateUID] call functionGetNestedArrayWithIndexValue;
		_candidateName = _playerDataRecord select 1;
		_indexInList = lbAdd [2005, _candidateName];
		lbSetData [2005, _indexInList, _candidateUID];
		//systemChat format ['Candidate: %1 (%2). Vote record: %3.', _candidateName, _candidateUID, _voterRecord];
		if (count _voterRecord > 0 and !(_ignoreVoterRecord))
		then
		{
			_voterRecordCandidateUID = _voterRecord select 1;
			if (_candidateUID == _voterRecordCandidateUID)
			then
			{
				lbSetCurSel [2005, _forEachIndex];
			};
		};
	} forEach _candidates;
};

functionStandForGeneralElectionClient =
{
	[[getPlayerUID player, side player], 'functionStandForGeneralElectionServer', false] call BIS_fnc_MP;
	ctrlSetText [2003, 'Withdraw from Election'];
	buttonSetAction [2003, 'call functionWithdrawFromGeneralElectionClient;'];
};

functionWithdrawFromGeneralElectionClient =
{
	[[getPlayerUID player, side player], 'functionWithdrawFromGeneralElectionServer', false] call BIS_fnc_MP;
	ctrlSetText [2003, 'Stand for Election to Commander'];
	buttonSetAction [2003, 'call functionStandForGeneralElectionClient;'];
};

functionHandleGeneralElectionCandidateSelection =
{
	_selectedID = _this select 1;
	_teamLiteral = [side player] call functionGetTeamFORName;
	_votes = missionNamespace getVariable (format ['generalElectionVotes%1', _teamLiteral]);
	_voterRecord = [_votes, 0, getPlayerUID player] call functionGetNestedArrayWithIndexValue;
	_voterRecordCandidateUID = '';
	if (count _voterRecord > 0)
	then
	{
		_voterRecordCandidateUID = _voterRecord select 1;
	};
	_candidateUID = lbData [2005, _selectedID];
	//diag_log format ['_voterRecordCandidateUID: %1. _candidateUID: %2.', _voterRecordCandidateUID, _candidateUID];
	//systemChat format ['_voterRecordCandidateUID: %1. _candidateUID: %2.', _voterRecordCandidateUID, _candidateUID];
	/*if (_voterRecordCandidateUID == _candidateUID)
	then
	{
		[true] call functionGeneralElectionPopulateCandidateList;
		[[getPlayerUID player, side player], 'functionGeneralElectionDeregisterVote', false] call BIS_fnc_MP;
	}
	else
	{*/
		[[getPlayerUID player, _candidateUID, side player], 'functionGeneralElectionRegisterVote', false] call BIS_fnc_MP;
	//};
};

functionResignAsCommanderClient =
{
	[[side player], 'functionResignAsCommanderServer', false] call BIS_fnc_MP;
	ctrlSetText [1002, 'Stand for Election to Commander'];
	buttonSetAction [1002, 'closeDialog 0; call functionStartGeneralElectionClient;'];
	ctrlEnable [1003, false];
	ctrlEnable [1004, false];
	ctrlEnable [1005, false];
	ctrlEnable [1006, false];
	ctrlEnable [1007, false];
	ctrlEnable [1008, false];
};

functionHandleNewCommander =
{
	_commanderName = _this select 0;
	_team = _this select 1;
	_teamLiteral = [_team] call functionGetTeamFORName;
	_message = format ['%1 has been elected %2 commander.', _commanderName, _teamLiteral];
	systemChat _message;
	['NotificationPositive', ['New Commander', _message]] call bis_fnc_showNotification;
	call functionUpdateTeamsInformationHUD;
};

functionHandleNoCommander =
{
	_commanderName = _this select 0;
	_reason = _this select 1;
	_team = _this select 2;
	_teamLiteral = [_team] call functionGetTeamFORName;
	call functionUpdateTeamsInformationHUD;
	_message = '';
	switch (_reason)
	do
	{
		case 'resign':
		{
			_message = format ['%1 has resigned as %2 commander.', _commanderName, _teamLiteral];
		};
		case 'disconnect':
		{
			_message = format ['Commander %1 disconnected. %2 commander vacant.', _commanderName, _teamLiteral];
		};
		default
		{
			_message = format ['%1 no longer has a commander.', _teamLiteral];
		};
	};
	systemChat _message;
	['NotificationNegative', ['Commander Vacant', _message]] call bis_fnc_showNotification;
};