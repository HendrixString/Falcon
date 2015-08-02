package com.hendrix.feathers.controls.core
{
  import flash.utils.Dictionary;
  
  import feathers.controls.ScreenNavigator;
  import feathers.controls.ScreenNavigatorItem;
  import feathers.motion.transitions.ScreenSlidingStackTransitionManager;
    
  /**
   * extended ScreenNavigator that supports a history stack
   * @author Tomer
   * 
   */
  public class ExtScreenNavigator extends ScreenNavigator
  {
    protected var _screensVec:      Vector.<ScreenNavigatorItem>  = null;
    protected var _screensDic:      Dictionary                    = null;
    
    protected var _screenIdHistory: Vector.<String>               = null;
    
    protected var _navTransitionManager:ScreenSlidingStackTransitionManager = null;
    
    private var _onTransitionComplete:Function = null;
    
    public function ExtScreenNavigator()
    {
      super();
      
      _navTransitionManager           = new ScreenSlidingStackTransitionManager(this);
      _navTransitionManager.duration  = 0.3;
      
      _screensVec       = new Vector.<ScreenNavigatorItem>;
      _screensDic       = new Dictionary(true);
      
      _screenIdHistory  = new Vector.<String>();
    }

    override protected function transitionComplete(cancelTransition:Boolean = false): void
    {      
      super.transitionComplete(cancelTransition);
      
      if(_onTransitionComplete is Function)
        _onTransitionComplete();
    }
 
    /*
    override protected function feathersControl_addedToStageHandler(event:Event):void
    {
      super.feathersControl_addedToStageHandler(event);
      
      addEventListener(FeathersEventType.TRANSITION_COMPLETE, transitionComplete);
    }
    
    override protected function feathersControl_removedFromStageHandler(event:Event):void
    {
      super.feathersControl_removedFromStageHandler(event);

      removeEventListener(FeathersEventType.TRANSITION_COMPLETE, transitionComplete);
    }
    */    
    
    public function addScreenWithDetails(screen: Object, $id: String, props: Object = null, events: Object = null): ScreenNavigatorItem
    {
      var propsLocal:Object = new Object();
      propsLocal["id"]      = $id;
      
      var item: ScreenNavigatorItem = new ScreenNavigatorItem(screen, events, props);
      
      addScreen($id, item);

      return item;
    }
    
    override public function addScreen(id: String, item: ScreenNavigatorItem): void
    {
      super.addScreen(id, item);
      
      _screensVec.push(item);
      _screensDic[item] = id;
    }
    
    override public function removeScreen(id: String): ScreenNavigatorItem
    {
      var item: ScreenNavigatorItem = _screens[id];
      var ix: int = _screensVec.indexOf(item);
      
      if(ix)
        _screensVec.splice(ix, 1);
      
      delete _screensDic[item];
      
      return super.removeScreen(id);
    }
    
    override public function removeAllScreens(): void
    {
      clearScreen();
      
      var item: ScreenNavigatorItem = null;
      var id: String;
      while (item)
      {
        _screensVec.pop();
        delete _screens[_screensDic[item]];
        delete _screensDic[item];
      }
    }
    
    /**
     * 
     */    
    public function pushScreen($id:String, recordHistory:Boolean = true):void
    {
      if(recordHistory)
        _screenIdHistory.push(activeScreenID);

      showScreen($id);
    }
    
    public function previousScreen(): void
    {
      if(_screenIdHistory.length == 0)
        return;
      
      var prevId: String  = _screenIdHistory.pop();
      
      if(prevId == null)
        return;
      
      showScreen(prevId);
    }
    
    public function get pageIndex(): int
    {
      var pi: int = getScreenIndexById(activeScreenID);
      return pi;
    }
    
    public function getScreenNavigatorItemById($id:String):ScreenNavigatorItem
    {
      return _screensVec[getScreenIndexById($id)];
    }
    
    /**
     * 
     */
    
    public function getScreenIdByIndex($index: int): String
    {
      var sid: String = _screensDic[_screensVec[$index]];
      
      return sid;
    }
    
    public function getScreenIndexById($id: String): int
    {
      return _screensVec.indexOf(_screens[$id]);
    }
    
    public function get numScreens(): int {
      return _screensVec.length;
    }
    
    public function get onTransitionComplete():Function {return _onTransitionComplete;  }
    public function set onTransitionComplete(value:Function):void
    {
      if(_onTransitionComplete != null)
        throw new Error("MrScreenNavigator.onTransitionComplete() set error: currently this object supports only one listener, please extend it!!!")
      
      _onTransitionComplete = value;
    }
    
    public function get navTransitionManager():ScreenSlidingStackTransitionManager
    {
      return _navTransitionManager;
    }
    
  }
  
}