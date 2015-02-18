package com.hendrix.feathers.controls.flex.tables.core.roTableDataType
{
  import flash.filesystem.File;
  import flash.filesystem.FileMode;
  import flash.filesystem.FileStream;
  import flash.utils.Dictionary;
  
  import feathers.data.ListCollection;
  
  public class TablesDataType
  {
    private var _roTables:    Vector.<TableDataType>  = null;
    private var _roTablesDic: Dictionary                = null;
    
    
    
    public function TablesDataType()
    {
      _roTables     = new Vector.<TableDataType>();
      _roTablesDic  = new Dictionary();
    }
    
    public function loadTablesFromXml($path:String):void
    {
      var xmlString:  String  = null;
      var tablesXML:  XML     = null;
      var file:       File    = File.applicationDirectory.resolvePath($path);
      
      if(!file.exists)
        return;
      
      var fs:         FileStream  = new FileStream();
      
      try{
        fs.open(file, FileMode.READ);
        xmlString = fs.readUTFBytes(fs.bytesAvailable);
        tablesXML   = new XML(xmlString);       
      }
      catch(err:Error){
        trace(err);
      }
      finally {
        fs.close();
      }
      
      var roTablesXML:XMLList = tablesXML.Tables.Table;
      
      for(var ix:uint = 0; ix < roTablesXML.length(); ix++)
      {
        var roTableColumnPropertiesXML: XMLList = roTablesXML[ix].properties.columnsProperties.column;
        
        var roTable:TableDataType = new TableDataType(roTablesXML[ix].name, roTablesXML[ix].@id);
        
        for(var lx:uint = 0; lx < roTableColumnPropertiesXML.length(); lx++)
        {
          var roTableColumnProperties:ColumnProperties = new ColumnProperties();
          
          roTableColumnProperties.roFontSize      = roTableColumnPropertiesXML[lx].@fontSize;
          roTableColumnProperties.roPercentWidth  = roTableColumnPropertiesXML[lx].@percentWidth;
          roTable.addColumnProperties(roTableColumnProperties);
        }
        
        var roRecordsXML:   XMLList         = roTablesXML[ix].Record;
        
        for(var ux:uint = 0;  ux  < roRecordsXML.length(); ux++)
        {
          var fields:       Vector.<String> = new Vector.<String>();
          var roFieldsXML:  XMLList         = roRecordsXML[ux].field;
          
          for(var kx:uint = 0;  kx  < roFieldsXML.length(); kx++)
          {
            fields.push(roFieldsXML[kx]);
          }
          
          var roRecord:RecordDataType = new RecordDataType(fields);
          roTable.roRecords.push(roRecord);
        }
        
        addTable(roTable);
      }
      
    }
    
    public function addTable($roTableDataType:TableDataType):void
    {
      _roTables.push($roTableDataType);
      _roTablesDic[$roTableDataType.roTableId] = $roTableDataType;
    }
    
    public function compileDataProviderById($id:String):TableDataType
    {
      return _roTablesDic[$id];
    }
    
    /**
     * data provider composed of tables id's
     */
    public function compileDataProviderForList():ListCollection
    {
      var tablesArr:Array = new Array();
      
      tablesArr.push(["0"], ["1"], ["2"], ["3"], ["4"], ["5"], ["6", "table7Addition"], ["7"]);
      
      return new ListCollection(tablesArr);
    }
    
    public function search($query:String):  Array
    {
      var recArr:     Array = new Array;
      var srCounter:  uint  = 1;
      
      $query  = $query.toLowerCase()
      
      if(($query == "") || ($query == " "))
        return recArr;
      
      for(var ix:uint = 0; ix < _roTables.length; ix++)
      {
        
        for(var ux:uint = 0;  ux  < _roTables[ix].roRecords.length - 1; ux++)
        {
          var record:         Object    = new Object;
          
          var matchAginst:String = _roTables[ix].roRecords[ux].roFields[1].toLowerCase();
          
          if(matchAginst.search($query) >= 0) {
            
            var firstIndex:   int       = matchAginst.indexOf($query);
            var tableName:    String    = _roTables[ix].roTableName;
            var tableIndex:   int       = ix;
            var resultString: String    = _roTables[ix].roRecords[ux].roFields[1].substr(firstIndex, 70);
            var arr:Array               = resultString.split("\r\n");
            resultString                = arr.join(" ");
            var resultStage:  String    = _roTables[ix].roRecords[ux].roFields[0];
            
            
            record.roTableName          = tableName;  
            record.roTableIndex         = tableIndex; 
            record.roResultString       = "... " + resultString + "...";  
            record.roResultStage        = resultStage;
            
            if(srCounter < 10)
              record.roSearchResultIndex  = "0" + String(srCounter++);
            else
              record.roSearchResultIndex  = String(srCounter++);
            
            recArr.push(record);
          }
        }
      }
      return recArr;
    }
    
    public function get roTables(): Vector.<TableDataType>
    {
      return _roTables;
    }
  }
}