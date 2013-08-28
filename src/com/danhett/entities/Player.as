package com.danhett.entities
{
	public class Player extends PlayerGraphic
	{
		public function Player()
		{
			//
		}
		
		public function left():Number
		{
			return this.x - (this.width * 0.5);
		}
		
		public function right():Number
		{
			return this.x + (this.width * 0.5);
		}
		
		public function top():Number
		{
			return this.y - (this.height * 0.5);
		}
		
		public function bottom():Number
		{
			return this.y + (this.height * 0.5);
		}
		
		public function halfWidth():Number
		{
			return this.width * 0.5;
		}
		
		public function halfHeight():Number
		{
			return this.height * 0.5;
		}
	}
}