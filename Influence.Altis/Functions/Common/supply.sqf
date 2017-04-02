functionFindBestSupplyRoute =
{
	private ["_startBaseObject", "_destinationBaseObject"];
	_startBaseObject = _this select 0;
	_destinationBaseObject = _this select 1;
	_startBaseObject setVariable ["g", 0, false];
	_openList = [_startBaseObject];
	_closedList = [];
	while {(_openList select 0) != _destinationBaseObject}
	do
	{
		_currentNode = _openList select 0;
		_currentNodePosition2D = [position _currentNode select 0, position _currentNode select 1];
		_currentNodeG = (_currentNode getVariable ["g", 0]);
		_openList = _openList - [_currentNode];
		_closedList = _closedList + [_currentNode];
		_neighborNodes = (_currentNode getVariable 'supplyNodeNeighbors');
		//diag_log format ['functionFindBestSupplyRoute _neighborNodes: %1.', _neighborNodes];
		{
			_neighborNode = _x;
			_neighborNodePosition2D = [position _neighborNode select 0, position _neighborNode select 1];
			_movementCost = (_currentNodeG) + ((_currentNodePosition2D) distance (_neighborNodePosition2D));
			if ((_neighborNode in _openList) and (_movementCost < (_neighborNode getVariable "g")))
			then
			{
				_openList = _openList - [_neighborNode];
			};
			if ((_neighborNode in _closedList) and (_movementCost < (_neighborNode getVariable "g")))
			then
			{
				_closedList = _closedList - [_neighborNode];
			};
			if (!(_neighborNode in _openList) and !(_neighborNode in _closedList))
			then
			{
				_neighborNode setVariable ['g', _movementCost, false];
				_openList = [_neighborNode, _openList, _destinationBaseObject] call functionInsertNodeIntoOpenListByPriority;
				_neighborNode setVariable ['parent', _currentNode, false];
			};
		} forEach _neighborNodes;
	};
	_routePossible = false;
	_returnInformation = [];
	if (count _openList > 0)
	then
	{
		_routePossible = true;
		_bestRouteEndNode = (_openList select 0);
		_bestRouteNodesInSequence = [_bestRouteEndNode];
		_bestRouteTraversalCurrentNode = _bestRouteEndNode;
		while {(_bestRouteTraversalCurrentNode getVariable "parent") != _startBaseObject}
		do
		{
			_bestRouteTraversalCurrentNode = (_bestRouteTraversalCurrentNode getVariable "parent");
			_bestRouteNodesInSequence = [_bestRouteTraversalCurrentNode] + _bestRouteNodesInSequence;
		};
		_bestRouteTraversalCurrentNodePosition2D = [position _bestRouteTraversalCurrentNode select 0, position _bestRouteTraversalCurrentNode select 1];
		_startBaseObjectPosition2D = [position _startBaseObject select 0, position _startBaseObject select 1];
		//diag_log format ["Best Supply Route First Node: %1. Distance: %2. Position: %3. Parent: %4.", (_bestRouteTraversalCurrentNode getVariable "id"), ((_bestRouteTraversalCurrentNodePosition2D) distance (_startBaseObjectPosition2D)), _bestRouteTraversalCurrentNodePosition2D, ((_bestRouteTraversalCurrentNode getVariable "parent") getVariable "id")];
		_bestRouteFirstNode = _bestRouteTraversalCurrentNode;
		_returnInformation = [_routePossible, _bestRouteFirstNode, _bestRouteNodesInSequence];
	}
	else
	{
		_routePossible = false;
		_returnInformation = [_routePossible];
	};
	_returnInformation;
};

