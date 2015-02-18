package com.hendrix.feathers.controls.flex
{
  import com.hendrix.feathers.controls.flex.dynTextInput.core.ExtStageTextTextEditor;
  
  import flash.text.TextFormatAlign;
  
  import feathers.controls.TextInput;
  import feathers.core.FeathersControl;
  import feathers.core.IFeathersControl;
  import feathers.events.FeathersEventType;
  
  import starling.display.DisplayObject;
  import starling.events.Event;
  
  /**
   * a flex TextInput, resizes font according to the height
   * <li>use <code>this.textInitial</code> for text hinting 
   * <li>use <code>this.fontFamily</code>
   * <li>use <code>this.color</code>
   * <li>use <code>this.textAlign</code>
   * @author Tomer Shalev
   */
  public class FlexTextInput extends TextInput
  {
    private var _initialHeight:             Number                  = NaN;
    /**
     * the size of the font proprtionally to it's parent [0..1] 
     */
    private var _fontPercentHeight:         Number                  = 0.9;
    
    private var _te:                        ExtStageTextTextEditor  = null;
    
    private var _textAlign:                 String                  = TextFormatAlign.RIGHT;
    
    private var _multiLine:                 Boolean                 = false;
    private var _fontFamily:                String                  = "Arial";
    private var _color:                     uint                    = 0x00;
    
    /**
     * text hint 
     */
    private var _textInitial:               String                  = null;
    
    private var _textInitialIgnore:         Boolean                 = false;
    
    // flex comp
    
    private var _percentWidth:              Number                  = NaN;
    private var _percentHeight:             Number                  = NaN;
    
    private var _top:                       Number                  = NaN;
    private var _bottom:                    Number                  = NaN;
    private var _left:                      Number                  = NaN;
    private var _right:                     Number                  = NaN;
    
    private var _horizontalCenter:          Number                  = NaN;
    private var _verticalCenter:            Number                  = NaN;
    
    private var _relativeCalcWidthParent:   DisplayObject           = null;
    private var _relativeCalcHeightParent:  DisplayObject           = null;
    
    /**
     * a flex TextInput, resizes font according to the height
     * <li>use <code>this.textInitial</code> for text hinting 
     * <li>use <code>this.fontFamily</code>
     * <li>use <code>this.color</code>
     * <li>use <code>this.textAlign</code>
     * @author Tomer Shalev
     */
    public function FlexTextInput()
    {
      super();
    }
    
    override public function dispose():void
    {
      super.dispose();
      
      _te                       = null;
      _relativeCalcHeightParent = null;
      _relativeCalcWidthParent  = null;
      
      removeEventListener(FeathersEventType.FOCUS_IN, onFocusIn);
      removeEventListener(FeathersEventType.FOCUS_OUT, onFocusOut);
      removeEventListener(Event.CHANGE, onChange);
    }
    
    override public function set height(value:Number):void
    {
      super.height      = value;
      
      //if(isNaN(_initialHeight))
      _initialHeight  = height;
      if(_te)
        if(!multiLine)
          _te.fontSize                    = _initialHeight*_fontPercentHeight;
      
    }
    
    override public function set text(value:String):void
    {
      if(_textInitial == null) {
        _textInitial  = value;
      }
      
      super.text    = value;
    }
    
    override public function get text():String
    {
      if(super.text == _textInitial)
        return null;
      
      return super.text;
    }
    
    public function get multiLine():                            Boolean { return _multiLine;  }
    public function set multiLine(value:Boolean):               void
    {
      _multiLine = value;
      
    }
    
    public function get fontFamily():                           String  { return _fontFamily; }
    public function set fontFamily(value:String):               void
    {
      _fontFamily = value;
    }
    
    public function get color():                                uint  { return _color;}
    public function set color(value:uint):                      void
    {
      _color = value;
    }
    
    // flex comp part
    
    public function get fontPercentHeight():              Number  { return _fontPercentHeight;  }
    public function set fontPercentHeight(value:Number):  void
    {
      _fontPercentHeight = value;
    }
    
    public function get percentWidth():                         Number  { return _percentWidth; }
    public function set percentWidth(value:Number):             void
    {
      _percentWidth = (value > 1) ? value / 100 : value;
      this.invalidate(INVALIDATION_FLAG_SIZE);
    }
    
    public function get percentHeight():                        Number  { return _percentHeight;  }
    public function set percentHeight(value:Number):            void
    {
      _percentHeight = (value > 1) ? value / 100 : value;
      this.invalidate(INVALIDATION_FLAG_SIZE);
    }
    
    public function get top():                                  Number  { return _top;  }
    public function set top(value:Number):                      void
    {
      _top = value;
      this.invalidate(INVALIDATION_FLAG_LAYOUT);
    }
    
    public function get bottom():                               Number  { return _bottom;}
    public function set bottom(value:Number):                   void
    {
      _bottom = value;
      this.invalidate(INVALIDATION_FLAG_LAYOUT);
    }
    
    public function get left():                                 Number  { return _left; }
    public function set left(value:Number):                     void
    {
      _left = value;
      this.invalidate(INVALIDATION_FLAG_LAYOUT);
    }
    
    public function get right():                                Number  { return _right;  }
    public function set right(value:Number):                    void
    {
      _right = value;
      this.invalidate(INVALIDATION_FLAG_LAYOUT);
    }
    
    /**
     * override parent for calculations
     */
    public function get relativeCalcWidthParent():              DisplayObject 
    { 
      return (_relativeCalcWidthParent && _relativeCalcWidthParent.width) ? _relativeCalcWidthParent : getValidAncestor();  
    }
    public function set relativeCalcWidthParent(value:DisplayObject): void
    {
      _relativeCalcWidthParent = value;
      this.invalidate(INVALIDATION_FLAG_SIZE);
    }
    
    public function get relativeCalcHeightParent():             DisplayObject 
    { 
      return (_relativeCalcHeightParent && _relativeCalcHeightParent.height) ? _relativeCalcHeightParent : getValidAncestor();  
    }
    public function set relativeCalcHeightParent(value:DisplayObject):  void
    {
      _relativeCalcHeightParent = value;
      this.invalidate(INVALIDATION_FLAG_SIZE);
    }
    
    public function get horizontalCenter():                     Number  { return _horizontalCenter; }
    public function set horizontalCenter(value:Number):         void
    {
      _horizontalCenter = value;
      this.invalidate(INVALIDATION_FLAG_LAYOUT);
    }
    
    public function get verticalCenter():                       Number  { return _verticalCenter; }
    public function set verticalCenter(value:Number):           void
    {
      _verticalCenter = value;
      this.invalidate(INVALIDATION_FLAG_LAYOUT);
    }
    
    public function get textCurrent():String
    {
      return super.text;
    }
    
    /**
     * text hint 
     */
    public function get textInitial():String { return _textInitial; }
    public function set textInitial(value:String):void
    {
      _textInitial  = value;
      super.text    = _textInitial;
    }
    
    public function get textAlign():String  { return _textAlign;  }
    public function set textAlign(value:String):void
    {
      _textAlign = value;
    }
    
    private var _pendingDisplayAsPassowrd:Boolean = false;
    
    override public function set displayAsPassword(value:Boolean):void
    {
      _pendingDisplayAsPassowrd = value;
    }
    
    public function get textInitialIgnore():Boolean { return _textInitialIgnore;  }
    public function set textInitialIgnore(value:Boolean):void
    {
      _textInitialIgnore = value;
      
      if(_textInitialIgnore) {
        removeEventListener(FeathersEventType.FOCUS_IN, onFocusIn);
        removeEventListener(FeathersEventType.FOCUS_OUT, onFocusOut);
      }
      else {
        addEventListener(FeathersEventType.FOCUS_IN, onFocusIn);
        addEventListener(FeathersEventType.FOCUS_OUT, onFocusOut);
      }
    }
    
    override protected function initialize():void
    {
      super.initialize();
      
      textEditorFactory = instStageTextEditor;
      
      textInitialIgnore = _textInitialIgnore;     
      //addEventListener(FeathersEventType.CREATION_COMPLETE, onCreationComplete);
    }
    
    override protected function draw():void
    {
      
      var sizeInvalid:    Boolean = isInvalid(INVALIDATION_FLAG_SIZE);
      var layoutInvalid:  Boolean = isInvalid(INVALIDATION_FLAG_LAYOUT);
      var dataInvalid:    Boolean = isInvalid(INVALIDATION_FLAG_DATA);
      
      if(!(sizeInvalid || layoutInvalid || dataInvalid))
        return;
      
      //if(sizeInvalid) {
      if(_multiLine && parent is IFeathersControl)
        (parent as FeathersControl).invalidate(INVALIDATION_FLAG_LAYOUT);
      
      layout();
      
      width
      height
      text
      //}
      
      if(_multiLine)
        addEventListener(Event.CHANGE, onChange);
      
      super.draw();
    }
    
    private function onCreationComplete(event:Event):void
    {
      onChange(null);     
    }
    
    private function getValidAncestor():DisplayObject
    {
      var validParent:  DisplayObject = parent;
      
      while(!validParent.height) {
        validParent                   = validParent.parent;
      }
      
      return validParent;
    }
    
    private function layout():void
    {
      var parentWidthDop:   DisplayObject = _relativeCalcWidthParent  ? _relativeCalcWidthParent  as DisplayObject : getValidAncestor() as DisplayObject;
      var parentHeightDop:  DisplayObject = _relativeCalcHeightParent ? _relativeCalcHeightParent as DisplayObject : getValidAncestor() as DisplayObject;
      
      if(!parentHeightDop || !parentWidthDop)
        throw new Error("no parent or parent override found!!");
      
      var w:  Number                      = actualWidth;
      var h:  Number                      = actualHeight;
      
      var fixY:Number                     = (parentHeightDop == parent) ? 0 : parentHeightDop.y;
      
      if(!isNaN(_percentWidth))
        w                                 = _percentWidth * parentWidthDop.width;
      
      if(!isNaN(_percentHeight))
        h                                 = _percentHeight * parentHeightDop.height;
      
      if(!isNaN(_horizontalCenter))
        x                                 = _horizontalCenter + (parentWidthDop.width - w)*0.5;
      
      if(!isNaN(_verticalCenter))
        y                                 = _verticalCenter + fixY + (parentHeightDop.height - h)*0.5;
      
      if(!isNaN(_bottom))
        y                                 = parentHeightDop.height - ( h + _bottom);
      
      if(!isNaN(_top))
        y                                 = _top;
      
      if(!isNaN(_left))
        x                                 = _left;
      
      if(!isNaN(_right))
        x                                 = parentWidthDop.width - (w + _right);
      
      width                               = w;
      height                              = h;      
    }
    
    private function instStageTextEditor():ExtStageTextTextEditor
    {
      var textRenderer: ExtStageTextTextEditor  = new ExtStageTextTextEditor();
      
      // customize properties and styleshere
      textRenderer.multiline                    = _multiLine;
      textRenderer.fontSize                     = _initialHeight*_fontPercentHeight;
      textRenderer.fontFamily                   = _fontFamily;
      textRenderer.color                        = _color;
      textRenderer.textAlign                    = _textAlign;
      //textRenderer.displayAsPassword            = true;
      
      _te                                       = textRenderer as ExtStageTextTextEditor;
      
      return textRenderer;
    }
    
    private function onFocusOut(event:Event):void
    {
      trace(super.text)
      if(super.text ==  "") {
        text = _textInitial;
        super.displayAsPassword = false;
      }
      trace(super.text)
    }
    
    private function onFocusIn(event:Event):void
    {
      onChange(null);
      
      if(super.text ==  _textInitial)
        super.text = "";
    }
    
    private function onChange(event:Event):void
    {
      super.displayAsPassword = _pendingDisplayAsPassowrd;
      
      if(!_multiLine)
        return;
      
      var textHeight: Number  = _te.measureTextField.textHeight
      
      if(textHeight == 0) {
        return;
      }
      
      super.height            = textHeight;
    }   
    
  }
  
}