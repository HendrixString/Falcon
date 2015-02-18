package com.hendrix.feathers.controls.flex.flexTabBar
{ 
  import com.hendrix.feathers.controls.CompsFactory;
  
  import feathers.controls.Button;
  import feathers.core.FeathersControl;
  
  import starling.display.DisplayObject;
  import starling.display.Quad;
  import starling.events.Event;
  
  /**
   * <p>a very lite Tab Bar component, requires a data provider</p>
   * @param $dataProvider the data provider object
   * <p><b>Example:</b><br>
   *        <code>
   *      _dataProvier = Vector.Object([<br>
   *        { id: "1", textureUp: _bm_btn_contact_up, textureDown: _bm_btn_contact_dwn},<br>
   *        { id: "2", textureUp: _bm_btn_contact_up, textureDown: _bm_btn_contact_dwn},<br>
   *        { id: "3", textureUp: _bm_btn_contact_up, textureDown: _bm_btn_contact_dwn},<br>
   *        { id: "4", textureUp: _bm_btn_contact_up, textureDown: _bm_btn_contact_dwn}<br>
   *      ]);</code><br>
   * <b>Notes:</b>
   * <code>textureDown, textureUp</code> can be anything: texture id from the GFXManager, class, bitmapdata, or a texture<br>
   * use bgSkin setter to set a background skin source
   * </p> 
   * @author Tomer Shalev
   */
  public class FlexTabBar extends FeathersControl
  {
    private var _btns:                  Vector.<Button> = null;
    
    protected var _dataProvider:        Vector.<Object> = null
    
    private var _gap:                   uint            = 0;
    private var _paddingRight:          uint            = 0;
    private var _paddingLeft:           uint            = 0;
    private var _percentHeight:         Number          = 0.11;
    
    private var _bgSkin:                DisplayObject   = null;
    protected var _bgSkinSource:        Object          = null;
    
    private var _onSelected:            Function        = null;
    
    /**
     * <p>a very lite Tab Bar component, requires a data provider</p>
     * @param $dataProvider the data provider object
     * <p><b>Example:</b><br>
     *        <code>
     *      _dataProvier = Vector.Object([<br>
     *        { id: "1", textureUp: _bm_btn_contact_up, textureDown: _bm_btn_contact_dwn},<br>
     *        { id: "2", textureUp: _bm_btn_contact_up, textureDown: _bm_btn_contact_dwn},<br>
     *        { id: "3", textureUp: _bm_btn_contact_up, textureDown: _bm_btn_contact_dwn},<br>
     *        { id: "4", textureUp: _bm_btn_contact_up, textureDown: _bm_btn_contact_dwn}<br>
     *      ]);</code><br>
     * <b>Notes:</b>
     * <code>textureDown, textureUp</code> can be anything: texture id from the GFXManager, class, bitmapdata, or a texture<br>
     * use bgSkin setter to set a background skin source
     * </p> 
     * @author Tomer Shalev
     */
    public function FlexTabBar($dataProvider:Vector.<Object> = null)
    {
      super();
      
      _dataProvider = $dataProvider;
    }
    
    public function get dataProvider():                       Vector.<Object> { return _dataProvider;   }
    public function set dataProvider(value:Vector.<Object>):  void            { _dataProvider = value;  }
    
    public function get gap():                                uint            { return _gap;            }
    public function set gap(value:uint):                      void            { _gap = value;           }
    
    public function get paddingRight():                       uint            { return _paddingRight;   }
    public function set paddingRight(value:uint):             void            { _paddingRight = value;  }
    
    public function get paddingLeft():                        uint            { return _paddingLeft;    }
    public function set paddingLeft(value:uint):              void            { _paddingLeft = value;   }
    
    
    /**
     * callback function signature function($id:String) 
     * @param value callback function
     */
    public function set onSelected(value:Function):           void            { _onSelected = value;    }
    
    /**
     * set a background skin source: class, texture id from GFXmanager, color
     * @param value source object
     */
    public function get bgSkin():                             Object          { return _bgSkin;   }
    public function set bgSkin(value:Object):                 void            
    { 
      _bgSkinSource = value;
    }
    
    public function get percentHeight():                      Number          { return _percentHeight;  }
    public function set percentHeight(value:Number):          void            
    { 
      _percentHeight = value;
      if(_percentHeight > 1)
        _percentHeight /= 100;
    }
    
    override public function dispose():void
    {
      super.dispose();
      
      _onSelected           = null;
      
      _btns.length          = 0;
      _dataProvider.length  = 0;
      
      _btns                 = null;
      
      _bgSkin               = null;
      _bgSkinSource         = null;
      
      if(_dataProvider) {
        _dataProvider.length = 0;
      }
      
    }
    
    override protected function initialize():void
    {
      super.initialize();
      
      if(_bgSkinSource is uint)
        _bgSkin = new Quad(1,1,uint(_bgSkinSource));
      else
        _bgSkin                       = CompsFactory.newImage(_bgSkinSource);
      
      addChild(_bgSkin);
      
      _btns                         = new Vector.<Button>();
      
      for(var ix:uint = 0; ix < _dataProvider.length; ix++)
      {
        var btn:  Button            = CompsFactory.newButton(_dataProvider[ix].textureDown, _dataProvider[ix].textureUp, onBtnTriggered);
        btn.name                    = _dataProvider[ix].id;
        _btns.push(btn);
        addChild(btn);
      }
    }
    
    override protected function draw():void
    {
      super.draw();
      
      var h:uint                  = _bgSkin.height  = _percentHeight*parent.height;
      var w:uint                  = _bgSkin.width = width;
      
      var combinedTabsWidth:uint  = w - ((_btns.length - 1)*_gap + _paddingLeft + _paddingRight);
      // cell width size
      var cellWidth:  Number      = combinedTabsWidth / _btns.length;
      
      var arW:Number              = Infinity;
      
      for(var ix:uint = 0; ix < _btns.length; ix++)
      {
        arW                       = Math.min(arW, cellWidth / _btns[ix].defaultSkin.width );
      }
      
      var arH:Number              = h / _btns[0].upSkin.height;
      
      var ar:Number               = Math.min(arW, arH);
      
      var pos:Number              = 0;
      for(ix = 0; ix < _btns.length; ix++)
      {
        pos                       = _paddingLeft + ix*(cellWidth + _gap);
        
        _btns[ix].width           = _btns[ix].defaultSkin.width   * ar;
        _btns[ix].height          = _btns[ix].defaultSkin.height  * ar;
        _btns[ix].x               = pos + (cellWidth - _btns[ix].width) / 2;
        
      }
      
      height                      = actualHeight = _btns[0].height;
    }
    
    private function onBtnTriggered(ev:Event):void
    {
      trace("btn Id: " + (ev.currentTarget as Button).name);  
      if(_onSelected is Function)
        _onSelected((ev.currentTarget as Button).name);
    }
    
  }
}