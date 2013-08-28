package com.danhett.entities
{
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	public class OldMan extends OldManGraphics
	{
		private var bounds:Rectangle;
		private var delay:Number;
		private var range:Number = 100;
		private var speed:int = 2;
		
		public function OldMan(_bounds:Rectangle)
		{
			bounds = _bounds;
			
			this.addEventListener(Event.ENTER_FRAME, update);
		}
		
		private function update(e:Event):void
		{
			this.x += speed;
			
			if(this.x > bounds.x + bounds.width - 50)
			{
				speed *= -1;
				this.scaleX = -1;
			}
			
			if(this.x < bounds.x + 50)
			{
				speed *= -1;
				this.scaleX = 1;
			}
		}
		
		private function randRange($min:Number, $max:Number):Number
		{
			return (Math.floor(Math.random() * ($max - $min + 1)) + $min);
		}
	}
}