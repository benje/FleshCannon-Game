package com.reynhart.FleshCannon
{
	import org.flixel.*;
	import org.flixel.

	public class PlayState extends FlxState
	{
		[Embed(source="data/gibs.png")] private var ImgGibs:Class;
		[Embed(source="data/trippy-bg.jpg")] private var BgImg:Class;
		[Embed(source="src/data/mapCSV_Group1_Map1.csv", mimeType="application/octet-stream")] public var CSV_Map1:Class;
		[Embed(source="src/data/mapCSV_Group1_Map2.csv", mimeType="application/octet-stream")] public var CSV_Map2:Class;
		[Embed(source="src/data/tiles.png")] public var Img_Map1:Class;
		[Embed(source="src/data/simiolian-tilesheet3.png")] public var Img_Map2:Class;
		[Embed(source="src/data/blood-dot.png")] public var BloodDot:Class;
		[Embed(source="data/sounds/fc-gameplay-track.mp3")] protected var GamePlaySound:Class;


		protected var _player:Player;
		public var _bullets:FlxGroup;
		public var enemyBullets:FlxGroup;
		protected var _level:FlxTilemap;
		protected var _trippyBg:FlxSprite;

		//meta groups, to help speed up collisions
		protected var _objects:FlxGroup;
		protected var _hazards:FlxGroup;
		protected var _littleGibs:FlxEmitter;
		protected var _bloodGibs:FlxEmitter;
		protected var _bloodFollowerGibs:FlxEmitter;
		private var enemyGroup:FlxGroup;
		protected var _particleGroup:FlxGroup;
		protected var _deathTicker:Number = 3;
		protected var _deathFlag:Boolean = false;


		//Create method
		override public function create():void		
		{
			FlxG.bgColor = 0xffcccccc;
			//_trippyBg = new FlxSprite(0, 0, BgImg);
			//_trippyBg.scrollFactor.x = _trippyBg.scrollFactor.y = 0.5;
			//add(_trippyBg);

			_level = new FlxTilemap();
			_level.loadMap( new CSV_Map1, Img_Map1, 16, 16 );
			//_level.loadMap( new CSV_Map2, Img_Map2, 32, 3 );
			add(_level);

			enemyBullets = new FlxGroup();
			enemyGroup = new FlxGroup();
			_particleGroup = new FlxGroup();
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

			//Blood gibs
			_bloodGibs = new FlxEmitter();
			_bloodGibs.setXSpeed(-75,75);
			_bloodGibs.setYSpeed(-120,30);
			_bloodGibs.gravity = 420;
			_bloodGibs.bounce = 0;
			_bloodGibs.particleDrag.x = _bloodGibs.particleDrag.y = 100;
			_bloodGibs.makeParticles( BloodDot,1000,10,false,0.5 );
			add(_bloodGibs);

			//Blood follower gibs
			_bloodFollowerGibs = new FlxEmitter();
			_bloodFollowerGibs.setXSpeed(-50,50);
			_bloodFollowerGibs.setYSpeed(-100,0);
			_bloodFollowerGibs.gravity = 420;
			_bloodFollowerGibs.bounce = 0;
			_bloodFollowerGibs.makeParticles( BloodDot,500,10,false,0.5 );
			add( _bloodFollowerGibs );

			//Now that we have references to the bullets and metal bits,
			//we can create the player object.
			_player = new Player( 100,200,_bullets, _littleGibs, _bloodGibs, _bloodFollowerGibs );

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

			_particleGroup.add( _littleGibs );
			_particleGroup.add( _bloodFollowerGibs );
			_particleGroup.add( _bloodGibs );

			add(enemyGroup);
			enemyGroup.add(new PatrolEnemy(100, 200, FlxObject.LEFT, _level, _player));
			enemyGroup.add(new PatrolEnemy(200, 200, FlxObject.LEFT, _level, _player));
			enemyGroup.add(new PatrolEnemy(300, 200, FlxObject.LEFT, _level, _player));
			enemyGroup.add(new PatrolEnemy(100, 100, FlxObject.LEFT, _level, _player));
			enemyGroup.add(new PatrolEnemy(200, 100, FlxObject.LEFT, _level, _player));
			enemyGroup.add(new PatrolEnemy(300, 100, FlxObject.LEFT, _level, _player));
			add(enemyBullets);

			//Stops all existing sounds
			FlxG.music.stop();

			//Play music and flash the screen
			FlxG.playMusic( GamePlaySound, 0.6 );
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
			FlxG.collide( _level, _particleGroup );
			FlxG.collide( enemyGroup, _level);
			//FlxG.collide( enemyGroup, _player);

			FlxG.overlap( _bullets, enemyGroup, overlapped );
			FlxG.overlap( enemyBullets, _player, overlapped );


			//Check for death
			if(_deathFlag)
			{
				_deathTicker -= FlxG.elapsed;
				if(_deathTicker <= 0)
				{
					FlxG.switchState(new MenuState());
				}
			}

		}


		//This is an overlap callback function, triggered by the calls to FlxU.overlap().
		protected function overlapped(Sprite1:FlxSprite,Sprite2:FlxSprite):void
		{
			//Check players health - if dead change state
			if( _player.health <= 20 )
			{
				_deathFlag = true;
			}

			if((Sprite1 is Bullet))
				Sprite1.kill();
			Sprite2.hurt(20);

		}

		protected function enemyBullOverlap( Sprite1:FlxSprite, Sprite2:FlxSprite ):void
		{

		}


	}
}

