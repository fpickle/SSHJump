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
