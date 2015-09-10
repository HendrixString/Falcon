package com.hendrix.feathers.controls.flex
{
  import com.hendrix.feathers.controls.utils.SColors;
  
  import flash.text.SoftKeyboardType;
  import flash.text.TextFormatAlign;
  
  import feathers.controls.TextInput;
  import feathers.events.FeathersEventType;
  
  import starling.display.Quad;
  import starling.events.Event;
  
  /**
   * <p>a Number Picker flex control</p>
   * 
   * <li>use <code>this.buttonPlus</code> to set the button
   * <li>use <code>this.buttonMinus</code> to set the button
   * <li>use <code>this.currentNumber</code> to get/set number
   * <li>use <code>this.buttonPercentHeight</code> to get/set number
   * <li>use <code>this.currentNumberText</code> to get/set number from String
   * <li>use <code>this.maxRange</code> to get/set the range
   * 
   * @author Tomer Shalev
   */
  public class NumberPicker extends FlexComp
  {
    /**
     * plus button
     */
    private var _btnPlus:             FlexButton  = null;
    /**
     * minus button
     */
    private var _btnMinus:            FlexButton  = null;
    private var _tiNumber:            TextInput   = null;
    private var _quadStrip1:          Quad        = null;
    private var _quadStrip2:          Quad        = null;
    
    /**
     * current number as a uint 
     */
    private var _currentNumber:       uint        = 0;
    /**
     * current number as a String 
     */
    private var _currentNumberText:   String      = "00";
    /**
     * max range of numbers 
     */
    private var _maxRange:            uint        = uint.MAX_VALUE;
    
    /**
     * percent height of the button 
     */
    private var _buttonPercentHeight: Number      = 0.25;
    
    private var _padDigits:           Boolean     = false;
    
    public var onChange:              Function    = null;
    
    /**
     * a Number Picker flex control
     * @author Tomer Shalev
     */
    public function NumberPicker()
    {
      super();
    }
    
    /**
     * plus button
     */
    public function get buttonPlus():FlexButton { return _btnPlus;  }
    public function set buttonPlus(value:FlexButton):void
    {
      _btnPlus = value;
    }
    
    /**
     * minus button
     */
    public function get buttonMinus():FlexButton  { return _btnMinus; }
    public function set buttonMinus(value:FlexButton):void
    {
      _btnMinus = value;
    }
    
    /**
     * current number as a uint 
     */
    public function get currentNumber():uint  { return _currentNumber;  }
    public function set currentNumber(value:uint):void
    {
      _currentNumber = value;
      
      if(_tiNumber)
        _tiNumber.text = _currentNumber.toString();
    }
    
    /**
     * percent height of the button 
     */
    public function get buttonPercentHeight():Number  { return _buttonPercentHeight;  }
    public function set buttonPercentHeight(value:Number):void
    {
      _buttonPercentHeight = value;
    }
    
    /**
     * max range of numbers 
     */
    public function get maxRange():uint { return _maxRange; }
    public function set maxRange(value:uint):void
    {
      _maxRange = value;
    }
    
    /**
     * current number as a String 
     */
    public function get currentNumberText():String {return _currentNumberText;}
    public function set currentNumberText(value:String):void
    {
      _currentNumberText  = value;
      _currentNumber      = uint(_currentNumberText);
      
      if(_tiNumber)
        _tiNumber.text    = _currentNumberText;
    }
    
    override public function dispose():void
    {
      super.dispose()
      
      _tiNumber     = null;
      _quadStrip1   = null;
      _quadStrip2   = null;
      _btnMinus     = null;
      _btnPlus      = null;
      onChange      = null;
    }
    
    override protected function initialize():void
    {
      super.initialize()
      
      _tiNumber                                           = new TextInput();
      _tiNumber.textEditorProperties.fontFamily           = "Arial";
      _tiNumber.textEditorProperties.color                = 0x00;
      _tiNumber.textEditorProperties.textAlign            = TextFormatAlign.CENTER;
      _tiNumber.text                                      = _currentNumberText;
      _tiNumber.restrict                                  = "0-9";
      _tiNumber.maxChars                                  = 2;
      _tiNumber.textEditorProperties.softKeyboardType     = SoftKeyboardType.NUMBER;
      _tiNumber.addEventListener(FeathersEventType.FOCUS_IN,  tiNumber_focusInHandler);
      _tiNumber.addEventListener(FeathersEventType.FOCUS_OUT, tiNumber_focusOutHandler);
      
      _btnMinus.addEventListener(Event.TRIGGERED, btnMinus_onTriggered);
      _btnPlus.addEventListener(Event.TRIGGERED, btnplus_onTriggered);
      
      _quadStrip1                                         = new Quad(1,1,SColors.PURPLE);
      _quadStrip2                                         = new Quad(1,1,SColors.PURPLE);
      
      addChild(_tiNumber);
      addChild(_quadStrip1);
      addChild(_quadStrip2);
      addChild(_btnMinus);
      addChild(_btnPlus);
    }
    
    override protected function draw():void
    {
      super.draw();
      
      var w:          Number                  = width;
      var h:          Number                  = height;
      
      var btnHeight:  Number                  = h * _buttonPercentHeight;
      
      _quadStrip1.width                       = 1;
      _quadStrip1.height                      = h;
      
      _quadStrip2.width                       = 1;
      _quadStrip2.height                      = h;
      _quadStrip2.x                           = w - _quadStrip2.width;
      
      
      _btnPlus.width                          = w;
      _btnPlus.height                         = btnHeight;
      
      _btnMinus.width                         = w;
      _btnMinus.height                        = btnHeight;
      _btnMinus.y                             = h - btnHeight;
      
      _tiNumber.width                         = w;
      _tiNumber.height                        = h - 2*btnHeight;
      _tiNumber.y                             = _btnPlus.height;
      
      _tiNumber.textEditorProperties.fontSize = _tiNumber.height*0.8;     
    }
    
    private function tiNumber_focusInHandler(event:Event):void
    {
      _tiNumber.text = "";      
    }
    
    private function tiNumber_focusOutHandler(event:Event):void
    {
      _currentNumber = Math.min(uint(_tiNumber.text), _maxRange - 1);
      updateNumber();
    }
    
    private function updateNumber():void
    {
      _currentNumber = _currentNumber % _maxRange;
      var text:String = _currentNumber.toString();
      if(text.length < 2)
        text = "0" + text;
      
      _tiNumber.text  = text;
      
      _currentNumberText  = text;
      
      if(onChange is Function)
        onChange();
    }
    
    private function btnplus_onTriggered(event:Event):void
    {
      _currentNumber += 1;
      updateNumber();
    }
    
    private function btnMinus_onTriggered(event:Event):void
    {
      _currentNumber -= 1;
      _currentNumber = Math.min(_currentNumber, _maxRange - 1);
      updateNumber();
    }
    
  }
  
}