package com.reynhart.FleshCannon
{
	import com.greensock.TweenLite;

	import flash.geom.Point;

	import org.flixel.*;

	public class Player extends FlxSprite
	{
		[Embed(source="data/spaceman.png")] protected var ImgSpaceman:Class;
		[Embed(source="data/newart/runningFrames2.png")] protected var FleshPlayer:Class;

		//Sounds
		[Embed(source="data/sounds/blood-splat1.mp3")] protected var BloodSplat:Class;
		[Embed(source="data/sounds/fc-jump1.mp3")] protected var JumpSound1:Class;
		[Embed(source="data/sounds/impact3.mp3")] protected var ImpactSound1:Class;

		protected var _jumpPower:int;
		protected var _aim:uint;
		protected var _bullets:FlxGroup;
		protected var _restart:Number;
		protected var _shootTimer:Number;
		protected var _gibs:FlxEmitter;
		protected var _bloodGibs:FlxEmitter;
		protected var _bloodGibsFollower:FlxEmitter;
		protected var _clones:Array = new Array();
		protected var _teleporting:Boolean = false;
		protected var _aimDir:Point = new Point();
		protected var _shotHeading:String = "N";
		protected var _fleshBullet:FleshBullet;


		protected var _newArt:Boolean = false;

		public function Player( X:int,Y:int,Bullets:FlxGroup, Gibs:FlxEmitter, BloodGibs:FlxEmitter, BloodFollowerGibs:FlxEmitter )
		{
			super(X,Y);
			_restart = 0;

			//If new art used
			if( _newArt )
			{
				loadGraphic( FleshPlayer, true, true, 41, 30 );
			} else {
				loadGraphic( ImgSpaceman,true,true,8 );
			}

			//basic player physics
			var runSpeed:uint = 80;
			drag.x = runSpeed*8;
			acceleration.y = 420;
			_jumpPower = 200;
			maxVelocity.x = runSpeed;
			maxVelocity.y = _jumpPower;
			health = 100;

			if( _newArt )
			{
				//animations
				addAnimation("idle", [0]);
				addAnimation("run", [1, 2, 3, 4,5,4,3,2,1,6,7,8,9,10,9,8,7,6], 22);
				addAnimation("jump", [4]);
				addAnimation("idle_up", [5]);
				addAnimation("run_up", [6, 7, 8, 5], 12);
				addAnimation("jump_up", [9]);
				addAnimation("jump_down", [10]);
			} 
			else 
			{
				//animations
				addAnimation("idle", [0]);
				addAnimation("run", [1, 2, 3, 0], 12);
				addAnimation("jump", [4]);
				addAnimation("idle_up", [5]);
				addAnimation("run_up", [6, 7, 8, 5], 12);
				addAnimation("jump_up", [9]);
				addAnimation("jump_down", [10]);
			}

			_bullets = Bullets;
			_gibs = Gibs;
			_bloodGibs = BloodGibs;
			_bloodGibsFollower = BloodFollowerGibs;

			FlxG.watch(this, "health");

//			FlxG.watch(_aimDir, "x");
//			FlxG.watch(_aimDir, "y");
		}


		override public function destroy():void
		{
			super.destroy();
			_bullets = null;
			_gibs = null;
		}

		override public function update():void
		{
			//game restart timer
			if(!alive)
			{
				_restart += FlxG.elapsed;
				if(_restart > 2)
					FlxG.resetState();
				return;
			}

			//make a little noise if you just touched the floor
			if(justTouched(FLOOR) && (velocity.y > 50))
			{
				FlxG.play( ImpactSound1 );
			}

			//MOVEMENT
			acceleration.x = 0;

			_aimDir.x = 0;
			_aimDir.y = 0;

			//Player facing direction default
			if (facing == LEFT)
			{
				_shotHeading = "W";
			} 
			else if (facing == RIGHT)
			{
				_shotHeading = "E";
			}

			//Check multiple keys
			if( FlxG.keys.LEFT && FlxG.keys.UP )
			{
				_shotHeading = "NW";
			} 
			else if ( FlxG.keys.LEFT && FlxG.keys.DOWN )
			{
				_shotHeading = "SW";
			}
			else if ( FlxG.keys.RIGHT && FlxG.keys.UP )
			{
				_shotHeading = "NE";
			}
			else if ( FlxG.keys.RIGHT && FlxG.keys.DOWN )
			{
				_shotHeading = "SE"
			}
			else if( FlxG.keys.LEFT )
			{
				facing = LEFT;
				_aimDir.x = -1;
				acceleration.x -= drag.x;
				_shotHeading = "W";
			}
			else if(FlxG.keys.RIGHT)
			{
				facing = RIGHT;
				_aimDir.x = 1;
				acceleration.x += drag.x;
				_shotHeading = "E";
			} 
			else if ( FlxG.keys.UP )
			{
				_aim = UP;
				_aimDir.y = -1;
				_shotHeading = "N";
			}
			else if( FlxG.keys.DOWN)
			{
				_aim = DOWN;
				_aimDir.y = 1;
				_shotHeading = "S";
			}


			if(FlxG.keys.justPressed("X") && !velocity.y || FlxG.keys.justPressed("SPACE") && !velocity.y)
			{
				//Set vertical velocity
				velocity.y = -_jumpPower;

				if ( FlxG.keys.LEFT )
				{
					velocity.x = -_jumpPower;
				}
				else if ( FlxG.keys.RIGHT )
				{
					velocity.x = _jumpPower;
				}

					//FlxG.play(SndJump);
			}

			//ANIMATION
			if(velocity.y != 0)
			{
				if(_aim == UP) play("jump_up");
				else if(_aim == DOWN) play("jump_down");
				else play("jump");
			}
			else if(velocity.x == 0)
			{
				if(_aim == UP) play("idle_up");
				else play("idle");
			}
			else
			{
				if(_aim == UP) play("run_up");
				else play("run");
			}

			//Checking bounds is within world
			if( x > FlxG.width - this.width )
			{
				this.x = FlxG.width - this.width
				this.velocity.x = 0;
			} 
			else if ( x < 0 )
			{
				this.x = 0;
				this.velocity.x = 0;
			}


			//Testing FleshCannon shoot key V
			if(FlxG.keys.justPressed("V"))
			{
				//If not already teleporting then shoot fleshcannon
				if(!_teleporting)
				{
					fleshCannonShoot();
				}
			}

			//SHOOTING
			if(FlxG.keys.justPressed("C"))
			{
				var bullet:Bullet = new Bullet( getMidpoint().x, getMidpoint().y );
				//(FlxG.state as PlayState)._bullets.add( bullet );
				(FlxG.state as PlayState).add( bullet );
				bullet.shoot( getMidpoint(), _shotHeading );
			}

			//Fading out clones from array & removing them.
			var markArray:Array = new Array();
			//Iterate clones array and fade down
			for (var i:Number = 0; i < this._clones.length; i++ )
			{
				_clones[i].alpha -= 0.01;

				if(_clones[i].alpha == 0)
				{
					_clones[i].alpha = 0
					markArray[i] = true;
				}
			}
			//Remove marked objects
			for ( var j:Number = 0; j < markArray.length; j++)
			{
				if(markArray[j])
				{
					_clones.splice( j, 1 );
				}
			}


			//If player "teleporting" then chase the flesh bullet with blood emitter
			if(_teleporting)
			{
				_bloodGibsFollower.x = _fleshBullet.x;
				_bloodGibsFollower.y = _fleshBullet.y;
			}
		}

		//On fleshCannon shoot
		private function fleshCannonShoot():void
		{
			_fleshBullet = new FleshBullet( getMidpoint().x, getMidpoint().y );
			(FlxG.state as PlayState).add( _fleshBullet );
			_fleshBullet.shoot( getMidpoint(), _shotHeading );
			FlxG.camera.follow( _fleshBullet );

			//Set player invisible
			visible = false;
			_teleporting = true;

			//Get blood emitter to follow flesh bullet
			if(_bloodGibsFollower != null)
			{
				_bloodGibsFollower.start(false,5,0.005,250);
			}



			//Listen for bullet to stop in new location
			_fleshBullet.bulletStopped.addOnce( teleportPlayer );

			createEmptyPlayerSkin();
		}

		//Create player skin - fades away when you shoot flesh bullet
		private function createEmptyPlayerSkin():void
		{
			var playerClone:FlxSprite = new FlxSprite();

			//If new art used
			if( _newArt )
			{
				playerClone.loadGraphic( FleshPlayer, true, true, 41, 30 );
			} else {
				playerClone.loadGraphic( ImgSpaceman,true,true,8 );
			}

			(FlxG.state as PlayState).add( playerClone );
			playerClone.x = x;
			playerClone.y = y;
			_clones.push( playerClone );

			if(_bloodGibs != null)
			{
				_bloodGibs.at(this);
				_bloodGibs.start(true,0,0,500);
			}
		}

		//Teleport player makes player appear at bullet destination
		private function teleportPlayer( destX:Number, destY:Number, bulletObject:FleshBullet ):void
		{	
			_teleporting = false;

			//Reset camera
			FlxG.camera.follow( this );

			x = destX;
			y = destY;
			visible = true;
			flicker(0.5);

			//Stop blood emitter
			if(_bloodGibsFollower != null)
			{
				_bloodGibsFollower.on = false;
			}

			//Arrival explosion
			if(_gibs != null)
			{
				_gibs.at(this);
					//_gibs.start(true,5,0,50);
			}
		}



		override public function hurt(Damage:Number):void
		{
			if(flickering)
				return;
			//FlxG.play(SndHurt);
			flicker(1.3);
			if(FlxG.score > 1000) FlxG.score -= 1000;
			if(velocity.x > 0)
				velocity.x = -maxVelocity.x;
			else
				velocity.x = maxVelocity.x;
			super.hurt(Damage);

			if( this.health == 0 )
			{
				kill();
			}
		}	

		override public function kill():void
		{
			if(!alive)
				return;
			super.kill();
			flicker(0);
			exists = true;
			visible = false;
			velocity.make();
			acceleration.make();
			FlxG.camera.shake(0.005,0.35);
			FlxG.camera.flash(0xffd8eba2,0.35);


		}

	}
}

