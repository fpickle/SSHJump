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
