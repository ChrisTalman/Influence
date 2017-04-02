functionHandleImapDumpClient =
{
	_dump = _this select 0;
	if (!(isNil 'influenceMap'))
	then
	{
		[influenceMap, _dump] call imapSetDump;
	};
};