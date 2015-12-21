package com.hendrix.feathers.controls.flex
{
  import com.hendrix.feathers.controls.flex.interfaces.IFlexComp;
  
  import flash.text.TextFormat;
  
  import feathers.controls.Label;
  import feathers.controls.text.TextFieldTextRenderer;
  import feathers.events.FeathersEventType;
  
  import starling.display.DisplayObject;
  import starling.display.Quad;
  
  /**
   * resizes font size according to width/height. right now only supports single line labels.<br>
   * give it height, then <code>validate()</code> and you will get a label with font size according to height and you
   * will get new height and width.<br>
   * in the future will be extended to support multiline like the algorithm implemented in DynTextInput
   * 
   * @author Tomer Shalev
   */
  public class FlexLabel extends Label implements IFlexComp
  {
    /**
     * for debug purposes
     */
    private var _bg:                        Quad          ;//= new Quad(1,1,0x00);//null;
    
    private var _autoSizeFont:              Boolean       = true;
    private var _fitWidthToText:            Boolean       = true;
    
    private var _heightForFont:             Number        = NaN;
    private var _fontPercentHeight:         Number        = 1;
    
    // flex comp
    
    private var _percentWidth:              Number        = NaN;
    private var _percentHeight:             Number        = NaN;
    
    private var _top:                       Number        = NaN;
    private var _bottom:                    Number        = NaN;
    private var _left:                      Number        = NaN;
    private var _right:                     Number        = NaN;
    
    private var _topPercentHeight:          Number        = NaN;
    private var _bottomPercentHeight:       Number        = NaN;
    private var _leftPercentWidth:          Number        = NaN;
    private var _rightPercentWidth:         Number        = NaN;
    
    private var _horizontalAlign:           String        = null;
    private var _verticalAlign:             String        = null;
    
    private var _horizontalCenter:          Number        = NaN;
    private var _verticalCenter:            Number        = NaN;
    
    private var _relativeCalcWidthParent:   DisplayObject = null;
    private var _relativeCalcHeightParent:  DisplayObject = null;
    
    private var _id:                        String        = null;     
    
    private var _data:                      Object        = null;     

    private var _isSensitiveToParent:       Boolean         = true;
    protected var _breakParentSensitivityAfter: Number      = 5;

    /**
     * resizes font size according to width/height. right now only supports single line labels.<br>
     * give it height, then <code>validate()</code> and you will get a label with font size according to height and you
     * will get new height and width.<br>
     * in the future will be extended to support multiline like the algorithm implemented in DynTextInput
     * @author Tomer Shalev
     */
    public function FlexLabel()
    {
      super();
    }
    
    public function layoutFlex():void
    {
      var parentWidthDop:   DisplayObject = _relativeCalcWidthParent  ? _relativeCalcWidthParent  as DisplayObject : getValidAncestor() as DisplayObject;
      var parentHeightDop:  DisplayObject = _relativeCalcHeightParent ? _relativeCalcHeightParent as DisplayObject : getValidAncestor() as DisplayObject;

      if(!parentHeightDop || !parentWidthDop)
        throw new Error("no parent or parent override found!!");
      
      var w:  Number                      = actualWidth;
      var h:  Number                      = actualHeight;
      
      if(!isNaN(_percentWidth))
        w                                 = _percentWidth * parentWidthDop.width;
      
      if(!isNaN(_percentHeight)) {
        h                                 = _percentHeight * parentHeightDop.height;
        _heightForFont                    = h;
      }
      
      var sized:  Boolean                 = setSizeInternal(w, h, false);
      
      if(sized && (_flagPendingCancel==false))
        invalidate(INVALIDATION_FLAG_SIZE);
      
      _flagPendingCancel                  = !_flagPendingCancel;
      
      layoutPosition();
    }
    
    override public function dispose():void
    {
      super.dispose();
      
      _bg                       = null;
      _relativeCalcWidthParent  = null;
      _relativeCalcHeightParent = null;
    }
    
    override public function set height(value:Number):void
    {
      _heightForFont = value;
      
      invalidate(INVALIDATION_FLAG_SIZE);
      validate();
    }
    
    public function get autoSizeFont():             Boolean   { return _autoSizeFont;}
    public function set autoSizeFont(value:Boolean):  void
    {
      _autoSizeFont = value;
    }
    
    public function get fitWidthToText():               Boolean   { return _fitWidthToText; }
    public function set fitWidthToText(value:Boolean):  void
    {
      _fitWidthToText = value;
    }
    
    public function get bg():                     Quad      { return _bg; }
    public function set bg(value:Quad):           void
    {
      _bg = value;
    }
    
    public function get fontPercentHeight():Number  { return _fontPercentHeight;  }
    public function set fontPercentHeight(value:Number):void
    {
      _fontPercentHeight = value;
    }
    
    // flex comp
    
    // layout
    
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
    
    public function get topPercentHeight():Number { return _topPercentHeight; }
    public function set topPercentHeight(value:Number):void
    {
      _topPercentHeight = (value >= 1) ? value / 100 : value;
      this.invalidate(INVALIDATION_FLAG_LAYOUT);
    }
    
    public function get bottomPercentHeight():Number  { return _bottomPercentHeight;  }
    public function set bottomPercentHeight(value:Number):void
    {
      _bottomPercentHeight = (value >= 1) ? value / 100 : value;
      this.invalidate(INVALIDATION_FLAG_LAYOUT);
    }
    
    public function get leftPercentWidth():Number { return _leftPercentWidth; }
    public function set leftPercentWidth(value:Number):void
    {
      _leftPercentWidth = (value >= 1) ? value / 100 : value;
      this.invalidate(INVALIDATION_FLAG_LAYOUT);
    }
    
    public function get rightPercentWidth():Number  { return _rightPercentWidth;  }
    public function set rightPercentWidth(value:Number):void
    {
      _rightPercentWidth = (value >= 1) ? value / 100 : value;
      this.invalidate(INVALIDATION_FLAG_LAYOUT);
    }
    
    public function get horizontalAlign():String  { return _horizontalAlign;  }
    public function set horizontalAlign(value:String):void
    {
      _horizontalAlign  = value;
      
      this.invalidate(INVALIDATION_FLAG_LAYOUT);
    }
    
    public function get verticalAlign():String  { return _verticalAlign;  }
    public function set verticalAlign(value:String):void
    {
      _verticalAlign  = value;
      
      this.invalidate(INVALIDATION_FLAG_LAYOUT);
    }
    
    public function get id():String { return _id; }
    public function set id(value:String):void
    {
      _id = value;
    }
    
    public function get data():Object { return _data; }    
    public function set data(value:Object):void
    {
      _data = value;
    }    

    public function applyAlignment():void { }
    public function get isSensitiveToParent(): Boolean { return false; }
    public function setSensitiveToParent(count:uint):void
    {
      _breakParentSensitivityAfter  = count;
      _isSensitiveToParent          = count==0 ? false : true;
      
      if(!_isSensitiveToParent)
        return;
      
      if(isCreated)
        internal_parent_observer();
    }
    
    protected function internal_parent_observer(on:Boolean = true):void {
      var parentWidthDop:   DisplayObject = _relativeCalcWidthParent  ? _relativeCalcWidthParent  as DisplayObject : getValidAncestorWidth() as DisplayObject;
      var parentHeightDop:  DisplayObject = _relativeCalcHeightParent ? _relativeCalcHeightParent as DisplayObject : getValidAncestorHeight() as DisplayObject;
      
      if(parentHeightDop == parentWidthDop) {
      }
      else {
        if(parentHeightDop) {
          if(on)
            parentHeightDop.addEventListener(FeathersEventType.RESIZE, onParentResized);
          else
            parentHeightDop.removeEventListener(FeathersEventType.RESIZE, onParentResized);
        }
      }
      
      if(parentWidthDop) {
        if(on)
          parentWidthDop.addEventListener(FeathersEventType.RESIZE, onParentResized);
        else
          parentWidthDop.removeEventListener(FeathersEventType.RESIZE, onParentResized);
      }
    }
    
    private function onParentResized():void
    {
      if(_breakParentSensitivityAfter-- == 0)
        internal_parent_observer(false);
      
      invalidate(INVALIDATION_FLAG_SIZE);      
    }

    override protected function initialize():void
    {
      super.initialize();
      
      if(_isSensitiveToParent)
        internal_parent_observer();

      if(_bg)
        addChildAt(_bg, 0);
    }
    
    override protected function draw():void
    {
      var sizeInvalid:    Boolean = isInvalid(INVALIDATION_FLAG_SIZE);
      var dataInvalid:    Boolean = isInvalid(INVALIDATION_FLAG_DATA);
      var layoutInvalid:  Boolean = isInvalid(INVALIDATION_FLAG_LAYOUT);
      
      if(!(sizeInvalid || layoutInvalid || dataInvalid))
        return;
      
      if(sizeInvalid) {
        //if(parent is FeathersControl)
        //  (parent as FeathersControl).invalidate();
      }

      layoutFlex();
      
      resetText();
      
      layoutPosition();     
    }
    
    private var _isFontInvalid:Boolean = true;
    
    private function resetText():void
    {
      var sizeInvalid:  Boolean             = isInvalid(INVALIDATION_FLAG_SIZE);
      var textInvalid:  Boolean             = isInvalid(INVALIDATION_FLAG_DATA);

      var tf: TextFormat                    = textRendererProperties.textFormat as TextFormat;
      
      if(textRenderer)
        tf = (textRenderer as TextFieldTextRenderer).textFormat;
      
      if(tf) {
        
        if(_horizontalAlign)
          tf.align                          = _horizontalAlign;
        
        if(_autoSizeFont)
          tf.size                           = _heightForFont * _fontPercentHeight;
        
        var tff:  TextFormat                = new TextFormat(tf.font,tf.size,tf.color);
        tff.align                           = tf.align;
        
        
        
        textRendererProperties.textFormat   = null;
        textRendererProperties.textFormat   = tff;
        
        if(textRenderer) {
          (textRenderer as TextFieldTextRenderer).textFormat = null;
          (textRenderer as TextFieldTextRenderer).textFormat = tff;
        }
        
        // this will force the Label to compute it's area based on font size and text's bounds
        explicitWidth                       = width;
        
        if(_fitWidthToText)
          explicitWidth                     = NaN;
        
        if(height == 0)
          explicitHeight                    = NaN;
      }
      
      super.draw();
      
      if(_bg) {
        _bg.width                           = width;
        _bg.height                          = height;
      }
    }
    
    private function getValidAncestor():DisplayObject
    {
      var validParent:  DisplayObject = parent;
      
      while(validParent && !validParent.height) {
        validParent                   = validParent.parent;
      }
      
      return validParent;
    }
    
    private var _flagPendingCancel:Boolean = false;
    
    private function layoutPosition():void
    {
      var parentWidthDop:   DisplayObject = _relativeCalcWidthParent  ? _relativeCalcWidthParent  as DisplayObject : getValidAncestor() as DisplayObject;
      var parentHeightDop:  DisplayObject = _relativeCalcHeightParent ? _relativeCalcHeightParent as DisplayObject : getValidAncestor() as DisplayObject;
      
      var fixY:Number                     = (parentHeightDop == parent) ? 0 : parentHeightDop.y;
      
      var w:  Number                      = actualWidth;
      var h:  Number                      = actualHeight;
      
      if(!isNaN(_horizontalCenter))
        x                                 = _horizontalCenter + (parentWidthDop.width - w)*0.5;
      
      if(!isNaN(_verticalCenter))
        y                                 = _verticalCenter + fixY + (parentHeightDop.height - h)*0.5;
      
      if(!isNaN(_bottomPercentHeight))
        y                                 = parentHeightDop.height - ( h + _bottomPercentHeight * parentHeightDop.height);
      
      if(!isNaN(_topPercentHeight))
        y                                 = fixY + parentHeightDop.height*_topPercentHeight;
      
      if(!isNaN(_leftPercentWidth))
        x                                 = parentWidthDop.width*_leftPercentWidth;
      
      if(!isNaN(_rightPercentWidth))
        x                                 = parentWidthDop.width - (w + parentWidthDop.width*_rightPercentWidth);
      
      if(!isNaN(_bottom))
        y                                 = fixY + parentHeightDop.height - ( h + _bottom);
      
      if(!isNaN(_top))
        y                                 = _top;
      
      if(!isNaN(_left))
        x                                 = _left;
      
      if(!isNaN(_right))
        x                                 = parentWidthDop.width - (w + _right);
    }
  
    private function getValidAncestorHeight():DisplayObject
    {
      var validParent:  DisplayObject = parent;
      
      while(validParent && !validParent.height) {
        validParent                   = validParent.parent;
      }
      
      return validParent;
    }
    
    private function getValidAncestorWidth():DisplayObject
    {
      var validParent:  DisplayObject = parent;
      
      while(validParent && !validParent.width) {
        validParent                   = validParent.parent;
      }
      
      return validParent;
    }

  }
  
}