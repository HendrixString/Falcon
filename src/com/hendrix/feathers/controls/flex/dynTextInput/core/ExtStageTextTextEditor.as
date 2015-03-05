package com.hendrix.feathers.controls.flex.dynTextInput.core
{
  import flash.display.BitmapData;
  import flash.events.FocusEvent;
  import flash.geom.Matrix;
  import flash.geom.Rectangle;
  import flash.text.TextField;
  
  import feathers.controls.text.StageTextTextEditor;
  import feathers.events.FeathersEventType;
  import feathers.utils.geom.matrixToScaleX;
  import feathers.utils.geom.matrixToScaleY;
  
  import starling.core.Starling;
  import starling.display.Image;
  import starling.textures.Texture;
  
  /**
   * <code>StageTextTextEditor</code> etended to fix a bug related to the invalidation of the size and therefore
   * did not refresh the <code>textsnapshot</code> 
   *  
   * @author Tomer Shalev
   * 
   */
  public class ExtStageTextTextEditor extends StageTextTextEditor implements IExtTextEditor
  {
    private var _textSnapshotBitmapData:BitmapData= null;
    
    public function ExtStageTextTextEditor()
    {
      super();
    }
    
    /**
     * get the snapshot bitmapdata of the text
     */
    public function getSnapShotBitmapData():BitmapData
    {
      validate();
      
      drawViewportToBitmapdata()
      
      return _textSnapshotBitmapData;
    }    
    
    /** 
     * get the TextField for measurement purposes
     * @return <code>TextField</code> object
     */
    public function get measureTextField():TextField
    {
      return _measureTextField;
    }
    
    public function getStageText():Object
    {
      return stageText;
    }
    
    /**
     * overriden to fix the bug of refreshing the bitmapData of the text snapshot when focus is out
     */
    override protected function stageText_focusOutHandler(event:FocusEvent):void
    {
      this._stageTextHasFocus = false;
      //since StageText doesn't expose its scroll position, we need to
      //set the selection back to the beginning to scroll there. it's a
      //hack, but so is everything about StageText.
      //in other news, why won't 0,0 work here?
      this.stageText.selectRange(1, 1);
      
      this.invalidate(INVALIDATION_FLAG_DATA);
      this.invalidate(INVALIDATION_FLAG_SKIN);
      this.invalidate(INVALIDATION_FLAG_SIZE);
      this.dispatchEventWith(FeathersEventType.FOCUS_OUT);
    }

    private function drawViewportToBitmapdata():void
    {
      //StageText's stage property cannot be null when we call
      //drawViewPortToBitmapData()
      if(this.stage && !this.stageText.stage)
      {
        this.stageText.stage = Starling.current.nativeStage;
      }
      if(!this.stageText.stage)
      {
        //we need to keep a flag active so that the snapshot will be
        //refreshed after the text editor is added to the stage
        this.invalidate(INVALIDATION_FLAG_DATA);
        return;
      }
      var viewPort:Rectangle = this.stageText.viewPort;
      if(viewPort.width == 0 || viewPort.height == 0)
      {
        return;
      }
      var nativeScaleFactor:Number = 1;
      if(Starling.current.supportHighResolutions)
      {
        nativeScaleFactor = Starling.current.nativeStage.contentsScaleFactor;
      }
      //StageText sucks because it requires that the BitmapData's width
      //and height exactly match its view port width and height.
      //(may be doubled on Retina Mac) 
      try
      {
        var bitmapData:BitmapData = new BitmapData(viewPort.width * nativeScaleFactor, viewPort.height * nativeScaleFactor, true, 0x00ff00ff);
        this.stageText.drawViewPortToBitmapData(bitmapData);
      } 
      catch(error:Error) 
      {
        //drawing stage text to the bitmap data at double size may fail
        //on runtime versions less than 15, so fall back to using a
        //snapshot that is half size. it's not ideal, but better than
        //nothing.
        bitmapData.dispose();
        bitmapData = new BitmapData(viewPort.width, viewPort.height, true, 0x00ff00ff);
        this.stageText.drawViewPortToBitmapData(bitmapData);
      }

      if(_textSnapshotBitmapData)
        _textSnapshotBitmapData.dispose();
      
      _textSnapshotBitmapData = bitmapData;
    }
    
    
  }
}