functionInsertNodeIntoOpenListByPriority =
{
	_nodeToInsert = _this select 0;
	_openList = _this select 1;
	_destinationBaseObject = _this select 2;
	_nodeToInsertPosition2D = [position _nodeToInsert select 0, position _nodeToInsert select 1];
	_destinationBaseObjectPosition2D = [position _destinationBaseObject select 0, position _destinationBaseObject select 1];
	_nodeToInsertF = (_nodeToInsert getVariable "g") + ((_nodeToInsertPosition2D) distance (_destinationBaseObjectPosition2D));
	if (count _openList == 0)
	then
	{
		_openList = _openList + [_nodeToInsert];
	}
	else
	{
		_lesserPrioritySegment = [];
		_greaterPrioritySegment = [];
		{
			_nodeToRankByPriority = _x;
			__nodeToRankByPriorityPosition2D = [position _nodeToRankByPriority select 0, position _nodeToRankByPriority select 1];
			__nodeToRankByPriorityF = (_nodeToRankByPriority getVariable "g") + ((__nodeToRankByPriorityPosition2D) distance (_destinationBaseObjectPosition2D));
			if ((__nodeToRankByPriorityF) > (_nodeToInsertF))
			then
			{
				_lesserPrioritySegment = _lesserPrioritySegment + [_nodeToRankByPriority];
			}
			else
			{
				if ((__nodeToRankByPriorityF) <= (_nodeToInsertF))
				then
				{
					_greaterPrioritySegment = _greaterPrioritySegment + [_nodeToRankByPriority];
				};
			};
		} forEach _openList;
		_openList = _greaterPrioritySegment + [_nodeToInsert] + _lesserPrioritySegment;
	};
	_openList;
};

functionGetNodeIDsInArray =
{
	_array = _this select 0;
	_arrayOutput = "[";
	if (count _array > 0)
	then
	{
		_loopCounter = 0;
		{
			_arrayOutput = _arrayOutput + (_x getVariable "id");
			if (!(_loopCounter == ((count _array) - 1)))
			then
			{
				_arrayOutput = _arrayOutput + ",";
			};
			_loopCounter = _loopCounter + 1;
		} forEach _array;
	};
	_arrayOutput = _arrayOutput + "]";
	_arrayOutput;
};

functionGetNodeNeighbors =
{
	private ['_node', '_nodePosition2D', '_neighborNodes', '_currentSupplyNode', '_currentSupplyNodePosition2D', '_team'];
	_node = _this select 0;
	_team = _this select 1;
	_nodePosition2D = [position _node select 0, position _node select 1];
	//diag_log format ['functionGetNodeNeighbors supplyNodes: %1.', supplyNodes];
	_neighborNodes = [];
	{
		_currentSupplyNode = _x;
		if ((_currentSupplyNode getVariable 'team') == _team)
		then
		{
			_currentSupplyNodePosition2D = [position _currentSupplyNode select 0, position _currentSupplyNode select 1];
			if ((((_currentSupplyNodePosition2D) distance (_nodePosition2D)) <= (supplyRelayStationRadius * 2)) and (_currentSupplyNode != _node))
			then
			{
				_neighborNodes = _neighborNodes + [_currentSupplyNode];
			};
		};
	} forEach supplyNodes;
	//diag_log format ['functionGetNodeNeighbors _neighborNodes: %1.', _neighborNodes];
	_neighborNodes;
};

functionGetTotalSupply =
{
	// Arguments: team
	private ['_team', '_totalSupply'];
	_team = _this select 0;
	_totalSupply = 0;
	{
		if ((_x getVariable 'team') == _team)
		then
		{
			_totalSupply = _totalSupply + (_x getVariable 'supplyAmount');
		};
	} forEach (playerControlledBases + FOBs);
	_totalSupply;
};

functionGetTotalQuota =
{
	// Arguments: team, (optional) exclude offline players
	private ['_team', '_excludeOffline', '_totalQuota', '_currentTeam', '_playerUID', '_playerQuota'];
	_team = _this select 0;
	_excludeOffline = false;
	if (count _this > 1)
	then
	{
		_excludeOffline = _this select 1;
	};
	_totalQuota = 0;
	{
		_currentTeam = _x select 3;
		if (_currentTeam == _team)
		then
		{
			_playerUID = _x select 0;
			if (!(_excludeOffline) or (_excludeOffline and ([_playerUID] call functionIsPlayerOnline)))
			then
			{
				_playerQuota = _x select 2;
				_totalQuota = _totalQuota + _playerQuota;
			};
		};
	} forEach playersDataPublic;
	_totalQuota;
};