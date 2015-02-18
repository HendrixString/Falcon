package com.hendrix.feathers.controls.widgets
{
  import com.hendrix.collection.common.interfaces.IDisposable;
  
  import feathers.controls.List;
  import feathers.events.FeathersEventType;
  
  import starling.events.Event;
  import starling.textures.Texture;
  
  /**
   * a List update widget with callback for top and bottom refresh requests,
   * with appropriate animations 
   * @author Tomer
   * 
   */
  public class ListUpdateWidget implements IDisposable
  {
    /**
     * loader animation for top refresh  
     */
    private var _loaderAnimTop:           SimpleLoader  = null;
    /**
     * loader animation for bottom refresh  
     */
    private var _loaderAnimBottom:        SimpleLoader  = null;
    
    private var _list:                    List          = null;
    
    private var _padding:                 Number        = 12;
    
    private var _flagRequestedBottom:     Boolean       = false;    
    private var _flagRequestedTop:        Boolean       = false;
    private var _isPulled:                Boolean       = false;
    private var _isReleased:              Boolean       = false;
    private var _isLoading:               Boolean       = false;    
    private var _isDisabled:              Boolean       = false;
    
    /**
     * callback for refresh top request
     */
    public var onRefreshRequestedTop:     Function      = null;
    /**
     * callback for refresh bottom request
     */
    public var onRefreshRequestedBottom:  Function      = null;
    
    public function dispose():void
    {
      onRefreshRequestedBottom  = null;
      onRefreshRequestedTop     = null;
      
      _loaderAnimTop.animateStop();
      
      _loaderAnimTop            = null;
      
      _list.removeChild(_loaderAnimTop, true);
      _list.removeChild(_loaderAnimBottom, true);
      
      _list.removeEventListener(Event.SCROLL, list_onScroll);
      _list.removeEventListener(FeathersEventType.END_INTERACTION, onEndInteract);
    }
    
    /**
     * a List update widget with callback for top and bottom refresh requests,
     * with appropriate animations 
     * @param $list the list to apply the widget on
     * @param $animationTop a SimpleLoader (animation) or Texture for top widget
     * @param $onRefreshRequestedTop callback for top refresh request
     * @param $animationBottom a SimpleLoader (animation) or Texture for top widget
     * @param $onRefreshRequestedBottom callback for bottom refresh request
     * 
     */
    public function ListUpdateWidget($list:List = null, $animationTop:Object = null, $onRefreshRequestedTop:Function = null, $animationBottom:Object = null, $onRefreshRequestedBottom:Function = null)
    {
      hookList($list);
      hookLoadingAnimationTop($animationTop);
      hookLoadingAnimationBottom($animationBottom);
      
      onRefreshRequestedTop     = $onRefreshRequestedTop;
      onRefreshRequestedBottom  = $onRefreshRequestedBottom;
    }
    
    /**
     * @param $list the list to apply the widget on 
     */
    public function hookList($list:List):void
    {
      if($list == null)
        return;
      
      _list = $list;
      
      if(!_isDisabled)
        _list.addEventListener(Event.SCROLL, list_onScroll);
      
      addLoadinAnimation();
    }
    
    /**
     * @param $list the list to apply the widget on 
     */
    public function hookLoadingAnimationTop($src:Object):void
    {
      if($src == null)
        return;
      
      if($src is SimpleLoader)
        _loaderAnimTop = $src as SimpleLoader;
      else if($src is Texture)
        _loaderAnimTop = new SimpleLoader($src as Texture);
      
      addLoadinAnimation();
    }
    
    /**
     * @param $src attach a SimpleLoader (animation) or Texture for bottom widget
     */
    public function hookLoadingAnimationBottom($src:Object):void
    {
      if($src == null)
        return;
      
      if($src is SimpleLoader)
        _loaderAnimBottom = $src as SimpleLoader;
      else if($src is Texture)
        _loaderAnimBottom = new SimpleLoader($src as Texture);
      
      addLoadinAnimation();
    }
    
    /**
     * stop the top widget 
     */
    public function stopLoaderTop():void
    {
      _isLoading        = false;
      _flagRequestedTop = false;
      
      _list.scrollToPosition(0,0, 0.6);
    }
    
    /**
     * stop the bottom widget 
     */
    public function stopLoaderBottom():void
    {
      _flagRequestedBottom = false;
    }
    
    /**
     * disable the widget 
     */
    public function disable():void
    {
      if(_list) {
        _list.removeEventListener(Event.SCROLL, list_onScroll);
        _list.removeEventListener(FeathersEventType.END_INTERACTION, onEndInteract);
      }
      
      if(_loaderAnimBottom)
        _loaderAnimBottom.animateStop();
      if(_loaderAnimTop)
        _loaderAnimTop.animateStop();
      
      _isDisabled = true;
    }
    
    /**
     * enable the widget 
     */
    public function enable():void
    {
      _list.addEventListener(Event.SCROLL, list_onScroll);
      
      _isDisabled = false;
    }
    
    /**
     * helper function for layout dimensions 
     */
    public function updateLoaderWidgetPercentWidth($percentWidth:Number):void
    {
      var ar:Number;
      
      if(_list == null)
        return;
      
      if(_loaderAnimTop) {
        ar                                    = _list.width * $percentWidth / _loaderAnimTop.width;
        _loaderAnimTop.width                 *= ar;
        _loaderAnimTop.height                *= ar;
      }
      
      if(_loaderAnimBottom)
      {
        ar                                    = _list.width * $percentWidth / _loaderAnimBottom.width;
        _loaderAnimBottom.width               *= ar;
        _loaderAnimBottom.height              *= ar;
        
        (_list.layout as Object).paddingBottom = _loaderAnimBottom.height + 2*_padding;
      }
    }
    
    private function addLoadinAnimation():void
    {
      if(_list == null)
        return;
      
      if(_loaderAnimTop && (_loaderAnimTop.parent!=_list)) {
        _list.addChild(_loaderAnimTop);
        _loaderAnimTop.visible = false;
      }
      
      if(_loaderAnimBottom && (_loaderAnimBottom.parent!=_list)) {
        _list.addChild(_loaderAnimBottom);
        _loaderAnimBottom.visible = false;
      }
      
    }
    
    private function list_onScroll(event:Event):void
    {
      if(_list.dataProvider == null)
        return
      
      if(_list.dataProvider.length == 0)
        return;
      
      if(_list.height == 0)
        return;
      
      //trace(_list.verticalScrollPosition )
      if(_loaderAnimTop)
      {
        if(_list.verticalScrollPosition < 0) 
        {
          _padding                        = _list.height * 0.018;
          
          _loaderAnimTop.visible          = true;
          var windowHeight:   Number      = Math.abs(_list.verticalScrollPosition);
          
          if(windowHeight >= _loaderAnimTop.heightOriginal + _padding*2)
            _loaderAnimTop.y              = windowHeight*0.5;
          else
            _loaderAnimTop.y              = windowHeight - _loaderAnimTop.heightOriginal / 2 - _padding;
          
          _loaderAnimTop.x                = _list.width * 0.5;
          
          if(_isReleased) {
            if(windowHeight <= _loaderAnimTop.heightOriginal + _padding * 2.2) 
            {
              _loaderAnimTop.animateLoading();
              _list.stopScrolling();
              
              //_feed.prevPageFeed(onPrevPageFeed);
              
              if(_flagRequestedTop == false) {
                _flagRequestedTop         = true
                if(onRefreshRequestedTop is Function)
                  onRefreshRequestedTop();
              }
              
              _isReleased = false;
            }
            return;
            
          }
          _isReleased = false;
          
          
          var residualHeight: Number    = Math.max(windowHeight - (_loaderAnimTop.heightOriginal + _padding), 0);
          
          var factor:         Number    = residualHeight / (_loaderAnimTop.heightOriginal*1);
          var rad:            Number    = Math.PI *  Math.min(1, factor);
          if(_isLoading == false)
          {
            if(factor > 1.1) {
              _isPulled = true;
              _list.addEventListener(FeathersEventType.END_INTERACTION, onEndInteract);
            }
            else {
              _isPulled = false;
              _list.removeEventListener(FeathersEventType.END_INTERACTION, onEndInteract);
            }
            _loaderAnimTop.rotation     = rad;
          }
          else {
            _loaderAnimTop.animateLoading();
          }
          
          //trace("residualHeight1 "+ _loaderAnim.height);
          //trace("residualHeight2 "+ windowHeight);
          
        }
        else {
          _loaderAnimTop.animateStop();
        }
        
      }
      
      if(_loaderAnimBottom) 
      {
        var listPaddingBottom:Number  = (_list.layout as Object).paddingBottom;
        
        if(_list.maxVerticalScrollPosition <= listPaddingBottom)
          return;
        
        var window:Number             = _list.verticalScrollPosition - (_list.maxVerticalScrollPosition + 0 ) + listPaddingBottom;
        
        //trace("window: " + window);
        //trace("verticalScrollPosition: " + _list.verticalScrollPosition);
        //trace("maxVerticalScrollPosition " +_list.maxVerticalScrollPosition);
        
        if(window >= 0) {
          _loaderAnimBottom.animateLoading();
          
          _loaderAnimBottom.x         = _list.width*0.5;;
          _loaderAnimBottom.y         = _list.height - window + _loaderAnimBottom.heightOriginal*0.5 + _padding;
          
          if(_flagRequestedBottom == false)
          {
            _flagRequestedBottom      = true;
            if(onRefreshRequestedBottom is Function)
              onRefreshRequestedBottom();
          }
          
          
        }
        else {
          //_flagRequestedBottom = false;
          _loaderAnimBottom.animateStop();
        }
        
      }
      
    }       
    
    private function onEndInteract(event:Event):void
    {
      _isReleased = true;
      _list.removeEventListener(FeathersEventType.END_INTERACTION, onEndInteract);
    }
    
  }
  
}