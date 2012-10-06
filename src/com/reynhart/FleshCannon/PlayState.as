package com.reynhart.FleshCannon {
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;

	import flash.display.Graphics;
	
	public class PlayState extends FlxState
	{
		[Embed(source="../../../../assets/gibs.png")] private var ImgGibs:Class;
		[Embed(source="../../../../assets/trippy-bg.jpg")] private var BgImg:Class;
		
		[Embed(source="../../../../assets/simiolian-tilesheet3.png")] public var Img_Map2:Class;
		[Embed(source="../../../../assets/blood-dot.png")] public var BloodDot:Class;
		[Embed(source="../../../../assets/sounds/fc-gameplay-track.mp3")] protected var GamePlaySound:Class;

		protected var _player:Player;
		public var _bullets:FlxGroup;
//		public var enemyBullets:FlxGroup;
		
		protected var _trippyBg:FlxSprite;

		//meta groups, to help speed up collisions
		protected var _objects:FlxGroup;
		protected var _hazards:FlxGroup;
		protected var _littleGibs:FlxEmitter;
		protected var _bloodGibs:FlxEmitter;
		protected var _bloodFollowerGibs:FlxEmitter;
//		private var enemyGroup:FlxGroup;
		protected var _particleGroup:FlxGroup;
		protected var _deathTicker:Number = 3;
		protected var _deathFlag:Boolean = false;
		
		//Player weapon control
		protected var pistol:FlxWeapon;
		protected var level:Level1;
		
		
		public var explosionRadius:int = 25;
		public var explosionSprite:FlxSprite;


		//Create method
		override public function create():void		
		{
			level = new Level1;
			
			//_trippyBg = new FlxSprite(0, 0, BgImg);
			//_trippyBg.scrollFactor.x = _trippyBg.scrollFactor.y = 0.5;
			//add(_trippyBg);

//			enemyBullets = new FlxGroup();
//			enemyGroup = new FlxGroup();
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
			
			//Add player weapon
			pistol = new FlxWeapon("pistol", _player, "x", "y");
			pistol.makePixelBullet(40, 2, 2, 0xff000000, 5, 6);
			pistol.setBulletSpeed(400);
			
			//	The following are controls for the player, note that the "setFireButton" controls the speed at which bullets are fired, not the Weapon class itself
			
			//	Enable the plugin - you only need do this once (unless you destroy the plugin)
			if (FlxG.getPlugin(FlxControl) == null)
			{
				FlxG.addPlugin(new FlxControl);
			}
			
			FlxControl.create(_player, FlxControlHandler.MOVEMENT_ACCELERATES, FlxControlHandler.STOPPING_DECELERATES, 1, true, false);
			FlxControl.player1.setWASDControl(false, false, true, true);
			FlxControl.player1.setJumpButton("SPACE", FlxControlHandler.KEYMODE_PRESSED, 200, FlxObject.FLOOR, 250, 200);
			
			//	Because we are using the MOVEMENT_ACCELERATES type the first value is the acceleration speed of the sprite
			//	Think of it as the time it takes to reach maximum velocity. A value of 100 means it would take 1 second. A value of 400 means it would take 0.25 of a second.
			FlxControl.player1.setMovementSpeed(400, 0, 100, 200, 400, 0);
			
			//	Set a downward gravity of 400px/sec
			FlxControl.player1.setGravity(0, 400);

			add(pistol.group);

			//Then we add the player and set up the scrolling camera,
			//which will automatically set the boundaries of the world.
			add(level);
			add(_player);
			add(level.barrels);
			
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

//			add(enemyGroup);
//			enemyGroup.add(new PatrolEnemy(100, 200, FlxObject.LEFT, _level, _player));
//			enemyGroup.add(new PatrolEnemy(200, 200, FlxObject.LEFT, _level, _player));
//			enemyGroup.add(new PatrolEnemy(300, 200, FlxObject.LEFT, _level, _player));
//			enemyGroup.add(new PatrolEnemy(100, 100, FlxObject.LEFT, _level, _player));
//			enemyGroup.add(new PatrolEnemy(200, 100, FlxObject.LEFT, _level, _player));
//			enemyGroup.add(new PatrolEnemy(300, 100, FlxObject.LEFT, _level, _player));
//			add(enemyBullets);

			//Stops all existing sounds
			FlxG.music.stop();

			//Play music and flash the screen
			FlxG.playMusic( GamePlaySound, 0.6 );
			
			//Create explodeSprite
			explosionSprite = new FlxSprite();
			drawCircle(explosionSprite, new FlxPoint(100, 200),explosionRadius, 0xff33ff33, 1, 0x4433ff33);
			
			add(explosionSprite);
			
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
			
			//If mouse clicked - fire bullet
			if (FlxG.mouse.justPressed())
			{
				pistol.fireAtMouse();
			}

			//Run collision
			FlxG.collide( _player, level );
			FlxG.collide( level, _particleGroup ); //Floating blood gibs
			FlxG.overlap( pistol.group, level.barrels, hitBarrel);
			
			
//			FlxG.collide( enemyGroup, _level);
			//FlxG.collide( enemyGroup, _player);

//			FlxG.overlap( _bullets, enemyGroup, overlapped );
//			FlxG.overlap( enemyBullets, _player, overlapped );


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
	
		//Overlap function to explode barrel when shot with player bullet
		private function hitBarrel(pBullet:FlxObject, barrel:FlxObject):void
		{
			//trace(barrel);
			if(barrel is Barrel)
			{
				(barrel as Barrel).hitBarrel();
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
		
		
		
		
		
		/**
		 * Draw a circle to a sprite.
		 *
		 * @param   Sprite          The FlxSprite to draw to
		 * @param   Center          x,y coordinates of the circle's center
		 * @param   Radius          Radius in pixels
		 * @param   LineColor       Outline color
		 * @param   LineThickness   Outline thickness
		 * @param   FillColor       Fill color
		 */
		public function drawCircle(Sprite:FlxSprite, Center:FlxPoint, Radius:Number = 30, LineColor:uint = 0xffffffff, LineThickness:uint = 1, FillColor:uint = 0xffffffff):void {
		 
		    var gfx:Graphics = FlxG.flashGfx;
		    gfx.clear();
		 
		    // Line alpha
		    var alphaComponent:Number = Number((LineColor >> 24) & 0xFF) / 255;
		    if(alphaComponent <= 0)
		        alphaComponent = 1;
		 
		    gfx.lineStyle(LineThickness, LineColor, alphaComponent);
		 
		    // Fill alpha
		    alphaComponent = Number((FillColor >> 24) & 0xFF) / 255;
		    if(alphaComponent <= 0)
		        alphaComponent = 1;
		 
		    gfx.beginFill(FillColor & 0x00ffffff, alphaComponent);
		 
		    gfx.drawCircle(Center.x, Center.y, Radius);
		 
		    gfx.endFill();
		 
		    Sprite.pixels.draw(FlxG.flashGfxSprite);
		    Sprite.dirty = true;
		}


	}
}

