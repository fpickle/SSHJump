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
