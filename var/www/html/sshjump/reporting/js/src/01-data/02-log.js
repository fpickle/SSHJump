function getLogStore(id) {
  var Parameters;

  if(typeof(id) == "undefined") {
    Parameters = {
      Class: 'HostLogUser'
    };
  } else {
    Parameters = {
      Class: 'HostLogUser',
      SessionID: id
    };
  }

  var LogReader = new Ext.data.JsonReader(
    { id: 'Log' },
    [ { name: 'LogID',
        type: 'int',
        mapping: 'LogID' },
    { name: 'UserName',
        type: 'string',
        mapping: 'UserName' },
    { name: 'HostName',
        type: 'string',
        mapping: 'HostName' },
    { name: 'EntryType',
        type: 'string',
        mapping: 'EntryType' },
    { name: 'EntryTime',
        type: 'string',
        mapping: 'EntryTime' },
    { name: 'Entry',
        type: 'string',
        mapping: 'Entry' } ]
  );

  LogStore = new Ext.data.Store( {
    id:       'LogStore',
    proxy:    Url,
    reader:   LogReader,
    sortInfo: {
      field:     'EntryTime',
      direction: 'ASC'
    },
    baseParams: Parameters
  } );

  LogStore.load();

  return LogStore;
}
