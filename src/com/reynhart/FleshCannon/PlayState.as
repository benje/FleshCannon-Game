package com.reynhart.FleshCannon {
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;
	
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
		
		public var playerImpulseVel:int = 0;
		
		//Mouse-aim sprite
		private var mouseAimLine:FlxSprite;


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
			_player = new Player( 100,100,_bullets, _littleGibs, _bloodGibs, _bloodFollowerGibs );
			
			//Add player weapon
			pistol = new FlxWeapon("pistol", _player, "x", "y");
			pistol.makePixelBullet(40, 2, 2, 0xff000000, 5, 6);
			pistol.setBulletBounds( new FlxRect( 0, 0, level.width, level.height) );
			pistol.setBulletLifeSpan(1000);
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
			add(level.explosionHitBoxes);
			
			//	Don't let the camera wander off the edges of the map
			FlxG.camera.setBounds(0, 0, level.width, level.height);
			FlxG.camera.follow(_player, FlxCamera.STYLE_PLATFORMER);
			
			//	Tell flixel how big our game world is
			FlxG.worldBounds = new FlxRect(0, 0, level.width, level.height);

			//We add the bullets to the scene here,
			//so they're drawn on top of pretty much everything
			add(_bullets);
			
			//Create the Mouse aim line
//			mouseAimLine = new FlxSprite();
//			mouseAimLine.solid = false;
//			add( mouseAimLine );

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
			
			//Add Debug UI Buttons
			var resetBarrelsBtn:FlxButton = new FlxButton(10, 10, "Reset barrels", resetBarrels);
			resetBarrelsBtn.scrollFactor = new FlxPoint(0, 0);
			add(resetBarrelsBtn);
			
			FlxG.watch(this, "playerImpulseVel");
		}
		
		//Button callbacks
		private function resetBarrels():void
		{
			trace("test");
			
			level.barrels.callAll("resetBarrelState");
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
			
			//Re-draw aim line function
			drawMouseAimLine( _player );
			
			//If mouse clicked - fire bullet
			if (FlxG.mouse.justPressed())
			{
				pistol.fireAtMouse();
			}

			//Run collision
			FlxG.collide( _player, level );
			FlxG.collide( level, _particleGroup ); //Floating blood gibs
			FlxG.overlap( pistol.group, level.barrels, hitBarrel);
			FlxG.overlap( _player, level.explosionHitBoxes, touchingBarrel );
			
			
//			FlxG.collide( enemyGroup, _level);
//			FlxG.collide( enemyGroup, _player);
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
				
				//kill bullet
				pBullet.kill();
			}
			
		}
		
		//If player touching barrel then apply impulse to player
		private function touchingBarrel(_Player:FlxObject, _ExplosionSprite:FlxObject):void
		{
			//If player touching explosionHitBox then apply impulse to player
			if(_Player is Player)
			{
				//Prevent player from colliding again
				_ExplosionSprite.solid = false;
				
				//Apply player impulse
				applyPlayerImpulse((_Player as Player), (_ExplosionSprite as ExplosionHitBox), 500);
			}
		}
		
		//Apply angular inpulse on player from explosion centre
		private function applyPlayerImpulse(_Player:Player, _ExplosionHitBox:ExplosionHitBox, _impulseAmount:Number):void
		{
			//_Player.velocity.y = -750;
//			var explosionOrigin:FlxPoint = new FlxPoint( (_ExplosionHitBox.x + (_ExplosionHitBox.width/2)), (_ExplosionHitBox.y + (_ExplosionHitBox.height/2)) );
//			var playerHitBoxAngleOrigin:Number = FlxVelocity.angleBetweenPoint(_Player, explosionOrigin);
//			//var playerHitBoxAngle:Number = FlxVelocity.angleBetween(_Player, _ExplosionHitBox);
//			var playerImpulseVel:FlxPoint = FlxVelocity.velocityFromAngle(playerHitBoxAngleOrigin, _impulseAmount);
			
			playerImpulseVel = FlxVelocity.distanceToPoint(_Player, new FlxPoint( (_ExplosionHitBox.x + (_ExplosionHitBox.width/2)), (_ExplosionHitBox.y + (_ExplosionHitBox.height/2)) ));
			//var scaledImpulse:Number = scaleRange(Number(playerImpulseVel), 0, 100, 5, 1);
			
			//_player.velocity.x = playerImpulseVel * 5;
			_player.acceleration.y = 200;
			_player.velocity.y = -(playerImpulseVel * _impulseAmount);
			
		}
		
		
		//Re-draw mouse-aim line
		private function drawMouseAimLine( _Player:Player ):void
		{
			//If line already exists then remove it
			if( mouseAimLine != null )
			{
				mouseAimLine.fill(0x00000000);
				remove(mouseAimLine);
			}
			
			//Create new graphic and draw line from _Player's centre to mouse position
			mouseAimLine = new FlxSprite(0, 0).makeGraphic(level.width, level.height, 0x0);
			mouseAimLine.drawLine( (_Player.x + (_Player.width/2)), (_Player.y + (_Player.height/2)), FlxG.mouse.x, FlxG.mouse.y, 0xffffffff, 1 );
			mouseAimLine.solid = false; //Not collidable!
			add(mouseAimLine);
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
		 * Scale a value to a new range from an old range
		 * @param currentValue
		 * @param oldScaleMin
		 * @param oldScaleMax
		 * @param newScaleMin
		 * @param newScaleMax
		 * @return 
		 * 
		 */		
		private function scaleRange(currentValue:Number, oldScaleMin:Number, oldScaleMax:Number, newScaleMin:Number, newScaleMax:Number):Number
		{
			var oldRange:Number = oldScaleMax - oldScaleMin;
			var newValue:Number = ((currentValue/oldRange)*(newScaleMax - newScaleMin));
			
			return newValue;
		}


	}
}

