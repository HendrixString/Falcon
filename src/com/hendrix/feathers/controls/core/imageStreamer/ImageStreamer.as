package com.hendrix.feathers.controls.core.imageStreamer
{
  import com.hendrix.collection.cache.CircularCache;
  import com.hendrix.collection.cache.core.interfaces.ICache;
  import com.hendrix.collection.poolManager.PoolManager;
  import com.hendrix.collection.poolManager.core.Pool;
  import com.hendrix.feathers.controls.core.imageStreamer.content.BitmapLoader;
  
  import flash.display.BitmapData;
  import flash.utils.Dictionary;
  import flash.utils.getQualifiedClassName;
  
  import starling.events.EventDispatcher;
  
  /**
   * Image streamer, manages bitmap requests with a fixed circular cache that manages disposal
   * of unused bitmaps. very efficient and simple. can be used to implement a lazy list.
   * uses a pool of bitmap loaders
   * @author Tomer Shalev
   * 
   */
  public class ImageStreamer extends EventDispatcher
  {
    public static const IMAGESTREAMER_CACHE_UPDATE:   String      = 'IMAGESTREAMER_CACHE_UPDATE';
    
    public static var instanceCounts:                 uint        = 0;
    
    private var _poolManager:                         PoolManager = null;
    private var _blPool:                              Pool        = null;
    private var _bdCache:                             ICache      = null;
    private var _pendingSet:                          Dictionary  = null;
    
    private var _cacheSize:                           uint        = 0;
    private var _poolBitmapLoadersSize:               uint        = 0;
    
    private var _resizedWidth:                        uint        = 0;  
    
    /**
     * Image streamer, manages bitmap requests with a fixed circular cache that manages disposal
     * of unused bitmaps. very efficient and simple. can be used to implement a lazy list
     * @author Tomer Shalev
     * 
     */
    public function ImageStreamer()
    {
      super();
      
      _poolManager          = PoolManager.instance;
      _pendingSet           = new Dictionary();
      
      instanceCounts       += 1;
    }
    
    /**
     * check if image with id is available in cache 
     */
    public function checkImagAvailability($id:String): Boolean
    {
      // check first if it was loaded
      if(_bdCache.getCachedItemById($id) == null)
        return false;
      
      // chack in the pool maybe it is loading
      if(_pendingSet[$id] === undefined)
        return false;
      
      return true;
    }
    
    /**
     * is image pending download 
     */
    public function isImagePending($id:String):Boolean
    {
      if(_pendingSet[$id] === undefined)
        return false;
      
      return true;
    }
    
    /**
     * is image pending cached 
     */
    public function isImageCached($id:String):Boolean
    {
      var obj:Object = _bdCache.getCachedItemById($id);
      
      if(_bdCache.getCachedItemById($id) == null)
        return false;
      
      return true;
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
      if(isImageCached($id)) {
        var obj:  Object    = _bdCache.getCachedItemById($id);
        
        return _bdCache.getCachedItemById($id).data as BitmapData;
      }
      
      if(isImagePending($id))
        return null;
      
      if($src == null)
        return null;
      
      var bl: BitmapLoader  = _blPool.requestItem() as BitmapLoader;
      
      if(bl == null)
        return null;
      
      bl.src                = $src;
      bl.id                 = $id;
      
      _pendingSet[bl.id]    = true;
      
      bl.process(bitmapLoader_onComplete);
      
      return null;
    }
    
    /**
     * reset streamer 
     */
    public function reset():void
    {
      var size:   uint            = _blPool.itemsCount;
      
      var items:  Vector.<Object> = _blPool.itemsAll;
      
      var obj:BitmapLoader;
      
      for(var ix:uint = 0; ix < size; ix++) {
        obj                       = items[ix]; 
        
        obj.stop();
        
        _blPool.releaseItem(obj);
      }
      
      for (var key:String in _pendingSet)
      {
        delete _pendingSet[key];
      }
      
      _bdCache.clean();
    }
    
    /**
     * clean the cache 
     */
    public function cleanCache():void
    {
      _bdCache.clean();
    }
    
    /**
     * dispose the streamer
     */
    public function dispose():void
    {
      reset();
      
      _pendingSet                 = null;
      
      // dispose
      
      var size:   uint            = _blPool.itemsCount;
      
      var items:  Vector.<Object> = _blPool.itemsAll;
      
      var obj:BitmapLoader;
      for(var ix:uint = 0; ix < size; ix++) {
        obj                       = items[ix]; 
        
        obj.stop();
        obj.dispose();      
      }
      
      obj                         = null;
      
      _poolManager.disposePool("BitmapLoaderPool" + "_" + instanceCounts);
      
      // dispose cache
      
      _bdCache.dispose();
    }
    
    /**
     * the requested pool size for BitmapLoaders 
     */
    public function get poolBitmapLoadersSize():                uint    { return _poolBitmapLoadersSize;      }
    public function set poolBitmapLoadersSize(value:uint):      void
    {
      if(_poolBitmapLoadersSize != 0)
        return;
      
      _poolBitmapLoadersSize  = value;
      
      // make sure bitmaploaders are unique.
      _blPool                 = _poolManager.registerNewPool("BitmapLoaderPool" + "_" + instanceCounts, BitmapLoader, null, _poolBitmapLoadersSize);
      _blPool.initPool();
    }
    
    /**
     * the requested cache size 
     */
    public function get cacheSize():                            uint    { return _cacheSize;                  }
    public function set cacheSize(value:uint):                  void  
    {
      if(_cacheSize != 0)
        return;
      
      _cacheSize    = value;
      
      _bdCache      = new CircularCache(_cacheSize);
    }
    
    /**
     * resized width of downloaded images 
     */
    public function get resizedWidth():                         uint    { return _resizedWidth; }
    public function set resizedWidth(value:uint):               void
    {
      _resizedWidth                                         = value;
      
      var blCount:  uint                                    = _blPool.itemsAll.length;
      
      for(var ix:uint = 0; ix < blCount; ix++)
      {
        (_blPool.itemsAll[ix] as BitmapLoader).resizedWidth = _resizedWidth;
      }
    }
    
    private function bitmapLoader_onComplete($bl:BitmapLoader = null):void
    {
      if($bl.bitmap == null) {
        trace("bitmap loader failed");
      }
      else {
        _bdCache.cacheItemWith($bl.id, $bl.bitmap, $bl.bitmap.dispose);
      }
      
      delete _pendingSet[$bl.id];
      
      _blPool.releaseItem($bl);
      
      dispatchEventWith(ImageStreamer.IMAGESTREAMER_CACHE_UPDATE, false, $bl.id);
    }
    
  }
  
}