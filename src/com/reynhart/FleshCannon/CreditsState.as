package com.reynhart.FleshCannon
{
	import org.flixel.*;

	public class CreditsState extends FlxState
	{
		protected var _backButton:FlxButton;

		//Create function
		override public function create():void
		{
			FlxG.bgColor = 0xff131c1b;

			var text:FlxText;
			text = new FlxText(FlxG.width/2-50,FlxG.height/3+39,100,"Credits")
			text.alignment = "center";
			text.color = 0x3a5c39;
			add(text);

			//Create play button
			_backButton = new FlxButton( (FlxG.width/2) - 40, 200, "Back", onBackButtonPressed);
			add( _backButton );

			FlxG.mouse.show();

		}

		//Play pressed handler
		private function onBackButtonPressed():void		
		{
			FlxG.switchState(new MenuState());
		}

	}
}

