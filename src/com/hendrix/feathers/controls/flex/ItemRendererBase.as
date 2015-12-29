package com.hendrix.feathers.controls.flex
{
  
  import feathers.controls.List;
  import feathers.controls.renderers.IListItemRenderer;
  
  import starling.events.Event;
  
  /**
   * a basic implementation of <code>IListItemRenderer</code> as a Flex control
   * 
   * @author Tomer Shalev
   * 
   */
  public class ItemRendererBase extends FlexComp implements IListItemRenderer
  {
    protected var _data:        Object  = null;
    protected var _owner:       List    = null;
    protected var _isSelected:  Boolean = false;
    protected var _index:       int     = -1;
    
    /**
     * a basic implementation of <code>IListItemRenderer</code> as a Flex control
     * @author Tomer Shalev
     * 
     */
    public function ItemRendererBase()
    {
      super();
    }
    
    /**
     * @inheritDoc 
     */
    public override function get data():                     Object  { return this._data;  }
    /**
     * @inheritDoc 
     */
    public override function set data(value:Object):         void
    {
      if(this._data == value)
      {
        return;
      }
      this._data = value;
      this.invalidate(INVALIDATION_FLAG_DATA);
    }
    
    /**
     * @inheritDoc 
     */
    public function get index():                    int     { return this._index; }
    /**
     * @inheritDoc 
     */
    public function set index(value:int):           void
    {
      if(this._index == value)
      {
        return;
      }
      this._index = value;
      this.invalidate(INVALIDATION_FLAG_DATA);
    }
    
    /**
     * @inheritDoc 
     */
    public function get owner():                    List    { return List(this._owner); }
    /**
     * @inheritDoc 
     */
    public function set owner(value:List):          void
    {
      if(this._owner == value)
      {
        return;
      }
      this._owner = value;
      this.invalidate(INVALIDATION_FLAG_DATA);
    }
    
    /**
     * indicates selection 
     */
    public function get isSelected():               Boolean { return this._isSelected;  }
    /**
     * indicates selection 
     */
    public function set isSelected(value:Boolean):  void
    {
      if(this._isSelected == value)
      {
        return;
      }
      this._isSelected = value;
      this.invalidate(INVALIDATION_FLAG_SELECTED);
      this.dispatchEventWith(Event.CHANGE);
    }
    
    public function get factoryID():String
    {
      // TODO Auto Generated method stub
      return null;
    }
    
    public function set factoryID(value:String):void
    {
      // TODO Auto Generated method stub
      
    }
    
  }
  
}