SSHJump.SessionLogGrid = Ext.extend(Ext.grid.GridPanel, {
	SessionID: 0,
  initComponent:function() {
		var config = {
      store: getLogStore(this.SessionID),
      columns: [ { id:'SessionGrid',
                   header: "LogID",
                   width: 50,
                   sortable: true,
                   dataIndex: 'LogID' },
                 { header: "EntryTime",
                   width: 120,
                   sortable: true,
                   dataIndex: 'EntryTime' },
                { header: "EntryType",
                  width: 80,
                  sortable: true,
                  dataIndex: 'EntryType' },
                { header: "Entry",
                  width: 620,
                  sortable: true,
                  dataIndex: 'Entry' },
                { header: "HostName",
                  width: 98,
                  sortable: true,
                  dataIndex: 'HostName' } ],
      frame: true,
      width: 'auto',
      collapsible: true,
      animCollapse: true,
      layout: 'fit',
		};

  	Ext.apply(this, Ext.apply(this.initialConfig, config));
  	SSHJump.SessionLogGrid.superclass.initComponent.apply(this, arguments);
  }
} );

Ext.reg('SessionLogGrid', SSHJump.SessionLogGrid);
