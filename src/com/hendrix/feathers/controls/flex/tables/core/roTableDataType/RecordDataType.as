package com.hendrix.feathers.controls.flex.tables.core.roTableDataType
{
  public class RecordDataType
  {
    private var _roFields:          Vector.<String> = null;
    
    public function RecordDataType($roFields:Vector.<String>)
    {
      _roFields     = $roFields;
    }
    
    public function get roFields():Vector.<String>
    {
      return _roFields;
    }
  }
}