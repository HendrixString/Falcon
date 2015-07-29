package com.hendrix.feathers.controls.utils.geom
{
  import flash.geom.Point;
  /**
   * ...
   * @author Andrew McGrath - muongames.com - 2013
   */
  public class Polygon 
  {
    private var vertices:Vector.<Point> = null;
    
    public function Polygon() 
    {
      vertices = new Vector.<Point>();
    }
    
    public function addPoint(p:Point):void {
      vertices.push(p);
    }
    
    public function pointInPolygon(p:Point):Boolean
    {
      //Loop through vertices, check if point is left of each line.
      //If it is, check if it line intersects with horizontal ray from point p
      var n:int = vertices.length;
      var j:int;
      var v1:Point, v2:Point;
      var count:int;
      for (var i:int = 0; i < n; i++)
      {
        j = i + 1 == n ? 0: i + 1;
        v1 = vertices[i];
        v2 = vertices[j];
        //does point lay to the left of the line?
        if (isLeft(p,v1,v2))
        {
          if ((p.y > v1.y && p.y <= v2.y) || (p.y > v2.y && p.y <= v1.y))
          {
            count++;
          }
        }
      }
      if (count % 2 == 0)
      {
        return false;
      }else
      {
        return true;
      }
    }
    
    public function isLeft(p:Point, v1:Point, v2:Point):Boolean
    {
      if (v1.x == v2.x)
      {
        if (p.x <= v1.x)
        {
          return true;
        }else
        {
          return false;
        }
      }else
      {
        var m:Number = (v2.y - v1.y) / (v2.x - v1.x);
        var x2:Number = (p.y - v1.y) / m + v1.x;
        if (p.x <= x2)
        {
          return true;
        }else
        {
          return false;
        }
      }
    }
    
    public function size():Boolean
    {
      return vertices.length;
    }
  }
  
}