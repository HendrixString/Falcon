package com.hendrix.feathers.controls.flex
{
  import com.hendrix.feathers.controls.flex.interfaces.IFlexComp;
  
  import feathers.core.FeathersControl;
  import feathers.core.IFeathersControl;
  
  import starling.core.RenderSupport;
  import starling.display.DisplayObject;
  import starling.display.Quad;
  import starling.events.Event;
  
  /**
   * a Flex Quad
   * @author Tomer Shalev
   */
  public class FlexQuad extends Quad implements IFlexComp
  {
    public static const INVALIDATION_FLAG_ALL:                String = "all";
    public static const INVALIDATION_FLAG_SIZE:               String = "size";
    public static const INVALIDATION_FLAG_LAYOUT:             String = "layout";
    public static const INVALIDATION_FLAG_ALIGN:              String = "INVALIDATION_FLAG_ALIGN";
    static protected const INVALIDATION_FLAG_PARENT_RESIZED:  String  = "INVALIDATION_FLAG_PARENT_RESIZED";
    
    private var _percentWidth:              Number          = NaN;
    private var _percentHeight:             Number          = NaN;
    
    private var _top:                       Number          = NaN;
    private var _bottom:                    Number          = NaN;
    private var _left:                      Number          = NaN;
    private var _right:                     Number          = NaN;
    
    private var _topPercentHeight:          Number          = NaN;
    private var _bottomPercentHeight:       Number          = NaN;
    private var _leftPercentWidth:          Number          = NaN;
    private var _rightPercentWidth:         Number          = NaN;
    
    private var _horizontalCenter:          Number          = NaN;
    private var _verticalCenter:            Number          = NaN;
    
    private var _relativeCalcWidthParent:   DisplayObject   = null;
    private var _relativeCalcHeightParent:  DisplayObject   = null;
    
    // align for children
    private var _horizontalAlign:           String          = null;
    private var _verticalAlign:             String          = null;
    
    private var _isSensitiveToParent:       Boolean         = false;
    
    private var _id:                        String          = null;
    
    // invalidation flags   
    private var _invalidationFlags:         Object          = null;
    
    /**
     * a Flex Quad
     * @param color the color of the quad
     * @author Tomer Shalev
     */
    public function FlexQuad(color:uint=16777215, premultipliedAlpha:Boolean=true)
    {
      super(1, 1, color, premultipliedAlpha);
      
      _invalidationFlags  = new Object();;
    }
    
    public function layoutFlex():void
    {
      var parentWidthDop:   DisplayObject = _relativeCalcWidthParent  ? _relativeCalcWidthParent  as DisplayObject : getValidAncestorWidth()  as DisplayObject;
      var parentHeightDop:  DisplayObject = _relativeCalcHeightParent ? _relativeCalcHeightParent as DisplayObject : getValidAncestorHeight() as DisplayObject;
      
      var fixY: Number                    = (parentHeightDop == parent) ? 0 : parentHeightDop.y;
      
      if(!parentHeightDop || !parentWidthDop)
        throw new Error("no parent or parent override found!!");
      
      var w:  Number                      = width;
      var h:  Number                      = height;
      
      parentWidthDop.addEventListener(Event.RESIZE, onParentResize);
      parentHeightDop.addEventListener(Event.RESIZE, onParentResize);
      
      if(!isNaN(_percentWidth))
        w                                 = _percentWidth * parentWidthDop.width;
      
      if(!isNaN(_percentHeight))
        h                                 = _percentHeight * parentHeightDop.height;
      
      if(!isNaN(_horizontalCenter))
        x                                 = _horizontalCenter + (parentWidthDop.width - w)*0.5;
      
      if(!isNaN(_verticalCenter))
        y                                 = _verticalCenter + fixY + (parentHeightDop.height - h)*0.5;
      
      if(!isNaN(_bottomPercentHeight))
        y                                 = fixY + parentHeightDop.height - ( h + _bottomPercentHeight * parentHeightDop.height);
      
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
      
      width                               = w;
      height                              = h
    }
    
    public function applyAlignment():void
    {
    }
    
    override public function render(support:RenderSupport, parentAlpha:Number):void
    {
      super.render(support, parentAlpha);
      
      var sizeInvalid:        Boolean = isInvalid(INVALIDATION_FLAG_SIZE);
      var layoutInvalid:      Boolean = isInvalid(INVALIDATION_FLAG_LAYOUT);
      var parentSizeInvalid:  Boolean = isInvalid(INVALIDATION_FLAG_PARENT_RESIZED);
      
      if((sizeInvalid || layoutInvalid || parentSizeInvalid))
        layoutFlex();
      
      if(sizeInvalid) {
        if(parent is IFeathersControl)
          (parent as FeathersControl).invalidate(INVALIDATION_FLAG_LAYOUT);
      }
      
      clearInvalidationFlags();
    }
    
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
    
    /**
     * override parent for calculations
     */
    public function get relativeCalcWidthParent():              DisplayObject 
    { 
      //return (_relativeCalcWidthParent && _relativeCalcWidthParent.width) ? _relativeCalcWidthParent : getValidAncestor();  
      return (_relativeCalcWidthParent && _relativeCalcWidthParent.width) ? _relativeCalcWidthParent : getValidAncestorWidth(); 
    }
    public function set relativeCalcWidthParent(value:DisplayObject): void
    {
      _relativeCalcWidthParent = value;
      this.invalidate(INVALIDATION_FLAG_SIZE);
    }
    
    public function get relativeCalcHeightParent():             DisplayObject 
    { 
      return (_relativeCalcHeightParent && _relativeCalcHeightParent.height) ? _relativeCalcHeightParent : getValidAncestorHeight();  
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
      _topPercentHeight = value;
      this.invalidate(INVALIDATION_FLAG_LAYOUT);
    }
    
    public function get bottomPercentHeight():Number  { return _bottomPercentHeight;  }
    public function set bottomPercentHeight(value:Number):void
    {
      _bottomPercentHeight = value;
      this.invalidate(INVALIDATION_FLAG_LAYOUT);
    }
    
    public function get leftPercentWidth():Number { return _leftPercentWidth; }
    public function set leftPercentWidth(value:Number):void
    {
      _leftPercentWidth = value;
      this.invalidate(INVALIDATION_FLAG_LAYOUT);
    }
    
    public function get rightPercentWidth():Number  { return _rightPercentWidth;  }
    public function set rightPercentWidth(value:Number):void
    {
      _rightPercentWidth = value;
      this.invalidate(INVALIDATION_FLAG_LAYOUT);
    }
    
    public function get horizontalAlign():String  {return _horizontalAlign; }
    public function set horizontalAlign(value:String):void
    {
      _horizontalAlign = value;
      invalidate(INVALIDATION_FLAG_ALIGN);
    }
    
    public function get verticalAlign():String  { return _verticalAlign;  }
    public function set verticalAlign(value:String):void
    {
      _verticalAlign = value;
      invalidate(INVALIDATION_FLAG_ALIGN);
    }
    
    public function get isSensitiveToParent():Boolean
    {
      return _isSensitiveToParent;
    }
    
    public function set isSensitiveToParent(value:Boolean):void
    {
      _isSensitiveToParent = value;
    }
    
    public function get id():String { return _id; }
    public function set id(value:String):void
    {
      _id = value;
    }
    
    override public function dispose():void
    {
      super.dispose();
      
      clearInvalidationFlags();
      _invalidationFlags = null;
    }
    
    private function clearInvalidationFlags():void
    {
      for(var flag:String in this._invalidationFlags)
      {
        delete this._invalidationFlags[flag];
      }     
    }
    
    private function invalidate(flag:String = INVALIDATION_FLAG_ALL):void
    {
      _invalidationFlags[flag] =  true;
    }
    
    private function isInvalid(flag:String = null):Boolean
    {
      return _invalidationFlags[flag];
    }
    
    private function onParentResize(event:Event):void
    {
      invalidate(INVALIDATION_FLAG_PARENT_RESIZED);
      layoutFlex();
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