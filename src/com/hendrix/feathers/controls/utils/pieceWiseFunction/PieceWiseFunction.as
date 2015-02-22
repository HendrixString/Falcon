package com.hendrix.feathers.controls.utils.pieceWiseFunction
{
	/**
	 * 
	 * @author Tomer Shalev
	 * 
	 */
	public class PieceWiseFunction
	{
		private var _vecFunction:	Vector.<Value> = null;
		
		/**
		 * possibly invalid order due insertion 
		 */
		private var _flagInvalidOrder:Boolean = true;

		/**
		 * PieceWise function interpolator 
		 * 
		 */
		public function PieceWiseFunction()
		{
			_vecFunction 	= new Vector.<Value>();
		}
		
		/**
		 * y1 = f(x1), assumes user enters the series as strict descending or ascending
		 * @param x1
		 * @param y1
		 * @param value
		 * 
		 */
		public function addPair(x1:Number, y1:Number):void
		{
			var val:Value 		= new Value(x1, y1);
			
			_vecFunction.push(val);
			
			_flagInvalidOrder = true;
		}
		
		/**
		 * Linear Interpolation 
		 * @param x
		 * @return 
		 * 
		 */
		public function grabValueAt(x:Number):Number
		{
			validateOrder();
			
			var closestIdx:			int 		= binarySearchInsertion(_vecFunction, x, 0, _vecFunction.length);
			
			var closestValue1:	Value 	= _vecFunction[closestIdx];
			
			var closestValue2:	Value 	= (closestIdx + 1 >= _vecFunction.length) ? _vecFunction[closestIdx] : _vecFunction[closestIdx + 1];
			
			var ratio:					Number	=	(x - closestValue1.x) / (closestValue2.x - closestValue1.x);
			
			if(ratio < 0)
				trace("ratio lower 0");
			
			if(closestValue1 == closestValue2)
				ratio											=	1;
			
			var res:						Number 	= closestValue1.y + (closestValue2.y - closestValue1.y)*ratio; 
			
			trace("x=" + x + ": ratio=" + ratio + " : (x1,x2)=" + closestValue1.x + "," + closestValue2.x +" :res=" + res);
			
			if(isNaN(res)){
				trace("Nan");
			}
			
			return res;
		}
		
		private function validateOrder():void
		{
			if(_flagInvalidOrder == false)
				return;
			
			_vecFunction.sort(comparator);
			
			_flagInvalidOrder = false;
		}
		
		private function comparator(val1:Value, val2:Value):Number
		{
			return (val1.x - val2.x);
		}
		
		protected function binarySearchInsertion(vec:Vector.<Value>, value:Number, left:int, right:int):int
		{
			if(Math.abs(right - left) <= 1)
				return (left + right) * 0.5;
			
			var middle:int = (left + right) * 0.5;
			
			if(vec[middle].x == value)
				return middle;
			else if(vec[middle].x > value)
				return binarySearchInsertion(vec, value, left, middle - 0);
			else
				return binarySearchInsertion(vec, value, middle + 0, right);
		}
		
	}
	
}