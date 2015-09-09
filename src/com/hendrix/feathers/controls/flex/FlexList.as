package com.hendrix.feathers.controls.flex
{
  import com.hendrix.feathers.controls.flex.interfaces.IFlexComp;
  
  import feathers.controls.List;
  import feathers.core.FeathersControl;
  import feathers.core.IFeathersControl;
  import feathers.events.FeathersEventType;
  import feathers.layout.HorizontalLayout;
  import feathers.layout.VerticalLayout;
  
  import starling.display.DisplayObject;
  import starling.events.Event;
  
  /**
   * a Feather list that implements IFlexComp 
   * @author Tomer Shalev
   */
  public class FlexList extends List implements IFlexComp
  {
    static protected const INVALIDATION_FLAG_ALIGN:           String  = "INVALIDATION_FLAG_ALIGN";
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
    
    private var _isSensitiveToParent:       Boolean         = true;
    private var _breakParentSensitivityAfter: Number      = 3;

    private var _id:                        String          = null;
    
    /**
     * a Feather list that implements IFlexComp 
     * @author Tomer Shalev
     */
    public function FlexList()
    {
      super();
    }
    
    override public function dispose():void
    {
      super.dispose();
      
      _relativeCalcWidthParent  = null;
      _relativeCalcHeightParent = null;
      
      var parentWidthDop:   DisplayObject = _relativeCalcWidthParent  ? _relativeCalcWidthParent  as DisplayObject : getValidAncestorWidth() as DisplayObject;
      var parentHeightDop:  DisplayObject = _relativeCalcHeightParent ? _relativeCalcHeightParent as DisplayObject : getValidAncestorHeight() as DisplayObject;
      
      if(parentWidthDop)
        parentWidthDop.removeEventListener(FeathersEventType.RESIZE, onParentResized);
      
      if(parentHeightDop)
        parentHeightDop.removeEventListener(FeathersEventType.RESIZE, onParentResized);
    }
    
    public function layoutFlex():void
    {
      var parentWidthDop:   DisplayObject = _relativeCalcWidthParent  ? _relativeCalcWidthParent  as DisplayObject : getValidAncestorWidth() as DisplayObject;
      var parentHeightDop:  DisplayObject = _relativeCalcHeightParent ? _relativeCalcHeightParent as DisplayObject : getValidAncestorHeight() as DisplayObject;
      
      var fixY:Number = (parentHeightDop == parent) ? 0 : parentHeightDop.y;
      
      if(!parentHeightDop || !parentWidthDop)
        throw new Error("no parent or parent override found!!");
      
      var w:  Number                      = actualWidth;
      var h:  Number                      = actualHeight;
      
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
        y                                 = fixY + _top;
      
      if(!isNaN(_left))
        x                                 = _left;
      
      if(!isNaN(_right))
        x                                 = parentWidthDop.width - (w + _right);
      
      width                               = w;
      height                              = h
      //var a:Boolean = setSizeInternal(w, h, true);
      trace();//
    }
    
    
    public function applyAlignment():void
    {
      var child:DisplayObject = null;
      
      for(var ix:uint = 0; ix < numChildren; ix++)
      {
        child = getChildAt(ix);
        
        switch(_horizontalAlign)
        {
          case HorizontalLayout.HORIZONTAL_ALIGN_CENTER:
          {
            child.x = (width - child.width) * 0.5;
            break;
          }
          case HorizontalLayout.HORIZONTAL_ALIGN_RIGHT:
          {
            child.x = (width - child.width);
            break;
          }
          case HorizontalLayout.HORIZONTAL_ALIGN_LEFT:
          {
            child.x = 0;
            break;
          }
        }
        
        switch(_verticalAlign)
        {
          case VerticalLayout.VERTICAL_ALIGN_MIDDLE:
          {
            child.y = (height - child.height) * 0.5;
            break;
          }
          case VerticalLayout.VERTICAL_ALIGN_BOTTOM:
          {
            child.y = (height - child.height);
            break;
          }
          case VerticalLayout.VERTICAL_ALIGN_TOP:
          {
            child.y = 0;
            break;
          }
        }
        
      }
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
    
    public function get isSensitiveToParent():Boolean { return _isSensitiveToParent; }
    public function setSensitiveToParent(count:uint):void
    {
      _breakParentSensitivityAfter  = count;
      _isSensitiveToParent          = count==0 ? false : true;
      
      if(!_isSensitiveToParent)
        return;
      
      if(isCreated)
        internal_parent_observer();
    }
    
    public function get id():String { return _id; }
    public function set id(value:String):void
    {
      _id = value;
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

    override protected function initialize():void
    {
      super.initialize();
      
      if(_isSensitiveToParent)
        internal_parent_observer();
    }
    
    override protected function draw():void
    {
      var sizeInvalid:        Boolean = isInvalid(INVALIDATION_FLAG_SIZE);
      var layoutInvalid:      Boolean = isInvalid(INVALIDATION_FLAG_LAYOUT);
      var parentSizeInvalid:  Boolean = isInvalid(INVALIDATION_FLAG_PARENT_RESIZED);
      
      if((sizeInvalid || layoutInvalid || parentSizeInvalid))
        layoutFlex();
      
      if(sizeInvalid) {
        if(parent is IFeathersControl)
          (parent as FeathersControl).invalidate(INVALIDATION_FLAG_LAYOUT);
      }
      
      super.draw();
      
    }
    
    private function onParentResized(evt:Event):void
    {
      if(_breakParentSensitivityAfter <= 0) { 
        //internal_parent_observer(false);
        evt.currentTarget.removeEventListener(FeathersEventType.RESIZE, onParentResized);
        
        return;
      }
      
      _breakParentSensitivityAfter -= 1;
      
      trace("onParentResized::" + _breakParentSensitivityAfter);
      invalidate(INVALIDATION_FLAG_SIZE);      
    }
    
    private function isParentDependant():void
    {
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