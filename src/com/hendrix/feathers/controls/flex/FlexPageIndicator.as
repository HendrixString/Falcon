package com.hendrix.feathers.controls.flex
{
  import feathers.controls.PageIndicator;
  import feathers.core.FeathersControl;
  import feathers.events.FeathersEventType;
  
  import starling.display.DisplayObject;
  
  /**
   * <p>a small extension for <code>PageIndicator</code> enabling the <code>gap</code> to be determined automatically with a max limit.
   * Extended only because <code>selectedSymbol</code> is protected.</p> 
   * 
   * <b>Notes</b>
   * 
   * <li>use <code>maxSymbolWidth</code> for determining the max width for a symbol</li>
   * <li>use <code>maxGap</code> for determining the max Gap between symbols</li>
   * <li>use <code>typicalSymbol</code> for indicating a symbol, and thus make <code>arTypicalSymbol</code> available for sizing inside the symbol factories</li>
   * <li>use <code>arTypicalSymbol</code> if <code>typicalSymbol</code> was setup already to get the aspect ratio</li>
   * 
   * <br><b>TODO:</b><br>
   * 
   * currently only supports horizontal direction, extends to vertical.
   * 
   * @author Tomer Shalev
   */
  public class FlexPageIndicator extends PageIndicator
  {
    private var _maxSymbolWidth:    Number;
    private var _maxGap:            Number;
    private var _typicalSymbol:     DisplayObject;
    private var _arTypicalSymbol:   Number        = 1;
    
    private var _relativeCalcWidthParent:   DisplayObject   = null;
    private var _relativeCalcHeightParent:  DisplayObject   = null;

    private var _isSensitiveToParent:       Boolean         = true;

    /**
     * <p>a small extension for <code>PageIndicator</code> enabling the <code>gap</code> to be determined automatically with a max limit.
     * Extended only because <code>selectedSymbol</code> is protected.</p> 
     * <b>Notes</b>
     * <li>use <code>maxSymbolWidth</code> for determining the max width for a symbol</li>
     * <li>use <code>maxGap</code> for determining the max Gap between symbols</li>
     * <li>use <code>typicalSymbol</code> for indicating a symbol, and thus make <code>arTypicalSymbol</code> available for sizing inside the symbol factories</li>
     * <li>use <code>arTypicalSymbol</code> if <code>typicalSymbol</code> was setup already to get the aspect ratio</li>
     * <br><b>TODO:</b><br>
     * currently only supports horizontal direction, extends to vertical.
     */
    public function FlexPageIndicator()
    {
      super();
    }
    
    override public function dispose():void
    {
      super.dispose();
      
      if(_typicalSymbol) {
        _typicalSymbol.dispose();
        _typicalSymbol = null;
      }
      
    }
    
    /**
     * use <code>maxSymbolWidth</code> for determining the max width for a symbol    * 
     */
    public function get maxSymbolWidth():                   Number        { return _maxSymbolWidth;   }
    public function set maxSymbolWidth(value:Number):       void          { _maxSymbolWidth = value;  }
    
    /**
     * <li>use <code>maxGap</code> for determining the max Gap between symbols</li>
     */
    public function get maxGap():                           Number        { return _maxGap;           }
    public function set maxGap(value:Number):               void          
    { 
      _maxGap = value;
      
      invalidate();
    }
    
    /**
     * use this to set a typical symbol, this will be used to calculate a correct and effective
     * aspect ratios for you to use with the symbol factories resizing.
     */
    public function get typicalSymbol():                    DisplayObject { return _typicalSymbol;    }
    public function set typicalSymbol(value:DisplayObject): void          
    { 
      _typicalSymbol = value;
      
      if(_typicalSymbol is FeathersControl)
        (_typicalSymbol as FeathersControl).validate();
    }
    
    /**
     * the aspect ratio of a typical symbol, useful for resizing efficiently and elgantly inside the symbol factories<br>
     * <b>Example:</b><br>
     * <listing version="3.0">
     * _pi.normalSymbolFactory = function():Image 
     * {
     * var img: Image = MrPoolManager.newImage("general::ss1.radio_btn_up");
     *  img.width = img.width*_pi.arTypicalSymbol;
     *  img.height = img.width;
     *  return img;
     * }</listing>
     * 
     */
    public function get arTypicalSymbol():                  Number        { return _arTypicalSymbol;  }
    
    override protected function initialize():void
    {
      super.initialize();
      
      if(_isSensitiveToParent) {
        var parentWidthDop:   DisplayObject = _relativeCalcWidthParent  ? _relativeCalcWidthParent  as DisplayObject : getValidAncestorWidth() as DisplayObject;
        var parentHeightDop:  DisplayObject = _relativeCalcHeightParent ? _relativeCalcHeightParent as DisplayObject : getValidAncestorHeight() as DisplayObject;

        if(parentHeightDop == parentWidthDop) {
        }
        else {
          if(parentHeightDop)
            parentHeightDop.addEventListener(FeathersEventType.RESIZE, onParentResized);
        }
        
        if(parentWidthDop)
          parentWidthDop.addEventListener(FeathersEventType.RESIZE, onParentResized);
        
      }

      direction                   = PageIndicator.DIRECTION_HORIZONTAL;
    }
    
    override protected function draw():void
    {
      //width = height = 5;
      if(_typicalSymbol) {
        var combinedWidth:  Number  = (_typicalSymbol.width)*pageCount;
        var ar1:            Number  = width*0.9 / combinedWidth;
        _arTypicalSymbol            = Math.min(maxSymbolWidth/_typicalSymbol.width, ar1);
      }
      else {
        _arTypicalSymbol = 1;
      }
      
      super.draw();
      
      gap = selectedSymbol ? Math.min((width - pageCount*selectedSymbol.width) / pageCount, _maxGap) : 0;
    }
    
    private function onParentResized():void
    {
      invalidate(INVALIDATION_FLAG_SIZE);
    }

    private function getValidAncestorHeight():DisplayObject
    {
      var validParent:  DisplayObject = parent;
      
      return validParent;
    }
    
    private function getValidAncestorWidth():DisplayObject
    {
      var validParent:  DisplayObject = parent;
      
      return validParent;
    }
   
  }
  
}