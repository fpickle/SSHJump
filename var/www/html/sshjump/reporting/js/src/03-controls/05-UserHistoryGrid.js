SSHJump.UserHistoryGrid = Ext.extend(Ext.grid.GridPanel, {
  HistoryStore: getHistoryStore(),
  reloadStore:function() {
    this.HistoryStore.removeAll();
    this.HistoryStore.reload();
  },
  initComponent:function() {
		var config = {
      store: this.HistoryStore,
      columns: [ { header: "UserName",
                   width: 160,
                   sortable: true,
                   dataIndex: 'UserName' },
                 { header: "RealName",
                   width: 160,
                   sortable: true,
                   dataIndex: 'RealName' },
                 { header: "Email",
                   width: 160,
                   sortable: true,
                   dataIndex: 'Email' },
                 { header: "Phone",
                   width: 160,
                   sortable: true,
                   dataIndex: 'Phone' },
                 { header: "Sessions",
                   width: 160,
                   sortable: true,
                   dataIndex: 'Sessions' },
                 { header: "LastEntryTime",
                   width: 167,
                   sortable: false,
                   dataIndex: 'LastEntryTime' } ],
      listeners: {
        'rowdblclick': {
          fn: function (grid, row, e) {
            var record = this.HistoryStore.getAt(row);
            this.fireEvent( 'user', this, record);
          }
        }
      },
      frame: true,
      width: 'auto',
      collapsible: true,
      animCollapse: true,
      layout: 'fit',
      sm: new Ext.grid.RowSelectionModel( { singleSelect:true } )
		};

  	Ext.apply(this, Ext.apply(this.initialConfig, config));
  	SSHJump.UserHistoryGrid.superclass.initComponent.apply(this, arguments);

		this.addEvents('user');
  }
} );

Ext.reg('UserHistoryGrid', SSHJump.UserHistoryGrid);
