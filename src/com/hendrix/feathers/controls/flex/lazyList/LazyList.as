package com.hendrix.feathers.controls.flex.lazyList
{
  import com.hendrix.collection.poolManager.PoolManager;
  import com.hendrix.collection.poolManager.core.Pool;
  import com.hendrix.feathers.controls.core.imageStreamer.ImageStreamer;
  import com.hendrix.feathers.controls.flex.FlexList;
  
  import flash.display.BitmapData;
  import flash.utils.getQualifiedClassName;
  
  import feathers.controls.renderers.IListItemRenderer;
  import feathers.events.FeathersEventType;
  
  import starling.events.Event;
  
  /**
   * <p>a LazyList component, that uses ImageStreamer. but this is not it's main feature</p>
   * <b>Notes:</b>
   * <ul>
   * <li>uses a fixed itemrenderers pool as a factory to avoid Feathers' retardation with dynamic dimensions items, just don't forget<br>
   *     to override the <code>itemrenderer.dispose()</code> method and do only 
   * <listing>(owner as LazyList).poolIR.releaseItem(this)</listing>, do not call <code>super.dispose()</code> at the itemrenderer</li>
   * <li>from item renderer get a refernce to <code>this.imageStreamer</code> and add a listener to the streamer to recieve updates.</li>
   * <li>you can config the streamer through <code>this.cacheSize, this.poolBitmapLoadersSize</code></li>
   * <li>you can config the item renderers pool with <code>this.itemRendererPoolClassType, this.itemRendererPoolSize</code>, experiment yourself with<br>
   * <code>this.itemRendererPoolSize</code>, if you have a minHeight proportionally to the owner than you can know the maximum number of item renderers needed in the pool.
   * </li>
   * <li>you can implement yourself's LazyList with just having a reference to an <code>ImageStreamer</code> object</li>
   * </ul>
   * </p> 
   * @author Tomer Shalev
   */
  public class LazyList extends FlexList
  {
    private var _poolManager:                       PoolManager   = null;
    private var _imageStreamer:                     ImageStreamer = null;
    private var _cacheSize:                         uint          = 0;
    private var _poolBitmapLoadersSize:             uint          = 0;
    
    private var _itemRendererPoolClassType:         Class         = null;
    private var _itemRendererPoolSize:              uint          = 0;
    
    private var _flagManageDispose:                 Boolean       = true;
    
    private var _poolIR:                            Pool          = null;
    
    /**
     * 
     * @param $flagManageDispose do not let Feathers manage dispose, this is good if you want the list
     * to stay at RAM, for example a static list. since if it is static, then items renderers in the pool
     * should not be released because they are allready managed by Feathers, since Feathers does not know 
     * it is not disposed. THIS WILL CHANGE OFCOURSE ONCE I ADD A CACHE MANAGER SINGELTON. FOR NOW THIS LAZYLIST
     * SUPPORTS STATIC LAZY LIST.
     * 
     */
    public function LazyList($flagManageDispose:Boolean = true)
    {
      super();
      
      _flagManageDispose    = $flagManageDispose;
      
      _imageStreamer        = new ImageStreamer();
      _poolManager          = PoolManager.instance;
      
      this.addEventListener( FeathersEventType.RENDERER_ADD, list_rendererAddHandler );
      this.addEventListener( FeathersEventType.RENDERER_REMOVE, list_rendererRemoveHandler );
      //this.addEventListener( Event.CHANGE, list_changeHandler );
    }
    
    public function get poolIR():Pool
    {
      return _poolIR;
    }
    
    private function factory():IListItemRenderer
    {
      var item:IListItemRenderer = _poolIR.requestItem() as IListItemRenderer;
      
      if(item == null)
        return null;
      
      return item;
    }
    
    public function checkImagAvailability($id:String): Boolean
    {
      return _imageStreamer.checkImagAvailability($id);
    }
    
    /**
     * request a bitmap, if it is chached in RAM it will be returned, if src is provided than this will change behaviour into
     * downloading the image if it is not cached already. 
     * @param $id the id of the image
     * @param $src the src - optional
     * @return bitmapdata
     * 
     */
    public function requestBitmap($id:String, $src:String = null):BitmapData
    {
      return _imageStreamer.requestBitmap($id, $src);
    }
    
    /**
     * <li> Free all the bitmap loaders for future usage. 
     * <li> TODO: Free cache is optional. 
     * 
     */
    public function resetLazyList():void
    {
      //_imageStreamer.reset();     
      _imageStreamer.cleanCache();      
    }
    
    override public function dispose():void
    {
      resetLazyList();
      
      if(_flagManageDispose == true)
        return;
      
      super.dispose();
      
      _imageStreamer.dispose();
      // dispose
      
      var size:   uint                  = _poolIR.itemsCount;
      
      var items:  Vector.<Object> = _poolIR.itemsAll;
      
      var ir:Object;
      for(var ix:uint = 0; ix < size; ix++) {
        ir = items[ix];
        ir.kill();
        _poolIR.releaseItem(ir);
      }
      
      _poolManager.disposePool(getQualifiedClassName(_itemRendererPoolClassType));
    }
    
    /**
     * the requested pool size for item renderers 
     */
    public function get itemRendererPoolSize():                 uint          { return _itemRendererPoolSize;       }
    public function set itemRendererPoolSize(value:uint):       void
    {
      if(_itemRendererPoolSize != 0)
        return;
      
      _itemRendererPoolSize = value;
    }
    
    /**
     * the item renderer class type for the pool 
     */
    public function get itemRendererPoolClassType():            Class         { return _itemRendererPoolClassType;  }
    public function set itemRendererPoolClassType(value:Class): void
    {
      if(_itemRendererPoolClassType != null)
        return;
      
      _itemRendererPoolClassType  = value;
      
      itemRendererType            = null;
      itemRendererFactory         = factory;
    }
    
    /**
     * the requested pool size for BitmapLoaders 
     */
    public function get poolBitmapLoadersSize():                uint          { return _poolBitmapLoadersSize;      }
    public function set poolBitmapLoadersSize(value:uint):      void
    {
      if(_poolBitmapLoadersSize != 0)
        return;
      
      _poolBitmapLoadersSize  = value;
      
      _imageStreamer.poolBitmapLoadersSize  = _poolBitmapLoadersSize;
    }
    
    /**
     * the requested cache size 
     */
    public function get cacheSize():                            uint          { return _cacheSize;                  }
    public function set cacheSize(value:uint):                  void  
    {
      if(_cacheSize != 0)
        return;
      _cacheSize                = value;
      
      _imageStreamer.cacheSize  = _cacheSize;
    }
    
    public function get flagManageDispose():                    Boolean       { return _flagManageDispose;  }
    public function set flagManageDispose(value:Boolean):       void
    {
      _flagManageDispose = value;
    }
    
    public function get imageStreamer():                        ImageStreamer { return _imageStreamer;      }
    
    override protected function initialize():void
    {
      super.initialize();
      
      if(_poolIR == null) {
        _poolIR                     = _poolManager.registerNewPool(getQualifiedClassName(_itemRendererPoolClassType), _itemRendererPoolClassType, null, _itemRendererPoolSize);
        _poolIR.initPool();
      }
      
      if(_cacheSize == 0)
        cacheSize                   = 1;
      
      if(_poolBitmapLoadersSize ==  0)
        poolBitmapLoadersSize       = 1;
      
    }
    
    protected function list_rendererAddHandler( event:Event, itemRenderer:IListItemRenderer ):void
    {
      trace("added item Renderer: " + itemRenderer.index);
    }
    
    protected function list_rendererRemoveHandler( event:Event, itemRenderer:IListItemRenderer ):void
    {
      trace("removed item Renderer: " + itemRenderer.index);
    }
    
    protected function list_changeHandler( event:Event ):void
    {
      trace( "selectedIndex:", this.selectedIndex );
    }
    
    protected function itemRenderer_triggeredHandler( event:Event ):void
    {
      var itemRenderer:IListItemRenderer = IListItemRenderer( event.currentTarget );
    }
    
  }
  
}