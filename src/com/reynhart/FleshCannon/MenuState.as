package com.reynhart.FleshCannon
{
	import org.flixel.*;

	public class MenuState extends FlxState
	{
		//Some graphics and sounds
		[Embed(source="data/menu-bg.png")] protected var MenuBg:Class;
		[Embed(source="data/sounds/fc-menu-track.mp3")] protected var MenuSound:Class;


		protected var _menuBg:FlxSprite;
		protected var _playButton:FlxButton;
		protected var _creditsButton:FlxButton;
		protected var _howToPlayButton:FlxButton;

		//Override create function
		override public function create():void
		{
			//Create menu bg
			_menuBg = new FlxSprite(0, 0, MenuBg);
			_menuBg.scale.x = _menuBg.scale.y = 0.5;
			_menuBg.offset.x = 200;
			_menuBg.offset.y = 150;
			add( _menuBg );

			//Create play button
			_playButton = new FlxButton( (FlxG.width/2) - 40, 200, "Play Now", onPlayPressed);
			add( _playButton );

			//How to play button
			_howToPlayButton = new FlxButton( (FlxG.width/2) - 40, 225, "How to play", onHowToPlayPressed);
			add( _howToPlayButton );

			//Credits button
			_creditsButton = new FlxButton( (FlxG.width/2) - 40, 250, "Credits", onCreditsPressed);
			add( _creditsButton );

			FlxG.mouse.show();
			FlxG.flash(0xffff0000,0.5);

			if( !FlxG.music )
			{
				//Play music and flash the screen
				FlxG.playMusic( MenuSound, 1 );
			}
		}


		//Play pressed handler
		private function onPlayPressed():void		
		{
			FlxG.switchState(new TutorialState());
		}

		//Play pressed handler
		private function onCreditsPressed():void		
		{
			FlxG.switchState(new CreditsState());
		}

		//Play pressed handler
		private function onHowToPlayPressed():void		
		{
			FlxG.switchState(new HowToPlayState());
		}


	}
}

