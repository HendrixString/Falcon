package com.hendrix.feathers.controls.flex.flexTabBar
{
  import com.hendrix.feathers.controls.CompsFactory;
  import com.hendrix.feathers.controls.flex.FlexButton;
  import com.hendrix.feathers.controls.flex.HGroup;
  
  /**
   * a very lite and fast TabBar HGroup like Flex, but used only with a dataprovider<br>
   * <p><b>Example:</b><br>
   * use <code>this.dataProvider</code> for layout sruff, the reason we use it is that because non of feather or starling and Feathers<br>
   * comps come with these basic and useful layout/sizing properties<br>
   * <code>
   *      this.dataProvier = Vector.Object([<br>
   *        { id: "1", texUp: t1, texDown: t2},<br>
   *        { id: "2", texUp: t3, texDown: t4},<br>
   *        { id: "3", texUp: t5, texDown: t6},<br>
   *      ]);</code><br>
   * <b>Notes:</b>
   * <ul>
   * <li> use <code>this.backgroundSkin</code> have a background skin that stretches.
   * <li> use <code>this.onSelected</code> callback to listen on button clicks.
   * <li> can only be used with a data provider for now.
   * </ul>
   * <b>TODO:</b>
   * <ul>
   * <li> interface for updating data.
   * </ul>
   * @author Tomer Shalev
   * 
   */
  public class FlexTabBarC extends HGroup
  {
    private var _dataProviderNew:Vector.<Object> = null;
    
    /**
     * a very lite and fast TabBar HGroup like Flex, but used only with a dataprovider<br>
     * <p><b>Example:</b><br>
     * use <code>this.dataProvider</code> for layout sruff, the reason we use it is that because non of feather or starling and Feathers<br>
     * comps come with these basic and useful layout/sizing properties<br>
     * <code>
     *      this.dataProvier = Vector.Object([<br>
     *        { id: "1", texUp: t1, texDown: t2},<br>
     *        { id: "2", texUp: t3, texDown: t4},<br>
     *        { id: "3", texUp: t5, texDown: t6},<br>
     *      ]);</code><br>
     * <b>Notes:</b>
     * <ul>
     * <li> use <code>this.backgroundSkin</code> have a background skin that stretches.
     * <li> use <code>this.onSelected</code> callback to listen on button clicks.
     * <li> can only be used with a data provider for now.
     * </ul>
     * <b>TODO:</b>
     * <ul>
     * <li> interface for updating data.
     * </ul>
     * @author Tomer Shalev
     * 
     */
    public function FlexTabBarC()
    {
      super();
      
      stickyButtons = true;
    }
    
    override public function dispose():void
    {
      super.dispose();
      
      if(_dataProviderNew) {
        _dataProviderNew.length = 0;
        _dataProviderNew        = null
      }
      
    }
    
    override public function get dataProvider():                      Vector.<Object> { return _dataProviderNew; }
    override public function set dataProvider(value:Vector.<Object>): void
    {
      _dataProviderNew          = value;
      
      var count:    uint        = _dataProviderNew.length;
      var uniformW: Number      = 100/count;
      var btn:      FlexButton  = null;
      
      for(var ix: uint = 0; ix < count; ix++)
      {
        btn                   = new FlexButton();
        btn.downIcon          = CompsFactory.newImage(_dataProviderNew[ix].texDown);
        btn.defaultIcon       = btn.upIcon  = CompsFactory.newImage(_dataProviderNew[ix].texUp);
        btn.percentWidth      = uniformW;
        btn.percentHeight     = 100;
        btn.iconPercentHeight = 1;
        btn.id                = btn.name = _dataProviderNew[ix].id;
        addChild(btn);
      }
      
    }
    
  }
  
}