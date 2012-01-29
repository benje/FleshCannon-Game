package com.reynhart.FleshCannon
{
	import org.flixel.*;

	public class PlayState extends FlxState
	{
		[Embed(source="data/gibs.png")] private var ImgGibs:Class;
		[Embed(source="data/trippy-bg.jpg")] private var BgImg:Class;
		[Embed(source="src/data/mapCSV_Group1_Map1.csv", mimeType="application/octet-stream")] public var CSV_Map1:Class;
		[Embed(source="src/data/tiles.png")] public var Img_Map1:Class;

		protected var _player:Player;
		public var _bullets:FlxGroup;
		protected var _level:FlxTilemap;
		protected var _trippyBg:FlxSprite;

		//meta groups, to help speed up collisions
		protected var _objects:FlxGroup;
		protected var _hazards:FlxGroup;
		protected var _littleGibs:FlxEmitter;

		//Create method
		override public function create():void		
		{
			FlxG.bgColor = 0xffcccccc;
			//_trippyBg = new FlxSprite(0, 0, BgImg);
			//_trippyBg.scrollFactor.x = _trippyBg.scrollFactor.y = 0.5;
			//add(_trippyBg);

			_level = new FlxTilemap();
			_level.loadMap( new CSV_Map1, Img_Map1, 16, 16 );
			add(_level);

			_bullets = new FlxGroup();

			//Here we are creating a pool of 100 little metal bits that can be exploded.
			//We will recycle the crap out of these!
			_littleGibs = new FlxEmitter();
			_littleGibs.setXSpeed(-150,150);
			_littleGibs.setYSpeed(-200,0);
			_littleGibs.setRotation(-720,-720);
			_littleGibs.gravity = 350;
			_littleGibs.bounce = 0.5;
			_littleGibs.makeParticles(ImgGibs,10,10,true,0.5);
			add(_littleGibs);

			//Now that we have references to the bullets and metal bits,
			//we can create the player object.
			_player = new Player( 100,200,_bullets, _littleGibs );

			//Then we add the player and set up the scrolling camera,
			//which will automatically set the boundaries of the world.
			add(_player);
			FlxG.camera.setBounds(0,0,640,640,true);
			FlxG.camera.follow(_player,FlxCamera.STYLE_PLATFORMER);

			//We add the bullets to the scene here,
			//so they're drawn on top of pretty much everything
			add(_bullets);

			//Finally we are going to sort things into a couple of helper groups.
			//We don't add these groups to the state, we just use them for collisions later!
			_objects = new FlxGroup();
			_objects.add(_bullets);
			_objects.add(_player);
		}


		override public function destroy():void
		{
			super.destroy();
			_bullets = null;
			_player = null;

			//meta groups, to help speed up collisions
			_objects = null;
			_hazards = null;
		}


		//Update function
		override public function update():void
		{
			super.update();

			//Run collision
			FlxG.collide( _level, _player );
			FlxG.overlap(_bullets, _level, overlapped);
		}


		//This is an overlap callback function, triggered by the calls to FlxU.overlap().
		protected function overlapped(Sprite1:FlxSprite,Sprite2:FlxSprite):void
		{
			if((Sprite1 is Bullet))
				Sprite1.kill();
			//Sprite2.hurt(1);
		}

	}
}

