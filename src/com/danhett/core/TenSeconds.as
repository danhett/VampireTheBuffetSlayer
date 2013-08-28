package com.danhett.core
{
	import com.danhett.audio.AudioPlayer;
	import com.danhett.entities.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.utils.Timer;

	/**
	 * Vampire The Buffet Slayer
	 * Created in barely any time at all, during the August 2013 Ludum Dare
	 * at the Manchester Game Jam. Art by Dan and Dillion Whitehead!
	 * I REGRET NOTHING!
	 */
	[SWF(width='1024',height='768',backgroundColor='#000000',frameRate='60')]
	public class TenSeconds extends Sprite
	{		
		private var bounds:Rectangle; // player wall constraints
		private var enemyBounds:Rectangle; // enemy constraints (so no food overlaps etc)
		
		private var world:MovieClip;
		
		private var table:PlayerTable;
		private var player:Player;
		private var title:TitleScreen;
		private var count:Countdown;
		
		// control triggers
		private var UP:Boolean = false;
		private var DOWN:Boolean = false;
		private var LEFT:Boolean = false;
		private var RIGHT:Boolean = false;
		
		// the food!
		private var helpings:Array = new Array();
		
		// the enemies
		private var enemies:Array = new Array();
		
		// player physics
		private var SPEED:Number = 6;
		private var DRAG:Number = 0.3;
		private var targetX:Number;
		private var targetY:Number;
		private var diffX:Number;
		private var diffY:Number;
		
		private var tableCount:int = 5;
		private var NPCCount:int = 6;
		private var hitRange:int = 45;
		
		private var carryingFood:Boolean = false;
		private var eatingFood:Boolean = false;
		private var invincible:Boolean = false;
		
		private var eaten:int = 0;
		private var enemy:MovieClip;
		private var lastGrabbed:Food;
		private var timer:Timer;
		
		private var music:Soundtrack;
		private var channel:SoundChannel;
		private var trans:SoundTransform;
		private var eating:EatingScreen;
		
		private var foodFrame:int;
		
		// win and loss screens
		private var win:WinScreen;
		private var lose:LoseScreen;
				
	    public function TenSeconds()
	    {
			addChild(new Floor());
			
			world = new MovieClip();
			addChild(world);
			
			title = new TitleScreen();
			addChild(title);
			
			title.playBtn.buttonMode = true;
			title.playBtn.addEventListener(MouseEvent.CLICK, constructGame);	
			
			var chatter:Chatter = new Chatter();
			chatter.play(0, 999);
	    }
		
		
		private function constructGame(e:MouseEvent = null):void
		{
			TweenMax.to(title, 1, {y:stage.stageHeight, ease:Back.easeInOut});
			
			createObjects();
			
			keyListen();
			
			addEventListener(Event.ENTER_FRAME, loop);	
			
			eating = new EatingScreen();
			eating.y = stage.stageHeight;
			addChild(eating);
			
			count = new Countdown();
			count.x = 100;
			count.y = stage.stageHeight - 70;
			addChild(count);
			startTime();
			
			music = new Soundtrack();
			channel = music.play(0,999);
			
			// WIN SCREEN
			win = new WinScreen();
			win.y = stage.stageHeight;
			addChild(win);
			
			// LOSE SCREEN
			lose = new LoseScreen();
			lose.y = stage.stageHeight;
			addChild(lose);
			
			// RESET COMMANDS
			win.playAgain.buttonMode = true;
			win.playAgain.addEventListener(MouseEvent.CLICK, playAgain);
			lose.playAgain.buttonMode = true;
			lose.playAgain.addEventListener(MouseEvent.CLICK, playAgain);
			
			startGameTimer();
		}
		
		private function createObjects():void
		{	
			bounds = new Rectangle(53, 48, 920, 718);
			enemyBounds = new Rectangle(55, 131, 913, 516);
			
			addBuffetTables();
			
			addEnemies();
			
			player = new Player();
			player.x = stage.stageWidth / 2;
			player.y = stage.stageHeight - 105;
			player.stop();
			world.addChild(player);
			
			player.food.alpha = 0;
			
			// player table
			table = new PlayerTable();
			table.x = stage.stageWidth / 2;
			table.y = stage.stageHeight - 90;
			world.addChild(table);
			
			targetX = player.x;
			targetY = player.y;
			
			// create a timer for use later
			timer = new Timer(1000, 10);
			timer.addEventListener(TimerEvent.TIMER, updateTime);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, timeComplete);
		}
		
		private function addBuffetTables():void
		{
			var count:int = 0;
			
			for(var i:int = 0; i < 5; i++)
			{
				var buffet:BuffetTable = new BuffetTable();
				buffet.x = 85 + (i * 180);
				buffet.y = 60;
				world.addChild(buffet);
				
				for(var j:int = 0; j < 2; j++)
				{
					var food:Food = new Food();
					
					if(j == 0)
						food.x = buffet.x + 38;
					else
						food.x = buffet.x + 83;
					
					food.y = buffet.y + 10;
					
					count++
					food.gotoAndStop(count);
					helpings.push(food);
					
					world.addChild(food);
				}
			}
		}
		
		private function addEnemies():void
		{
			// REGULAR DUDES
			for(var i:int = 0; i < NPCCount; i++)
			{
				var person:*;
				
				if(i % 2 == 0)
					person = new Person(enemyBounds);
				else
					person = new Person2(enemyBounds);
				
				person.x = randRange(enemyBounds.x, enemyBounds.x + enemyBounds.width);
				person.y = randRange(enemyBounds.y, enemyBounds.y + enemyBounds.height);
				world.addChild(person);
				enemies.push(person);
			}
			
			// KIDS
			var kid:Kid = new Kid(enemyBounds);
			kid.x = randRange(enemyBounds.x, enemyBounds.x + enemyBounds.width);
			kid.y = randRange(enemyBounds.y, enemyBounds.y + enemyBounds.height);
			world.addChild(kid);
			enemies.push(kid);
			
			// OLD MAN
			var old1:OldMan = new OldMan(enemyBounds);
			old1.x = enemyBounds.x + 50;
			old1.y = 120;
			world.addChild(old1);
			enemies.push(old1);
			
			var old2:OldMan = new OldMan(enemyBounds);
			old2.x = enemyBounds.x + enemyBounds.width - 50;
			old2.y = 120;
			old2.scaleX = -1;
			world.addChild(old2);
			enemies.push(old2);
			
			var old3:OldMan = new OldMan(enemyBounds);
			old3.x = enemyBounds.x + enemyBounds.width - 400;
			old3.y = 500;
			world.addChild(old3);
			enemies.push(old3);
		}
		
		private function keyListen():void
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{			
			switch(e.keyCode)
			{
				case 38: UP = true; break;
				case 40: DOWN = true; break;
				case 37: LEFT = true; break;
				case 39: RIGHT = true; break;
			}
		}
		
		private function onKeyUp(e:KeyboardEvent):void
		{
			switch(e.keyCode)
			{
				case 38: UP = false; break;
				case 40: DOWN = false; break;
				case 37: LEFT = false; break;
				case 39: RIGHT = false; break;
			}	
		}
		
		/**
		 * GAME LOOP!
		 */
		private function loop(e:Event):void
		{
			updatePlayer();
			checkBounds();
			checkCollisions();
		}
		
		private function updatePlayer():void
		{
			if(UP)
				targetY -= SPEED;
			if(DOWN)
				targetY += SPEED;
			if(LEFT)
				targetX -= SPEED;
			if(RIGHT)
				targetX += SPEED;
			
			diffX = targetX - player.x;
			diffX *= DRAG;
			player.x += diffX;
			
			diffY = targetY - player.y;
			diffY *= DRAG;
			player.y += diffY;
			
			if(UP || DOWN || LEFT || RIGHT)
				player.gotoAndStop("walking");
			else
				player.gotoAndStop("stopped");
		}
		
		private function checkBounds():void
		{
			if(player.left() < bounds.x - 30)
			{
				player.x = bounds.x + player.halfWidth() - 30;
				targetX = player.x;
			}
			
			if(player.right() > bounds.x + bounds.width + 20)
			{
				player.x = bounds.x + bounds.width - player.halfWidth() + 20;
				targetX = player.x;
			}
			
			if(player.top() < bounds.y + 10)
			{
				player.y = bounds.y + player.halfHeight() + 10;
				targetY = player.y;
			}
			
			if(player.bottom() > bounds.y + bounds.height - 60)
			{
				player.y = bounds.y - player.halfHeight() + bounds.height - 60;
				targetY = player.y;
			}
		}
		
		private function checkCollisions():void
		{
			// check if we're near some available food
			for(var i:int = 0; i < helpings.length; i++)
			{
				if(distanceBetween(player.x, helpings[i].x, player.y, helpings[i].y) < 60)
				{
					if(!carryingFood && helpings[i].alpha != 0)
					{
						player.food.gotoAndStop(helpings[i].currentFrame);
						player.food.alpha = 1;
						
						carryingFood = true;
						helpings[i].alpha = 0;
						
						var plate:Plate = new Plate();
						plate.play(0, 1);
						
						// store a reference to the food so we can drop it if we hit an enemy
						lastGrabbed = helpings[i];
						this.foodFrame = helpings[i].currentFrame;
					}
				}
			}
			
			// if we're carrying food and we go near the player table, eat it!
			if(carryingFood)
			{								
				if(distanceBetween(player.x, table.x, player.y, table.y) < 50)
				{
					carryingFood = false;
					player.food.alpha = 0;
					
					// EATING
					eating.food.gotoAndStop(this.foodFrame);
					TweenMax.to(eating, 1, {y:0, ease:Expo.easeOut});
					removeEventListener(Event.ENTER_FRAME, loop);
					
					stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
					stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
					
					stage.addEventListener(KeyboardEvent.KEY_DOWN, eatFood);
				}
			}
			
			// if we're carrying food and we hit an enemy, drop the food (reset)
			if(carryingFood)
			{
				for(var j:int = 0; j < enemies.length; j++)
				{	
					enemy = MovieClip(enemies[j]);

					if(distanceBetween(player.x, enemy.x, player.y, enemy.y) < hitRange)
					{
						if(!invincible)
							makeInvincible();
						
						var collide:Collide = new Collide();
						collide.play(0, 1);
												
						resetFood();
					}
				}
			}
		}
		
		
		private var chompTarget:int = 10;
		private var chomps:int;
		private var eat:Eat = new Eat();
		private function eatFood(e:KeyboardEvent):void
		{
			if(e.keyCode == 32)
			{
				chomps++;
				
				if(eating.eatAnim.currentFrame == 1)
					eating.eatAnim.gotoAndPlay(2);
				
				eating.chompMask.gotoAndStop(chomps);
				eat.play(0, 1);
				
				if(chomps == chompTarget)
				{
					doneEating();
				}
			}
		}
		
		private function doneEating():void
		{
			chomps = 0;
			eating.chompMask.gotoAndStop(1);
			
			TweenMax.to(eating, 1, {y:stage.stageHeight, ease:Expo.easeOut});
			addEventListener(Event.ENTER_FRAME, loop);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, eatFood);
			
			eaten++;
			
			if(eaten == 10)
			{
				triggerWin();	
			}
			else
			{
				var burp:Burp = new Burp();
				burp.play(0, 1);
				
				UP = false;
				DOWN = false;
				LEFT = false;
				RIGHT = false;
				
				resetTime();
			}
		}
		
		private function makeInvincible():void
		{
			invincible = true;
			
			TweenMax.to(player, 0.2, {alpha:0.2, yoyo:true, repeat:-1});
			TweenMax.delayedCall(3, stopInvincible);
		}
		
		private function stopInvincible():void
		{
			TweenMax.killTweensOf(player);
			player.alpha = 1;
			invincible = false;
		}
		
		private function resetFood():void
		{
			player.food.alpha = 0;
			carryingFood = false;
			lastGrabbed.alpha = 1;
		}
		
		private function startTime():void
		{
			timer.start();
		}
		
		private function resetTime():void
		{
			timer.stop();
			timer.reset();
			timer.repeatCount = 11;
			timer.start();
			count.readout.text = "OK!";
		}
		
		private function updateTime(e:TimerEvent):void
		{			
			count.readout.text = (10 - e.currentTarget.currentCount).toString();
		}
		
		private function timeComplete(e:TimerEvent):void
		{
			triggerLose("Time up!");
		}
		
		private function triggerWin():void
		{			
			TweenMax.to(win, 1, {y:0, ease:Expo.easeOut});
			
			SoundMixer.stopAll();
			var cheers:Crowdcheer = new Crowdcheer();
			cheers.play(0, 1);
			
			timer.stop();
			
			removeEventListener(Event.ENTER_FRAME, loop);
			
			TweenMax.killDelayedCallsTo(addSecond);
			
			win.readout.text = TIME + " SECONDS!";
		}
		
		private function triggerLose(reason:String):void
		{			
			TweenMax.to(lose, 1, {y:0, ease:Expo.easeOut});
			
			TweenMax.to(eating, 1, {y:stage.stageHeight, ease:Expo.easeOut});
			
			count.readout.text = "";
			
			SoundMixer.stopAll();
			var fail:Failure = new Failure();
			fail.play(0, 1);
			
			timer.stop();
			
			removeEventListener(Event.ENTER_FRAME, loop);
		}
		
		private function distanceBetween(x1:Number, x2:Number,  y1:Number, y2:Number): Number {
			var dx:Number = x1-x2;
			var dy:Number = y1-y2;
			return Math.sqrt(dx * dx + dy * dy);
		}
		
		private function randRange($min:Number, $max:Number):Number
		{
			return (Math.floor(Math.random() * ($max - $min + 1)) + $min);
		}
		
		private function startGameTimer():void
		{
			TweenMax.delayedCall(1, addSecond);
		}
		
		private var TIME:int = 0;
		private function addSecond():void
		{
			TIME++;
			TweenMax.delayedCall(1, addSecond);
		}
		
		private function playAgain(e:MouseEvent):void
		{
			while(world.numChildren)
			{
				world.removeChildAt(0);	
			}
			
			UP = false;
			DOWN = false;
			LEFT = false;
			RIGHT = false;
			
			enemies = [];
			helpings = [];
			
			carryingFood = false;
			eatingFood = false;
			invincible = false;
			
			timer = null;
			player = null;
			table = null;
			
			music = new Soundtrack();
			channel = music.play(0,999);
			
			eating.y = stage.stageHeight;
			win.y = stage.stageHeight;
			lose.y = stage.stageHeight;
			
			this.createObjects();
			
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, eatFood);
			
			eaten = 0;
			
			addEventListener(Event.ENTER_FRAME, loop);
			
			keyListen();
		}
	}
}
