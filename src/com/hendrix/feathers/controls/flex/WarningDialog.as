package com.hendrix.feathers.controls.flex
{
  import com.hendrix.feathers.controls.CompsFactory;
  
  import flash.text.TextFormat;
  
  import feathers.controls.Button;
  import feathers.controls.Label;
  
  import flashx.textLayout.formats.TextAlign;
  
  import starling.animation.Transitions;
  import starling.animation.Tween;
  import starling.core.Starling;
  import starling.display.Quad;
  import starling.events.Event;
  
  /**
   * <p>a warning popup comp, supports:</p>
   * 
   * <li>one/two action buttons
   * <li>action callbacks
   * <li>headline
   * <li>warning text
   *  
   * <p><b>use:</b></p>
   * 
   * <li><code>this.onAction</code> to set a callback function
   * <li><code>this.show()</code> to display
   * <li><code>this.textHeadline</code> to set headline text
   * <li><code>this.textWarning</code> to set waring text
   * <li><code>this.textYes</code> to set YES button text
   * <li><code>this.textNo</code> to set NO button text
   * 
   * @author Tomer Shalev
   * 
   */
  public class WarningDialog extends FlexComp
  {
    static public var YES:    String    = "YES";
    static public var NO:     String    = "NO";
    
    private var _btnYes:      Button    = null;
    private var _btnNo:       Button    = null;
    private var _lblHeadLine: Label     = null;
    private var _lblWarning:  Label     = null;
    private var _quadBgDark:  Quad      = null;
    private var _quadBg:      Quad      = null;
    private var _quadStrip0:  Quad      = null;
    private var _quadStrip1:  Quad      = null;
    private var _quadStrip2:  Quad      = null;
    
    private var _textFormat:  TextFormat= null;
    
    private var _tweenFade:   Tween     = null;
    
    public function set btnNo(value:Button):void
    {
      _btnNo = value;
    }

    public function set btnYes(value:Button):void
    {
      _btnYes = value;
    }

    /**
     * callback for user action 
     */
    public  var onAction:     Function  = null;
    
    /**
     * headline text 
     */
    private var _textHeadline:String;
    /**
     * warning text 
     */
    private var _textWarning: String;   
    /**
     * YES button text 
     */
    private var _textYes:     String;   
    /**
     * NO button text 
     */
    private var _textNo:      String;   
    
    private var _dialogPercentWidth:    Number = NaN;
    private var _dialogPercentHeight:   Number = NaN;
    private var _fontSizePercent:       Number = NaN;
    

    /**
     * a warning popup comp, supports:<br>
     * <li>one/two action buttons
     * <li>action callbacks
     * <li>headline
     * <li>warning text 
     * use:<br>
     * <li><code>this.onAction</code> to set a callback function
     * <li><code>this.show()</code> to display
     * <li><code>this.textHeadline</code> to set headline text
     * <li><code>this.textWarning</code> to set waring text
     * <li><code>this.textYes</code> to set YES button text
     * <li><code>this.textNo</code> to set NO button text
     * 
     * @author Tomer Shalev
     * 
     */
    public function WarningDialog()
    {
      super();
      
      _tweenFade  = new Tween(this, 0.25);
    }
    
    public function show():void
    {
      _quadBgDark.alpha = 0;

      Starling.juggler.remove(_tweenFade);
      
      _tweenFade.reset(_quadBgDark, 0.35, Transitions.EASE_OUT);
      _tweenFade.fadeTo(0.7);
      
      Starling.juggler.add(_tweenFade);
    }
    
    public function get textFormat():TextFormat { return _textFormat; }
    public function set textFormat(value:TextFormat):void
    {
      _textFormat = value;
    }
    
    /**
     * warning text 
     */
    public function get textWarning():              String  { return _textWarning;  }
    public function set textWarning(value:String):  void
    {
      _textWarning = value;
      if(_lblWarning)
        _lblWarning.text = _textWarning;
    }
    
    /**
     * YES button text 
     */
    public function get textYes():                  String  { return _textYes;      }
    public function set textYes(value:String):      void
    {
      _textYes = value;
    }
    
    /**
     * NO button text 
     */
    public function get textNo():                   String  { return _textNo;       }
    public function set textNo(value:String):       void
    {
      _textNo = value;
    }
    
    /**
     * headline text 
     */
    public function get textHeadline():             String  { return _textHeadline; }
    public function set textHeadline(value:String): void
    {
      _textHeadline = value;
    }
    
    public function get fontSizePercent():Number { return _fontSizePercent; }
    public function set fontSizePercent(value:Number):void
    {
      _fontSizePercent = value;
    }
    
    private var _colorBg:uint = 0x00;
    
    public function get colorBg():uint { return _colorBg; }
    public function set colorBg(value:uint):void
    {
      _colorBg = value;
      
      if(_quadBg) {
        _quadBg.color = _colorBg;
      }
    }
    
    public function get dialogPercentWidth():Number { return _dialogPercentWidth; }
    public function set dialogPercentWidth(value:Number):void
    {
      _dialogPercentWidth = value;
    }
    
    public function get dialogPercentHeight():Number { return _dialogPercentHeight; }
    public function set dialogPercentHeight(value:Number):void
    {
      _dialogPercentHeight = value;
    }

    override public function set visible(value:Boolean):void
    {
      if(value == true)
        show();
      else if(value == false)
        Starling.juggler.remove(_tweenFade);
      
      super.visible = value;
    }
    
    override public function dispose():void
    {
      super.dispose();
      
      _btnYes     = null;
      _btnNo      = null;
      _lblWarning = null;
      _quadBg     = null;
      _quadBgDark = null;
      _quadStrip1 = null;
      _quadStrip2 = null;
      
      onAction  = null;
    }
    
    override protected function initialize():void
    {
      super.initialize();
      
      var tf_btns:  TextFormat                  = _textFormat ? _textFormat : new TextFormat("arial11", 22, 0x3C3C3C);
      var tf_lbl:   TextFormat                  = _textFormat ? _textFormat : new TextFormat("arial11", 22, 0x3C3C3C);
      
      _btnYes                                   = _btnYes ? _btnYes : CompsFactory.newButton(0x7DD9FF,  null, btnYes_onTriggered, tf_btns,  _textYes);
      _btnNo                                    = _btnNo  ? _btnNo  : CompsFactory.newButton(0x7DD9FF,  null, btnNo_onTriggered,  tf_btns,  _textNo);
      
      _btnYes.addEventListener(Event.TRIGGERED, btnYes_onTriggered);
      _btnNo.addEventListener(Event.TRIGGERED,  btnNo_onTriggered);
      
      if(_btnYes.defaultLabelProperties.textFormat == null)
        _btnYes.defaultLabelProperties.textFormat = tf_btns;
      if(_btnNo.defaultLabelProperties.textFormat == null)
        _btnNo.defaultLabelProperties.textFormat  = tf_btns;
      
      _btnYes.label                             = _textYes;
      _btnNo.label                              = _textNo;
      
      _btnYes.defaultLabelProperties.embedFonts = true;
      _btnNo.defaultLabelProperties.embedFonts  = true;
      
      _btnYes.horizontalAlign                   = Button.HORIZONTAL_ALIGN_CENTER;
      _btnNo.horizontalAlign                    = Button.HORIZONTAL_ALIGN_CENTER;
      
      _lblWarning                               = CompsFactory.newLabel(_textWarning, tf_lbl, true, true, TextAlign.CENTER); 
      
      _quadBg                                   = new Quad(1, 1, _colorBg);
      _quadBgDark                               = new Quad(1, 1, 0x00);
      
      _quadBgDark.alpha                         = 0.4;
      
      _quadStrip0                               = new Quad(1, 1, 0xEF7F3C); // 0x7DD9FF
      _quadStrip1                               = new Quad(1, 1, 0xD1D1D1);
      _quadStrip2                               = new Quad(1, 1, 0xD1D1D1);
      
      //_quadStrip1.alpha = _quadStrip2.alpha = 0.25
      
      addChild(_quadBgDark);
      addChild(_quadBg);
      addChild(_lblWarning);
      addChild(_btnNo);
      addChild(_btnYes);
      addChild(_quadStrip0);
      addChild(_quadStrip1);
      addChild(_quadStrip2);
    }
        
    override protected function draw():void
    {
      super.draw();
      
      var stripThickness:Number                 = 1;
      
      _quadBgDark.width                         = width;
      _quadBgDark.height                        = height;
      
      var padding:      Number                  = height  * 0.01;
      
      _quadBg.width                             = isNaN(_dialogPercentWidth) ? width * 0.95 : width * _dialogPercentWidth / 100;
      _quadBg.x                                 = (width - _quadBg.width) * 0.5;
      _quadBg.y                                 = (height - _quadBg.height) * 0.5;
      
      _lblWarning.width                         = _quadBg.width*0.95;
      _lblWarning.textRendererProperties.textFormat.size = isNaN(_fontSizePercent) ? width * 0.05 : height * _fontSizePercent / 100;
      _lblWarning.validate();
      _lblWarning.height                       *= 2;
      _lblWarning.x                             = _quadBg.x + (_quadBg.width - _lblWarning.width) * 0.5;
      _lblWarning.y                             = _quadBg.y + (_lblWarning.height*2 - _lblWarning.height) * 0.5;
      
      //
      
      _quadStrip1.width                         = _quadBg.width;
      _quadStrip1.height                        = stripThickness;
      _quadStrip1.x                             = _quadBg.x + (_quadBg.width - _quadStrip1.width) * 0.5;
      _quadStrip1.y                             = _lblWarning.y + _lblWarning.height;//_quadBg.y + topHeight;
      
      _quadStrip2.width                         = stripThickness;
      _quadStrip2.x                             = _quadBg.x + (_quadBg.width - _quadStrip2.width) * 0.5;
      _quadStrip2.y                             = _quadStrip1.y + _quadStrip2.height;
      
      //
      
      var tf: TextFormat                        = _btnNo.defaultLabelProperties.textFormat;
      
      tf.size                                   = isNaN(_fontSizePercent) ? width * 0.06 : height * _fontSizePercent / 100;
      
      _btnNo.defaultLabelProperties.textFormat  = null;
      _btnNo.defaultLabelProperties.textFormat  = tf;
      
      _btnYes.defaultLabelProperties.textFormat = null;
      _btnYes.defaultLabelProperties.textFormat = tf;
      
      //_btnNo.height = 0;
      //_btnYes.height = 0;
      _btnNo.validate();
      _btnYes.validate();
      
      var btnWidth:Number                       = _quadStrip2.x - (_quadBg.x);
      
      _btnNo.width                              = btnWidth; 
      _btnNo.height                             *= 2; 
      
      _btnYes.width                             = btnWidth; 
      _btnYes.height                            *= 2; 
      
      _btnYes.visible                           = true;
      _btnNo.visible                            = true;
      
      _btnNo.x                                  = _quadBg.x + (_quadBg.width*0.5 - _btnNo.width) * 0.5;
      _btnNo.y                                  = _quadStrip1.y + _quadStrip1.height;// +  (1.1*_btnNo.height - _btnNo.height) * 0.5;
      
      _btnYes.x                                 = _quadBg.x + _quadBg.width*0.5 + (_quadBg.width*0.5 - _btnNo.width) * 0.5;
      _btnYes.y                                 = _quadStrip1.y + _quadStrip1.height;// +  (1.1*_btnYes.height - _btnYes.height) * 0.5;
      
      _quadStrip2.height                        = _btnYes.height;
      
      _quadBg.height                            = _btnYes.y + _btnYes.height - _quadBg.y
      
      if(_textNo == null) {
        _btnYes.width                           = _quadBg.width; 
        //_btnYes.height                          = _btnNo.height; 
        _btnYes.x                               = _quadBg.x;
        _btnYes.y                               = _quadStrip1.y + _quadStrip1.height;
        _quadStrip2.visible                     = false;
      }
      
      if(_textHeadline) 
      {
        var tf_lbl:   TextFormat                = _textFormat ? _textFormat : new TextFormat("arial11", 22, 0x3C3C3C);
        _lblHeadLine                            = CompsFactory.newLabel(_textHeadline, tf_lbl, false, true, TextAlign.CENTER); 
        _lblHeadLine.textRendererProperties.textFormat.size = isNaN(_fontSizePercent) ? width * 0.05 : height * _fontSizePercent / 100;;
        
        addChild(_lblHeadLine);
        
        _lblHeadLine.validate();
        
        var h:  Number                          = _lblHeadLine.height;
        h                                       = Math.max(h*1.1, height * 0.05);
        
        _quadBg.height                         += h;
        _quadBg.y                              -= h;
        
        _lblHeadLine.y                          = _quadBg.y + (h - _lblHeadLine.height) * 0.5;
        _lblHeadLine.x                          = _quadBg.x + (_quadBg.width - _lblHeadLine.width) * 0.5;
        
        _quadStrip0.visible                     = true;
        _quadStrip0.width                       = _quadBg.width;
        _quadStrip0.height                      = 2;
        
        _quadStrip0.x                           = _quadBg.x;
        _quadStrip0.y                           = _quadBg.y + h;
      }
      
      // vertical align
      
      var diff: Number                          = _quadBg.y;
      
      _quadBg.y                                 = (height - _quadBg.height) * 0.5;
      
      diff                                     -= _quadBg.y;
      
      if(_lblHeadLine)
        _lblHeadLine.y                         -= diff;
      
      _quadStrip0.y                            -= diff;
      _quadStrip1.y                            -= diff;
      _quadStrip2.y                            -= diff;
      _lblWarning.y                            -= diff;
      _btnNo.y                                 -= diff;
      _btnYes.y                                -= diff;
    }
    
    private function btnNo_onTriggered(event:Event):void
    {
      if(onAction is Function)
        onAction(NO);
    }
    
    private function btnYes_onTriggered(event:Event):void
    {
      if(onAction is Function)
        onAction(YES);
    }
    
  }
  
}