package com.hendrix.feathers.controls.flex
{
  import com.hendrix.feathers.controls.flex.FlexButton;
  import com.hendrix.feathers.controls.utils.geom.Polygon;
  
  import flash.geom.Point;
  
  import starling.display.DisplayObject;
  import starling.events.TouchEvent;
  
  /**
   * a flex button with a definable Polygon hit area.
   * if the polygon is not setup than the default algorithm for
   * hitArea will be used.
   * 
   * @author Tomer Shalev
   * 
   */
  public class HitButton extends FlexButton
  {
    private var _polygon_test: Polygon = null;
    
    public function HitButton()
    {
      super();
      
      _polygon_test = new Polygon();
    }
    
    /**
     * add a <code>Point</code> to the <code>Polygon</code>.
     *  
     * @param p a <code>Point</code>
     * 
     * @see Polygon
     * 
     */
    public function addPoint(p:Point):void {
      _polygon_test.addPoint(p);     
    }

    override protected function button_touchHandler(event:TouchEvent):void
    {      
      super.button_touchHandler(event);
    }
    
    override public function hitTest(localPoint:Point, forTouch:Boolean=false):DisplayObject
    {
      if(_polygon_test.size() < 3)
        return super.hitTest(localPoint, forTouch);
        
      if(_polygon_test.pointInPolygon(localPoint))      
        return super.hitTest(localPoint, forTouch);
      
      return null;
    }    
    
  }
  
}