package com.reynhart.FleshCannon
{
	import org.flixel.*;

	public class TutorialState extends FlxState
	{
		//Some graphics and sounds
		[Embed(source="data/sounds/fc-scrolltext-track.mp3")] protected var StoryTrack:Class;

		protected var _backButton:FlxButton;

		//Create function
		override public function create():void
		{
			FlxG.bgColor = 0xff131c1b;

			var text:FlxText;
			text = new FlxText(FlxG.width/2-100,50,200,"YOU ARE MY FAVOURITE, PALINDROME. YOU ARE THE DRAGON AND YOU ARE THE PHOENIX")
			text.alignment = "center";
			text.color = 0xFFFFFFFF;
			add(text);

			//Create play button
			_backButton = new FlxButton( (FlxG.width/2) - 40, 200, "Play", onBackButtonPressed);
			add( _backButton );

			//Stops all existing sounds
			FlxG.music.stop();

			//Play music and flash the screen
			FlxG.playMusic( StoryTrack, 1 );

			FlxG.mouse.show();
		}

		//Play pressed handler
		private function onBackButtonPressed():void		
		{
			FlxG.switchState(new PlayState());
		}

	}
}

