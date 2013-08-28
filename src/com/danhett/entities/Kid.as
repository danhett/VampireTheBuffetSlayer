package com.danhett.entities
{
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	import flash.geom.Rectangle;
	
	public class Kid extends KidGraphics
	{
		private var bounds:Rectangle;
		private var delay:Number;
		private var range:Number = 200;
		
		public function Kid(_bounds:Rectangle)
		{
			bounds = _bounds;
			
			delayWalk();
		}
		
		private function walk():void
		{
			//this.gotoAndStop("walking");
			
			TweenMax.to(this, 0.8, {x:getX(),
				y:getY(), 
				onComplete:delayWalk,
				ease:Quad.easeInOut});
		}
		
		private var destX:Number;
		private var destY:Number;
		private function getX():Number
		{
			if(this.x < bounds.x + range)
			{
				destX = randRange(this.x, this.x + range);
			}
			else if(this.x > (bounds.x + bounds.width) - range)
			{
				destX = randRange(this.x - range, this.x);
			}
			else
			{
				destX = randRange(this.x - range, this.x + range);
			}
			
			return destX;
		}
		
		private function getY():Number
		{
			if(this.y < bounds.y + range)
			{
				destY = randRange(this.y, this.y + range);
			}
			else if(this.y > (bounds.y + bounds.height) - range)
			{
				destY = randRange(this.y - range, this.y);
			}
			else
			{
				destY = randRange(this.y - range, this.y + range);
			}
			
			return destY;
		}
		
		private function delayWalk():void
		{
			//this.gotoAndStop("stopped");
			
			TweenMax.delayedCall(0, walk);
		}
		
		private function randRange($min:Number, $max:Number):Number
		{
			return (Math.floor(Math.random() * ($max - $min + 1)) + $min);
		}
	}
}