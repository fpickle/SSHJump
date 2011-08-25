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
