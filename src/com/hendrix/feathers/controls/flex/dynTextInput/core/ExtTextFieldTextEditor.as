package com.hendrix.feathers.controls.flex.dynTextInput.core
{
  import flash.display.BitmapData;
  import flash.events.Event;
  import flash.text.TextField;
  import flash.text.TextFormat;
  
  import feathers.controls.text.TextFieldTextEditor;
  
  /**
   * <code>StageTextTextEditor</code> etended to fix a bug related to the invalidation of the size and therefore
   * did not refresh the <code>textsnapshot</code> 
   *  
   * @author Tomer Shalev
   * 
   */
  public class ExtTextFieldTextEditor extends TextFieldTextEditor implements IExtTextEditor
  {
    private var _textSnapshotBitmapData:BitmapData= null;
    
    public function ExtTextFieldTextEditor()
    {
      super();
    }
    
    /**
     * get the snapshot bitmapdata of the text
     */
    public function getSnapShotBitmapData():BitmapData
    {
      return _textSnapshotBitmapData;
    }
    
    
    /** 
     * get the TextField for measurement purposes
     * @return <code>TextField</code> object
     */
    public function get measureTextField():TextField
    {
      return super.textField;
    }
    
    
    override protected function textField_changeHandler(event:flash.events.Event):void
    {
      measureTextField.textHeight;
      
      super.textField_changeHandler(event);
      
      measureTextField.textHeight;
      
      return;
      /**
       * tomer
       */
      measureTextField.text = text;
      var tf:TextFormat = textField.getTextFormat();
      measureTextField.numLines;
      //measureTextField.setTextFormat(new TextFormat(tf.font, 20));
      trace(measureTextField.numLines);
    }
    
  }
}