package com.hendrix.feathers.controls.flex
{
  import com.hendrix.feathers.controls.CompsFactory;
  import com.hendrix.feathers.controls.utils.TextUtils;
  
  import flash.text.TextFormat;
  
  import feathers.controls.Button;
  import feathers.core.FeathersControl;
  import feathers.core.IFeathersControl;
  import feathers.layout.HorizontalLayout;
  import feathers.layout.VerticalLayout;
  
  import starling.display.DisplayObject;
  import starling.display.Quad;
  import starling.events.Event;
  
  /**
   * a very lite Verical Group like Flex, but used only with a dataprovider<br>
   * <p><b>Example:</b><br>
   * use <code>this.dataProvider</code> for layout sruff, the reason we use it is that because non of feather or starling and Feathers<br>
   * comps come with these basic and useful layout/sizing properties<br>
   * <code>
   *      this.dataProvier = Vector.Object([<br>
   *        { id: "1", src: dop1, percentWidth: 95, percentHeight: NaN, width:NaN, height:1},<br>
   *        { id: "2", src: dop1, percentWidth: 100, percentHeight: 11, width:NaN, height:NaN},<br>
   *        { id: "3", src: dop3, percentWidth: 95, percentHeight: NaN, width:NaN, height:1},<br>
   *      ]);</code><br>
   * <b>Notes:</b>
   * <ul>
   * <li> use <code>this.relativeCalcObject</code> to modify the component on which relative percent height calculations are based upon.
   * <li> use <code>this.horizontalAlign, padding, gap, gapPercentHeight</code> to control layout.
   * <li> use <code>this.backgroundSkin</code> have a background skin that stretches.
   * <li> can only be used with a data provider for now.
   * </ul>
   * <b>TODO:</b>
   * <ul>
   * <li> interface for updating data.
   * </ul>
   * @author Tomer Shalev
   * 
   */
  public class HGroup extends FlexComp
  {
    static public const INVALIDATION_FLAG_ITEMS_MOVED:  String  = "INVALIDATION_FLAG_ITEMS_MOVED"; 
    
    // data
    protected var _dataProvider:        Vector.<Object>         = null;
        
    // layout
    private var _relativeCalcObject:  DisplayObject           = null;
    private var _verticalAlign:       String                  = HorizontalLayout.HORIZONTAL_ALIGN_CENTER;
    private var _horizontalAlign:     String                  = HorizontalLayout.HORIZONTAL_ALIGN_CENTER;
    private var _padding:             Number                  = NaN;
    private var _paddingTop:          Number                  = NaN;
    private var _paddingLeft:         Number                  = NaN;
    private var _gap:                 Number                  = NaN;
    private var _gapPercentWidth:     Number                  = NaN;
    
    private var _stickyButtons:       Boolean                 = false;
    
    private var _onSelected:          Function                = null;
    
    public function HGroup()
    {
      super();
    }
    
    override public function addChild(child:DisplayObject):DisplayObject
    {
      invalidate(INVALIDATION_FLAG_ITEMS_MOVED);
      
      if(_stickyButtons) {
        if(child is Button)
          (child as Button).addEventListener(Event.TRIGGERED, stickyButtons_onTriggered);
      }
      
      return super.addChild(child);
    }
    
    override public function addChildAt(child:DisplayObject, index:int):DisplayObject
    {
      invalidate(INVALIDATION_FLAG_ITEMS_MOVED);
      
      if(_stickyButtons) {
        if(child is Button)
          (child as Button).addEventListener(Event.TRIGGERED, stickyButtons_onTriggered);
      }
      
      return super.addChildAt(child, index);
    }
    
    override public function removeChild(child:DisplayObject, dispose:Boolean=false):DisplayObject
    {
      invalidate(INVALIDATION_FLAG_ITEMS_MOVED);
      return super.removeChild(child, dispose);
    }
    
    override public function removeChildAt(index:int, dispose:Boolean=false):DisplayObject
    {
      invalidate(INVALIDATION_FLAG_ITEMS_MOVED);
      return super.removeChildAt(index, dispose);
    }
    
    override public function removeChildren(beginIndex:int=0, endIndex:int=-1, dispose:Boolean=false):void
    {
      invalidate(INVALIDATION_FLAG_ITEMS_MOVED);
      super.removeChildren(beginIndex, endIndex, dispose);
    }
    
    override public function dispose():void
    {
      super.dispose();
      
      if(_dataProvider) {
        _dataProvider.length = 0;
      }
      
      _backgroundSkin       = null;
      _relativeCalcObject   = null;
      _onSelected           = null;
    }
    
    /**
     * the relative object to calculate percent Height 
     */
    public function get relativeCalcObject():                     DisplayObject     { return _relativeCalcObject; }
    public function set relativeCalcObject(value:DisplayObject):  void
    {
      _relativeCalcObject = value;
      invalidate(INVALIDATION_FLAG_ALL);
    }
    
    public function get dataProvider():                           Vector.<Object>   { return _dataProvider; }
    public function set dataProvider(value:Vector.<Object>):      void
    {
      if(_dataProvider) {
        _dataProvider.length  = 0;
        _dataProvider = null;
      }
      
      _dataProvider = value;
      
      if(isInitialized)
        commitItemsIfDataProvider();
      
      invalidate(INVALIDATION_FLAG_DATA);
    }
    
    override public function set verticalAlign(value:String):           void
    {
      _verticalAlign = value;
      invalidate(INVALIDATION_FLAG_LAYOUT);
    }
    
    override public function set horizontalAlign(value:String):         void
    {
      _horizontalAlign = value;
      invalidate(INVALIDATION_FLAG_LAYOUT);
    }
    
    public function get padding():                                Number            { return _padding;  }
    public function set padding(value:Number):                    void
    {
      _padding = _paddingTop = value;
      invalidate(INVALIDATION_FLAG_LAYOUT);
    }
    
    public function get paddingTop():                             Number            { return _paddingTop; }
    public function set paddingTop(value:Number):                 void
    {
      _paddingTop = value;
      invalidate(INVALIDATION_FLAG_LAYOUT);
    }
    
    public function get gap():                                    Number            { return _gap;  }
    public function set gap(value:Number):                        void
    {
      _gap = value;
      invalidate(INVALIDATION_FLAG_LAYOUT);
    }
    
    public function get gapPercentWidth():                        Number  { return _gapPercentWidth;  }
    public function set gapPercentWidth(value:Number):            void
    {
      _gapPercentWidth = value >= 1 ? value/100 : value;
      invalidate(INVALIDATION_FLAG_LAYOUT);
    }
    
    override public function get backgroundSkin():                         DisplayObject     { return _backgroundSkin; }
    override public function set backgroundSkin(value:DisplayObject):      void
    {
      if(_backgroundSkin)
        _backgroundSkin.removeFromParent(false);
      
      _backgroundSkin = value;
      
      if(isInitialized) {
        super.addChildAt(_backgroundSkin, 0);
        validateBackground();
      }
    }
    
    public function get stickyButtons():                          Boolean           { return _stickyButtons;  }
    public function set stickyButtons(value:Boolean):             void
    {
      _stickyButtons = value;
    }
    
    public function get onSelected():                             Function          { return _onSelected; }
    public function set onSelected(value:Function):               void
    {
      _onSelected = value;
      _stickyButtons = true;
    }
    
    override protected function initialize():void
    {
      super.initialize();
      
      if(_backgroundSkin) {
        super.addChildAt(_backgroundSkin, 0);
      }
      
      commitItemsIfDataProvider()
    }
    
    override protected function draw():void
    {     
      super.draw();
      
      var sizeInvalid:        Boolean               = isInvalid(INVALIDATION_FLAG_SIZE);
      var layoutInvalid:      Boolean               = isInvalid(INVALIDATION_FLAG_LAYOUT);
      var dataInvalid:        Boolean               = isInvalid(INVALIDATION_FLAG_DATA);
      var itemsMovedInvalid:  Boolean               = isInvalid(INVALIDATION_FLAG_ITEMS_MOVED);
      var invalid:            Boolean               = sizeInvalid || dataInvalid || layoutInvalid || itemsMovedInvalid;
      
      if(!invalid)
        return;
      
      var calcW:    Number;
      var calcH:    Number;
      
      _relativeCalcObject                           = relativeCalcWidthParent;
      
      var calcGap:  Number                          = isNaN(_gap) ?  isNaN(_gapPercentWidth) ? 0 : _relativeCalcObject.width * _gapPercentWidth : _gap;
      
      if(isNaN(_paddingTop))
        _paddingTop                                 = calcGap;
      
      if(isNaN(_paddingLeft))
        _paddingLeft                                = 0;
      
      var posx:     Number                          = _paddingLeft;
      
      var doRef:    DisplayObject                   = null;
      
      var correct:uint                              = 0;
      
      if(_backgroundSkin)
        correct                                     = 1;
      
      for(var ix:uint = 0; ix < numChildren - correct; ix++)
      {
        doRef                                       = getChildAt(ix + correct);
        
        if(dataInvalid || sizeInvalid || itemsMovedInvalid)
        {
          if(_dataProvider) {
            calcW                                   = isNaN(_dataProvider[ix].percentWidth)  ?  (isNaN(_dataProvider[ix].width)   ? doRef.width   : _dataProvider[ix].width)  : !(_dataProvider[ix].hasOwnProperty("relativeCalcParent")) ? (_dataProvider[ix].percentWidth/100)*width : (_dataProvider[ix].percentWidth/100)*_dataProvider[ix].relativeCalcParent.width;
            calcH                                   = isNaN(_dataProvider[ix].percentHeight) ?  ((isNaN(_dataProvider[ix].height) ? doRef.height  : _dataProvider[ix].height)) : !(_dataProvider[ix].hasOwnProperty("relativeCalcParent")) ? (_dataProvider[ix].percentHeight/100)*height : (_dataProvider[ix].percentHeight/100)*_dataProvider[ix].relativeCalcParent.height;
            
            if(calcW)
              doRef.width                           = calcW;
            
            if(calcH)
              doRef.height                          = calcH;
          }
          
          // layout the child
          if(doRef is IFeathersControl)
            (doRef as IFeathersControl).validate();
        }
        
        doRef.x                                     = posx;
        
        switch(_verticalAlign)
        {
          case VerticalLayout.VERTICAL_ALIGN_MIDDLE:
          {
            doRef.y                                 = (height - (doRef.height))*0.5;
            break;
          }
          case VerticalLayout.VERTICAL_ALIGN_TOP:
          {
            doRef.y                                 = _paddingTop;
            break;
          }
          case VerticalLayout.VERTICAL_ALIGN_BOTTOM:
          {
            doRef.y                                 = (height - (doRef.height));
            break;
          }
        }
        
        posx                                       += doRef.width + calcGap;
      }
      
      posx                                          = posx - calcGap + _paddingLeft;
      
      var align:Number                              = 0;
      
      if(_horizontalAlign == HorizontalLayout.HORIZONTAL_ALIGN_CENTER) {
        align                                       = (width - posx)*0.5;
        
        for(ix = correct; ix < numChildren; ix++) {
          doRef                                     = getChildAt(ix);
          doRef.x                                  += align;
        }
      }
      else if(_horizontalAlign == HorizontalLayout.HORIZONTAL_ALIGN_RIGHT) {
        align                                       = (width - posx);
        
        for(ix = correct; ix < numChildren; ix++) {
          doRef                                     = getChildAt(ix);
          doRef.x                                  += align;
        }
      }
      
      if(width == 0) {
        explicitWidth                               = NaN;
        var c:  Number                              = isNaN(percentHeight) ? 0 : percentWidth*relativeCalcWidthParent.width;
        var a:  Boolean                             = setSizeInternal(Math.max(posx,c), height, false);
      }
      
      validateBackground();
      
      if(parent is IFeathersControl){
        (parent as FeathersControl).invalidate(INVALIDATION_FLAG_LAYOUT);
        (parent as IFeathersControl).validate();
      }
      
    }
    
    private function stickyButtons_onTriggered(event:Event):void
    {
      if(onSelected is Function)
        onSelected((event.currentTarget as Button).name);
    }
    
    private function commitItemsIfDataProvider():void
    {
      if(_dataProvider == null)
        return;
      
      if(_dataProvider) {
        var sIndex:uint       = _backgroundSkin ? 1 : 0;
        
        removeChildren(sIndex);
      }
      
      var doRef:DisplayObject = null;
      
      for(var ix:uint = 0; ix < _dataProvider.length; ix++)
      {
        doRef                 = _dataProvider[ix].src;
        
        if(doRef == null)
          continue;
        
        if(_dataProvider[ix].id)
          doRef.name          = _dataProvider[ix].id;
        
        if(_stickyButtons) {
          if(doRef is Button)
            (doRef as Button).addEventListener(Event.TRIGGERED, stickyButtons_onTriggered);
        }
        
        addChild(doRef);
      }
    }
    
    private function testDataProvider():void
    {
      {
        var tf:TextFormat = new TextFormat("arial11", 1, 0xffffff);
        
        _dataProvider = Vector.<Object>([
          { id: "1", src: new Quad(1,1,0x404040), percentWidth: 95, percentHeight: NaN, width:NaN, height:1},
          { id: "liked", src: CompsFactory.newLabel("rere",tf,false,true,"right",true), percentWidth: 100, percentHeight: 33, width:NaN, height:NaN},
          { id: "1", src: new Quad(1,1,0x404040), percentWidth: 95, percentHeight: NaN, width:NaN, height:1},
          { id: "recommended", src: CompsFactory.newButton(new Quad(1,1,0x303030),null,null,tf,TextUtils.reverse("המומלצים"), true, "general::ss1.star",true,"right", true), percentWidth: 100, percentHeight: 4, width:NaN, height:NaN},
          { id: "1", src: new Quad(1,1,0x404040), percentWidth: 95, percentHeight: NaN, width:NaN, height:1},
          { id: "latest", src: CompsFactory.newButton(new Quad(1,1,0x303030),null,null,tf,TextUtils.reverse("העדכניים"), true, "general::ss1.star",true,"right", true), percentWidth: 100, percentHeight: 4, width:NaN, height:NaN},
          { id: "1", src: new Quad(1,1,0x404040), percentWidth: 95, percentHeight: NaN, width:NaN, height:1},
          { id: "meAndFriends", src: CompsFactory.newButton(new Quad(1,1,0x303030),null,null,tf,TextUtils.reverse("שלי ושל חברים"), true, "general::ss1.star",true,"right", true), percentWidth: 100, percentHeight: 4, width:NaN, height:NaN},
          { id: "1", src: new Quad(1,1,0x404040), percentWidth: 95, percentHeight: NaN, width:NaN, height:1},
        ]);
      }
    }
    
  }
  
}