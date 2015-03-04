package com.hendrix.feathers.controls.flex
{
  import com.hendrix.feathers.controls.flex.interfaces.IFlexComp;
  
  import flash.text.TextFormat;
  
  import feathers.controls.ToggleButton;
  
  import starling.display.DisplayObject;
  import starling.display.Image;
  import starling.textures.Texture;
  
  /**
   * a responsive flex button, resizes both default icon and font's size.
   * <li>use <code>this.fontPercentHeight</code>
   * <li>use <code>this.iconPercentHeight</code>
   * @author Tomer Shalev
   */
  public class FlexButton extends ToggleButton implements IFlexComp
  {
    // flex comp part
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
    
    private var _horizontalCenter:          Number        = NaN;
    private var _verticalCenter:            Number        = NaN;
    
    private var _relativeCalcWidthParent:   DisplayObject = null;
    private var _relativeCalcHeightParent:  DisplayObject = null;
    
    private var _id:                        String        = null;
    
    /**
     * font size in percentages based on the control height 
     */
    private var _fontPercentHeight:         Number        = 0.75;
    /**
     * icon size in percentages based on the control height 
     */
    private var _iconPercentHeight:         Number        = 0.55;
    
    /**
     * a responsive flex button, resizes both default icon and font's size.
     * <li>use <code>this.fontPercentHeight</code>
     * <li>use <code>this.iconPercentHeight</code>
     * @author Tomer Shalev
     */
    public function FlexButton()
    {
      super();
    }
    
    /**
     * a responsive flex button, resizes both default icon and font's size 
     * @author Tomer Shalev
     */
    public function layoutFlex():void
    {
      var parentWidthDop:   DisplayObject = _relativeCalcWidthParent  ? _relativeCalcWidthParent  as DisplayObject : getValidAncestorHeight() as DisplayObject;
      var parentHeightDop:  DisplayObject = _relativeCalcHeightParent ? _relativeCalcHeightParent as DisplayObject : getValidAncestorWidth() as DisplayObject;
      
      var fixY:Number                     = (parentHeightDop == parent) ? 0 : parentHeightDop.y;
      
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
      
      trace("name: " + name);
      
      if (name == "add") {
        trace();
      }
      
      width                               = w;
      height                              = h;
      
      var a:Boolean                       = setSizeInternal(w, h, false);
      
      return;
      if(w && h) {
        explicitWidth = w;
        
        explicitHeight = h;
      }
      
    }
    
    /**
     * font size in percentages based on the control height 
     */
    public function get fontPercentHeight():Number  { return _fontPercentHeight;  }
    public function set fontPercentHeight(value:Number):void
    {
      _fontPercentHeight = value;
    }
    
    /**
     * icon size in percentages based on the control height 
     */
    public function get iconPercentHeight():Number  { return _iconPercentHeight;}
    public function set iconPercentHeight(value:Number):void
    {
      _iconPercentHeight = value;
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
    
    /**
     * override parent for calculations
     */
    public function get relativeCalcWidthParent():              DisplayObject 
    { 
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
    
    public function get id():String { return _id; }
    public function set id(value:String):void
    {
      _id = value;
    }
    
    public function applyAlignment():void { }
    public function get isSensitiveToParent():                        Boolean { return false; }
    public function set isSensitiveToParent(value:Boolean):           void {}
    
    override public function dispose():void
    {
      super.dispose();
      
      _relativeCalcWidthParent  = null;
      _relativeCalcHeightParent = null;
    }
    
    override protected function initialize():void
    {
      super.initialize();
      
      if(isToggle) {
        if(downIcon && (upIcon || defaultIcon)) {
          
          if(!upIcon)
            upIcon = defaultIcon;
          
          selectedUpIcon    = downIcon;
          selectedDownIcon  = upIcon;
          selectedHoverIcon = downIcon;
        }
      }
    }
    
    protected function setupSize():void
    {
      var arIcon:   Number;
      var arIconW:  Number;
      var arIconH:  Number;
      
      gap                                                 = gap ? gap: width*0.03; 
      padding                                             = gap;
      
      if(defaultIcon) {
        var tex:Texture                                   = (defaultIcon as Image).texture;
        
        arIconW                                           = width/tex.width;
        arIconH                                           = height/tex.height;
        //trace(arIconW);
        arIcon                                            = Math.min(arIconW, arIconH);
        
        if(defaultIcon is Image) {
          defaultIcon.height                              = tex.height*_iconPercentHeight*arIcon;
          defaultIcon.width                               = tex.width*_iconPercentHeight*arIcon;
          //trace();
        }
        
      }   
      
      if(downIcon) {
        downIcon.width                                    = defaultIcon.width; 
        downIcon.height                                   = defaultIcon.height;
      }
      if(upIcon) {
        upIcon.width                                      = defaultIcon.width; 
        upIcon.height                                     = defaultIcon.height;
      }
      
      if(defaultSelectedIcon) {
        defaultSelectedIcon.width                         = defaultIcon.width; 
        defaultSelectedIcon.height                        = defaultIcon.height;
      }
      
      if(selectedDownIcon) {
        selectedDownIcon.width                            = defaultIcon.width; 
        selectedDownIcon.height                           = defaultIcon.height;
      }
      
      if(selectedUpIcon) {
        selectedUpIcon.width                              = defaultIcon.width; 
        selectedUpIcon.height                             = defaultIcon.height;
      }
      if(selectedHoverIcon) {
        selectedHoverIcon.width                           = defaultIcon.width; 
        selectedHoverIcon.height                          = defaultIcon.height;
      }
      
      var tf: TextFormat                                  = defaultLabelProperties.textFormat as TextFormat;
      
      if(tf)  {
        tf.size                                           = height * _fontPercentHeight;
        
        if(defaultLabelProperties.textFormat)
          defaultLabelProperties.textFormat.size          = tf.size;
        
        if(defaultSelectedLabelProperties.textFormat)
          defaultSelectedLabelProperties.textFormat.size  = tf.size;
        
        var tff:  TextFormat                              = new TextFormat(tf.font,tf.size,tf.color);
        tff.align                                         = tf.align;
        
        if(defaultSelectedLabelProperties.textFormat) {
          var tff2: TextFormat                            = new TextFormat(defaultSelectedLabelProperties.textFormat.font,defaultSelectedLabelProperties.textFormat.size,defaultSelectedLabelProperties.textFormat.color);
          tff2.align                                      = defaultSelectedLabelProperties.textFormat.align;
        }
        
        if(disabledLabelProperties.textFormat) {
          
          var tff3: TextFormat                            = new TextFormat(disabledLabelProperties.textFormat.font,tf.size,disabledLabelProperties.textFormat.color);
          tff3.align                                      = disabledLabelProperties.textFormat.align;
          
          disabledLabelProperties.textFormat              = null;
          disabledLabelProperties.textFormat              = tff3;
        }
        
        var sizeInvalid:Boolean                           = isInvalid(INVALIDATION_FLAG_SIZE);
        
        if(sizeInvalid) {
          //tff2 = selectedDisabledLabelProperties.textFormat;
          defaultLabelProperties.textFormat               = null;
          defaultLabelProperties.textFormat               = tff;
          
          if(defaultSelectedLabelProperties.textFormat)
            defaultSelectedLabelProperties.textFormat     = tff2;
        }
        
      }     
      
    }
    
    override protected function draw():void
    {
      var sizeInvalid:    Boolean = isInvalid(INVALIDATION_FLAG_SIZE);
      var layoutInvalid:  Boolean = isInvalid(INVALIDATION_FLAG_LAYOUT);
      
      
      if((sizeInvalid || layoutInvalid))
        layoutFlex();
      
      if((sizeInvalid || layoutInvalid))
        setupSize();
      
      super.draw();     
    }
    
    private function getValidAncestorHeight():DisplayObject
    {
      var validParent:  DisplayObject = parent;
      
      while(!validParent.height) {
        validParent                   = validParent.parent;
      }
      
      return validParent;
    }
    
    private function getValidAncestorWidth():DisplayObject
    {
      var validParent:  DisplayObject = parent;
      
      while(!validParent.width) {
        validParent                   = validParent.parent;
      }
      
      return validParent;
    }
    
  }
  
}