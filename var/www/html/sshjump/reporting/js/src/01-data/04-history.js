function getHistoryStore() {

  var HistoryReader = new Ext.data.JsonReader(
    { id: 'HistoryReader' },
    [ { name: 'Email',
        type: 'string',
        mapping: 'Email' },
      { name: 'LastEntryTime',
        type: 'string',
        mapping: 'LastEntryTime' },
      { name: 'Phone',
        type: 'string',
        mapping: 'Phone' },
      { name: 'RealName',
        type: 'string',
        mapping: 'RealName' },
      { name: 'Sessions',
        type: 'int',
        mapping: 'Sessions' },
      { name: 'UserName',
        type: 'string',
        mapping: 'UserName' },
      { name: 'UserID',
        type: 'int',
        mapping: 'UserID' } ]
  );

  var HistoryStore = new Ext.data.Store ( {
    id: 'HistoryStore',
    proxy:  Url,
    reader: HistoryReader,
    sortInfo: {
      field:     'UserName',
      direction: 'ASC'
    },
    baseParams: {
      Class:  'LogSessionUser',
    }
  } );

  HistoryStore.load();

  return HistoryStore;
}
