/**** Begin 01-data.js ****/
var Url = new Ext.data.HttpProxy( { url: 'data.pl',
                                    method: 'POST' } );
/**** End 01-data.js ******/
/**** Begin 02-log.js ****/
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
/**** End 02-log.js ******/
/**** Begin 03-session.js ****/
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
/**** End 03-session.js ******/
/**** Begin 04-history.js ****/
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
/**** End 04-history.js ******/
/**** Begin application.js ****/
Ext.ns('SSHJump');
Ext.BLANK_IMAGE_URL = '/extjs/resources/images/default/s.gif';

Ext.onReady(function() {
	try {
		Ext.QuickTips.init();

		var MainTabs = new Ext.TabPanel( {
			applyTo        : 'Tabs',
			autoTabs       : true,
			activeTab      : 0,
			deferredRender : false,
			border         : false,
			items          : [ { id: 'CurrentUsers',
                           xtype: 'CurrentUserPanel',
                           title: 'Current Users' },
			                   { id: 'UserHistory',
                           xtype: 'UserHistoryPanel',
                           title: 'User History' } ]
		} );

		var Main = new Ext.Window( {
			applyTo     : 'Main',
			layout      : 'fit',
			width       : 1000,
			height      : 700,
			closable    : false,
      draggable   : false,
			plain       : true,
      resizable   : false,
			items       : MainTabs,
			buttons     : [ { text: 'Refresh',
                        handler: function() {
                          Ext.getCmp('CurrentAPPUsers').reloadStore();
                          Ext.getCmp('CurrentCMDUsers').reloadStore();
                          Ext.getCmp('UserHistoryGrid').reloadStore();
                        } } ]
		} );

		Main.show();

		/**** Click Handlers ****/
		Ext.getCmp('CurrentAPPUsers').on("session", function(grid, record) {
			addTab(record);
		} );

		Ext.getCmp('CurrentCMDUsers').on("session", function(grid, record) {
			addTab(record);
		} );

		Ext.getCmp('UserHistoryGrid').on("user", function(grid, record) {
			Ext.getCmp('UserSessionsGrid').reloadStore(record.data.UserID);
		} );

		Ext.getCmp('UserSessionsGrid').on("session", function(grid, record) {
			addTab(record);
		} );
		/*********************************************/

		function addTab(record) {
      var SessionID = record.data.SessionID;
      var User = record.data.UserName;

			MainTabs.add( {
        id: 'SessionID' + SessionID,
				title: 'SessionID ' + SessionID,
				closable: true,
        items: { id: 'SessionLogGrid' + SessionID,
                 SessionID: SessionID,
                 xtype: 'SessionLogGrid',
                 title: User + ' SessionID ' + SessionID,
                 height: 609 }
			}).show();
		}

		function updateTab(tabId, title) {
			var tab = MainTabs.getItem(tabId);

			if(tab){
				tab.getUpdater().update(count);
				tab.setTitle(title);
			}else{
				tab = addTab(title);
			}

			MainTabs.setActiveTab(tab);
		}

	} catch(exception) {
		alert('Error: "' + exception.message +'" at line: ' + exception.lineNumber);
	}
} );
/**** End application.js ******/
/**** Begin 01-CurrentAPPUserGrid.js ****/
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
/**** End 01-CurrentAPPUserGrid.js ******/
/**** Begin 02-CurrentCMDUserGrid.js ****/
SSHJump.CurrentCMDUserGrid = Ext.extend(Ext.grid.GridPanel, {
  SessionStore: getSessionStore('CMD', 'OPEN', 0),
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
  	SSHJump.CurrentCMDUserGrid.superclass.initComponent.apply(this, arguments);

		this.addEvents('session');
  }
} );

Ext.reg('CurrentCMDUserGrid', SSHJump.CurrentCMDUserGrid);
/**** End 02-CurrentCMDUserGrid.js ******/
/**** Begin 03-SessionLogGrid.js ****/
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
/**** End 03-SessionLogGrid.js ******/
/**** Begin 04-CurrentUserPanel.js ****/
SSHJump.CurrentUserPanel = Ext.extend(Ext.Panel, {
  initComponent:function() {
    var config = {
      layout: 'vbox',
      style: { overflow: 'auto' },
      layoutConfig: {
        animate: true,
        align:'stretch'
      },
      items: [ { id: 'CurrentAPPUsers',
                 xtype: 'CurrentAPPUserGrid',
                 title: 'Current sshjump-admin Users',
                 height: 150 },
               { id: 'CurrentCMDUsers',
                 xtype: 'CurrentCMDUserGrid',
                 title: 'Current sshjump Users',
                 height: 459 } ]
    };

  	Ext.apply(this, Ext.apply(this.initialConfig, config));
  	SSHJump.CurrentUserPanel.superclass.initComponent.apply(this, arguments);
  }
} );

Ext.reg('CurrentUserPanel', SSHJump.CurrentUserPanel);
/**** End 04-CurrentUserPanel.js ******/
/**** Begin 05-UserHistoryGrid.js ****/
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
/**** End 05-UserHistoryGrid.js ******/
/**** Begin 06-UserSessionsGrid.js ****/
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
/**** End 06-UserSessionsGrid.js ******/
/**** Begin 07-UserHistoryPanel.js ****/
SSHJump.UserHistoryPanel = Ext.extend(Ext.Panel, {
  initComponent:function() {
    var config = {
      layout: 'vbox',
      style: { overflow: 'auto' },
      layoutConfig: {
        animate: true,
        align:'stretch'
      },
      items: [ { id: 'UserHistoryGrid',
                 xtype: 'UserHistoryGrid',
                 title: 'User History',
                 height: 150 },
               { id: 'UserSessionsGrid',
                 xtype: 'UserSessionsGrid',
                 title: 'User Sessions',
                 height: 459 } ]
    };

  	Ext.apply(this, Ext.apply(this.initialConfig, config));
  	SSHJump.UserHistoryPanel.superclass.initComponent.apply(this, arguments);
  }
} );

Ext.reg('UserHistoryPanel', SSHJump.UserHistoryPanel);
/**** End 07-UserHistoryPanel.js ******/
/**** Begin 08-ScriptPopUp.js ****/
SSHJump.ScriptPopUp = Ext.extend(Ext.Window, {
  url: '',
  title: document.title,
  width: 700,
  height: 600,
  initComponent: function(){

    var config = {
      border: false,
      closable: true,
      closeAction: 'close',
      height: this.height,
      layout: 'fit',
      maximizable: true,
      modal: true,
      plain: false,
      autoLoad: this.url,
      autoScroll: true,
      title: this.title,
      width: this.width,
      bodyStyle: 'background-color: #000000'
    };

    Ext.apply(this, Ext.apply(this.initialConfig, config));
    SSHJump.ScriptPopUp.superclass.initComponent.call(this);
  }
});

Ext.reg('ScriptPopUp', SSHJump.ScriptPopUp);
/**** End 08-ScriptPopUp.js ******/
