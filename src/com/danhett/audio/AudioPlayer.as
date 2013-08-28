package com.danhett.audio
{
	import com.danhett.InvisibleGame;
	
	import flash.display.*;
	import flash.events.*;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	
	public class AudioPlayer
	{
		// SOUNDTRACK EMBEDS
		[Embed(source="../../../../sound/music.mp3")]
		private static var Soundtrack:Class;
		
		private static var root_path:String = "../sound/";
		public function AudioPlayer()
		{
			init();
		}
		
		private function init():void
		{
			// static methods only, this doesn't get called
		}
		
		
		public static var music:Sound
		public static var channel:SoundChannel;
		public static function playMusic():void
		{
			music = new Soundtrack as Sound;
			channel = music.play(0,999);	
		}
		
		
		public static var sound:Sound
		public static var chan:SoundChannel;
		public static function throwAudio(audio:String):void
		{	
			if(!InvisibleGame.Instance.DEBUG)
			{
				chan = new SoundChannel();
				
				switch(audio)
				{
					case "alarm":
						sound = new Alarm as Sound;
					break;
					
					case "ahh":
						sound = new Ahh as Sound;
					break;
					
					case "game_over":
						sound = new GameOver as Sound;
					break;
				}
				
				chan = sound.play();	
				chan.addEventListener(Event.SOUND_COMPLETE, handleSoundComplete)
			}
		}
		
		private static var check:Number;
		public static var speech:Sound
		public static var speechchan:SoundChannel;
		private static var talking:Boolean = false;
		public static function throwSpeech(audio:String):void
		{	
			if(!InvisibleGame.Instance.DEBUG && !talking)
			{
				if(audio == "invisible" && !talking)
				{
					speechchan = new SoundChannel();
					talking = true;
					
					switch(randRange(1, 5))
					{
						case 1: speech = new Invisible1 as Sound; break;
						case 2: speech = new Invisible2 as Sound; break;
						case 3: speech = new Invisible3 as Sound; break;
						case 4: speech = new Invisible4 as Sound; break;
						case 5: speech = new Invisible5 as Sound; break;
					}
					
					speechchan = speech.play();
				}
					
				else if(audio == "visible" && !talking)
				{
					speechchan = new SoundChannel();
					talking = true;
					
					switch(randRange(1, 4))
					{
						case 1: speech = new Reveal1 as Sound; break;
						case 2: speech = new Reveal2 as Sound; break;
						case 3: speech = new Reveal3 as Sound; break;
						case 4: speech = new Reveal4 as Sound; break;
					}
					
					speechchan = speech.play();
				}

				speechchan.addEventListener(Event.SOUND_COMPLETE, handleSoundComplete)
			}
		}
		
		public static function killMusic():void
		{
			if(!InvisibleGame.Instance.DEBUG)
			{
				AudioPlayer.channel.stop();	
			}	
		}
		
		private static function handleSoundComplete(e:Event):void
		{
			talking = false;
		}
		
		
		// MATHS CRAP
		private static function randRange($min:Number, $max:Number):Number
		{
			return (Math.floor(Math.random() * ($max - $min + 1)) + $min);
		}
	}
}