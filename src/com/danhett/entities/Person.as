package com.danhett.entities
{
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	import flash.geom.Rectangle;
	
	public class Person extends PersonGraphics
	{
		private var bounds:Rectangle;
		private var delay:Number;
		private var range:Number = 100;
		
		public function Person(_bounds:Rectangle)
		{
			bounds = _bounds;
			
			delayWalk();
		}
		
		private function walk():void
		{
			this.gotoAndStop("walking");
			
			TweenMax.to(this, randRange(1, 2), {x:getX(),
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
			this.gotoAndStop("stopped");
			
			TweenMax.delayedCall(randRange(0.1, 1), walk);
		}
		
		private function randRange($min:Number, $max:Number):Number
		{
			return (Math.floor(Math.random() * ($max - $min + 1)) + $min);
		}
	}
}