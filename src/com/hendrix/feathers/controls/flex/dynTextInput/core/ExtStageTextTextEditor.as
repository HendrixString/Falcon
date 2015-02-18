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
      refreshSnapshot();
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
    
    protected static const HELPER_MATRIX:Matrix = new Matrix();
    
    /**
     * had to override because in the new feathers build he ommited bitmapdata saving.
     * i had to change <code>HELPER_MATRIX</code> from <code>private</code> to <code>protected</code> in <code>StageTextTextEditor</code> Class.
     */
    override protected function refreshSnapshot():void
    {
      //super.refreshSnapshot()
      const viewPort:Rectangle = this.stageText.viewPort;
      if(viewPort.width == 0 || viewPort.height == 0)
      {
        return;
      }
      
      //StageText sucks because it requires that the BitmapData's width
      //and height exactly match its view port width and height.
      var bitmapData:BitmapData = new BitmapData(viewPort.width, viewPort.height, true, 0x00ff00ff);
      this.stageText.drawViewPortToBitmapData(bitmapData);
      
      var newTexture:Texture;
      if(!this.textSnapshot || this._needsNewTexture)
      {
        newTexture = Texture.fromBitmapData(bitmapData, false, false, Starling.contentScaleFactor);
        newTexture.root.onRestore = texture_onRestore;
      }
      if(!this.textSnapshot)
      {
        this.textSnapshot = new Image(newTexture);
        this.addChild(this.textSnapshot);
      }
      else
      {
        if(this._needsNewTexture)
        {
          this.textSnapshot.texture.dispose();
          this.textSnapshot.texture = newTexture;
          this.textSnapshot.readjustSize();
        }
        else
        {
          //this is faster, if we haven't resized the bitmapdata
          const existingTexture:Texture = this.textSnapshot.texture;
          existingTexture.root.uploadBitmapData(bitmapData);
        }
      }
      this.getTransformationMatrix(this.stage, HELPER_MATRIX);
      this.textSnapshot.scaleX = 1 / matrixToScaleX(HELPER_MATRIX);
      this.textSnapshot.scaleY = 1 / matrixToScaleY(HELPER_MATRIX);
      
      _textSnapshotBitmapData = bitmapData;
      //bitmapData.dispose();
      this.textSnapshot.visible = !this._stageTextHasFocus;
      this._needsNewTexture = false;
    }
    
  }
}