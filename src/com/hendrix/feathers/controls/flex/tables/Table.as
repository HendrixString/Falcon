package com.hendrix.feathers.controls.flex.tables
{
  import com.hendrix.feathers.controls.flex.tables.core.roTableDataType.ColumnProperties;
  import com.hendrix.feathers.controls.flex.tables.core.roTableDataType.TableDataType;
  
  import feathers.controls.ScrollContainer;
  import feathers.layout.VerticalLayout;
  
  /**
   * supports records pooling in order to spare instantiation (if desired)
   * 
   */
  public class Table extends ScrollContainer
  {
    private var _dataProvider:          TableDataType         = null;
    private var _childrenTableRecords:  Vector.<TableRecord>  = null;
    private var _prePopulateRecords:    int;
    
    private var _roColumnProperties:      Vector.<ColumnProperties>     = null;
    
    public function Table($dataProvider:TableDataType = null, $prePopulateRecords:int = -1)
    {
      super();
      
      _dataProvider = $dataProvider;
      
      if(_dataProvider != null)
        _roColumnProperties = _dataProvider.roColumnsProperties;
      
      _prePopulateRecords = $prePopulateRecords;
      
      if(_dataProvider  ==  null)
        return;
      
      /**
       * test set
       */
      var ran:Number  =   1 + Math.floor(Math.random()*10);
      for(var ix:uint = 0; ix < ran; ix++)
      {
        var obj:Object  = new Object();
        
        obj.roTableStage      = ix.toString();
        obj.roTableStageInfo  = "Hemorrhagic radiation cystitis (HRC) is a significant clinical problem that occurs after pelvic radiation therapy and is often refractory";
        
        //_dataProvider.push(obj);
      }
    }
    
    override protected function initialize(): void
    {
      super.initialize();
      
      var vLayout:  VerticalLayout        = new VerticalLayout();
      vLayout.gap                         = 1;
      vLayout.horizontalAlign             = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
      
      this.layout                         = vLayout;
      this.horizontalScrollPolicy         = ScrollContainer.SCROLL_POLICY_OFF;
      this.verticalScrollPolicy           = ScrollContainer.SCROLL_POLICY_OFF;
      
      _childrenTableRecords               = new Vector.<TableRecord>();
      
      if(_prePopulateRecords >= 0) {
        for(var ux:uint = 0; ux < _prePopulateRecords; ux++)
        {
          var rec:TableRecord = new TableRecord();
          
          _childrenTableRecords.push(rec);
          
          addChild(rec);
        }
      }
      
      if(_dataProvider  ==  null)
        return;
      
      for(var ix:uint = 0; ix < _dataProvider.roRecords.length; ix++)
      {
        var roTableRecord:TableRecord = new TableRecord(_dataProvider.roRecords[ix], _roColumnProperties);
        
        _childrenTableRecords.push(roTableRecord);
        
        addChild(roTableRecord);
      }
    }
    
    public function update():void
    {
      for(var ix:uint = 0; ix < _childrenTableRecords.length; ix++)
      {
        if(_dataProvider[ix]){
          _childrenTableRecords[ix].update(_dataProvider[ix]);
          _childrenTableRecords[ix].visible = true;
        }
        else{
          _childrenTableRecords[ix].visible = false;
        }
      }
      
      validate();
    }
    
    override public function dispose():void
    {
      if(_childrenTableRecords == null)
        return;
      for(var ux:uint = 0; ux < _childrenTableRecords.length; ux++) {
        if(_childrenTableRecords[ux]  ==  null)
          return;
        
        removeChild(_childrenTableRecords[ux]);
        _childrenTableRecords[ux].dispose();
        _childrenTableRecords[ux] = null;
      }
      
      _childrenTableRecords = null;
      
      super.dispose();
      
    }
    
    override protected function draw(): void
    {
      super.draw();
      
      for(var ux:uint = 0; ux < _childrenTableRecords.length; ux++) {
        _childrenTableRecords[ux].width = this.width;
      }
    }
    
    public function get dataProvider():TableDataType  {
      return _dataProvider;
    }
    public function set dataProvider(value:TableDataType):void  {
      _dataProvider = value;
      _roColumnProperties = _dataProvider.roColumnsProperties;
      
    }
  }
}