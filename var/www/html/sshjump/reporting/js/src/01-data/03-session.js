function getSessionStore(type, status, id) {

  var SessionReader = new Ext.data.JsonReader(
    { id: 'SessionReader' },
    [ { name: 'HostName',
        type: 'string',
        mapping: 'HostName' },
      { name: 'LastEntry',
        type: 'string',
        mapping: 'LastEntry' },
      { name: 'LogID',
        type: 'int',
        mapping: 'LogID' },
      { name: 'Reason',
        type: 'string',
        mapping: 'Reason' },
      { name: 'SessionID',
        type: 'int',
        mapping: 'SessionID' },
      { name: 'Status',
        type: 'string',
        mapping: 'Status' },
      { name: 'TimeClosed',
        type: 'string',
        mapping: 'TimeClosed' },
      { name: 'TimeOpened',
        type: 'string',
        mapping: 'TimeOpened' },
      { name: 'Type',
        type: 'string',
        mapping: 'Type' },
      { name: 'UserName',
        type: 'string',
        mapping: 'UserName' } ]
  );

  var SessionStore = new Ext.data.Store ( {
    id: 'SessionStore',
    proxy:  Url,
    reader: SessionReader,
    sortInfo: {
      field:     'UserName',
      direction: 'ASC'
    },
    baseParams: {
      Class: 'HostLogSessionUser',
      Status: status,
      Type: type,
      UserID: id
    }
  } );

  SessionStore.load();

  return SessionStore;
}
