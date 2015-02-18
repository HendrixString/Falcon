package com.hendrix.feathers.controls.flex.tables.core.roTableDataType
{
  public class TableDataType
  {
    private var _roTableName:         String                      = null;
    private var _roTableId:           String                      = null;
    private var _roRecords:           Vector.<RecordDataType>   = null;
    
    private var _roColumnsProperties: Vector.<ColumnProperties> = null;
    
    public function TableDataType($roTableName:String, $roTableId:String)
    {
      _roTableName          = $roTableName;
      _roTableId            = $roTableId;
      
      _roRecords            = new Vector.<RecordDataType>();
      _roColumnsProperties  = new Vector.<ColumnProperties>();
    }
    
    public function addColumnProperties($roColumnProperties:ColumnProperties):void
    {
      _roColumnsProperties.push($roColumnProperties);
    }
    
    public function get roTableName():String
    {
      return _roTableName;
    }
    
    public function get roRecords():Vector.<RecordDataType>
    {
      return _roRecords;
    }
    
    public function get roTableId():String
    {
      return _roTableId;
    }
    
    public function get roColumnsProperties():Vector.<ColumnProperties>
    {
      return _roColumnsProperties;
    }
    
  }
}