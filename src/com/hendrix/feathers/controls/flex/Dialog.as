package com.hendrix.feathers.controls.flex
{
  import com.hendrix.feathers.controls.CompsFactory;
  import com.hendrix.feathers.controls.flex.interfaces.IFlexComp;
  import com.hendrix.feathers.controls.utils.SColors;
  
  import flash.events.KeyboardEvent;
  import flash.text.TextFormat;
  import flash.ui.Keyboard;
  
  import feathers.layout.HorizontalLayout;
  import feathers.layout.VerticalLayout;
  
  import flashx.textLayout.formats.TextAlign;
  
  import starling.core.Starling;
  import starling.display.DisplayObject;
  import starling.display.Quad;
  import starling.events.Event;
  
  /**
   * a Dialog control <br>
   * <li>use <code>this.dialogContent</code> to put a DisplayObject as the content of the dialog.
   * <li>use <code>this.textOK, this.textCANCEL, this.textHEADLINE</code> to alter the text.
   * <li>use <code>this.textCANCEL</code> to put a DisplayObject as the content of the dialog.
   * <li>use <code>this.tf_buttons, tf_headline</code> to control textFormat of buttons and headline respectively.
   * <li>use <code>this.onAction</code> callback to listen to OK/CANCEL, callback will return ACTION_OK/ACTION_CANCEL respectively.
   * <li>use <code>this.show()/close()</code> to show/close the dialog.
   * @author Tomer Shalev 
   * 
   */
  public class Dialog extends FlexComp
  {
    static public const ACTION_OK:      String  = "ACTION_OK";
    static public const ACTION_CANCEL:  String  = "ACTION_CANCEL";
    
    public var onAction:        Function        = null;
    
    private var _quad_bg:       FlexQuad        = null;
    
    private var _tf_buttons:    TextFormat      = null;
    private var _tf_headline:   TextFormat      = null;
    
    private var _textOK:        String          = "ok";
    private var _textCANCEL:    String          = "cancel";
    private var _textHEADLINE:  String          = "headline";
    
    private var _color_text:    uint            = 0x00;
    
    private var _dialogContent: DisplayObject   = null;
    private var _container:     FlexComp        = null;
    
    /**
     * a Dialog control <br>
     * <li>use <code>this.dialogContent</code> to put a DisplayObject as the content of the dialog.
     * <li>use <code>this.textOK, this.textCANCEL, this.textHEADLINE</code> to alter the text.
     * <li>use <code>this.textCANCEL</code> to put a DisplayObject as the content of the dialog.
     * <li>use <code>this.tf_buttons, tf_headline</code> to control textFormat of buttons and headline respectively.
     * <li>use <code>this.onAction</code> callback to listen to OK/CANCEL, callback will return ACTION_OK/ACTION_CANCEL respectively.
     * <li>use <code>this.show()/close()</code> to show/close the dialog.
     * @author Tomer Shalev 
     * 
     */
    public function Dialog()
    {
      super();
    }
    
    /**
     * main content of the dialog 
     */
    public function get dialogContent():DisplayObject
    {
      return _dialogContent;
    }
    /**
     * @private
     */
    public function set dialogContent(value:DisplayObject):void
    {
      _dialogContent                                    = value;
      
      if(_dialogContent is IFlexComp) {
        (_dialogContent as IFlexComp).verticalCenter    = 0;
        (_dialogContent as IFlexComp).horizontalCenter  = 0;
        (_dialogContent as IFlexComp).percentWidth      = 100;
        (_dialogContent as IFlexComp).percentHeight     = 50;
      }
    }
    
    /**
     * show the dialog.
     * do not use addChild(..) 
     */
    public function show():void
    {
      Starling.current.stage.addChild(this);
    }
    /**
     * close the dialog.
     * do not use removeChild(..) 
     */
    public function close():void
    {
      this.removeFromParent();
      
      Starling.current.nativeStage.removeEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
    }
    
    public function get color_text():uint { return _color_text; }
    public function set color_text(value:uint):void
    {
      _color_text = value;
    }
    
    public function get textHEADLINE():String { return _textHEADLINE; }
    public function set textHEADLINE(value:String):void
    {
      _textHEADLINE = value;
    }
    
    public function get textCANCEL():String { return _textCANCEL; }
    public function set textCANCEL(value:String):void
    {
      _textCANCEL = value;
    }
    
    public function get textOK():String { return _textOK; }
    public function set textOK(value:String):void
    {
      _textOK = value;
    }
    
    public function get tf_headline():TextFormat { return _tf_headline; }
    public function set tf_headline(value:TextFormat):void
    {
      _tf_headline = value;
    }
    
    public function get tf_buttons():TextFormat { return _tf_buttons; }
    public function set tf_buttons(value:TextFormat):void
    {
      _tf_buttons = value;
    }
    
    override public function dispose():void
    {
      super.dispose();
    }
    
    override protected function initialize():void
    {
      super.initialize();
      
      if(_dialogContent == null)
        throw new Error("please supply dialogContent!!!!");
      
      percentWidth                          = 100;
      percentHeight                         = 100;
      
      var q_bg:           FlexQuad          = new FlexQuad(SColors.WHITE);
      var qStripV:        FlexQuad          = new FlexQuad(SColors.GREY_HARD);
      var qStrip_1:       FlexQuad          = new FlexQuad(SColors.GREY_HARD);
      var qStrip_2:       FlexQuad          = new FlexQuad(SColors.GREY_HARD);
      var vGrp:           VGroup            = new VGroup();
      var hGrp:           HGroup            = new HGroup();
      _container                            = new FlexComp();
      _quad_bg                              = new FlexQuad(0x00);
      
      var lbl_headline:   FlexLabel         = CompsFactory.newLabel(_textHEADLINE, _tf_headline, false, true, TextAlign.CENTER, true) as FlexLabel;
      var btn_ok:         FlexButton        = CompsFactory.newButton(0x7DD9FF, null, btn_onAction, _tf_buttons, _textOK, false, null, true, "center", true) as FlexButton;
      var btn_cancel:     FlexButton        = CompsFactory.newButton(0x7DD9FF, null, btn_onAction, _tf_buttons, _textCANCEL, false, null, true, "center", true) as FlexButton;
      
      btn_ok.id                             = ACTION_OK;
      btn_cancel.id                         = ACTION_CANCEL;
      
      hGrp.addChild(btn_cancel);
      hGrp.addChild(qStripV);
      hGrp.addChild(btn_ok);
      
      _container.addChild(_dialogContent);
      
      vGrp.addChild(lbl_headline);
      vGrp.addChild(qStrip_1);
      vGrp.addChild(_container);
      vGrp.addChild(qStrip_2);
      vGrp.addChild(hGrp);
      
      vGrp.backgroundSkin                   = new Quad(1, 1, SColors.WHITE);
      vGrp.percentWidth                     = 95;
      vGrp.relativeCalcObject               = this;
      vGrp.horizontalCenter                 = 0;
      vGrp.verticalCenter                   = 0;
      vGrp.padding                          = 0;
      
      _quad_bg.percentWidth                 = 100;
      _quad_bg.percentHeight                = 100;
      _quad_bg.alpha                        = 0.3;
      
      _container.verticalAlign              = VerticalLayout.VERTICAL_ALIGN_MIDDLE;
      _container.horizontalAlign            = HorizontalLayout.HORIZONTAL_ALIGN_CENTER;
      
      //lbl_headline.height             = 333;
      
      lbl_headline.percentHeight            = 25;
      lbl_headline.autoSizeFont             = true;
      lbl_headline.fontPercentHeight        = 0.25;
      lbl_headline.percentWidth             = 95;
      lbl_headline.fitWidthToText           = false;
      lbl_headline.relativeCalcHeightParent = this
      lbl_headline.relativeCalcWidthParent  = this
      
      
      //_container.backgroundSkin             = new Quad(1,1,0xff0000);
      _container.percentWidth               = 100;
      _container.percentHeight              = 45;
      _container.relativeCalcHeightParent   = this;
      
      hGrp.percentHeight                    = 9;
      hGrp.percentWidth                     = 100;
      hGrp.relativeCalcHeightParent         = this;
      
      btn_cancel.percentWidth               = 50;
      btn_cancel.percentHeight              = 100;
      btn_ok.percentWidth                   = 50;
      btn_ok.percentHeight                  = 100;
      btn_ok.fontPercentHeight              = 0.35;
      btn_cancel.fontPercentHeight          = 0.35;
      
      qStripV.percentHeight                 = 100;
      qStripV.percentWidth                  = 0.001;
      
      qStrip_1.height                       = 1;
      qStrip_1.percentWidth                 = 100;
      
      qStrip_2.height                       = 1;
      qStrip_2.percentWidth                 = 100;
      
      verticalCenter                        = 0;
      
      addChild(_quad_bg);
      addChild(vGrp);
    }
    
    override protected function draw():void
    {
      super.draw();
      
      if(!(_dialogContent is IFlexComp)) {
        _dialogContent.width  = _container.width;
        _dialogContent.height = _container.height * 0.5;
      }
      
      // in case dialog content is not a FlexComp
      _container.applyAlignment();
      
    }

    override protected function feathersControl_addedToStageHandler(event:Event):void
    {
      super.feathersControl_addedToStageHandler(event);
      
      Starling.current.nativeStage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed, false, int.MAX_VALUE);
    }
    
    override protected function feathersControl_removedFromStageHandler(event:Event):void
    {
      super.feathersControl_removedFromStageHandler(event);
      
      Starling.current.nativeStage.removeEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
    }
    
    private function btn_onAction(event:Event):void
    {
      var btn_id: String = (event.currentTarget as FlexButton).id;
      
      close();
      
      if(onAction is Function)
        onAction(btn_id);
    }
    
    private function keyPressed(e:KeyboardEvent):void
    {    
      if(e.keyCode == Keyboard.BACK)
      {
        e.preventDefault();
        e.stopImmediatePropagation();
        
        close();
      }
      
    }
    
  }
  
}