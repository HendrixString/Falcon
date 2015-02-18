package com.hendrix.feathers.controls.flex.tables
{
  import com.hendrix.feathers.controls.CompsFactory;
  import com.hendrix.feathers.controls.flex.tables.core.roTableDataType.ColumnProperties;
  
  import flash.text.TextFormat;
  
  import feathers.controls.Label;
  import feathers.controls.ScrollContainer;
  import feathers.core.FeathersControl;
  import feathers.layout.HorizontalLayout;
  import feathers.layout.VerticalLayout;
  
  import starling.display.DisplayObject;
  import starling.display.Quad;
  
  public class TableRecord extends FeathersControl
  {
    private var _roRecordData:    Object  = null;
    
    private var _quadBg:          Quad              = null;
    private var _hGrp:            ScrollContainer   = null;
    private var _hLayout:         HorizontalLayout  = null;
    
    private var _lblFields:       Vector.<Label>    = null;
    private var _quadlineFields:  Vector.<Quad>     = null;
    
    private var _bgColor:         uint;
    private var _stageLblColor:   uint;
    private var _infoLblColor:    uint;
    
    private var _sm:            CompsFactory      = null;
    
    private var _roColumnProperties:  Vector.<ColumnProperties> = null;
    private var _fontScale:Number = 1;
    
    public function TableRecord($roRecordData:Object  = null, $roColumnProperties:Vector.<ColumnProperties> = null)
    {
      super();
      
      _roRecordData       = $roRecordData;
      
      _roColumnProperties = $roColumnProperties;
      
      _bgColor            = 0xFFFFFF;
      _stageLblColor      = 0xA7A8A9;
      _infoLblColor       = 0x494A4A;
    }
    
    override protected function initialize(): void
    {
      _quadBg                                       = new Quad(1, 1, _bgColor);
      _hGrp                                         = new ScrollContainer();
      _hLayout                                      = new HorizontalLayout();
      
      _hLayout.gap                                  = 3;
      _hLayout.paddingLeft                          = 3;
      _hLayout.verticalAlign                        = VerticalLayout.VERTICAL_ALIGN_MIDDLE;
      
      _hGrp.layout                                  = _hLayout;
      _hGrp.horizontalScrollPolicy                  = ScrollContainer.SCROLL_POLICY_OFF;
      _hGrp.verticalScrollPolicy                    = ScrollContainer.SCROLL_POLICY_OFF;
      
      /**
       * Use current screen memory pool, for disposal as well
       */
      _sm                                           = new CompsFactory();
      
      var tf_stageLbl:  TextFormat                  = new TextFormat("FbSpoilerEng-Regular",  32, _stageLblColor, true);
      var tf_infoLbl:   TextFormat                  = new TextFormat("FbSpoilerEng-Regular",  19, _infoLblColor);
      
      _lblFields                                    = new Vector.<Label>();
      _quadlineFields                               = new Vector.<Quad>();
      
      for(var ix:uint = 0; ix < _roRecordData.roFields.length; ix++) 
      {
        var lbl:  Label;
        
        if(ix == 0)
          lbl = CompsFactory.newLabel(_roRecordData.roFields[ix],   tf_stageLbl);
        else
          lbl = CompsFactory.newLabel(_roRecordData.roFields[ix],   tf_infoLbl);
        
        lbl.textRendererProperties.embedFonts       = true;
        lbl.textRendererProperties.wordWrap         = true;
        
        _lblFields.push(lbl);
        
        _hGrp.addChild(lbl);
        
        if(ix < _roRecordData.roFields.length - 1) {
          var ql: Quad                              = new Quad(1, 1, 0xA7A8A9);
          
          _quadlineFields.push(ql);
          
          _hGrp.addChild(ql);
        }
      }
      
      addChild(_quadBg);
      addChild(_hGrp);
    }
    
    public function update($roRecordData:Object):void
    {
      _roRecordData   = $roRecordData;
      draw();
    }
    
    override public function dispose():void
    {
      for(var ix:uint = 0; ix < _quadlineFields.length; ix++) {
        disposeSingle(_quadlineFields[ix], _hGrp);
        _quadlineFields[ix] = null;
      }
      
      for(ix  = 0; ix < _lblFields.length; ix++) {
        disposeSingle(_lblFields[ix], _hGrp);
        _lblFields[ix] = null;
      }
      
      disposeSingle(_quadBg,   this);
      disposeSingle(_hGrp,     this);
      
      //if(_sm)
      //        _sm.disposeImages();
      
      super.dispose();
    }
    
    override protected function draw(): void
    {
      if(width == 0)
        return;
      
      /**
       * code specific for the ISGO tables
       */
      if(_roRecordData){
        var lenStage:uint = String(_roRecordData.roFields[0]).length;
        if(lenStage == 1){
          _bgColor        = 0x49BDEE;
          _stageLblColor  = 0xFFFFFF;
          _infoLblColor   = 0xFFFFFF;
        }
        else {
          _bgColor        = 0xFFFFFF;
          _stageLblColor  = 0xA7A8A9;
          _infoLblColor   = 0x464646;
        }
        
        if((lenStage == 2) && (String(_roRecordData.roFields[0]).charAt(1) == "*")){
          _bgColor        = 0x49BDEE;
          _stageLblColor  = 0xFFFFFF;
          _infoLblColor   = 0xFFFFFF;
        }
      }
      else
        return;
      
      super.draw();
      
      _quadBg.color                                               = _bgColor;
      
      var fieldsNum:    uint                                      = _roRecordData.roFields.length;
      var uniformSize:  Number                                    = (width - _lblFields[0].width) / (fieldsNum - 1);
      
      for(var ix:uint = 0; ix < fieldsNum; ix++)
      {
        _lblFields[ix].width                                      = width*_roColumnProperties[ix].roPercentWidth/102;
        
        if(ix == 0)
          _lblFields[ix].textRendererProperties.textFormat.color  = _stageLblColor;
        else
          _lblFields[ix].textRendererProperties.textFormat.color  = _infoLblColor;
        
        _lblFields[ix].textRendererProperties.textFormat.size     = _roColumnProperties[ix].roFontSize*_fontScale; //add font scaling here
      }
      
      var maxHeight:    Number                                    = 0;
      
      for(ix = 0; ix < fieldsNum; ix++)
      {
        _lblFields[ix].validate();
        
        maxHeight                                                 = Math.max(maxHeight, _lblFields[ix].height);
      }
      
      actualHeight                                                = maxHeight*1.2;
      
      for(ix = 0; ix < fieldsNum - 1; ix++)
      {
        _quadlineFields[ix].width                                 = 1;
        _quadlineFields[ix].height                                = actualHeight;
      }
      
      _quadBg.width                                               = width;
      _quadBg.height                                              = height;
      
      _hGrp.width                                                 = width;
      _hGrp.height                                                = height;
    }
    
    private function disposeSingle($obj:DisplayObject, $parent:Object):void
    {
      if($obj ==  null)
        return;
      
      $parent.removeChild($obj);
      $obj.dispose();
      
      $obj  = null;
    }
  }
}