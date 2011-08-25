SSHJump.CurrentAPPUserGrid = Ext.extend(Ext.grid.GridPanel, {
  SessionStore: getSessionStore('APP', 'OPEN', 0),
  reloadStore:function() {
    this.SessionStore.removeAll();
    this.SessionStore.reload();
  },
  initComponent:function() {
		var config = {
      store: this.SessionStore,
      columns: [ { header: "SessionID",
                   width: 84,
                   sortable: true,
                   dataIndex: 'SessionID' },
                 { header: "UserName",
                   width: 88,
                   sortable: true,
                   dataIndex: 'UserName' },
                 { header: "TimeOpened",
                   width: 120,
                   sortable: true,
                   dataIndex: 'TimeOpened' },
                 { header: "LastEntry",
                   width: 676,
                   sortable: false,
                   dataIndex: 'LastEntry' } ],
      listeners: {
        'rowdblclick': {
          fn: function (grid, row, e) {
            var record = this.SessionStore.getAt(row);
            this.fireEvent( 'session', this, record);
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
  	SSHJump.CurrentAPPUserGrid.superclass.initComponent.apply(this, arguments);

		this.addEvents('session');
  }
} );

Ext.reg('CurrentAPPUserGrid', SSHJump.CurrentAPPUserGrid);
