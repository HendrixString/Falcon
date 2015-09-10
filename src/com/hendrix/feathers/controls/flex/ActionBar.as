package com.hendrix.feathers.controls.flex
{ 
  import com.hendrix.feathers.controls.CompsFactory;
  
  import feathers.controls.Button;
  import feathers.core.FeathersControl;
  import feathers.core.IFeathersControl;
  
  import starling.display.DisplayObject;
  import starling.display.Quad;
  import starling.events.Event;
  
  /**
   * <p>a very lite Action Bar component, requires a data provider</p>
   * <p><b>Example:</b>
   * 
   *    <pre>
   *      this.dataProvier = Vector.Object([
   *        { id: "1", src: do1, align:"right"},
   *        { id: "2", src: do2, align:"center"},
   *        { id: "3", src: do3, align:"left"},
   *        { id: "4", src: do4, align:"left"}
   *      ]);</pre><br>
   * 
   * <b>Notes:</b>
   * 
   * <ul>
   *  <li>set <code>leftItemsPercentWidth/Height, rightItemsPercentWidth/Height, centerItemsPercentWidth/Height</code> to control layout</li>
   *  <li>set <code>percentHeight</code> to control height of componenet relative to it's parent, or <code>height</code> to control pixel wise</li>
   *  <li>set <code>bgSkinSource</code> to control background, it can be color, texture, class, bitmap etc..</li>
   *  <li>set <code>onSelected</code> to listen to items being clicked, it will return an <code>id</code> string</li>
   *  <li><code>src</code> can be any <code>DisplayObject</code></li>
   *  <li>use <code>mrUpdateContent(id, src)</code> to update an exiting item</li>
   * </ul>
   * 
   * @author Tomer Shalev
   */
  public class ActionBar extends FlexComp
  {
    public static const INVALIDATION_FLAG_RIGHT_ITEMS:  String                  = "RIGHT_ITEMS";
    public static const INVALIDATION_FLAG_LEFT_ITEMS:   String                  = "LEFT_ITEMS";
    public static const INVALIDATION_FLAG_CENTER_ITEMS: String                  = "CENTER_ITEMS";
    public static const INVALIDATION_FLAG_BACKGROUND:   String                  = "BACKGROUND";
    
    /**
     * the data provider 
     */
    protected var _dataProvider:                        Vector.<Object>         = null;
    
    private var _itemsLeft:                             Vector.<DisplayObject>  = null;
    private var _itemsCenter:                           Vector.<DisplayObject>  = null;
    private var _itemsRight:                            Vector.<DisplayObject>  = null;
    
    private var _leftItemsPercentWidth:                 Number                  = 1;
    private var _rightItemsPercentWidth:                Number                  = 1;
    private var _centerItemsPercentWidth:               Number                  = 1;
    
    private var _leftItemsPercentHeight:                Number                  = 1;
    private var _rightItemsPercentHeight:               Number                  = 1;
    private var _centerItemsPercentHeight:              Number                  = 1;
    
    private var _gap:                                   uint                    = 0;
    private var _paddingRight:                          uint                    = 0;
    private var _paddingLeft:                           uint                    = 0;
    
    private var _bgSkin:                                DisplayObject           = null;
    protected var _bgSkinSource:                        Object                  = null;
    
    private var _onSelected:                            Function                = null;
    
    private var _btnMode:                               Button                  = null;
    
    private var _buttonMode:                            Boolean                 = false;
    
    public var ignore:DisplayObject;
    
    /**
     * <p>a very lite Action Bar component, requires a data provider. the data provider handling is dynamic and can be updated at runtime.</p>
     * <p><b>Example:</b><br>
     *        <code>
     *      this.dataProvier = Vector.Object([<br>
     *        { id: "1", src: do1, align:"right"},<br>
     *        { id: "2", src: do2, align:"center"},<br>
     *        { id: "3", src: do3, align:"left"},<br>
     *        { id: "4", src: do4, align:"left"}<br>
     *      ]);</code><br>
     * <b>Notes:</b>
     * <ul>
     * <li>set <code>leftItemsPercentWidth/Height, rightItemsPercentWidth/Height, centerItemsPercentWidth/Height</code> to control layout</li>
     * <li>set <code>percentHeight</code> to control height of componenet relative to it's parent, or <code>height</code> to control pixel wise</li>
     * <li>set <code>bgSkinSource</code> to control background, it can be color, texture, class, bitmap etc..</li>
     * <li>set <code>onSelected</code> to listen to items being clicked, it will return an <code>id</code> string</li>
     * <li><code>src</code> can be any <code>DisplayObject</code></li>
     * <li>use <code>mrUpdateContent(id, src)</code> to update an exiting item</li>
     * </ul>
     * </p> 
     * @author Tomer Shalev
     */
    public function ActionBar()
    {
      super();
      
      verticalCenter                  = 0;
      
      _itemsLeft                      = new Vector.<DisplayObject>();
      _itemsCenter                    = new Vector.<DisplayObject>();
      _itemsRight                     = new Vector.<DisplayObject>();
    }
    
    
    override public function dispose():void
    {
      super.dispose();
      
      _itemsLeft.length   = 0;
      _itemsRight.length  = 0;
      _itemsCenter.length = 0;
      
      _itemsLeft          = null;
      _itemsRight         = null;
      _itemsCenter        = null;
      
      _onSelected         = null;
      _bgSkin             = null;
      _bgSkinSource       = null;
      
      if(_btnMode) {
        _btnMode.removeEventListener(Event.TRIGGERED, btnMode_onTriggered);
        _btnMode            = null;
      }
      
      if(_dataProvider) {
        _dataProvider.length = 0;
      }
    }
    
    /**
     * a simple update of content, not very optimal. 
     * @param $id the name of the previously registred items
     * @param $src the updated display object, if null it will return a reference to the display object
     */
    public function mrUpdateContent($id:String, $src:DisplayObject = null):DisplayObject
    {
      for(ix  = 0; ix < _itemsCenter.length; ix++)
      {
        if(_itemsCenter[ix].name == $id) {
          if($src == null)
            return _itemsCenter[ix];
          $src.name = $id;
          removeChild(_itemsCenter[ix], false);
          $src.addEventListener(Event.TRIGGERED, onChange);
          _itemsCenter[ix] = $src;
          addChild($src);
          invalidate(INVALIDATION_FLAG_CENTER_ITEMS);
          validate();
          return null;
        }
      }
      
      for(var ix:uint = 0; ix < _itemsLeft.length; ix++)
      {
        if(_itemsLeft[ix].name == $id) {
          if($src == null)
            return _itemsLeft[ix];
          $src.name = $id;
          removeChild(_itemsLeft[ix], false);
          $src.addEventListener(Event.TRIGGERED, onChange);
          _itemsLeft[ix] = $src;
          addChild($src);
          invalidate(INVALIDATION_FLAG_LEFT_ITEMS);
          validate();
          return null;
        }
      }
      
      for(ix  = 0; ix < _itemsRight.length; ix++)
      {
        if(_itemsRight[ix].name == $id) {
          if($src == null)
            return _itemsRight[ix];
          $src.name = $id;
          removeChild(_itemsRight[ix], false);
          $src.addEventListener(Event.TRIGGERED, onChange);
          _itemsRight[ix] = $src;
          addChild($src);
          invalidate(INVALIDATION_FLAG_RIGHT_ITEMS);
          validate();
          return null;
        }
      }
      
      return null;
    }
    
    /**
     *
     * <p><b>Example:</b><br>
     *         <code>
     *       this.dataProvier = Vector.Object([<br>
     *         { id: "1", src: do1, align:"right"},<br>
     *       { id: "2", src: do2, align:"center"},<br>
     *       { id: "3", src: do3, align:"left"},<br>
     *       { id: "4", src: do4, align:"left"}<br>
     *     ]);</code><br>
     */
    public function get dataProvider():                       Vector.<Object> { return _dataProvider;   }
    public function set dataProvider(value:Vector.<Object>):  void            
    { 
      if(_dataProvider) {
        removeChildren(0, -1, true);
        _itemsLeft.length     = 0;
        _itemsRight.length    = 0;
        _itemsCenter.length   = 0;
      }
      
      _dataProvider         = value;
      // if data provider was changed while this was added to the stage
      //if(this.stage != null)
      commitItems();
      
      this.invalidate(INVALIDATION_FLAG_ALL);
      
      if(_hasValidated)
        this.validate();
    }
    
    public function get gap():                                uint            { return _gap;            }
    public function set gap(value:uint):                      void            
    { 
      _gap = value;
      this.invalidate(INVALIDATION_FLAG_ALL);
    }
    
    public function get paddingRight():                       uint            { return _paddingRight;   }
    public function set paddingRight(value:uint):             void            
    { 
      _paddingRight = value;
      this.invalidate(INVALIDATION_FLAG_RIGHT_ITEMS);
    }
    
    public function get paddingLeft():                        uint            { return _paddingLeft;    }
    public function set paddingLeft(value:uint):              void            
    { 
      _paddingLeft = value;   
      this.invalidate(INVALIDATION_FLAG_LEFT_ITEMS);
    }
    
    
    /**
     * callback function signature function($id:String) 
     * @param value callback function
     */
    public function set onSelected(value:Function):           void            { _onSelected = value;    }
    
    /**
     * set a background skin, can be a displayObject or a color
     */
    public function get bgSkin():                             Object          { return _bgSkinSource;   }
    public function set bgSkin(value:Object):                 void            
    { 
      _bgSkinSource = value;
      this.invalidate(INVALIDATION_FLAG_BACKGROUND);
    }
    
    public function get leftItemsPercentWidth():              Number          { return _leftItemsPercentWidth;  }
    public function set leftItemsPercentWidth(value:Number):  void            
    { 
      if(value > 1) 
        _leftItemsPercentWidth = value / 100;
      else
        _leftItemsPercentWidth = value; 
      this.invalidate(INVALIDATION_FLAG_LEFT_ITEMS);
    }
    
    public function get rightItemsPercentWidth():             Number          { return _rightItemsPercentWidth; }
    public function set rightItemsPercentWidth(value:Number): void            
    {
      if(value > 1)
        _rightItemsPercentWidth = value / 100;
      else
        _rightItemsPercentWidth = value;
      this.invalidate(INVALIDATION_FLAG_RIGHT_ITEMS);
    }
    
    public function get centerItemsPercentWidth():            Number          { return _centerItemsPercentWidth;}
    public function set centerItemsPercentWidth(value:Number):void
    {
      if(value > 1)
        _centerItemsPercentWidth = value / 100;
      else
        _centerItemsPercentWidth = value;
      this.invalidate(INVALIDATION_FLAG_CENTER_ITEMS);
    }
    
    override public function set height(value:Number):        void
    {
      super.height = value;
      invalidate(INVALIDATION_FLAG_ALL);
    }
    
    public function get leftItemsPercentHeight():             Number  { return _leftItemsPercentHeight; }
    public function set leftItemsPercentHeight(value:Number): void
    {
      if(value > 1)
        _leftItemsPercentHeight = value / 100;
      else
        _leftItemsPercentHeight = value;
      this.invalidate(INVALIDATION_FLAG_LEFT_ITEMS);
    }
    
    public function get rightItemsPercentHeight():            Number  { return _rightItemsPercentHeight;  }
    public function set rightItemsPercentHeight(value:Number):void  
    {
      if(value > 1)
        _rightItemsPercentHeight = value / 100;
      else
        _rightItemsPercentHeight = value;
      this.invalidate(INVALIDATION_FLAG_RIGHT_ITEMS);
    }
    
    public function get centerItemsPercentHeight():             Number  { return _centerItemsPercentHeight; }
    public function set centerItemsPercentHeight(value:Number): void
    {
      if(value > 1)
        _centerItemsPercentHeight = value / 100;
      else
        _centerItemsPercentHeight = value;
      this.invalidate(INVALIDATION_FLAG_CENTER_ITEMS);
    }
    
    /**
     * set buttonMode make this component clickable 
     */
    public function get buttonMode():                         Boolean { return _buttonMode; }
    public function set buttonMode(value:Boolean):            void
    {
      _buttonMode         = value;
      
      if(_buttonMode) {
        if(_btnMode)
          return;
        
        _btnMode          = new Button();
        _btnMode.addEventListener(Event.TRIGGERED, btnMode_onTriggered);
        
        if(_isInitialized)
          addChild(_btnMode);
        if(_hasValidated) {
          _btnMode.width  = width;
          _btnMode.height = height;
        }
        
      }
      else {
        if(_btnMode)
          removeChild(_btnMode);
      }
    }
    
    override protected function initialize():void
    {
      super.initialize();
      //commitItems();
      
      if(_btnMode)
        addChild(_btnMode);
    }
    
    override protected function draw():void
    {
      super.draw();
      
      if(this.isInvalid(INVALIDATION_FLAG_BACKGROUND)) 
      {
        removeChild(_bgSkin, true);
        
        if(_bgSkinSource is uint)
          _bgSkin                 = new Quad(1, 1, uint(_bgSkinSource));
        else if(_bgSkinSource is DisplayObject)
          _bgSkin                 = _bgSkinSource as DisplayObject;
        else if(_bgSkin)
          _bgSkin                 = CompsFactory.newImage(_bgSkinSource);
        
        if(_bgSkin)
          addChildAt(_bgSkin, 0);
      }
      
      var h:            Number    = height;
      
      if(_bgSkin) {
        _bgSkin.height            = h;
        _bgSkin.width             = width;
      }
      
      var ar:           Number    = 0;
      var arW:          Number;
      var combinedWidth:Number    = 0;
      var maxHeightItem:Number    = 0;
      var posX:         Number    = 0;
      var ix:           uint      = 0;
      var reg:          Number;
      
      /**
       * left items
       */
      if(this.isInvalid(INVALIDATION_FLAG_LEFT_ITEMS) || isInvalid(INVALIDATION_FLAG_SIZE)) 
      {
        if(id == "tesss") {
          trace();
        }
        
        combinedWidth             = 0;
        
        for(ix = 0; ix < _itemsLeft.length; ix++) {
          if(_itemsLeft[ix] is FeathersControl) {
            //if(_itemsLeft[ix].isInvalid())
            //_itemsLeft[ix].invalidate();
            _itemsLeft[ix].validate();
            _itemsLeft[ix].name
          }
          
          if(_itemsLeft[ix].name == "ab"){
            _itemsLeft[ix].width
            _itemsLeft[ix].height
            trace();
          }
          
          combinedWidth          += _itemsLeft[ix].width + _gap;
        }
        
        combinedWidth            -= _gap;
        
        if(id == "tesss") {
          _itemsLeft[1].height;
        }

        
        // we counted one gap too many
        
        arW                       = (_leftItemsPercentWidth * width) / combinedWidth;
        
        
        posX                      = paddingLeft;
        
        for(ix = 0; ix < _itemsLeft.length; ix++) {
          
          ar                      = Math.min((h/_itemsLeft[ix].height)*leftItemsPercentHeight, arW);
          
          _itemsLeft[ix].height   = _itemsLeft[ix].height * ar;
          _itemsLeft[ix].width    = _itemsLeft[ix].width  * ar;
          
          if(_itemsLeft[ix] is IFeathersControl)
            _itemsLeft[ix].validate();
          
          _itemsLeft[ix].x        = posX;
          _itemsLeft[ix].y        = (h - _itemsLeft[ix].height) / 2;
          posX                    = _itemsLeft[ix].x + _itemsLeft[ix].width + _gap;
        } 
      }
      
      /**
       * right items
       */
      if(this.isInvalid(INVALIDATION_FLAG_RIGHT_ITEMS) || isInvalid(INVALIDATION_FLAG_SIZE)) 
      {
        combinedWidth             = 0;
        
        
        for(ix = 0; ix < _itemsRight.length; ix++) {
          if(_itemsRight[ix] is FeathersControl)
            //if(_itemsRight[ix].isInvalid())
            _itemsRight[ix].validate();
          combinedWidth          += _itemsRight[ix].width + _gap;
        }
        
        // we counted one gap too many
        combinedWidth            -= _gap;
        arW                       = (_rightItemsPercentWidth * width) / combinedWidth;
        
        
        posX                      = width - paddingRight;
        
        for(ix = 0; ix < _itemsRight.length; ix++) {
          ar                        = Math.min((h/_itemsRight[ix].height)*rightItemsPercentHeight, arW); // add here percent hright per object
          
          _itemsRight[ix].height  = _itemsRight[ix].height * ar;
          _itemsRight[ix].width   = _itemsRight[ix].width  * ar;
          if(_itemsRight[ix] is IFeathersControl)
            _itemsRight[ix].validate();
          
          _itemsRight[ix].x       = (posX - _itemsRight[ix].width);
          _itemsRight[ix].y       = (h - _itemsRight[ix].height) / 2;
          posX                    = _itemsRight[ix].x - ( _gap);
        }
      }
      
      /**
       * center items
       */
      if(this.isInvalid(INVALIDATION_FLAG_CENTER_ITEMS) || isInvalid(INVALIDATION_FLAG_SIZE)) 
      {
        combinedWidth               = 0;
        
        maxHeightItem               = 0;
        
        for(ix = 0; ix < _itemsCenter.length; ix++) {
          
          if(_itemsCenter[ix] is FeathersControl)
            //if(_itemsCenter[ix].isInvalid())
            _itemsCenter[ix].validate();
          
          if(_itemsCenter[ix].name == "medicine") {
            _itemsCenter[ix].width;
            _itemsCenter[ix].height;
            trace();  
          }
          
          combinedWidth            += _itemsCenter[ix].width + _gap;
        }
        
        
        // we counted one gap too many
        combinedWidth              -= _gap;
        arW                         = (_centerItemsPercentWidth * width) / combinedWidth;
        
        ar                          = Math.min((h/maxHeightItem)*centerItemsPercentHeight, arW);
        
        posX                        = 0;
        combinedWidth               = 0;
        
        for(ix = 0; ix < _itemsCenter.length; ix++) {
          
          ar                        = Math.min((h/_itemsCenter[ix].height)*centerItemsPercentHeight, arW);
          
          _itemsCenter[ix].height   = _itemsCenter[ix].height * ar;
          _itemsCenter[ix].width    = _itemsCenter[ix].width  * ar;
          if(_itemsCenter[ix] is IFeathersControl)
            _itemsCenter[ix].validate();
          
          _itemsCenter[ix].x        = posX;
          _itemsCenter[ix].y        = (h - _itemsCenter[ix].height) / 2;
          
          posX                     += _itemsCenter[ix].width + _gap;
        }
        
        combinedWidth               = posX - _gap*ar;
        posX                        = (width - combinedWidth)*0.5;
        
        for(ix = 0; ix < _itemsCenter.length; ix++) {
          _itemsCenter[ix].x       += posX;
        }
      }
      
      //super.height                  = actualHeight                = h;
      
      if(_btnMode) {
        _btnMode.width              = width;
        _btnMode.height             = height;
      }
      
    }
    
    private function onChange(event:Event):void
    {
      trace("selected: " + (event.currentTarget as DisplayObject).name);  
      
      var id:String = (event.currentTarget as DisplayObject).name;
      
      if(_onSelected is Function)
        _onSelected(id);
      
      dispatchEventWith(Event.TRIGGERED, false, id);
      
    }
    
    /**
     * remove previous items and dispose them and their references, and
     * commit a new data provider
     */
    private function commitItems():void
    {
      if(_dataProvider == null)
        return;
      
      removeChildren(1, -1, true);
      
      _itemsLeft.length               = 0;
      _itemsCenter.length             = 0;
      _itemsRight.length              = 0;
      
      for(var ix:uint = 0; ix < _dataProvider.length; ix++)
      {
        var dobj: DisplayObject       = _dataProvider[ix].src;
        
        // applicable if dobj is Button
        dobj.addEventListener(Event.TRIGGERED, onChange);
        
        if(_dataProvider[ix].id)
          dobj.name                     = _dataProvider[ix].id;
        switch(_dataProvider[ix].align) {
          case "right":
            _itemsRight.push(dobj);
            break;
          case "left":
            _itemsLeft.push(dobj);
            break;
          case "center":
            _itemsCenter.push(dobj);
            break;
        }
        addChild(dobj);
      }
    }
    
    private function btnMode_onTriggered(event:Event):void
    {
      dispatchEventWith(Event.TRIGGERED, false);
    }
    
  }
  
}