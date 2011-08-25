SSHJump.UserSessionsGrid = Ext.extend(Ext.grid.GridPanel, {
  SessionStore: getSessionStore('initialize', '', 0),
  reloadStore:function(id) {
    this.SessionStore.destroy();
    this.SessionStore = getSessionStore('', '', id);
    this.reconfigure(this.SessionStore, this.getColumnModel());
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
                 { header: "Reason",
                   width: 578,
                   sortable: false,
                   dataIndex: 'Reason' },
                 { header: "HostName",
                   width: 98,
                   sortable: false,
                   dataIndex: 'HostName' } ],
      listeners: {
        'rowdblclick': {
          fn: function (grid, row, e) {
            var record = this.SessionStore.getAt(row);
            this.fireEvent('session', this, record);
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
  	SSHJump.UserSessionsGrid.superclass.initComponent.apply(this, arguments);

		this.addEvents('session');
  }
} );

Ext.reg('UserSessionsGrid', SSHJump.UserSessionsGrid);
